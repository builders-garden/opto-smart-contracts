// SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;

import "./IOpto.sol";
import "./OptoLibrary.sol";
import "./OptoUtils.sol";

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

    // Storage variables
    address public usdcAddress;
    uint256 public lastOptionId;
    bool public isInitialized;
    bytes32 public s_lastRequestId;
    bytes32 public donID;
    uint64 public subscriptionId;
    uint32 public gasLimit;
    uint256[] public activeOptions;


    constructor(address _owner, address _router) ERC1155("") FunctionsClient(_router) ConfirmedOwner(_owner) { // TODO: add 1155 constructor data URI link
    }

    function init(address _usdcAddress, uint32 _gasLimit, bytes32 _donID, uint64 _subscriptionId) onlyOwner external {
        require(!isInitialized, "LighterFi: already initialized");
        usdcAddress = _usdcAddress;
        gasLimit = _gasLimit;
        donID = _donID;
        subscriptionId = _subscriptionId;
        isInitialized = true;
        queryTypes[OptionType.RPC_CALL_QUERY] = 1;
        queryTypes[OptionType.SUBGRAPH_QUERY_1] = 2;
        queryTypes[OptionType.SUBGRAPH_QUERY_2] = 3;
    }


    function createOption(
        address premiumReceiver,
        bool isCallOption,
        uint256 premium,
        uint256 strikePrice, 
        uint256 expirationDate,
        OptionType optionType,
        uint256 optionQueryId,
        uint256 assetAddressId,
        uint256 assetId,
        uint256 units,
        uint256 capPerUnit
    ) public {
        // Validate parameters
        // TODO: Validate parameters

        // Increment option id
        uint256 newOptionId = lastOptionId++;
        // Calculate total collateral from the writer
        uint256 collateral = capPerUnit * units;
        // Transfer collateral from the writer to the contract
        require(IERC20(usdcAddress).transferFrom(msg.sender, address(this), collateral), "Transfer failed");
        // Create option    
        options[newOptionId] = Option(
            msg.sender,
            premiumReceiver,
            setIsCall(bytes1(0x00), isCallOption),
            premium,
            strikePrice,
            expirationDate,
            optionType,
            optionQueryId,
            assetAddressId,
            units,
            capPerUnit,
            units,
            0
          
        );
        // Update last option id
        lastOptionId = newOptionId;
    }

    function buyOption(uint256 id, uint256 units) public {
        // Get option from storage
        Option storage option = options[id];
        // Check if option is paused
        require(!isPaused(option.statuses), "Option is paused");
        // Check if option is not expired
        require(block.timestamp < option.expirationDate, "Option is expired");
        // Check if there are enough units left
        require(option.unitsLeft >= units, "Not enough units left");
        // Calculate total price
        uint256 totalPrice = option.premium * units;
        // Transfer premium from the buyer to the writer
        require(IERC20(usdcAddress).transferFrom(msg.sender, option.premiumReceiver, totalPrice), "Transfer failed");
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
    }

    function claimOption(uint256 id, uint256 units) public {
        // Get option from storage
        Option storage option = options[id];
        // Check if option is paused
        require(!isPaused(option.statuses), "Option is paused");
        // Check if option is expired
        require(block.timestamp >= option.expirationDate, "Option is expired");
        // Check if option is deactived
        require(!isActive(option.statuses), "Option is not active");
        // Check if option is 
        require(hasToPay(option.statuses), "Option does not have to pay");
        // Check if the buyer has enough units
        require(balanceOf(msg.sender, id) >= units, "Not enough units");
        // Burn option NFT from the buyer
        _burn(msg.sender, id, units);
        // Calculate total collateral
        uint256 price = option.optionPrice * units;
        // Transfer collateral from the contract to the buyer
        require(IERC20(usdcAddress).transfer(msg.sender, price), "Transfer failed");
    }

    function checkUpkeep(bytes calldata) external view override returns (bool upkeepNeeded, bytes memory performData) {
    }
    function performUpkeep(bytes calldata  performData) external override {
        (, uint optionId) = abi.decode(performData, (uint, uint));
        // check optionId
        require(optionId != 0, "Invalid optionId");
        // Get option from storage
        Option memory option = options[optionId];
        // Check if option is paused
        require(!isPaused(option.statuses), "Option is paused");
        // Check if option is expired
        require(block.timestamp >= option.expirationDate, "Option is expired");
        // Check if option is deactived
        require(isActive(option.statuses), "Option is not active");
        // Check if option is not already claimed
        require(!hasToPay(option.statuses), "Option already settled");
        // Send request to Chainlink
        bytes32 requestId = _invokeSendRequest(optionId, option.optionType, option.optionQueryId, option.assetAddressId);

        // Store requestId for optionId
        requestIds[requestId] = optionId;
    }

    function _invokeSendRequest(uint256 optionId, OptionType optionType,  uint256 optionQueryId, uint256 queryAddress) internal returns (bytes32) {
        // Get query id
        uint256 queryId = queryTypes[optionType];
        string memory optionIdString = Strings.toString(optionId);
        // Get query and params from opto Library
        (string memory source, string[] memory args) = OptoLib.getQueryAndParams(optionIdString, queryId, optionQueryId, queryAddress);
        // Create request
        FunctionsRequest.Request memory req;
        // Initialize the request with JS code
        req.initializeRequestForInlineJavaScript(source); 
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
        if (s_lastRequestId != requestId) {
            revert UnexpectedRequestID(requestId);
        }
        uint256 price;
        // get optionId from requestId
        uint256 optionId = requestIds[requestId];
        // get price from response
        uint256 priceResult = abi.decode(response, (uint256));
        // get price max from option
        uint256 priceMax = options[optionId].capPerUnit;
        // check if price is less than price max
        priceMax >= priceResult ? price = priceResult : price = priceMax;
        // check if price is less than strike price
        bytes1 statuses = options[optionId].statuses;
        if (price < options[optionId].strikePrice) {
            options[optionId].statuses = setIsActive(statuses, false);
            options[optionId].statuses = setHasToPay(statuses, false);
        }
        // calculate price to pay to buyers
        uint256 priceToPayPerUnit = price - options[optionId].strikePrice; 
        // set option result
        options[optionId].statuses = setIsActive(statuses, false);
        options[optionId].statuses = setHasToPay(statuses, true);
        options[optionId].optionPrice = priceToPayPerUnit;
        // emit event
        emit Response(requestId, response, err);
    }
}
