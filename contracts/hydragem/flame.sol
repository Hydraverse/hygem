// SPDX-License-Identifier: AGPLv3
pragma solidity >=0.5.4;

import "./coin.sol";


contract HydraGemFlameToken is HydraGemBaseToken {
    HydraGemCoinToken _coinToken;

    constructor(HydraGemCoinToken coinToken_, address owner_)
        HydraGemBaseToken(unicode"FLAME 🔥", unicode"🔥", coinToken_.gemToken(), owner_)
    {
        _coinToken = coinToken_;
    }

    receive() external payable virtual override {
        return mint(_msgSender(), gasleft());
    }

    function mint() public {
        return mint(_msgSender(), gasleft());
    }

    function mint(address to, uint256 amount) public virtual override {
        uint256 gas = 1;

        if (amount == 0) amount = gasleft();

        require(amount >= gasleft(), unicode"🔥: mint() should be called with starting gas value");

        if (to == address(0)) to = _msgSender();

        gas = amount - gasleft();

        if (gas > 0)
            _mint(to, gas);
    }

    function redeemable() public view returns (bool) {
        return address(this).balance > 0 || _coinToken.balanceOf(address(this)) > 0;
    }
    
    function redeemable(address redeemer) public view returns (bool) {
        if (redeemer == address(0))
            redeemer = _msgSender();
        
        return redeemable() && balanceOf(redeemer) > 0;
    }

    function redeem() public {
        return redeem(_msgSender(), 0);
    }

    function redeem(uint256 amount) public {
        return redeem(_msgSender(), amount);
    }

    function tryRedeem() public {
        return tryRedeem(0);
    }

    function tryRedeem(uint256 amount) public {
        return tryRedeem(_msgSender(), amount);
    }

    function tryRedeem(address redeemer) public onlyOwners {
        return tryRedeem(redeemer, 0);
    }

    function tryRedeem(address redeemer, uint256 amount) public onlyOwners {
        if (redeemable(redeemer)) {
            return redeem(redeemer, amount);
        }
    }

    function redeem(address redeemer) public onlyOwners {
        return redeem(redeemer, 0);
    }

    function redeem(address redeemer, uint256 amount) public onlyOwners {
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
                withdraw(address(_coinToken), balance);
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
