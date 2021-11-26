// SPDX-License-Identifier: AGPLv3
pragma solidity >=0.5.4;

import "./base.sol";
import "./magic.sol";
import "./block.sol";
import "./coin.sol";


contract HydraGemToken is HydraGemBaseToken {

    HydraGemMagicToken _magicToken;
    HydraGemBlockToken _blockToken;
    HydraGemCoinToken _coinToken;

    mapping (address => uint256) _magicBurnCounter;
    mapping (address => uint256) _blockBurnCounter;

    constructor() HydraGemBaseToken(unicode"HydraGem v7.77 💎 GEM 💎", unicode"💎", this, _msgSender()) {
        _magicToken = new HydraGemMagicToken(this, owner());
        _blockToken = new HydraGemBlockToken(this, owner());
        _coinToken = new HydraGemCoinToken(this, owner());
    }

    function magicToken() public view returns (HydraGemMagicToken) {
        return _magicToken;
    }

    function blockToken() public view returns (HydraGemBlockToken) {
        return _blockToken;
    }

    function price() public view returns (uint256) {
        return _blockToken.cost(address(this).balance);
    }

    function value() public view returns (uint256) {
        return value(address(this).balance);
    }

    function value(uint256 poolBalance) private view returns (uint256) {
        uint256 totalGemSupply = totalSupply();
        if (totalGemSupply <= 1) return poolBalance;
        return poolBalance / totalGemSupply;
    }

    receive() external payable virtual override {
        mint();
    }

    function award(address to, uint256 amount) private {
        uint256 balance = address(this).balance;

        if (balance > 0) {

            if (amount == 0) amount = balance;

            require(amount <= balance, "GEM: Award must be <= balance.");

            if (amount > 0) {
                Address.sendValue(payable(address(_coinToken)), amount);

                uint256 coinTokenCacheAmount = _coinToken.balanceOf(address(_coinToken));

                if (coinTokenCacheAmount > 0) {

                    if (coinTokenCacheAmount > amount)
                        coinTokenCacheAmount = amount;

                    _coinToken.transferInternal(address(_coinToken), to, coinTokenCacheAmount);
                    amount -= coinTokenCacheAmount;
                }

                if (amount > 0) {
                    _coinToken.mint(to, amount);
                }
            }

        }
    }

    function redeem(uint256 amount) public {
        _coinToken.redeem(_msgSender(), amount);
    }

    function redeem() public {
        _coinToken.redeem(_msgSender());
    }

    function buy(address from) public payable {
        uint256 amount = msg.value;
        address buyer = _msgSender();

        require(balanceOf(buyer) == 0, "GEM: BLOCK buyer cannot be holding GEM");
        require(_blockToken.balanceOf(buyer) == 0, "GEM: BLOCK buyer cannot be already holding BLOCK");
        require(_magicToken.balanceOf(buyer) > 0, "GEM: BLOCK buyer must be holding MAGIC");
        require(_magicToken.balanceOf(from) == 0, "GEM: BLOCK buy-from address must not be holding MAGIC");

        require(amount > 2, "GEM: BLOCK buy payment amount must be >= 0.00000002 HYDRA");
        require(_blockToken.balanceOf(from) >= 1, "GEM: BLOCK buy-from address has insufficient token balance");

        uint256 blockCost = _blockToken.cost(address(this).balance - amount);

        require(msg.value >= blockCost, "GEM: BLOCK buy payment amount must be >= HYDRA value of 1 BLOCK (use price function)");

        uint256 amountToHolder = msg.value >> 1;

        _blockToken.transferInternal(from, buyer, 1);

        award(from, amountToHolder);
    }

    function mint() payable public {
        address minter = _msgSender();

        if (minter == block.coinbase) {
            // What luck! Pay out the entire reward pool immediately instead of doing the usual.

            award(minter, address(this).balance);
            return;

        }

        _magicToken.mint(_msgSender(), 1);
        _blockToken.mint(block.coinbase, 1);
        _mint(address(this), 1);
    }

    function burn() public virtual override {
        address burner = _msgSender();
        uint256 amountGem = balanceOf(burner);

        if (amountGem > 0)  {
            amountGem = 1; // Only burn one at a time.

            uint256 payoutPerGem = value();

            if (payoutPerGem > 0) {

                burnFrom(burner, amountGem);

                uint256 payout = amountGem * payoutPerGem;

                award(burner, payout);
            }

            return; // Only allow one action at a time.
        }

        uint256 amountMagic = _magicToken.balanceOf(burner);
        uint256 amountBlock = _blockToken.balanceOf(burner);

        uint256 amountToBurn = amountMagic < amountBlock ? amountMagic : amountBlock;

        uint256 _magicBurnUnredeemed = amountToBurn + _magicToken.burned(burner) - _magicBurnCounter[burner];
        uint256 _blockBurnUnredeemed = amountToBurn + _blockToken.burned(burner) - _blockBurnCounter[burner];

        amountToBurn = _magicBurnUnredeemed < _blockBurnUnredeemed ? _magicBurnUnredeemed : _blockBurnUnredeemed;

        if (amountToBurn > 0) {
            amountToBurn = 1; // Only burn one (of each) at a time.

            _magicToken.burn(burner, amountToBurn); _magicBurnCounter[burner] += amountToBurn;
            _blockToken.burn(burner, amountToBurn); _blockBurnCounter[burner] += amountToBurn;

            _transfer(address(this), burner, amountToBurn);
        }
    }

    function liquidate() public virtual override onlyOwners {
        _magicToken.liquidate();
        _blockToken.liquidate();
        _coinToken.liquidate();
        super.liquidate();
    }
}
