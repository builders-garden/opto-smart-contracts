// SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;

library OptoLib {

     string public constant RPC_CALL_QUERY = 
    "let feedAddress = args[0];"
  "const request = async () => {"
      "try {"
        "const response = await Functions.makeHttpRequest({"
          "url: 'https://arbitrum-one-rpc.publicnode.com',"
          "method: 'POST',"
          "headers: {"
                "'Content-Type': 'application/json',"
          "},"
          "data: {"
            "id: 1,"
            "jsonrpc: '2.0',"
            "method: 'eth_call',"
            "params: ["
              "{"
                "to: feedAddress,"
                "data: '0x50d25bcd'," 
              "},"
              "'latest',"
            "],"
          "},"
        "});"
        "const usdcPrice = response.data.result;"
        "return usdcPrice;"
      "} catch (error) {"
        "console.error('Error occurred:', error);"
        "throw error;"
      "}"
    "};"
    "let usdcPrice;"
    "try{"
    "const result = await request();"
    "usdcPrice = Math.round(result / 10**2);"
    "console.log(usdcPrice);"
  "} catch (error) {"
    "console.error('Failed to get balance:', error);"
  "}"
"return Functions.encodeUint256(BigInt(usdcPrice));";





    // Dynamic String for gas price 1 arg
      string public constant SUBGRAPH_QUERY_1 = 
      "let subgraphURL = args[0];"
       "const fetchPrice = () => Functions.makeHttpRequest({"
       "url: subgraphURL,"
        "method: 'POST',"
        "headers: {"
        "'Accept': 'application/json',"
        "'Content-Type': 'application/json',"
        "},"
        "data: {"
            "query: `query MyQuery {feeAggregators{gas_average_daily}}`,"
        "},"
    "});"
       "const {"
        "error,"
          "data: {"
            "data,"
          "},"
      "} = await fetchPrice();"
      "const {feeAggregators: [{ gas_average_daily }]} = data;"
      "const request = async () => {"
        "try {"
          "const response = await Functions.makeHttpRequest({"
            "url: 'https://arbitrum-one-rpc.publicnode.com',"
            "method: 'POST',"
            "headers: {"
                "'Content-Type': 'application/json',"
            "},"
            "data: {"
              "id: 1,"
              "jsonrpc: '2.0',"
              "method: 'eth_call',"
              "params: ["
                "{"
                  "to: '0x639Fe6ab55C921f74e7fac1ee960C0B6293ba612',"
                  "data: '0x50d25bcd'," 
                "},"
                "'latest',"
              "],"
            "},"
          "});"
          "const balance = response.data.result;"
          "return balance;"
        "} catch (error) {"
          "console.error('Error occurred:', error);"
          "throw error;" 
        "}"
      "};"
      "let ethUsdcPrice;"
      "try {"
        "const result = await request();"
        "ethUsdcPrice = (parseInt(result, 16) / 10**8);"
        "console.log(ethUsdcPrice);"
      "} catch (error) {"
        "console.error('Failed to get balance:', error);"
      "}"
      
    "let parsedAvg = parseInt(gas_average_daily);"
    "let usdc_gas_average_daily = (parsedAvg * ethUsdcPrice) / 1e12;"
    "let rounded_usdc_gas_average_daily = Math.floor(usdc_gas_average_daily);"
    "return Functions.encodeUint256(BigInt(rounded_usdc_gas_average_daily));";
    // Eth specific call for blob price - 0 args
    string public constant SUBGRAPH_QUERY_2 = 
     "const fetchPrice = () => Functions.makeHttpRequest({"
       "url: 'https://api.studio.thegraph.com/query/73482/opto-basefees-ethereum/version/latest',"
        "method: 'POST',"
        "headers: {"
        "'Accept': 'application/json',"
        "'Content-Type': 'application/json',"
        "},"
        "data: {"
            "query: `query MyQuery {feeAggregators{blob_average_daily}}`,"
        "},"
    "});"
       "const {"
        "error,"
          "data: {"
            "data,"
          "},"
      "} = await fetchPrice();"
    "const {feeAggregators: [{ blob_average_daily }]} = data;"
    "const request = async () => {"
      "try {"
        "const response = await Functions.makeHttpRequest({"
            "url: 'https://arbitrum-one-rpc.publicnode.com',"
            "method: 'POST',"
            "headers: {"
            "'Content-Type': 'application/json',"
          "},"
          "data: {"
            "id: 1,"
            "jsonrpc: '2.0',"
            "method: 'eth_call',"
            "params: ["
              "{"
                "to: '0x639Fe6ab55C921f74e7fac1ee960C0B6293ba612',"
                "data: '0x50d25bcd'," 
              "},"
              "'latest',"
            "],"
          "},"
        "});"
        "const balance = response.data.result;"
        "return balance;"
      "} catch (error) {"
        "console.error('Error occurred:', error);"
        "throw error;"
      "}"
    "};"
    "let ethUsdcPrice;"
    "try {"
      "const result = await request();"
      "ethUsdcPrice = (parseInt(result, 16) / 10**8);"
      "console.log(ethUsdcPrice);"
    "} catch (error) {"
      "console.error('Failed to get balance:', error);"
    "}"
    "let parsedAvg = parseInt(blob_average_daily);"
    "let usdc_blob_average_daily = (parsedAvg * ethUsdcPrice) / 1e12;"
    "let rounded_usdc_blob_average_daily = Math.floor(usdc_blob_average_daily);"
    "return Functions.encodeUint256(BigInt(rounded_usdc_blob_average_daily));";



    string public constant RPC_CALL_ADDRESS_1 = "0x8d0CC5f38f9E802475f2CFf4F9fc7000C2E1557c"; // Apple
    string public constant RPC_CALL_ADDRESS_2 = "0xd6a77691f071E98Df7217BED98f38ae6d2313EBA"; // Amazon
    string public constant RPC_CALL_ADDRESS_3 = "0x950DC95D4E537A14283059bADC2734977C454498"; // Coinbase
    string public constant RPC_CALL_ADDRESS_4 = "0x1D1a83331e9D255EB1Aaf75026B60dFD00A252ba"; // Alphabet
    string public constant RPC_CALL_ADDRESS_5 = "0xDde33fb9F21739602806580bdd73BAd831DcA867"; // Microsoft
    string public constant RPC_CALL_ADDRESS_6 = "0x4881A4418b5F2460B21d6F08CD5aA0678a7f262F"; // Nvidia
    string public constant RPC_CALL_ADDRESS_7 = "0x3609baAa0a9b1f0FE4d6CC01884585d0e191C3E3"; // Tesla
    string public constant RPC_CALL_ADDRESS_8 = "0x1F954Dc24a49708C26E0C1777f16750B5C6d5a2c"; // GOLD
    string public constant RPC_CALL_ADDRESS_9 = "0xC56765f04B248394CF1619D20dB8082Edbfa75b1"; // Silver

    string public constant SUBGRAPH_ENDPOINT_1 = "https://api.studio.thegraph.com/query/73482/opto-basefees-ethereum/version/latest";
    string public constant SUBGRAPH_ENDPOINT_2 = "https://api.studio.thegraph.com/query/73482/opto-basefees-avax/version/latest";


    function getQueryAndParams(uint256 index, uint256 optionalQueryId, uint256 contractQueryAddress) internal pure returns (string memory, string[] memory) {
        // Access constant strings from the Contract
        // You can hardcode the index or use some logic to select the string
        string memory query;
        string memory endpoint;
        string memory rpcAddress;
        string[] memory params = new string[](1);
   

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
            } 
            params[0] = rpcAddress;
        } else if (index == 1) {
            query = SUBGRAPH_QUERY_1;
            if (optionalQueryId == 1) {
                endpoint = SUBGRAPH_ENDPOINT_1;
            } else if (optionalQueryId == 2) {
                endpoint = SUBGRAPH_ENDPOINT_2;
            }
            params[0] = endpoint;
        } else {
            query = SUBGRAPH_QUERY_2;
            params[0] = "no_params";
        }
        return (query, params);
    }
}
