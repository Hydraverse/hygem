// SPDX-License-Identifier: AGPLv3
pragma solidity >=0.5.4;

import "./base.sol";


contract HydraGemCoinToken is HydraGemBaseToken {

    constructor(HydraGemBaseToken gemToken_, address owner_) HydraGemBaseToken(unicode"HydraGem v7.77 💎 GEMCOIN 🪙", unicode"🪙", gemToken_, owner_) {
    }

    function decimals() public view virtual override returns (uint8) {
        return 8;
    }

    receive() external payable virtual override onlyOwners {
    }

    function buy() public payable {

        address buyer = _msgSender();
        uint256 amount = msg.value;

        if (amount > 0) {

            uint256 cacheAmount = balanceOf(address(this));

            if (cacheAmount > 0) {
                if (cacheAmount > amount)
                    cacheAmount = amount;

                _transfer(address(this), buyer, cacheAmount);
                amount -= cacheAmount;
            }

            if (amount > 0)
                _mint(buyer, amount);

        }
    }

    function sell(uint256 amount) public {
        redeem(_msgSender(), amount);
    }

    function redeem(address seller) public {
        redeem(seller, 0);
    }

    function redeem(address seller, uint256 amount) public {
        if (amount == 0) amount = balanceOf(seller);

        require(amount <= balanceOf(seller), "GEMCOIN: Sell amount exceeds balance");

        if (amount > 0) {
            _transfer(seller, address(this), amount);
            Address.sendValue(payable(seller), amount);
        }
    }
}
