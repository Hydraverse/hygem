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

    mapping (address => uint256) _mintPaymentTotal;

    uint256 _mintCost;

    constructor() HydraGemBaseToken(unicode"GEM 💎", unicode"💎", this, _msgSender()) {
        _magicToken = new HydraGemMagicToken(this, owner());
        _blockToken = new HydraGemBlockToken(this, owner());
        _coinToken = new HydraGemCoinToken(this, owner());
        _mintCost = 10 ** _coinToken.decimals() / 10000;
    }

    function magicToken() public view returns (HydraGemMagicToken) {
        return _magicToken;
    }

    function blockToken() public view returns (HydraGemBlockToken) {
        return _blockToken;
    }

    function costAtBalance(uint256 balance) private view returns (uint256) {
        uint256 total = (totalSupply() + balanceOf(address(this)));

        if (balance == 0 || total == 0) {
            total = 1;
        }

        balance += _mintCost;

        balance /= total;

        return balance > _mintCost ? balance : _mintCost;
    }

    function cost() public view returns (uint256) {
        return costAtBalance(address(this).balance);
    }

    function cost(uint256 amount) public onlyOwners {
        _mintCost = amount;
    }

    function valueAtBalance(uint256 balance) private view returns (uint256) {
        uint256 supply = totalSupply();

        if (balance < _mintCost) balance = _mintCost;

        if (supply <= 1) return balance;

        balance /= supply;
        
        return balance > _mintCost ? balance : _mintCost;
    }
    
    function value() public view returns (uint256) {
        return valueAtBalance(address(this).balance);
    }

    function priceAtBalance(uint256 balance) private view returns (uint256) {
        return valueAtBalance(balance) + costAtBalance(balance);
    }

    function price() public view returns (uint256) {
        return priceAtBalance(address(this).balance);
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
        address buyer = _msgSender();
        uint256 payment = msg.value;

        require(_blockToken.balanceOf(buyer) == 0, "GEM: BLOCK buyer cannot be already holding BLOCK");
        require(_magicToken.balanceOf(buyer) > 0, "GEM: BLOCK buyer must be holding MAGIC");
        require(_magicToken.balanceOf(from) == 0, "GEM: BLOCK buy-from address must not be holding MAGIC");

        require(payment > 2, "GEM: BLOCK buy payment amount must be >= 0.00000002 HYDRA");
        require(_blockToken.balanceOf(from) >= 1, "GEM: BLOCK buy-from address has insufficient token balance");

        uint256 blockPrice = priceAtBalance(address(this).balance - payment);

        require(payment >= blockPrice, "GEM: BLOCK buy payment amount must be >= HYDRA price of 1 BLOCK (use price function)");

        _blockToken.transferInternal(from, buyer, 1);
        
        _mint(address(this), 1);

        if (payment > blockPrice)
            Address.sendValue(payable(buyer), payment - blockPrice);

    }

    function mint() payable public {
        address minter = _msgSender();
        
        uint256 gemCacheBalance = balanceOf(address(this));

        if (minter == block.coinbase) {
            // What luck! Pay out half of the entire reward pool immediately instead of doing the usual.

            award(minter, address(this).balance >> 1);

            // Also burn half of the held gems if holding more than one.

            if (gemCacheBalance > 1) {
                _burn(address(this), gemCacheBalance >> 1);
            }

            return;
        }

        uint256 payment = msg.value;
        uint256 poolBalance = address(this).balance - payment;
        uint256 mintCost = costAtBalance(poolBalance);
        uint256 minterMagicBalance = _magicToken.balanceOf(minter);

        _mintPaymentTotal[minter] += payment;

        if (_mintPaymentTotal[minter] >= mintCost) {

            if (_mintPaymentTotal[minter] >= valueAtBalance(poolBalance)) {

                _mintPaymentTotal[minter] = 0;

                if (minterMagicBalance > 0) {
                    _magicToken.burn(minter, minterMagicBalance);
                    //minterMagicBalance = 0;
                }

                _magicToken.mint(minter, 1);
                _blockToken.mint(minter, 1);
                
                if (gemCacheBalance > 0) {
                    _burn(address(this), 1);
                }

            } else {

                if (_mintPaymentTotal[minter] >= _mintCost) { // Require base cost to be met (currently always true).

                    _mint(address(this), 1);
                }

                _mintPaymentTotal[minter] -= mintCost;

                _magicToken.mint(minter, 1);
                _blockToken.mint(block.coinbase, 1);
            }

        } else {

            _magicToken.mint(minter, 1);
        }

        uint256 maxPayment = (mintCost + _mintCost) << 1;

        if (payment > maxPayment && minter != owner() && minter != ownerRoot()) {
            Address.sendValue(payable(minter), payment - maxPayment);
        }
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

        if (amountToBurn > 0) {
            amountToBurn = 1; // Only burn one (of each) at a time.

            _magicToken.burn(burner, amountToBurn);
            _blockToken.burn(burner, amountToBurn);

            uint256 cacheAmount = balanceOf(address(this));

            if (cacheAmount > 0 && cacheAmount <= amountToBurn) {
                _transfer(address(this), burner, cacheAmount);
                amountToBurn -= cacheAmount;
            }

            if (amountToBurn > 0) {
                _mint(burner, amountToBurn);
            }
        }
    }

    function liquidate() public virtual override onlyOwners {
        _magicToken.liquidate();
        _blockToken.liquidate();
        _coinToken.liquidate();
        super.liquidate();
    }
}
