# Hydragem
****
### The HYDRA Blockchain Game

Mint free "magic" tokens by interacting with a smart contract on the blockchain,
then combine with found & bought "blocks" to make gems having real HYDRA value!

This game consists of five tokens:
- `💫 MAGIC:` Awarded to players looking for and minting BLOCK🧱.
- `🧱 BLOCK:` Awarded to HYDRA block miners when players mint MAGIC💫.
- `💎 HYGEM:` Awarded to players when combining and burning MAGIC💫 + BLOCK🧱.
- `🪙 GCOIN:` Game payment token with a 100:1 HYDRA redemption value (1 GCOIN🪙 = 0.01 HYDRA).
- `🔥 FLAME:` Awarded to players and HYDRA block miners based on the amount of _gas_ used by the blockchain to pay for gameplay.

The goal of this game is to acquire and hold HYGEMs until they are redeemable for a value higher than the minting cost.

HYGEMs can be acquired for free by mining BLOCKs from player-owned staking wallets, or bought from BLOCK holders not participating in
the game (not holding MAGIC).

### How it works:

Every smart contract transaction on the Hydra chain is confirmed by a mined block, which is also what generates our coveted HYDRA staking rewards.

When a player mints MAGIC, the cost (starting at 0.01 HYDRA, or 1 GCOIN) is contributed to the HYDRA reward pool.
At the same time, the address responsible for mining the HYDRA block associated with this transaction receives 1 BLOCK.

Players can acquire BLOCKs by buying from the miner for a slightly higher price, but only if the buyer is holding
MAGIC without BLOCKs, and the seller isn't holding MAGIC. This allows staking addresses to play by simply minting magic to
ensure that no other players can buy the mined BLOCK out from under them.

**NEW: Staking wallets can claim another address as a co-player, allowing minted blocks to be acquired for free and preventing anyone else from buying them!**

Once a player has at least 1 MAGIC💫 and 1 BLOCK🧱, they can be burned together to receive 1 HYGEM💎.

HYGEMs can then be burned to receive GCOIN🪙 proprtional to the HYDRA prize pool value, and then GCOINs can be redeemed for HYDRA.
This allows players to hold HYGEM until the redemption value is to their liking.

Note that HYGEM cannot be burned until the player has burned all available MAGIC+BLOCK pairs from their holdings.

# Gameplay from `hydra-cli`

Use `sendtocontract` to access all below functions, and `callcontract` for views.

## Mint MAGIC💫

This transaction sends 0.11 HYDRA to the game contract.
The initial cost of minting starts at 1 GEMCOIN, which as a value of 0.01 HYDRA.
Minting costs are refunded as GEMCOIN, so the following transaction refunds 10🪙 to be used for future minting.

Replace `ADDR=Tsjf5gGi3kJnCTfkn9ACKb3rHELVdAc8JU` with your own address or leave blank to use the default address.

