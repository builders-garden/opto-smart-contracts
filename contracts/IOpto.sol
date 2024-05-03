// SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;
interface IOpto {
    // Enum for option type
    enum OptionType { 
        RPC_CALL_QUERY, 
        SUBGRAPH_QUERY_1, 
        SUBGRAPH_QUERY_2,
        CUSTOM_QUERY
    }

    // Option struct
    struct Option {
        address writer;
        address premiumReceiver;
        bool isCall;
        uint256 premium; 
        uint256 strikePrice; 
        uint256 expirationDate;

        OptionType optionType;
        uint256 optionQueryId;
        uint256 assetAddressId;

        uint256 units;
        uint256 capPerUnit; 
        uint256 unitsLeft;
        uint256 optionPrice; 
        
        bool hasToPay;
        bool isActive;
        bool isPaused;
    }

    error UnexpectedRequestID(bytes32 requestId);

    event OptionCreated(
        uint256 indexed optionId,
        address indexed writer,
        address premiumReceiver,
        bool isCall,
        uint256 premium,
        uint256 strikePrice,
        uint256 expirationDate,
        OptionType optionType,
        uint256 optionQueryId,
        uint256 units,
        uint256 capPerUnit
    );

    event OptionBought(
        uint256 indexed optionId,
        address indexed buyer,
        uint256 units,
        uint256 totalPrice
    );

    event OptionClaimed(
        uint256 indexed optionId,
        address indexed claimer,
        uint256 units,
        uint256 totalPrice
    );

    event OptionResult(
        uint256 indexed optionId,
        bool indexed hasToPay
    );

    event OptionPaused(uint256 indexed optionId);

    event Response(
        bytes32 indexed requestId,
        bytes response,
        bytes err
    );

}
