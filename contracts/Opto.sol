// SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;

import "./IOpto.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import {FunctionsClient} from "@chainlink/contracts/src/v0.8/functions/v1_0_0/FunctionsClient.sol";
import {AutomationCompatibleInterface} from "@chainlink/contracts/src/v0.8/automation/AutomationCompatible.sol";
import {ConfirmedOwner} from "@chainlink/contracts/src/v0.8/shared/access/ConfirmedOwner.sol";
import {FunctionsRequest} from "@chainlink/contracts/src/v0.8/functions/v1_0_0/libraries/FunctionsRequest.sol";

contract Opto is IOpto, ERC1155, FunctionsClient, AutomationCompatibleInterface, ConfirmedOwner {

    mapping(uint256 => Option) public options;
    mapping(uint256 => string[]) public queries; //change it, use library. add a custom query storage
    
    address public usdcAddress;
    uint256 public lastOptionId;
    bool public isInitialized;

    constructor(address _owner, address _router) ERC1155() FunctionsClient(_router) ConfirmedOwner(_owner) { // TODO: add 1155 constructor data URI link
    }

    function init(address _usdcAddress, uint32 _gasLimit, bytes32 _donID, uint64 _subscriptionId) onlyOwner external {
        require(!isInitialized, "LighterFi: already initialized");
        usdcAddress = _usdcAddress;
        gasLimit = _gasLimit;
        donID = _donID;
        subscriptionId = _subscriptionId;
        isInitialized = true;
    }


    function createOption(
        address premiumReceiver,
        bool isCall,
        uint256 premium,
        uint256 strikePrice,
        uint256 expirationDate,
        OptionType optionType,
        uint256 optionQueryId,
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
            isCall,
            premium,
            strikePrice,
            expirationDate,
            optionType,
            optionQueryId,
            units,
            capPerUnit,
            units,
            0,
            false,
            false,
            false
        );
        // Update last option id
        lastOptionId = newOptionId;
    }

    function buyOption(uint256 id, uint256 units) public {
        // Get option from storage
        Option storage option = options[id];
        // Check if option is paused
        require(!option.isPaused, "Option is paused");
        // Check if option is not expired
        require(block.timestamp < option.expirationDate, "Option is expired");
        // Check if there are enough units left
        require(option.unitsLeft >= units, "Not enough units left");
        // Calculate total price
        uint256 totalPrice = option.premium * units;
        // Transfer premium from the buyer to the writer
        require(IERC20(usdcAddress).transferFrom(msg.sender, option.premiumReceiver, totalPrice), "Transfer failed");
        // If this is the first time the option is bought, make the option active
        if (option.unitsLeft == option.units && !option.isActive) {
            option.isActive = true;
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
        require(!option.isPaused, "Option is paused");
        // Check if option is expired
        require(block.timestamp >= option.expirationDate, "Option is expired");
        // Check if option is deactived
        require(!option.isActive, "Option is not active");
        // Check if option is 
        require(option.hasToPay, "Option does not have to pay");
        // Check if the buyer has enough units
        require(balanceOf(msg.sender, id) >= units, "Not enough units");
        // Burn option NFT from the buyer
        _burn(msg.sender, id, units);
        // Calculate total collateral
        uint256 price = option.optionPrice * units;
        // Transfer collateral from the contract to the buyer
        require(IERC20(usdcAddress).transfer(msg.sender, price), "Transfer failed");
    }

    function checkUpkeep(bytes calldata ) external view override returns (bool upkeepNeeded, bytes memory performData) {
        return (true, "");
    }
    function performUpkeep(bytes calldata /* performData */) external override {
    }
    function fulfillRequest(
        bytes32 requestId,
        bytes memory response,
        bytes memory err
    ) internal override {
        
        emit Response(requestId, s_lastResponse, s_lastError);
    }
}