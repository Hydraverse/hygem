# HydraGem Mining Game

Mint magic 💫 and combine with found & bought 🧱 blocks to make 💎 gems that pay a HYDRA reward when burned!

Every smart contract transaction is confirmed by a mined block.

An immediate HYDRA "cash" prize awaits those lucky enough to mine blocks when minting magic!

Additionally, all block miners get an opportunity to redeem the proportional gem burning reward, every time magic is minted, and from anywhere!

# Function Map

Use `sendtocontract` to access all below functions, and `callcontract` for views.

Example of minting a `💫` token and adding 1.12345678 HYDRA to the reward pool from a specific wallet (replace `TbHZbSd3ZfpKnzGfTgLY2GaNyG2YwiiYp2` with your own address):

```shell
$ hydra-cli -testnet sendtocontract 919ed2d23fa2b88374c6b78a22d3e54648a42cc0 1249c58b 1.12345678 250000 TbHZbSd3ZfpKnzGfTgLY2GaNyG2YwiiYp2 
```

Example of buying one `🧱` from another holder at the queried price.

On testnet, that holder is pretty much always the most prolific miner at `TvuuV8G8S3dstJ6C75WJLPKboiA4qX8zNv`.

```shell
$ hydra-cli -testnet callcontract 919ed2d23fa2b88374c6b78a22d3e54648a42cc0 a035b1fe # price()
{
  "address": "919ed2d23fa2b88374c6b78a22d3e54648a42cc0",
  "executionResult": {
    "gasUsed": 25567,
    "excepted": "None",
    "newAddress": "919ed2d23fa2b88374c6b78a22d3e54648a42cc0",
    "output": "0000000000000000000000000000000000000000000000000000000008be7c4d",
    "codeDeposit": 0,
    "gasRefunded": 0,
    "depositSize": 0,
    "gasForDeposit": 0,
    "exceptedMessage": ""
  },
  "transactionReceipt": {
    "stateRoot": "eedcbb96f774b799c51134c74ef3305a2426a0f5d1100f4ce02d79a65004e0f6",
    "gasUsed": 25567,
    "bloom": "...",
    "log": [
    ]
  }
}

$ python3 -c 'print(0x8be7c4d / 10**8)'
1.46701389

$ hydra-cli -testnet gethexaddress TvuuV8G8S3dstJ6C75WJLPKboiA4qX8zNv
ecfdca6aced679c041241de8d12a90779f3dc71a

$ hydra-cli -testnet sendtocontract 919ed2d23fa2b88374c6b78a22d3e54648a42cc0 f088d547000000000000000000000000ecfdca6aced679c041241de8d12a90779f3dc71a 1.46701389 250000 TbHZbSd3ZfpKnzGfTgLY2GaNyG2YwiiYp2
{
  ...
}
```
This is also a good example of parameter passing: in the `sendtocontract` call, `f088d547` is the function identifier, and the rest of the data is the `address` parameter.

Parameters are always padded to length 64 with zeroes, and addresses are always converted to hex as above.

Here is a method for constructing function calls with `python3`:

```python

def format_param(param):
  return str(param).rjust(64, '0')


def format_number_param(number):
  return format_param(hex(int(number * 10**8) if isinstance(number, float) else number)[2:])


def format_call(function, *params):
  return function + ''.join(format_param(param) if isinstance(param, str) else format_number_param(param) for param in params)


call = '23b872dd'  # transferFrom(address,address,uint256)

addr_from = 'ecfdca6aced679c041241de8d12a90779f3dc71a'
addr_to = '15b3d269d20b5ba9d596a236b679b9fbc14df51b'

amount = 0.83333333

print(format_call(call, addr_from, addr_to, amount))
```

This functionality is also available using `call.py`, and includes a map of function names.

```shell
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

```

### Main Contract

```
919ed2d23fa2b88374c6b78a22d3e54648a42cc0 HydraGem v7.77 💎 GEM 💎 [testnet]
```

### Functions

- ### `70a08231` `balanceOf(address)`

    Get the balance of `💎` tokens associated with `address`.

- ### `1249c58b` `mint()`

    Mint one `💫` token to the caller, and one `🧱` token to `block.coinbase`,
    otherwise known as the miner of the block that confirmed the current transaction.
    If the caller is also the miner, half of the current HYDRA reward pool is paid out
    instead.

    A payment of HYDRA can optionally be included and added to the game reward pool.

- ### `44df8e70` `burn()`

    This function's behavior depends on the caller's token holdings.

    If the caller holds both `💫` and `🧱` tokens, one of each is burned,
    and the caller is awarded with one `💎` token.

    If the caller has a `💎` token, it gets burned instead and a proportion of the
    HYDRA reward pool is paid out to the caller in the form of redeemable gemcoin `🪙` tokens.
    
    The estimated amount of the award can be determined from the `value()` function.

- ### `f088d547` `buy(address)`

    Buy one `🧱` token from `address` for at least `price()` HYDRA included as payment.

    Conditions must be met in order for the purchase to be allowed:

     - The buyer cannot be holding `💎` tokens.
     - The buyer cannot be holding `🧱` tokens.
     - The buyer must be holding `💫` tokens.
     - The `🧱` holder at `address` must not be holding `💫` tokens.

    Once these conditions are met, the HYDRA payment is split between the reward pool
    and the `🧱` holder at `address` after transferring the token to the caller.

- ### `be040fb0` `redeem()`
  ### `db006a75` `redeem(amount)`

    Redeem `amount` of held `GEMCOIN` `🪙` tokens 1:1 for HYDRA.

    The purpose of these tokens is to provide permanence to the game's reward history,
    and are otherwise usable as normal tokens and collateral for HYDRA.

    They can be bought directly from the `GEMCOIN` contract, traded on the DEX, and transferred.
    However, unlike normal tokens these cannot be burned.

- ### `a035b1fe` `price()`

    View returning the expected current HYDRA cost of one `🧱`, based on total supply in combination with `💎`.

- ### `3fa4f245` `value()`

    View returning the expected current HYDRA reward from burning one `💎`.

## Generic Functions for All Contracts

All `HydraGem` contracts are tokens and share a common structure based from ERC20 tokens and `openzeppelin` libraries.

### Auxiliary Contracts

```
a5c6a9afd112dff3cf5a64d6d25bd6ef917d0d17 HydraGem v7.77 💎 MAGIC 💫 [testnet]
```

```
36e076c738e60e4104b5d9b1878ff131b23b73d7 HydraGem v7.77 💎 BLOCK 🧱 [testnet]
```

```
175ec0712c7f7094cbc90e5b63a9a9f6e05fd093 HydraGem v7.77 💎 GEMCOIN 🪙 [testnet]
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
