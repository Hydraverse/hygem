# HydraGem Mining Game
****
Mint magic 💫 and combine with found & bought 🧱 blocks to make 💎 gems that pay a reward when burned!

🪙 Gemcoin rewards are redeemable 1:1 for HYDRA and can be bought, sold or traded.

**NEW: 🪙 can now be used for minting and buying 🧱 -- no more draining UTXOs for anything but the TX fees!!**

**ALSO: 🔥 is now minted for _gas_ that gets used for gameplay! These tokens will acquire value whenever the contract creator periodically refunds gameplay fees.**

### How it works:

Every smart contract transaction on the Hydra chain is confirmed by a mined block.

When a player mints 💫, the cost (starting at 0.001 HYDRA, or 1🪙) is contributed to the HYDRA reward pool.
At the same time, the address responsible for mining the block associated with this transaction receives 1🧱.

Players can acquire 🧱 by buying from the miner for a slightly higher price, but only if the buyer is holding
💫 but not 🧱, and the seller isn't holding 💫.

**NEW: Staking wallets can claim another address as a co-player, allowing minted blocks to be acquired for free and preventing anyone else from buying them!**

Once the player has at least 1💫 and 1🧱, they can be burned together to receive 1💎.

💎 can then be burned to receive 🪙 proprtional to the HYDRA prize pool value, and then 🪙 can be redeemed 1:1 for HYDRA.
This allows players to hold 💎 until the redemption value is to their liking.

Note that 💎 cannot be burned until the player has burned all available 💫🧱 pairs from their holdings.

# Usage

Use `sendtocontract` to access all below functions, and `callcontract` for views.

### Example of minting a 💫 token and adding HYDRA to the reward pool:

Replace `ADDR=Tsjf5gGi3kJnCTfkn9ACKb3rHELVdAc8JU` with your own address or leave blank to use the default address.

