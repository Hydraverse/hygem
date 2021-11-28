// SPDX-License-Identifier: AGPLv3
pragma solidity >=0.5.4;

import "./base.sol";


contract HydraGemMagicToken is HydraGemBaseToken {

    constructor(HydraGemBaseToken gemToken_, address owner_) HydraGemBaseToken(unicode"💫 MAGIC", unicode"💫", gemToken_, owner_) {
    }
}
