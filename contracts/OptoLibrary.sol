// SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;

library OptoLib {

    // Chainlink functions query schemas
    string public constant RPC_CALL_QUERY = "rpc_call";
    string public constant SUBGRAPH_QUERY_1 = "subgraph";
    string public constant SUBGRAPH_QUERY_2 = "subgraph";

    string public constant RPC_CALL_ADDRESS_1 = "rpc_call";
    string public constant RPC_CALL_ADDRESS_2 = "rpc_call";
    string public constant RPC_CALL_ADDRESS_3 = "rpc_call";
    string public constant RPC_CALL_ADDRESS_4 = "rpc_call";
    string public constant RPC_CALL_ADDRESS_5 = "rpc_call";
    string public constant RPC_CALL_ADDRESS_6 = "rpc_call";
    string public constant RPC_CALL_ADDRESS_7 = "rpc_call";
    string public constant RPC_CALL_ADDRESS_8 = "rpc_call";
    string public constant RPC_CALL_ADDRESS_9 = "rpc_call";
    string public constant RPC_CALL_ADDRESS_10 = "rpc_call";

    string public constant SUBGRAPH_ENDPOINT_1 = "subgraph";
    string public constant SUBGRAPH_ENDPOINT_2 = "subgraph";


    function getQueryAndParams(string memory optionId, uint256 index, uint256 optionalQueryId, uint256 contractQueryAddress) internal pure returns (string memory, string[] memory) {
        // Access constant strings from the Contract
        // You can hardcode the index or use some logic to select the string
        string memory query;
        string memory endpoint;
        string memory rpcAddress;
        string[] memory params;
        // get query
        if (index == 0) {
            query = RPC_CALL_QUERY;
            if (contractQueryAddress == 1) {
                rpcAddress = RPC_CALL_ADDRESS_1;
            } else if (contractQueryAddress == 2) {
                rpcAddress = RPC_CALL_ADDRESS_2;
            } else if (contractQueryAddress == 3) {
                rpcAddress = RPC_CALL_ADDRESS_3;
            } else if (contractQueryAddress == 4) {
                rpcAddress = RPC_CALL_ADDRESS_4;
            } else if (contractQueryAddress == 5) {
                rpcAddress = RPC_CALL_ADDRESS_5;
            } else if (contractQueryAddress == 6) {
                rpcAddress = RPC_CALL_ADDRESS_6;
            } else if (contractQueryAddress == 7) {
                rpcAddress = RPC_CALL_ADDRESS_7;
            } else if (contractQueryAddress == 8) {
                rpcAddress = RPC_CALL_ADDRESS_8;
            } else if (contractQueryAddress == 9) {
                rpcAddress = RPC_CALL_ADDRESS_9;
            } else if (contractQueryAddress == 10) {
                rpcAddress = RPC_CALL_ADDRESS_10;
            }
        } else if (index == 1) {
            query = SUBGRAPH_QUERY_1;
            if (optionalQueryId == 1) {
                endpoint = SUBGRAPH_ENDPOINT_1;
            } else if (optionalQueryId == 2) {
                endpoint = SUBGRAPH_ENDPOINT_2;
            }
        } else {
            query = SUBGRAPH_QUERY_2;
        }
        // build params array with rpcAddress and endpoint
        params[0] = optionId;
        params[1] = rpcAddress;
        params[2] = endpoint;
        return (query, params);
    }



    // String array to store queries

    //Type
    // 0 - RPC_CALL_QUERY
    // 1 - SUBGRAPH_QUERY

    //RPC
    // rpc -> un endpoint (Arbitrum)
    // per ogni endpoint -> lista di address


    // SUBGRAPH
    // gas -> lista di endpoint
    // blob -> no parametri
    

    // queries

}
