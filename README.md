# opto-smart-contracts
Opto is a decentralized option exchange of derivative products. In particular, Opto supports European put and call options.

Users can:

- buy an existing option
- write a new one using one of the Opto built-in options
- publish custom options
- trade their options since options are represented by ERC721 tokens
Opto supports different built-in options with different data sources:
- 24h average mainnet blob fees, from subgraph and public RPC
- 24h average gas fees for multiple EVM chains, from subgraph and public RPC
- Equities, from Chainlink Price feed
- Commodities, from Chainlink Price feed

When writing a new option (or publishing a new one), users can choose:

- expiration date and buy deadline
- strike price in $
- premium price in $
- put or call
- n. of units available to be bought
- optional stop loss in $ for each unit

## Deployments and Chainlink subscriptions

Polygon(PoS) Amoy:

[Polygonscan - Opto Contract](https://amoy.polygonscan.com/address/0x55ef9ba96e80c634e6652fb164fa61517f5611d1#code)

[Chainlink - Functions Subscription](https://functions.chain.link/polygon-amoy/219)

[Chainlink - Automation Panel](https://automation.chain.link/polygon-amoy/8305038180283115066428651333900288117675581444467762397722197618458504533169)

Avalanche Fuji:

[Snowtrace - Opto Contract](https://testnet.snowtrace.io/address/0xdDa994D19956EC4D8E669e1CA8DBEc4e038C08a8)


[Chainlink - Functions Subscription](https://functions.chain.link/fuji/7633)

[Chainlink - Automation Panel](https://automation.chain.link/fuji/45209714636357398284842939654919830991322731419128780532945778056239980412066)



## The drone
The drone wont hack on chainlink anymore