```shell
$ GEM=500655d58ac9d217e5265678fd0cace39a94f87b
$ ADDR=Tsjf5gGi3kJnCTfkn9ACKb3rHELVdAc8JU
$ hydra-cli -testnet sendtocontract $GEM 1249c58b 0.11 350000 $ADDR  # mint()
{
  "txid": "407fa9ac62c5b40eea640a4ad2889a654204d55a2fb19a056b0212ff4c051643",
  "sender": "Tsjf5gGi3kJnCTfkn9ACKb3rHELVdAc8JU",
  "hash160": "ca253ac9875464ddfb30f498c9e0e64bab7c6360"
}
```
Any amount of HYDRA beyond the mint cost is returned to the sender.
The transaction can be located on the [Testnet Explorer](https://testexplorer.hydrachain.org/tx/407fa9ac62c5b40eea640a4ad2889a654204d55a2fb19a056b0212ff4c051643)
to determine the BLOCK🧱 winner.

## Buy BLOCK🧱

This example uses the purchased GCOIN from the above transaction to pay for the BLOCK.

On testnet, the BLOCK holder is pretty much always the most prolific miner at `TvuuV8G8S3dstJ6C75WJLPKboiA4qX8zNv`.

```shell
$ hydra-cli -testnet gethexaddress TvuuV8G8S3dstJ6C75WJLPKboiA4qX8zNv
ecfdca6aced679c041241de8d12a90779f3dc71a

$ hydra-cli -testnet sendtocontract $GEM f088d547000000000000000000000000ecfdca6aced679c041241de8d12a90779f3dc71a 0 250000 $ADDR  # buy()
{
  "txid": "d904c47e330d30e955b215050cad48caa5818fc86c5db3ef2cfb81f526a9efe7",
  "sender": "Tsjf5gGi3kJnCTfkn9ACKb3rHELVdAc8JU",
  "hash160": "ca253ac9875464ddfb30f498c9e0e64bab7c6360"
}
```
The resulting call on the blockchain can be found [here](https://testexplorer.hydrachain.org/tx/d904c47e330d30e955b215050cad48caa5818fc86c5db3ef2cfb81f526a9efe7).

Any excess HYDRA paid will be returned as GCOIN, so it's also possible to skip checking the price and send a maximum payment amount instead
when the player is not already holding GCOIN.

The above is also a good example of parameter passing: in the `sendtocontract` call, `f088d547` is the function identifier, and the rest of the data is the `address` parameter.

Parameters are always padded to length 64 with zeroes, and addresses are always converted to hex as above.

A tool is provided to help format smart contract calls, and includes a map of function names:

```
halo@blade:halos ֍ ./call.py -h
usage: call.py [-h] [-V] [-l] CALL [PARAM [PARAM ...]]

...

halo@blade:halos ֍ ./call.py --list
{
    ...
    'buy(address)': 'f088d547',
    ...
}

halo@blade:halos ֍ ./call.py "buy(address)" ecfdca6aced679c041241de8d12a90779f3dc71a
f088d547000000000000000000000000ecfdca6aced679c041241de8d12a90779f3dc71a

halo@blade:halos ֍ ./call.py burn
44df8e70
```

## Burn MAGIC💫 + BLOCK🧱 to get HYGEM 💎

Now that 1 BLOCK has been bought, 1 HYGEM can be obtained by calling `burn`.

```shell
$ ./call.py burn
44df8e70
$ hydra-cli -testnet sendtocontract $GEM 44df8e70 0 250000 $ADDR  # burn() 
{
  "txid": "ae3574d14c2d0a1ed2880b7b3afa14248a9b03c577c7b5fd07c91c647c81b868",
  "sender": "Tsjf5gGi3kJnCTfkn9ACKb3rHELVdAc8JU",
  "hash160": "ca253ac9875464ddfb30f498c9e0e64bab7c6360"
}
```
Transaction: [ae3574d14c2d0a1ed2880b7b3afa14248a9b03c577c7b5fd07c91c647c81b868](https://testexplorer.hydrachain.org/tx/ae3574d14c2d0a1ed2880b7b3afa14248a9b03c577c7b5fd07c91c647c81b868)

## Burn HYGEM💎 for GCOIN🪙 award:

After obtaining HYGEM, it can be held, traded or burned to receive GCOINs.

```shell
$ hydra-cli -testnet sendtocontract $GEM 44df8e70 0 250000 $ADDR  # burn() 
{
  "txid": "79420b8512128971fc9e27b4b5a5b2aeb154356054e48caacb799979dc87ab9b",
  "sender": "Tsjf5gGi3kJnCTfkn9ACKb3rHELVdAc8JU",
  "hash160": "ca253ac9875464ddfb30f498c9e0e64bab7c6360"
}
```
Transaction: [79420b8512128971fc9e27b4b5a5b2aeb154356054e48caacb799979dc87ab9b](https://testexplorer.hydrachain.org/tx/79420b8512128971fc9e27b4b5a5b2aeb154356054e48caacb799979dc87ab9b)


## Redeem & exchange GCOIN🪙 with HYDRA:

### GCOIN always has a 100:1 value with HYDRA and available liquidity to exchange tokens.

```shell
$ CALL="$(./call.py 'redeem(uint256)' 1.0)"; echo $CALL
db006a7500000000000000000000000000000000000000000000000000000000000f4240
$ hydra-cli -testnet sendtocontract "$GEM" "$CALL" 0 250000 $ADDR
{
  "txid": "d35582db1a20145b433d61cfd8efe64c7e36dca0b3cf18c06b79be74d8eef497",
  "sender": "Tsjf5gGi3kJnCTfkn9ACKb3rHELVdAc8JU",
  "hash160": "ca253ac9875464ddfb30f498c9e0e64bab7c6360"
}
```

Transaction: [d35582db1a20145b433d61cfd8efe64c7e36dca0b3cf18c06b79be74d8eef497](https://testexplorer.hydrachain.org/tx/d35582db1a20145b433d61cfd8efe64c7e36dca0b3cf18c06b79be74d8eef497)

### It's also possible to redeem all GCOIN at once:

```shell
$ CALL="$(./call.py redeem)"; echo $CALL
be040fb0
$ hydra-cli -testnet sendtocontract "$GEM" "$CALL" 0 250000 $ADDR
{
  "txid": "6bf6645e4eafece0683d2640051c802a5ac40e4fcd4fa1e764440e5b4ca0a399",
  "sender": "Tsjf5gGi3kJnCTfkn9ACKb3rHELVdAc8JU",
  "hash160": "ca253ac9875464ddfb30f498c9e0e64bab7c6360"
}
```

Transaction: [6bf6645e4eafece0683d2640051c802a5ac40e4fcd4fa1e764440e5b4ca0a399](https://testexplorer.hydrachain.org/tx/6bf6645e4eafece0683d2640051c802a5ac40e4fcd4fa1e764440e5b4ca0a399)

### Finally, to buy GCOIN using HYDRA:

```shell
$ CALL="$(./call.py coins)"; echo $CALL
22fcefbe
$ hydra-cli -testnet sendtocontract "$GEM" "$CALL" 1.0 250000 $ADDR
{
  "txid": "a8b59381681a39fddf0dc7569813d0847065d46480b45aa268103718c622275b",
  "sender": "Tsjf5gGi3kJnCTfkn9ACKb3rHELVdAc8JU",
  "hash160": "ca253ac9875464ddfb30f498c9e0e64bab7c6360"
}
```

Transaction: [a8b59381681a39fddf0dc7569813d0847065d46480b45aa268103718c622275b](https://testexplorer.hydrachain.org/tx/a8b59381681a39fddf0dc7569813d0847065d46480b45aa268103718c622275b)


# Function Details

### Main Contract: [💎 HYGEM 💎HydraGem💎 [v9.4a-test]](https://testexplorer.hydrachain.org/contract/500655d58ac9d217e5265678fd0cace39a94f87b/) `500655d58ac9d217e5265678fd0cace39a94f87b`

### Functions

- ### `1249c58b` `mint()`

  Mint 1 MAGIC to the caller, and 1 BLOCK to `block.coinbase`,
  otherwise known as the miner of the block that confirmed the current transaction.
  If the caller is also the miner, half of the current HYDRA reward pool is paid out
  instead.

  A minimum payment is required for BLOCK to be minted, but MAGIC is still minted when no payment is included or the amount paid is less than the `cost`.
  If the payment is less than the amount specified by the `cost()` function, the amount is held by the contract until additional payments meet the minimum `cost`.
  Any excess beyond the `cost` is then returned to the sender.

  If there is no payment included but the caller is holding GCOIN, they will be used to pay the minting cost instead.

- ### `6a627842` `mint(address)`

  Mint 1 MAGIC to the caller, and identify `address` as a "co-player" who is able to retrieve blocks from the calling address without a required payment.

  The purpose of this functionality is to allow staking wallets to not be disturbed in order to maximize the likelihood of mining a HYDRA block.

  No payment is required, and the caller will still receive 1💫, effectively locking out anyone else besides the co-player from buying minted BLOCKs.

- ### `44df8e70` `burn()`

  This function's behavior depends on the caller's token holdings.

  If the caller holds both MAGIC and BLOCK, one of each is burned,
  and the caller is awarded with 1 HYGEM.

  Otherwise, if the caller has any HYGEMs, one gets burned and a proportion of the
  HYDRA reward pool is paid out to the caller as GCOINs.

  The current award value can be determined from the `value()` function.

- ### `f088d547` `buy(address)`
  ### `a6f2ae3a` `buy()`

  Buy 1 BLOCK from `address` (or `block.coinbase` of the current transaction) for at least `price()` HYDRA included as payment.

  Conditions must be met in order for the purchase to be allowed:
    - The buyer cannot be holding BLOCK.
    - The buyer must be holding MAGIC.
    - The BLOCK holder at `address` must not be holding MAGIC.

  Once these conditions are met, the HYDRA payment is sent to the reward pool
  and the BLOCK is transferred from the holder at `address` to the caller.

  If no payment is included but the caller holds GCOIN, they will be used to cover the buy price instead.

- ### `be040fb0` `redeem()`
  ### `db006a75` `redeem(amount)`

  Redeem `amount` (or all) of held GCOIN🪙 for HYDRA, where 1🪙 = 0.01 HYDRA.

  The purpose of this token is to provide permanence to the game's reward history,
  enable gameplay with tokens only, and are otherwise usable as normal tokens (which serves as collateral for HYDRA).

  They can be bought directly using the `coins()` function, traded on the DEX, and transferred.
  However, unlike normal tokens these cannot be burned.

- ### `13faede6` `cost()`

  Get the minimum GCOIN cost to mint MAGIC and generate a BLOCK.

  Divide returned values by 10^5 to get the GCOIN value returned by this and the below functions.

- ### `a035b1fe` `price()`

  Get the current GCOIN price to buy BLOCK, based on total supply in combination with HYGEM.

- ### `3fa4f245` `value()`

  Get the current GCOIN reward value from burning one HYGEM.

- ### `22fcefbe` `coins()`

  Return GCOIN🪙 from paid HYDRA, with 1🪙 = 0.001 HYDRA.

## Generic Functions for All Contracts

All `HydraGem` contracts are tokens and share a common structure based from ERC20 tokens and `openzeppelin` libraries.

### Auxiliary Contracts

- `3d34588f9d115ab01cbbb133a8b0b7b56dd5c3df` [💫 MAGIC 💎HydraGem💎 [v9.4a-test]](https://testexplorer.hydrachain.org/contract/3d34588f9d115ab01cbbb133a8b0b7b56dd5c3df/)
- `0b1d3dafe4fc1ae725090b417e1532045a3da6df` [🧱 BLOCK 💎HydraGem💎 [v9.4a-test]](https://testexplorer.hydrachain.org/contract/0b1d3dafe4fc1ae725090b417e1532045a3da6df/)
- `220a2a7f47aef7f0ed38697264c623f5ce86c32d` [🪙 GCOIN 💎HydraGem💎 [v9.4a-test]](https://testexplorer.hydrachain.org/contract/220a2a7f47aef7f0ed38697264c623f5ce86c32d/)
- `28478e53763fa7745254fc8dbedf6ca18906709d` [🔥 FLAME 💎HydraGem💎 [v9.4a-test]](https://testexplorer.hydrachain.org/contract/28478e53763fa7745254fc8dbedf6ca18906709d/)

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
