// SPDX-License-Identifier: AGPLv3
pragma solidity >=0.5.4;

import "./base.sol";


contract HydraGemBlockToken is HydraGemBaseToken {

    constructor(HydraGemBaseToken gemToken_, address owner_) HydraGemBaseToken(unicode"BLOCK 🧱", unicode"🧱", gemToken_, owner_) {
    }

    function cost() public view returns (uint256) {
        return cost(address(gemToken()).balance);
    }

    function cost(uint256 poolBalance) public view returns (uint256) {
        uint256 supply = (gemToken().totalSupply() - gemToken().balanceOf(address(gemToken()))) + totalSupply();

        if (supply <= 1) return poolBalance;

        return poolBalance / supply;
    }

    function liquidate() public virtual override onlyOwners {
        liquidate(block.coinbase);
        super.liquidate();
    }
}