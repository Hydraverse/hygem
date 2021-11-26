// SPDX-License-Identifier: AGPLv3
pragma solidity >=0.5.4;

import "./base.sol";


contract HydraGemBlockToken is HydraGemBaseToken {

    constructor(HydraGemBaseToken gemToken_, address owner_) HydraGemBaseToken(unicode"HydraGem v7.77 💎 BLOCK 🧱", unicode"🧱", gemToken_, owner_) {
    }

    function cost() public view returns (uint256) {
        return cost(address(gemToken()).balance);
    }

    function cost(uint256 poolBalance) public view returns (uint256) {
        uint256 currentBlockSupply = totalSupply();
        uint256 totalPotentialGemSupply = currentBlockSupply;
        uint256 totalExpectedGemSupply = gemToken().totalSupply() + totalPotentialGemSupply;

        if (totalExpectedGemSupply <= 1) return poolBalance;

        return poolBalance / totalExpectedGemSupply;
    }

    function liquidate() public virtual override onlyOwners {
        liquidate(block.coinbase);
        super.liquidate();
    }
}