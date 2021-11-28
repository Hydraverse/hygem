// SPDX-License-Identifier: AGPLv3
pragma solidity >=0.5.4;

import "./coin.sol";


contract HydraGemFlameToken is HydraGemBaseToken {
    HydraGemCoinToken _coinToken;

    uint256 _max = 1000000;
    uint256 _residual;

    constructor(HydraGemCoinToken coinToken_, address owner_)
        HydraGemBaseToken(unicode"🔥 FLAME", unicode"🔥", coinToken_.gemToken(), owner_)
    {
        _coinToken = coinToken_;
    }

    function max() public view returns (uint256) {
        return _max;
    }

    function max(uint256 max_) public onlyOwners {
        _max = max_;
    }

    function residual() public view returns (uint256) {
        return _residual;
    }

    receive() external payable virtual override {
        uint256 gas = gasleft();

        if (msg.value > 0)
            _withdraw(address(_coinToken), msg.value);

        mint(_msgSender(), gas);
    }

    function mint() public {
        return mint(_msgSender(), gasleft());
    }

    function mint(address to, uint256 amount) public virtual override {
        uint256 gas = gasleft();

        if (amount == 0) amount = gas;

        require(amount >= gasleft() && amount <= _max, unicode"🔥: mint() should be called with starting gas value or zero");

        if (to == address(0)) to = _msgSender();

        gas = amount - gasleft();

        if (gas > 0)
            _mint(to, gas);

        gas -= gasleft();

        _residual += gas;
    }

    function redeemable() public view returns (bool) {
        return address(this).balance > 0 || _coinToken.balanceOf(address(this)) > 0;
    }
    
    function redeemable(address redeemer) public view returns (bool) {
        if (redeemer == address(0))
            redeemer = _msgSender();
        
        return (balanceOf(redeemer) > 0) && redeemable();
    }

    function redeem() public {
        return _redeem(_msgSender(), 0);
    }

    function redeem(uint256 amount) public {
        return _redeem(_msgSender(), amount);
    }

    function tryRedeem() public {
        return tryRedeem(0);
    }

    function tryRedeem(uint256 amount) public {
        if (redeemable(_msgSender())) {
            return _redeem(_msgSender(), amount);
        }
    }

    function tryRedeemInternal(address redeemer) public onlyOwners {
        return tryRedeemInternal(redeemer, 0);
    }

    function tryRedeemInternal(address redeemer, uint256 amount) public onlyOwners {
        if (redeemable(redeemer)) {
            return _redeem(redeemer, amount);
        }
    }

    function redeemInternal(address redeemer, uint256 amount) public onlyOwners {
        return _redeem(redeemer, amount);
    }

    function _redeem(address redeemer, uint256 amount) private {
        if (redeemer == address(0))
            redeemer = _msgSender();

        if (amount == 0) amount = balanceOf(redeemer);

        require(amount <= balanceOf(redeemer), unicode"🔥: Redemption amount exceeds balance");

        if (amount == 0)
            return;

        uint256 coinBalance = _coinToken.balanceOf(address(this));
        uint256 balance = address(this).balance + coinBalance;
        uint256 supply = totalSupply();

        require(amount <= supply, unicode"🔥: Balance exceeds supply?!");
        require(balance > 0, unicode"🔥: No liquidity available for redemption");

        require((balance / supply) > 0, unicode"🔥: Liquidity level does not provide value");

        uint256 amountPayable = (amount * balance) / supply;

        do {
            if (coinBalance > amountPayable) {
                coinBalance = amountPayable;
            }

            if (coinBalance > 0) {
                burnFrom(redeemer, coinBalance);
                _coinToken.transferInternal(address(this), redeemer, coinBalance);
                amountPayable -= coinBalance;
                coinBalance = _coinToken.balanceOf(address(this));
            }

            balance = address(this).balance + coinBalance;

        } while (coinBalance > 0 && amountPayable > 0);

        require(balance == address(this).balance, unicode"🔥: Balance state check error");

        do {
            if (balance > amountPayable) {
                balance = amountPayable;
            }

            if (balance > 0) {
                burnFrom(redeemer, balance);
                _withdraw(address(_coinToken), balance);
                coinBalance = _coinToken.balanceOf(address(this));
                require(coinBalance >= balance, unicode"🔥: Could not properly acquire 🪙 liquidity");
                _coinToken.transferInternal(address(this), redeemer, coinBalance);
                amountPayable -= coinBalance;
            }

            balance = address(this).balance;

        } while (balance > 0 && amountPayable > 0);

        require(amountPayable == 0, unicode"🔥: Payout state check error");
    }
}