```shell
$ GEM=f57944a55d1d95cb2fab513171f2230e68931f7b
$ ADDR=Tsjf5gGi3kJnCTfkn9ACKb3rHELVdAc8JU
$ hydra-cli -testnet sendtocontract $GEM 1249c58b 0.101 350000 $ADDR  # mint()
{
  "txid": "0bea03a73c0c0b83721bb19b56d0dd0b78e55f3b4edf23945ba73d16fd5fffbb",
  "sender": "Tsjf5gGi3kJnCTfkn9ACKb3rHELVdAc8JU",
  "hash160": "ca253ac9875464ddfb30f498c9e0e64bab7c6360"
}
```
Any amount of HYDRA beyond the mint cost is returned to the sender.
The transaction can be located on the [Testnet Explorer](https://testexplorer.hydrachain.org/tx/0bea03a73c0c0b83721bb19b56d0dd0b78e55f3b4edf23945ba73d16fd5fffbb)
to determine the 🧱 winner. 

### Example of buying one 🧱 from another holder at the queried price:

On testnet, that holder is pretty much always the most prolific miner at `TvuuV8G8S3dstJ6C75WJLPKboiA4qX8zNv`.

```shell
$ hydra-cli -testnet callcontract $GEM a035b1fe # price()
{
  "address": "f57944a55d1d95cb2fab513171f2230e68931f7b",
  "executionResult": {
    ...
    "output": "000000000000000000000000000000000000000000000000000000000002781c",
    ...
  },
  ...
}

python3 -c 'print(0x2781c / 10**8)'
0.0016182

$ hydra-cli -testnet gethexaddress TvuuV8G8S3dstJ6C75WJLPKboiA4qX8zNv
ecfdca6aced679c041241de8d12a90779f3dc71a

$ hydra-cli -testnet sendtocontract $GEM f088d547000000000000000000000000ecfdca6aced679c041241de8d12a90779f3dc71a 0.1 250000 $ADDR  # buy()
{
  "txid": "9095a2aee45fb9e98be4cc96f72aac43ecaad50c808cf6902d546c9099e6a3a4",
  "sender": "Tsjf5gGi3kJnCTfkn9ACKb3rHELVdAc8JU",
  "hash160": "ca253ac9875464ddfb30f498c9e0e64bab7c6360"
}
```
The resulting call on the blockchain can be found [here](https://testexplorer.hydrachain.org/tx/9095a2aee45fb9e98be4cc96f72aac43ecaad50c808cf6902d546c9099e6a3a4).

Any excess HYDRA paid will be returned, so it's also possible to skip checking the `price` and set a maximum amount instead.


The above is also a good example of parameter passing: in the `sendtocontract` call, `f088d547` is the function identifier, and the rest of the data is the `address` parameter.

Parameters are always padded to length 64 with zeroes, and addresses are always converted to hex as above.

A tool is provided to help format smart contract calls, and includes a map of function names:

```
halo@blade:halos ֍ ./call.py -h
usage: call.py [-h] [-V] [-l] CALL [PARAM [PARAM ...]]

Format a smart contract call.

positional arguments:
  CALL           function address or alias.
  PARAM          function param.

optional arguments:
  -h, --help     show this help message and exit
  -V, --version  show program's version number and exit
  -l, --list     list known functions
  
halo@blade:halos ֍ ./call.py --list
{
    'burn()': '44df8e70',
    'burned(address)': 'a7509b83',
    'buy()': 'a6f2ae3a',
    'buy(address)': 'f088d547',
    'coins()': '22fcefbe',
    'cost()': '13faede6',
    'mint()': '1249c58b',
    'mint(address)': '6a627842',
    'name()': '06fdde03',
    'price()': 'a035b1fe',
    'redeem()': 'be040fb0',
    'redeem(uint256)': 'db006a75',
    'symbol()': '95d89b41',
    'totalBalance()': 'ad7a672f',
    'totalSupply()': '18160ddd',
    'transfer(address,uint256)': 'a9059cbb',
    'transferFrom(address,address,uint256)': '23b872dd',
    'value()': '3fa4f245'
}

halo@blade:halos ֍ ./call.py "buy(address)" ecfdca6aced679c041241de8d12a90779f3dc71a
f088d547000000000000000000000000ecfdca6aced679c041241de8d12a90779f3dc71a

halo@blade:halos ֍ ./call.py burn
44df8e70
```

### Example of burning 💫 + 🧱 to get 💎:

Now that 1🧱 has been bought, 1💎 can be obtained by calling `burn`.

```shell
$ ./call.py burn
44df8e70
$ hydra-cli -testnet sendtocontract $GEM 44df8e70 0 250000 $ADDR  # burn() 
{
  "txid": "3c93ec6f8c66e69de22a6e13a8b1cadcd23e9d60f7e0b2294e156d2ecb540ab3",
  "sender": "Tsjf5gGi3kJnCTfkn9ACKb3rHELVdAc8JU",
  "hash160": "ca253ac9875464ddfb30f498c9e0e64bab7c6360"
}
```
Transaction: [3c93ec6f8c66e69de22a6e13a8b1cadcd23e9d60f7e0b2294e156d2ecb540ab3](https://testexplorer.hydrachain.org/tx/3c93ec6f8c66e69de22a6e13a8b1cadcd23e9d60f7e0b2294e156d2ecb540ab3)

### Example of burning 💎 to get 🪙 award (same call):

After obtaining 💎, it can be held, traded or burned to receive 🪙.

```shell
$ hydra-cli -testnet sendtocontract $GEM 44df8e70 0 250000 $ADDR  # burn() 
{
  "txid": "43c38847c29e37466f4719623f514b5066a58603c8285486396b3c558c2838cb",
  "sender": "Tsjf5gGi3kJnCTfkn9ACKb3rHELVdAc8JU",
  "hash160": "ca253ac9875464ddfb30f498c9e0e64bab7c6360"
}
```
Transaction: [43c38847c29e37466f4719623f514b5066a58603c8285486396b3c558c2838cb](https://testexplorer.hydrachain.org/tx/43c38847c29e37466f4719623f514b5066a58603c8285486396b3c558c2838cb)


### Example of redeeming 🪙 for HYDRA:

🪙 always has a 1:1 value with HYDRA and available liquidity to exchange tokens.

```shell
$ CALL="$(./call.py 'redeem(uint256)' 1.0)"
db006a7500000000000000000000000000000000000000000000000000000000000186a0
$ hydra-cli -testnet sendtocontract $GEM $CALL 0 250000 $ADDR
{
  "txid": "5237e3ed6fa8e5fcaf75b7c6d08cb78d83b8c7237da6fd3514e48dec0f744e50",
  "sender": "Tsjf5gGi3kJnCTfkn9ACKb3rHELVdAc8JU",
  "hash160": "ca253ac9875464ddfb30f498c9e0e64bab7c6360"
}

```

Transaction: [5237e3ed6fa8e5fcaf75b7c6d08cb78d83b8c7237da6fd3514e48dec0f744e50](https://testexplorer.hydrachain.org/tx/5237e3ed6fa8e5fcaf75b7c6d08cb78d83b8c7237da6fd3514e48dec0f744e50)



# Function Details

### Main Contract: [💎 HYGEM 💎HydraGem💎 [v9.3a-test]](https://testexplorer.hydrachain.org/contract/f57944a55d1d95cb2fab513171f2230e68931f7b/) `f57944a55d1d95cb2fab513171f2230e68931f7b`

### Functions

- ### `1249c58b` `mint()`

    Mint one 💫 to the caller, and one 🧱 to `block.coinbase`,
    otherwise known as the miner of the block that confirmed the current transaction.
    If the caller is also the miner, half of the current HYDRA reward pool is paid out
    instead.

    A minimum payment is required for 🧱 to be minted, but 💫 is still minted when no payment is included or the amount paid is less than the `cost`.
    If the payment is less than the amount specified by the `cost()` function, the amount is held by the contract until additional payments meet the minimum `cost`.
    Any excess beyond the `cost` is then returned to the sender.

    If there is no payment included but the caller is holding 🪙, they will be used to pay the minting cost instead.

- ### `6a627842` `mint(address)`

    Mint one 💫 to the caller, and identify `address` as a "co-player" who is able to retrieve blocks from the calling address without a required payment.

    The purpose of this functionality is to allow staking wallets to not be disturbed in order to maximize the likelihood of mining a HYDRA block.

    No payment is required, and the caller will still receive 1💫, effectively locking out anyone else besides the co-player from buying minted 🧱.

- ### `44df8e70` `burn()`

    This function's behavior depends on the caller's token holdings.

    If the caller holds both 💫 and 🧱, one of each is burned,
    and the caller is awarded with 1💎.

    If the caller has 💎, it gets burned and a proportion of the
    HYDRA reward pool is paid out to the caller in the form of redeemable gemcoin 🪙 tokens.
    
    The current award value can be determined from the `value()` function.

- ### `f088d547` `buy(address)`
  ### `a6f2ae3a` `buy()`

    Buy one 🧱 token from `address` (or `block.coinbase` of the current transaction) for at least `price()` HYDRA included as payment.

    Conditions must be met in order for the purchase to be allowed:
     - The buyer cannot be holding 🧱.
     - The buyer must be holding 💫.
     - The 🧱 holder at `address` must not be holding 💫.

    Once these conditions are met, the HYDRA payment is sent to the reward pool
    and the 🧱 is transferred from the holder at `address` to the caller.

    If no payment is included but the caller holds 🪙, they will be used to cover the buy price instead.

- ### `be040fb0` `redeem()`
  ### `db006a75` `redeem(amount)`

    Redeem `amount` (or all) of held 🪙 for HYDRA, where 1🪙 = 0.001 HYDRA.

    The purpose of these tokens is to provide permanence to the game's reward history,
    enable gameplay with tokens only, and are otherwise usable as normal tokens (which serves as collateral for HYDRA).

    They can be bought directly using the `coins()` function, traded on the DEX, and transferred.
    However, unlike normal tokens these cannot be burned.

- ### `13faede6` `cost()`

  Get the current HYDRA cost to mint one 💫 🧱 pair.

- ### `a035b1fe` `price()`

    Get the current buy price of one 🧱, based on total supply in combination with 💎.

- ### `3fa4f245` `value()`

    Get the current 🪙 reward value from burning one 💎.

- ### `22fcefbe` `coins()`

    Return 🪙 from paid HYDRA, with 1🪙 = 0.001 HYDRA.

## Generic Functions for All Contracts

All `HydraGem` contracts are tokens and share a common structure based from ERC20 tokens and `openzeppelin` libraries.

### Auxiliary Contracts

- `54fa1d203231118b7e1d5a657079dbedcf15e0b7` [💫 MAGIC 💎HydraGem💎 [v9.3a-test]](https://testexplorer.hydrachain.org/contract/54fa1d203231118b7e1d5a657079dbedcf15e0b7/)
- `c1722c727778c500b3440743cc4b47d8c9c3a1d1` [🧱 BLOCK 💎HydraGem💎 [v9.3a-test]](https://testexplorer.hydrachain.org/contract/c1722c727778c500b3440743cc4b47d8c9c3a1d1/)
- `9894cbb77b7812ddc2973c3a66f1f8ef43f0ba0f` [🪙 GCOIN 💎HydraGem💎 [v9.3a-test]](https://testexplorer.hydrachain.org/contract/9894cbb77b7812ddc2973c3a66f1f8ef43f0ba0f/)
- `a65154396fcb66b5603897ea31059584f0ba88c2` [🔥 FLAME 💎HydraGem💎 [v9.3a-test]](https://testexplorer.hydrachain.org/contract/a65154396fcb66b5603897ea31059584f0ba88c2/)

### Functions

- ### `a9059cbb` `transfer(address dest, uint256 amount)`
  Transfer `amount` contract tokens from caller to `dest`.

- ### `23b872dd` `transferFrom(address owner, address dest, uint256 amount)`
  Transfer `amount` contract tokens from `owner` to `dest`.

- ### `18160ddd` `totalSupply()`
  View returning the total supply of the called contract token.

- ### `70a08231` `balanceOf(address)`
  View returning the balance of contract tokens associated with `address`.

- ### `a7509b83` `burned(address from)`
  View returning the amount of contract tokens burned by `from`.

- ### `06fdde03` `name()`
  View returning the name of the called contract.

- ### `95d89b41` `symbol()`
  View returning the symbol of the called contract token.
