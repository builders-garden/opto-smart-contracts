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
        bytes1 statuses;
        OptionType optionType;
        uint256 buyDeadline;
        uint256 premium; 
        uint256 strikePrice; 
        uint256 expirationDate;
        uint256 optionQueryId;
        uint256 assetAddressId;
        uint256 units;
        uint256 capPerUnit; 
        uint256 unitsLeft;
        uint256 optionPrice; 
    }

    error UnexpectedRequestID(bytes32 requestId);

    event OptionCreated(
        uint256 indexed optionId,
        address indexed writer,
        bool isCall,
        uint256 premium,
        uint256 strikePrice,
        uint256 expirationDate,
        uint256 buyDeadline,
        OptionType optionType,
        uint assetId,
        uint256 optionQueryId,
        uint256 units,
        uint256 capPerUnit
    );

    event CustomOptionCreated(
        uint256 indexed optionId,
        address indexed writer,
        bool isCall,
        uint256 premium,
        uint256 strikePrice,
        uint256 expirationDate,
        uint256 buyDeadline,
        uint256 units,
        uint256 capPerUnit,
        string name,
        string desc
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

    event OptionDeleted(
        uint indexed optionId
    );
    event Response(
        uint256 indexed optionId,
        bool indexed hasToPay,
        bytes32 indexed requestId,
        bytes response,
        bytes err
    );
    
    event erroredClaimed(
        uint256 indexed optionId,
        address indexed claimer, 
        uint totalClaimed
    );
}
