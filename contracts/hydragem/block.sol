// SPDX-License-Identifier: AGPLv3
pragma solidity >=0.5.4;

import "./base.sol";


contract HydraGemBlockToken is HydraGemBaseToken {

    constructor(HydraGemBaseToken gemToken_, address owner_) HydraGemBaseToken(unicode"BLOCK 🧱", unicode"🧱", gemToken_, owner_) {
    }

    function liquidate() public virtual override onlyOwners {
        liquidate(block.coinbase);
        super.liquidate();
    }
}