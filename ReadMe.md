# Supply chain & data auditing

This repository containts an Ethereum DApp that demonstrates a Supply Chain flow between a Coffee Seller and Buyer. The user story is similar to any commonly used supply chain process. A Seller can add items to the inventory system stored in the blockchain. A Buyer can purchase such items from the inventory system. Additionally a Seller can mark an item as Shipped, and similarly a Buyer can mark an item as Received.

## Etherscan Rinkeby Transaction ID
https://rinkeby.etherscan.io/tx/0x60bea67a4d04d4778af31c6669bb73b5298f54212eee9054e75ae8d6c9bde125

## Etherscan Rinkeby Contract Address
https://rinkeby.etherscan.io/address/0x354d0C1af988cDe13E88585d364d4449bB0374d8

## Config.env (To be added to the main folder)
const INFURA_KEY = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx";
const MNEMONIC = "xxxxxx xxxxxxx xxxxxx xxxxx xxxx xxxxx xxxxx xxxxx xxxx xxxxxx xxxxxx xxxxxx";
module.exports = {
    INFURA_KEY,
    MNEMONIC
};

## Libraries
### "mocha": "^7.1.1"
### "truffle-hdwallet-provider": "^1.0.17"

## Node version
v12.16.1
## Truffle version
v5.0.5
## Solidity version
0.4.26
## Web3
web3@1.2.1