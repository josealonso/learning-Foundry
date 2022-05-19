### Installing Foundry on bash

- `curl -L https://foundry.paradigm.xyz | bash`
- `foundryup` ---> adds foundryup to PATH

### Creating an NFT with Solmate

- Install dependencies

`forge install Rari-Capital/solmate Openzeppelin/openzeppelin-contracts foundry-rs/forge-std`

- Check the project structure
`tree -L 2`

- Implement a basic NFT contract
`mv -v src/Contract.sol src/NFT.sol`

- Compile and deploy with forge
`forge build`

Set your environment variables
```
export RPC_URL=<Your RPC endpoint>
export PRIVATE_KEY=<Your wallets private key>
```

Deploy
`forge create NFT --rpc-url=$RPC_URL --private-key=$PRIVATE_KEY --constructor-args <name> <symbol>`
If successfully deployed, you will see the deploying wallet's address, the contract's address as well as the transaction hash printed to your terminal.

 

