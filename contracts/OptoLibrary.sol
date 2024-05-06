// SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;

library OptoLib {

    // Chainlink functions query schemas
    string public constant RPC_CALL_QUERY = "rpc_call";
    string public constant SUBGRAPH_QUERY_1 = 
        'let subgraphURL = args[0]' 
        'const fetchPrice = () => Functions.makeHttpRequest({'
            'url: subgraphURL,'
            'method: "POST",'
            'data: {'
                'query: `query MyQuery {'
                    'feeAggregator(id: "init") {'
                        'gas_average_daily'
                    '}'
                '}`,'
            '},'
        '})'
        
        'const request = async () => {'
            'try {'
                'const response = await Functions.makeHttpRequest({'
                    'url: "https://arb1.arbitrum.io/rpc",'
                    'method: "POST",'
                    'data: {'
                        'id: 1,'
                        'jsonrpc: "2.0",'
                        'method: "eth_call",'
                        'params: ['
                            '{'
                                'to: "0x639Fe6ab55C921f74e7fac1ee960C0B6293ba612",'
                                'data: "0x50d25bcd",'
                            '},'
                            '"latest",'
                        '],'
                    '},'
                '})'
        
                '// Assuming the response contains the balance information'
                'const balance = response.data.result'
                'return balance'
            '} catch (error) {'
                'console.error("Error occurred:", error)'
                'throw error // Propagate the error'
            '}'
        '}'
        
        'let ethUsdcPrice'
        '// Call the request function to get the balance'
        'try {'
            'const result = await request()'
            'ethUsdcPrice = (parseInt(result, 16) / 10**8)'
            'console.log(ethUsdcPrice)'
        '} catch (error) {'
            'console.error("Failed to get balance:", error)'
        '}'
        
        
        
        'const {'
            'error,'
            'data: {'
                'errors,'
                'data,'
            '},'
        '} = await fetchPrice()'
        
        'const {feeAggregator: { gas_average_daily }} = data'
        
        'let usdc_gas_average_daily = (gas_average_daily * ethUsdcPrice) / 1e12'
        'let rounded_usdc_gas_average_daily = Math.floor(usdc_gas_average_daily)'
        
        'return Functions.encodeUint256(BigInt(rounded_usdc_gas_average_daily))';

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
