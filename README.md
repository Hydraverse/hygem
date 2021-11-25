# HydraGem Mining Game

Mint magic 💫 and combine with found & bought 🧱 blocks to make 💎 gems that pay a HYDRA reward when burned!

Every smart contract transaction is confirmed by a mined block.

An immediate HYDRA "cash" prize awaits those lucky enough to mine blocks when minting magic!

Additionally, all block miners get an opportunity to redeem the proportional gem burning reward, every time magic is minted, and from anywhere!

# Function Map

Use `sendtocontract` to access all below functions, and `callcontract` for views.

Example of minting a `💫` token and adding 1.12345678 HYDRA to the reward pool from a specific wallet:

```shell
$ hydra-cli -testnet sendtocontract 030cee1ee7769e4c2f293dc861061f5489b4f745 1249c58b 1.12345678 250000 TbHZbSd3ZfpKnzGfTgLY2GaNyG2YwiiYp2 
```

### Main Contract

```
030cee1ee7769e4c2f293dc861061f5489b4f745 HydraGem v7 💎 GEM 💎 [testnet]
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

    This function behavior depends on the caller's token holdings.

    If the caller holds both `💫` and `🧱` tokens, one of each is burned,
    and the caller is awarded with one `💎` token.

    If the caller has a `💎` token, it gets burned instead and a proportion of the
    HYDRA reward pool is paid out to the caller. The estimated amount of the award
    can be determined from the `value()` function.

    To accompany the HYDRA reward, the gem burner also receives an equivalent amount
    of `🪙` tokens. They are not a further part of this game, but are like any tokens
    that can be traded or sold on the DEX. Unlike normal tokens however, the `GEMCOIN`
    token can't be burned.

- ### `f088d547` `buy(address)`

    Buy one `🧱` token from `address` for at least `price()` HYDRA included as payment.

    Conditions must be met in order for the purchase to be allowed:

     - The buyer cannot be holding `💎` tokens.
     - The buyer cannot be holding `🧱` tokens.
     - The buyer must be holding `💫` tokens.
     - The `🧱` holder at `address` must not be holding `💫` tokens.

    Once these conditions are met, the HYDRA payment is split between the reward pool
    and the `🧱` holder at `address` after transferring the token to the caller.

- ### `a035b1fe` `price()`

    View returning the expected current HYDRA cost of one `🧱`, based on total supply in combination with `💎`.

- ### `3fa4f245` `value()`

    View returning the expected current HYDRA reward from burning one `💎`.

## Generic Functions for All Contracts

All `HydraGem` contracts are tokens and share a common structure based from ERC20 tokens and `openzeppelin` libraries.

### Auxiliary Contracts

```
edc7848958435c9dd16dd9a0bb72e399bed2dba9 HydraGem v7 💎 MAGIC 💫 [testnet]
```

```
405a7e8491ef732d99d3b2e3faba272cd17f8a3c HydraGem v7 💎 BLOCK 🧱 [testnet]
```

```
65299ddb1c9cadd14d83fbb48fc635c931c4f110 HydraGem v7 💎 GEMCOIN 🪙 [testnet]
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
