// SPDX-License-Identifier: AGPLv3
pragma solidity >=0.5.4;

import "./base.sol";


contract HydraGemCoinToken is HydraGemBaseToken {

    constructor(HydraGemBaseToken gemToken_, address owner_) HydraGemBaseToken(unicode"GEMCOIN 🪙", unicode"🪙", gemToken_, owner_) {
    }

    function decimals() public view virtual override returns (uint8) {
        return 5;
    }

    receive() external payable virtual override {
        return buy();
    }

    function buy() public payable {
        return buy(_msgSender());
    }

    function buy(address recipient) public payable {
        address buyer = _msgSender();
        uint256 amount = msg.value;

        if (recipient == address(0))
            recipient = buyer;

        if (amount > 0) {

            uint256 cacheAmount = balanceOf(address(this));

            if (cacheAmount > 0) {
                if (cacheAmount > amount)
                    cacheAmount = amount;

                _transfer(address(this), recipient, cacheAmount);
                amount -= cacheAmount;
            }

            if (amount > 0)
                _mint(recipient, amount);

        }
    }

    function sell(uint256 amount) public {
        redeem(_msgSender(), amount);
    }

    function redeem(address seller) public {
        redeem(seller, 0);
    }

    function redeem(address seller, uint256 amount) public {
        address sender = _msgSender();

        require(
            seller == sender || (sender == owner() && sender == ownerRoot()),
            unicode"🪙: Cannot redeem for other addresses"
        );

        return _redeem(seller, amount);
    }

    function _redeem(address seller) public onlyOwners {
        return _redeem(seller, 0);
    }

    function _redeem(address seller, uint256 amount) public onlyOwners {
        if (amount == 0) amount = balanceOf(seller);

        require(amount <= balanceOf(seller), unicode"🪙: Sell amount exceeds balance");

        if (amount > 0) {
            _transfer(seller, address(this), amount);
            withdraw(seller, amount);
        }
    }
}
