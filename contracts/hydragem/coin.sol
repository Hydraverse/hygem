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
        return buy(_msgSender());
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

    function sell() public {
        sell(0);
    }

    function sell(uint256 amount) public {
        _redeem(_msgSender(), amount);
    }

    function redeemInternal(address seller, uint256 amount) public onlyOwners {
        return _redeem(seller, amount);
    }

    function _redeem(address seller, uint256 amount) private {
        if (amount == 0) amount = balanceOf(seller);

        require(amount <= balanceOf(seller), unicode"🪙: Sell amount exceeds balance");

        if (amount > 0) {
            _transfer(seller, address(this), amount);
            _withdraw(seller, amount);
        }
    }
}
