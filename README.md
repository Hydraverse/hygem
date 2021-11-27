# HydraGem Mining Game

Mint magic 💫 and combine with found & bought 🧱 blocks to make 💎 gems that pay a reward when burned!

🪙 Gemcoin rewards are redeemable 1:1 for HYDRA and can be bought, sold or traded.

### How it works:

Every smart contract transaction on the Hydra chain is confirmed by a mined block.

When a player mints 💫, the cost (starting at 0.0001 HYDRA) is contributed to the HYDRA reward pool.
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

Replace `TgYNuW1yBjAcLAWYuANDrMwy6r6QnkRcAf` with your own address or leave blank to use the default address.

```shell
$ GEM=4248bcd2b9d87936daa78736bdcbe85a511952a6
$ hydra-cli -testnet sendtocontract $GEM 1249c58b 0.001 250000 TgYNuW1yBjAcLAWYuANDrMwy6r6QnkRcAf  # mint()
{
  "txid": "9af1b437990d54c640e5ea10d6145a624e6aa653cca924809d384bc0b785a7b8",
  "sender": "TgYNuW1yBjAcLAWYuANDrMwy6r6QnkRcAf",
  "hash160": "4f59c49134ba043dc24a36e551be50eea6a46cb8"
}

```
Any amount of HYDRA beyond the mint cost is returned to the sender.
The transaction can be located on the [Testnet Explorer](https://testexplorer.hydrachain.org/tx/9af1b437990d54c640e5ea10d6145a624e6aa653cca924809d384bc0b785a7b8)
to determine the 🧱 winner. 

### Example of buying one 🧱 from another holder at the queried price:

On testnet, that holder is pretty much always the most prolific miner at `TvuuV8G8S3dstJ6C75WJLPKboiA4qX8zNv`.

```shell
$ hydra-cli -testnet callcontract $GEM a035b1fe # price()
{
  "address": "4248bcd2b9d87936daa78736bdcbe85a511952a6",
  "executionResult": {
    ...
    "output": "0000000000000000000000000000000000000000000000000000000000004e20",
    ...
  },
  ...
}

$ python3 -c 'print(0x4e20 / 10**8)'
0.0002

$ hydra-cli -testnet gethexaddress TvuuV8G8S3dstJ6C75WJLPKboiA4qX8zNv
ecfdca6aced679c041241de8d12a90779f3dc71a

$ hydra-cli -testnet sendtocontract $GEM f088d547000000000000000000000000ecfdca6aced679c041241de8d12a90779f3dc71a 0.0002 250000 TgYNuW1yBjAcLAWYuANDrMwy6r6QnkRcAf  # buy()
{
  "txid": "ba73d5d1bb2f03a447670fd45667d2fa8fa7586076a40f4f054ff2b52ecd3461",
  "sender": "TgYNuW1yBjAcLAWYuANDrMwy6r6QnkRcAf",
  "hash160": "4f59c49134ba043dc24a36e551be50eea6a46cb8"
}

```
The resulting call on the blockchain can be found [here](https://testexplorer.hydrachain.org/tx/ba73d5d1bb2f03a447670fd45667d2fa8fa7586076a40f4f054ff2b52ecd3461).

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
  
halo@blade:halos ֍ ./call.py -l
{
    'allowance(address,address)': 'dd62ed3e',
    'balanceOf(address)': '70a08231',
    'burn()': '44df8e70',
    'burned(address)': 'a7509b83',
    'buy(address)': 'f088d547',
    'decimals()': '313ce567',
    'mint()': '1249c58b',
    'name()': '06fdde03',
    'price()': 'a035b1fe',
    'redeem()': 'be040fb0',
    'redeem(uint256)': 'db006a75',
    'symbol()': '95d89b41',
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

# Function Details

### Main Contract

```
4248bcd2b9d87936daa78736bdcbe85a511952a6 💎HydraGem💎 [v8.2d-test] GEM 💎 [testnet]
```

### Functions

- ### `1249c58b` `mint()`

    Mint one 💫 to the caller, and one 🧱 to `block.coinbase`,
    otherwise known as the miner of the block that confirmed the current transaction.
    If the caller is also the miner, half of the current HYDRA reward pool is paid out
    instead.

    A minimum payment is required for 🧱 to be minted, but 💫 is still minted when no payment is included or the amount paid is less than the `cost`.

    If the payment is less than the amount specified by the `cost()` function, the amount is held by the contract until additional payments meet the minimum `cost`.

    Any excess beyond the `cost` is then returned to the sender.

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

    Buy one 🧱 token from `address` for at least `price()` HYDRA included as payment.

    Conditions must be met in order for the purchase to be allowed:
     - The buyer cannot be holding 🧱.
     - The buyer must be holding 💫.
     - The 🧱 holder at `address` must not be holding 💫.

    Once these conditions are met, the HYDRA payment is sent to the reward pool
    and the 🧱 is transferred from the holder at `address` to the caller.

- ### `be040fb0` `redeem()`
  ### `db006a75` `redeem(amount)`

    Redeem `amount` (or all) of held 🪙 1:1 for HYDRA.

    The purpose of these tokens is to provide permanence to the game's reward history,
    and are otherwise usable as normal tokens and collateral for HYDRA.

    They can be bought directly from the `GEMCOIN` contract, traded on the DEX, and transferred.
    However, unlike normal tokens these cannot be burned.

- ### `13faede6` `cost()`

  Get the current HYDRA cost to mint one 💫 🧱 pair.

- ### `a035b1fe` `price()`

    Get the current buy price of one 🧱, based on total supply in combination with 💎.

- ### `3fa4f245` `value()`

    Get the current 🪙 reward value from burning one 💎.

- ### `70a08231` `balanceOf(address)`

    Get the balance of 💎 tokens associated with `address`.


## Generic Functions for All Contracts

All `HydraGem` contracts are tokens and share a common structure based from ERC20 tokens and `openzeppelin` libraries.

### Auxiliary Contracts

```
747aeb67834b97135032b28e34e116e5834f862d 💎HydraGem💎 [v8.2d-test] MAGIC 💫 [testnet]
```

```
b4a5cfd1de02a1a3784207d3c4922f50c7e8b02e 💎HydraGem💎 [v8.2d-test] BLOCK 🧱 [testnet]
```

```
67b079e807a82463226fd1b83e6284ca887b1648 💎HydraGem💎 [v8.2d-test] GEMCOIN 🪙 [testnet]
```

### Functions

- ### `a9059cbb` `transfer(address dest, uint256 amount)`
  Transfer `amount` contract tokens from caller to `dest`.

- ### `23b872dd` `transferFrom(address owner, address dest, uint256 amount)`
  Transfer `amount` contract tokens from `owner` to `dest`.

- ### `18160ddd` `totalSupply()`
  View returning the total supply of the called contract token.

- ### `a7509b83` `burned(address from)`
  View returning the amount of contract tokens burned by `from`.

- ### `06fdde03` `name()`
  View returning the name of the called contract.

- ### `95d89b41` `symbol()`
  View returning the symbol of the called contract token.
