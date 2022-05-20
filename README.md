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

Verify
`forge flatten --output src/NFT.flattened.sol src/NFT.sol`

`forge verify-contract --chain-id 4 --constructor-args 
    $(cast abi-encode "constructor(string,string)" "myNFT" "fNFT")
    --compiler-version v0.8.10+commit.fc410830 <the_contract_address> src/NFT.sol:NFT <your_etherscan_api_key>`

Success !!

#### Shell Autocompletion

```
mkdir -p $HOME/.local/share/bash-completion/completions
forge completions bash > $HOME/.local/share/bash-completion/completions/forge
cast completions bash > $HOME/.local/share/bash-completion/completions/cast
exec bash
```

#### Minting NFTs from your contract
 
Calling functions on your NFT contract is made simple with Cast, Foundry's command-line tool for interacting with smart contracts, sending transactions, and getting chain data.
```
cast send --rpc-url=$RPC_URL <contractAddress>  "mintTo(address)" <arg> --private-key=$PRIVATE_KEY
```

