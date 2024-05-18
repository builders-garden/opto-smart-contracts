// SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;

import "./IOpto.sol";
import "./OptoLibrary.sol";
import "./OptoUtils.sol";
import "hardhat/console.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import {FunctionsClient} from "@chainlink/contracts/src/v0.8/functions/v1_0_0/FunctionsClient.sol";
import {AutomationCompatibleInterface} from "@chainlink/contracts/src/v0.8/automation/AutomationCompatible.sol";
import {ConfirmedOwner} from "@chainlink/contracts/src/v0.8/shared/access/ConfirmedOwner.sol";
import {FunctionsRequest} from "@chainlink/contracts/src/v0.8/functions/v1_0_0/libraries/FunctionsRequest.sol";

contract Opto is IOpto, ERC1155, FunctionsClient, AutomationCompatibleInterface, ConfirmedOwner, OptoUtils{ 
    using FunctionsRequest for FunctionsRequest.Request;
    mapping(uint256 => Option) public options;
    mapping(bytes32 => uint256) public requestIds;
    mapping(OptionType => uint256) public queryTypes;
    mapping(uint256 => string) public customOptionQueries;
    mapping(uint256 => string[]) public customOptionArgs;
    mapping(uint => bool) public exhaustedArrays;
    // Storage variables
    address public usdcAddress;
    uint256 public lastOptionId;
    bool public isInitialized;
    bytes32 public s_lastRequestId;
    bytes32 public donID;
    uint64 public subscriptionId;
    uint32 public gasLimit;
    uint256[] public activeOptions;

    constructor(
        address _owner,
        address _router
    ) ERC1155("") FunctionsClient(_router) ConfirmedOwner(_owner) {
    }

     function init(
        address _usdcAddress,
        uint32 _gasLimit,
        bytes32 _donID,
        uint64 _subscriptionId
    ) external onlyOwner {
        require(!isInitialized, "Err19");
        usdcAddress = _usdcAddress;
        gasLimit = _gasLimit;
        donID = _donID;
        subscriptionId = _subscriptionId;
        isInitialized = true;
        queryTypes[OptionType.RPC_CALL_QUERY] = 0;
        queryTypes[OptionType.SUBGRAPH_QUERY_1] = 1;
        queryTypes[OptionType.SUBGRAPH_QUERY_2] = 2;
        queryTypes[OptionType.CUSTOM_QUERY] = 3;
    }

    function createOption(
        bool isCallOption,
        uint256 premium,
        uint256 strikePrice,
        uint256 buyDeadline,
        uint256 expirationDate,
        OptionType optionType,
        uint256 optionQueryId,
        uint256 assetAddressId,
        uint256 units,
        uint256 capPerUnit
    ) public {
        // Validate parameters
        require(premium > 0 && premium <= capPerUnit, "Err1");
        require(strikePrice > 0, "Err2");
        require(
            buyDeadline > block.timestamp,
            "Err3"
        );
        require(
            expirationDate > buyDeadline,
            "Err4"
        );
        require(units > 0, "Err5");
        require(capPerUnit > 0, "Err6");
        // Calculate total collateral from the writer
        uint256 collateral = capPerUnit * units;
        // Transfer collateral from the writer to the contract
        require(
            IERC20(usdcAddress).transferFrom(
                msg.sender,
                address(this),
                collateral
            ),
            "Err7"
        );
        // Update lastOptionInd
        lastOptionId += 1;
        // Create option
        options[lastOptionId] = Option(
            msg.sender,
            setIsCall(bytes1(0x00), isCallOption),
            optionType,
            buyDeadline,
            premium,
            strikePrice,
            expirationDate,
            optionQueryId,
            assetAddressId,
            units,
            capPerUnit,
            units,
            0
        );
        emit OptionCreated(lastOptionId, msg.sender, isCallOption, premium, strikePrice, expirationDate, buyDeadline, optionType, optionQueryId, assetAddressId, units, capPerUnit);
    }

    function createCustomOption(
        bool isCallOption,
        uint256 premium,
        uint256 strikePrice, 
        uint256 buyDeadline,
        uint256 expirationDate,
        uint256 units,
        uint256 capPerUnit,
        string memory query,
        string[] memory args,
        string memory name,
        string memory desc
    ) public {
        // Validate parameters
        require(premium > 0 && premium <= capPerUnit, "Err1");
        require(strikePrice > 0, "Err2");
        require(buyDeadline > block.timestamp, "Err3");
        require(expirationDate > buyDeadline, "Err4");
        require(units > 0, "Err5");
        require(capPerUnit > 0, "Err6");
        // Calculate total collateral from the writer
        uint256 collateral = capPerUnit * units;
        // Transfer collateral from the writer to the contract
        require(IERC20(usdcAddress).transferFrom(msg.sender, address(this), collateral), "Err7");
        // Update lastOptionInd
        lastOptionId += 1;
        // Create option    
        options[lastOptionId] = Option(
            msg.sender,
            setIsCall(bytes1(0x00), isCallOption),
            OptionType.CUSTOM_QUERY,
            buyDeadline,
            premium,
            strikePrice,
            expirationDate,
            99, // dummy value
            99, // dummy value
            units,
            capPerUnit,
            units,
            0
        );
        // Store custom query
        emit CustomOptionCreated(lastOptionId, msg.sender, isCallOption, premium, strikePrice, expirationDate, buyDeadline, units, capPerUnit, name, desc);
        customOptionQueries[lastOptionId] = query;
        customOptionArgs[lastOptionId] = args;
    }


    function buyOption(uint256 id, uint256 units) public {
        // Get option from storage
        Option storage option = options[id];
        // Check if option exists
        require(option.writer != address(0), "Err8");
        // Check if option is paused
        require(!isPaused(option.statuses), "Err9");
        // Check if option is not expired
        require(
            block.timestamp < option.buyDeadline,
            "Err10"
        );
        // Check if there are enough units left
        require(option.unitsLeft >= units, "Err11");
        // Calculate total price
        uint256 totalPrice = option.premium * units;
        // Transfer premium from the buyer to the writer
        require(
            IERC20(usdcAddress).transferFrom(
                msg.sender,
                option.writer,
                totalPrice
            ),
            "Err7"
        );
        // If this is the first time the option is bought, make the option active
        if (option.unitsLeft == option.units && !isActive(option.statuses)) {
            option.statuses = setIsActive(option.statuses, true);
            // Add option to active options for upkeep automation
            activeOptions.push(id);
        }
        // Update units left
        option.unitsLeft -= units;
        // Mint option NFT to the buyer
        _mint(msg.sender, id, units, "");

        emit OptionBought(id, msg.sender, units, totalPrice);
    }

    function claimOption(uint256 id) public {
        // Get option from storage
        Option storage option = options[id];
        // get units owned
        uint units = balanceOf(msg.sender, id);
        // Check if option is paused
        require(!isPaused(option.statuses), "Err9");
        // Check if option is expired
        require(block.timestamp >= option.expirationDate, "Err13");
        // Check if option is deactived
        require(!isActive(option.statuses), "Err12");
        // Check if option is 
        require(hasToPay(option.statuses), "Err14");
        // Check if the buyer has enough units
        require(balanceOf(msg.sender, id) >= units, "Err11");
        // Burn option NFT from the buyer
        _burn(msg.sender, id, units);
        // Calculate total collateral
        uint256 price = option.optionPrice * units;
        // Transfer collateral from the contract to the buyer
        require(IERC20(usdcAddress).transfer(msg.sender, price), "Err7");

        emit OptionClaimed(id, msg.sender, units, price);
    }

    function claimForPausedOption(uint256 id, uint256 units, bool isWriter) public returns(uint256) {
        // Get option from storage
        Option storage option = options[id];
        // Check if options has to pay
        require(hasToPay(option.statuses), "Err14");
        // Check if option is paused
        require(isPaused(option.statuses), "Err14");
        // define price var
        uint256 price;
        // Check if for writer
        if (isWriter) {
            // Check if the caller is the writer
            require(msg.sender == option.writer, "Err19");
            // Calculate total collateral
            price = (option.capPerUnit - option.premium) * units;
            // check price is greater than 0
            require(price > 0, "Err20");
            // Transfer collateral from the contract to the writer
            require(IERC20(usdcAddress).transfer(msg.sender, price), "Err7");
        } else {
        // Check if the buyer has enough units
        require(balanceOf(msg.sender, id) >= units, "Err11");
        // Burn option NFT from the buyer
        _burn(msg.sender, id, units);
        // Calculate total collateral
        price = option.premium * units;
        // Transfer collateral from the contract to the buyer
        require(IERC20(usdcAddress).transfer(msg.sender, price), "Err7");
        // Increment units left
        option.unitsLeft += units;
        }
        emit erroredClaimed(id, msg.sender, price);
        return price;
    }

    function deleteOption(uint256 id) public {
        // Get option from storage
        Option storage option = options[id];
        // Check if option is deactived
        require(!isActive(option.statuses), "Err17");
        // Check if option is not already claimed
        require(!hasToPay(option.statuses), "Err16");
        // Transfer collateral from the contract to the writer
        require(
            IERC20(usdcAddress).transfer(
                option.writer,
                option.units * option.capPerUnit
            ),
            "Err7"
        );
        // Delete option
        delete options[id];
        emit OptionDeleted(id);
    }

    function setExhausted(uint index) internal {
        exhaustedArrays[index] = true;
    }

    function checkUpkeep(
        bytes calldata checkdata
    ) external view returns (bool upkeepNeeded, bytes memory performData) {
        // all ever activated options length
        uint arrayLength = activeOptions.length;
        uint maxSubarrayLength = 200;
        // calculate subarray num
        uint numSubarrays = (arrayLength + maxSubarrayLength - 1) / maxSubarrayLength;
        // index of current sub array. Ticks at rate of 2 seconds window per subarray
        uint subarrayIndex = uint(block.timestamp / 2) % numSubarrays;
        uint startingIndex = subarrayIndex * maxSubarrayLength;
        uint endIndex = startingIndex + maxSubarrayLength;
        // if the current subarray is already depleted
        if (exhaustedArrays[subarrayIndex]) {
            // cycle in next subarrays and check if they are exhausted
            for (uint i = subarrayIndex; i < numSubarrays; ++i) {
                if (!exhaustedArrays[i]) {
                    startingIndex = startingIndex + (i * maxSubarrayLength);
                    endIndex = endIndex + (i * maxSubarrayLength);
                }
                // end of subarray met, return false
                if (i == numSubarrays - 1) {
                    return (false, abi.encode(0, 0));
                }
            }
        }
        // prevent out of bounds
        if (endIndex > arrayLength) {
            endIndex = arrayLength;
        }
        Option memory option;
        // check expired element in active options
        uint j;
        for (uint i = startingIndex; i < endIndex; ++i) {
            j++;
            option = options[activeOptions[i]];
            if (
                option.expirationDate < block.timestamp &&
                isActive(option.statuses)
            ) {
                return (
                    upkeepNeeded = true,
                    // id 1 is for match found
                    performData = abi.encode(1, activeOptions[i])
                );
            }
            if (i == endIndex && j == maxSubarrayLength) {
                return (
                    upkeepNeeded = true,
                    // id 2 is for exhausted subarrays
                    performData = abi.encode(2, subarrayIndex)
                );
            }
        }
    }
    function performUpkeep(bytes calldata performData) external override {
        (uint op, uint optionId) = abi.decode(performData, (uint, uint));
        if (op == 1){
            // check optionId
            require(optionId != 0, "Err18");
            // Get option from storage
            Option storage option = options[optionId];
            // Check if option is paused
            require(!isPaused(option.statuses), "Err9");
            // Check if option is expired
            require(
                block.timestamp >= option.expirationDate,
                "Err8"
            );
            // Check if option is deactived
            require(isActive(option.statuses), "Err12");
            // Check if option is not already claimed
            require(!hasToPay(option.statuses), "Err16");
            // Send request to Chainlink
            
            bytes32 requestId = _invokeSendRequest(
                option.optionType,
                option.optionQueryId,
                option.assetAddressId
            );
            // Store requestId for optionId
            requestIds[requestId] = optionId;
            option.statuses = setIsActive(option.statuses, false);
        }
        if (op == 2){
            setExhausted(optionId);
        }
        
    }

    function _invokeSendRequest(
        OptionType optionType,
        uint256 optionQueryId,
        uint256 queryAddress
    ) internal returns (bytes32) {
        // Get query id
        uint256 queryId = queryTypes[optionType];
        string memory query;
        string[] memory args;
        // Check if it's a custom query
        if (queryId == 3) {
            // Custom query
             query = customOptionQueries[optionQueryId];
             args = customOptionArgs[optionQueryId];
         
        } else {
            // Get query and params from opto Library
            (query, args) = OptoLib.getQueryAndParams(queryId, optionQueryId, queryAddress);
        }
        
        // Create request
        FunctionsRequest.Request memory req;
        // Initialize the request with JS code
        req.initializeRequestForInlineJavaScript(query);
        // Set the arguments for the request
        req.setArgs(args);
        // Send the request and store the request ID
        bytes32 requestId = _sendRequest(
            req.encodeCBOR(),
            subscriptionId,
            gasLimit,
            donID
        );
        return requestId;
    }



    function fulfillRequest(
        bytes32 requestId,
        bytes memory response,
        bytes memory err
    ) internal override {
        // Get optionId from requestId
        uint id = requestIds[requestId];
        Option memory option = options[id];
        // Handle error response
     
        bool hasToPay;
        // get price from response
        uint256 result = abi.decode(response, (uint256));
  
        // check if the option is a call option
        bool isCallOption = isCall(option.statuses);
        
        // put and call cases
        if (isCallOption) {
            // check if the price is less than the strike price
            if (result <= option.strikePrice) {
                // set option result
                uint refundableAmount = option.units * option.capPerUnit;
                  IERC20(usdcAddress).transfer(
                    option.writer,
                    refundableAmount
                );
                
            } else {
                // set option result
                hasToPay = true;
                option.statuses = setHasToPay(option.statuses, hasToPay);
                uint pricePerUnit = result - option.strikePrice;
                if (pricePerUnit > option.capPerUnit){
                    pricePerUnit = option.capPerUnit;
                }
                option.optionPrice = pricePerUnit;
                uint refundableAmount = option.unitsLeft * option.capPerUnit;
                if (refundableAmount > 0){
                    IERC20(usdcAddress).transfer(
                    option.writer,
                    refundableAmount
                );
                }
            }
        } else {
            // check if the price is greater than the strike price
            if (result > option.strikePrice) {
                // set option result
                uint refundableAmount = option.units * option.capPerUnit;
                IERC20(usdcAddress).transfer(
                    option.writer,
                    refundableAmount
                );
            } else {
                // set option result
                hasToPay = true;
                option.statuses = setHasToPay(option.statuses, hasToPay);
      
                uint pricePerUnit =  option.strikePrice - result;
                if (pricePerUnit > option.capPerUnit){
                    pricePerUnit = option.capPerUnit;
                }
                option.optionPrice = pricePerUnit;
                uint refundableAmount = option.unitsLeft * option.capPerUnit;
                if (refundableAmount > 0){
                    IERC20(usdcAddress).transfer(
                        option.writer,
                        refundableAmount
                );
                }
            }
        }
        // update option in storage
        options[id] = option;
        // emit event
        emit Response(id, hasToPay, requestId, response, err);
          
    }
    
}
// Error codes:
// err1: invalid premium
// err2: invalid strike price
// err3: invalid buy deadline
// err4: invalid expiration date
// err5: invalid units
// err6: invalid cap per unit
// err7: transfer failed
// err8: option not exist
// err9: option paused
// err10: can't buy option
// err11: not enough units
// err12: option not active
// err13: option expired
// err14: option not to pay
// err15: option not paused
// err16: option not settled
// err17: option activated
// err18: invalid option id
// Err19: unhauthorized
// Err20: no price
