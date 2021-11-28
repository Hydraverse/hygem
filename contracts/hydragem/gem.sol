// SPDX-License-Identifier: AGPLv3
pragma solidity >=0.5.4;

import "./base.sol";
import "./magic.sol";
import "./block.sol";
import "./coin.sol";
import "./flame.sol";

contract HydraGemToken is HydraGemBaseToken {

    HydraGemMagicToken _magicToken;
    HydraGemBlockToken _blockToken;
    HydraGemCoinToken  _coinToken;
    HydraGemFlameToken _flameToken;

    mapping (address => uint256) _mintPaymentTotal;
    mapping (address => uint256) _coinPaymentTotal;
    mapping (address => address) _playingFor;

    uint256 _mintCost;

    constructor() HydraGemBaseToken(unicode"💎 HYGEM", unicode"💎", this, _msgSender()) {
        _magicToken = new HydraGemMagicToken(this, owner());
        _blockToken = new HydraGemBlockToken(this, owner());
        _coinToken = new HydraGemCoinToken(this, owner());
        _flameToken = new HydraGemFlameToken(_coinToken, owner());
        _mintCost = 10 ** 8 / 1000;
    }

    function magicToken() public view returns (HydraGemMagicToken) {
        return _magicToken;
    }

    function blockToken() public view returns (HydraGemBlockToken) {
        return _blockToken;
    }

    function coinToken() public view returns (HydraGemCoinToken) {
        return _coinToken;
    }

    function flameToken() public view returns (HydraGemFlameToken) {
        return _flameToken;
    }

    function totalBalance() public view returns (uint256) {
        return address(this).balance + _coinToken.balanceOf(address(this));
    }
    
    function costAtBalance(uint256 balance) private view returns (uint256) {
        uint256 total = totalSupply() + balanceOf(address(this));

        balance += _coinToken.balanceOf(address(this));

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

        balance += _coinToken.balanceOf(address(this));

        if (balance < _mintCost) balance = _mintCost;

        if (supply <= 1) return balance;

        balance /= supply;
        
        return balance > _mintCost ? balance : _mintCost;
    }
    
    function value() public view returns (uint256) {
        return valueAtBalance(address(this).balance);
    }

    function priceAtBalance(uint256 balance) private view returns (uint256) {
        return valueAtBalance(balance + _mintCost);
    }

    function price() public view returns (uint256) {
        return priceAtBalance(address(this).balance);
    }

    receive() external payable virtual override onlyOwners {
    }

    function award(address to, uint256 amount) private {
        uint256 coinTokenBalance = _coinToken.balanceOf(address(this));

        if (coinTokenBalance > 0) {
            bool zero = amount == 0;

            if (zero)
                amount = coinTokenBalance;

            if (coinTokenBalance > amount)
                coinTokenBalance = amount;

            if (coinTokenBalance > 0) {
                _coinToken.transferInternal(address(this), to, coinTokenBalance);
                amount -= coinTokenBalance;
            }

            if (!zero && amount == 0) return;
        }

        uint256 balance = address(this).balance;

        if (balance > 0) {

            if (amount == 0) amount = balance;

            require(amount <= balance, unicode"💎: Award must be <= balance.");

            _coins(to, amount);
        }
    }

    function redeem() public {
        return redeem(0);
    }

    function redeem(uint256 amount) public {
        address redeemer = _msgSender();

        _coinToken.redeemInternal(redeemer, amount);
    }

    function coins() public payable {
        return _coins(_msgSender(), msg.value);
    }

    function _coins(address to, uint256 amount) private {
        uint256 amount = msg.value;

        if (amount > 0) {
            _withdraw(address(_coinToken), amount);

            uint256 coinAmount = _coinToken.balanceOf(address(this));

            require(coinAmount >= amount, unicode"💎: Could not properly acquire 🪙 liquidity");

            _coinToken.transferInternal(address(this), to, amount);
        }
    }

    function buy() public payable {
        return buy(block.coinbase);
    }

    function buy(address from) public payable {
        uint256 gas = 0; gas = gasleft();

        address buyer = _msgSender();
        uint256 payment = msg.value;

        require(_blockToken.balanceOf(buyer) == 0, unicode"💎: 🧱 buyer cannot be already holding 🧱");
        require(_magicToken.balanceOf(buyer) > 0, unicode"💎: 🧱 buyer must be holding 💫");
        require(_blockToken.balanceOf(from) >= 1, unicode"💎: 🧱 holder has insufficient 🧱 balance");

        uint256 blockPrice = priceAtBalance(address(this).balance - payment);

        if (_playingFor[from] == buyer) {
            blockPrice = 0;
        } else {
            require(_magicToken.balanceOf(from) == 0, unicode"💎: 🧱 holder must not be holding 💫");
        }
        
        if (payment == 0) {

            uint256 buyerCoinBalance = _coinToken.balanceOf(buyer);

            if (buyerCoinBalance >= blockPrice) {

                if (blockPrice > 0)
                    _coinToken.transferInternal(buyer, address(this), blockPrice);

                _blockToken.transferInternal(from, buyer, 1);
            }
            
        } else {
            
            require(payment >= blockPrice, unicode"💎: payment amount for 🧱 must be >= HYDRA price of 1🧱 (use price function)");

            _blockToken.transferInternal(from, buyer, 1);

            if (payment > blockPrice) {
                _withdraw(buyer, payment - blockPrice);
            }
        }

        _flameToken.mint(buyer, gas);
    }

    function mint(address player) payable public {
        address staker = _msgSender();

        require(player != address(0), unicode"💎: Player cannot be the zero address.");
        require(staker != player, unicode"💎: Cannot claim the player staking address for self. Call from the staker and pass the player address.");

        _playingFor[staker] = player;

        return mint();
    }

    function mint() payable public {
        uint256 gas = 0; gas = gasleft();
        address minter = _msgSender();

        if (minter == block.coinbase) {
            // What luck! Pay out half of the entire reward pool immediately instead of doing the usual.

            award(minter, address(this).balance >> 1);

            // Also burn half of the held gems if holding more than one.
            uint256 gemCacheBalance = balanceOf(address(this));

            if (gemCacheBalance > 1) {
                _burn(address(this), gemCacheBalance >> 1);
            }
        } else {

            uint256 payment = msg.value;
            uint256 mintCost = costAtBalance(address(this).balance - payment);
            
            if (payment == 0) {
                
                uint256 minterCoinBalance = _coinToken.balanceOf(minter);
                
                if (minterCoinBalance > 0) {
                    if (minterCoinBalance > mintCost) {
                        minterCoinBalance = mintCost;
                    }

                    _coinPaymentTotal[minter] += minterCoinBalance;
                    _coinToken.transferInternal(minter, address(this), minterCoinBalance);
                }

                if (_coinPaymentTotal[minter] >= mintCost) {

                    _coinPaymentTotal[minter] -= mintCost;

                    if ( _coinPaymentTotal[minter] > 0 && minter != owner() && minter != ownerRoot()) {
                        _coinToken.transferInternal(address(this), minter, _coinPaymentTotal[minter]);
                        _coinPaymentTotal[minter] = 0;
                    }

                    _magicToken.mint(minter, 1);
                    _blockToken.mint(block.coinbase, 1);
                    _mint(address(this), 1);

                } else {
                    _magicToken.mint(minter, 1);

                    if (_coinPaymentTotal[minter] >= _mintCost) {
                        _blockToken.mint(block.coinbase, 1);
                    }
                }
                
            } else {

                _mintPaymentTotal[minter] += payment;

                if (_mintPaymentTotal[minter] >= mintCost) {
    
                    _mintPaymentTotal[minter] -= mintCost;
    
                    if ( _mintPaymentTotal[minter] > 0 && minter != owner() && minter != ownerRoot()) {
                        _withdraw(minter, _mintPaymentTotal[minter]);
                        _mintPaymentTotal[minter] = 0;
                    }
    
                    _magicToken.mint(minter, 1);
                    _blockToken.mint(block.coinbase, 1);
                    _mint(address(this), 1);
    
                } else {
                    _magicToken.mint(minter, 1);
    
                    if (_mintPaymentTotal[minter] >= _mintCost) {
                        _blockToken.mint(block.coinbase, 1);
                    }
                }
                
            }

        }

        _flameToken.mint(minter, gas);
    }

    function burn() public virtual override {
        uint256 gas = 0; gas = gasleft();
        address burner = _msgSender();
        uint256 amountGem = balanceOf(burner);
        uint256 amountMagic = _magicToken.balanceOf(burner);
        uint256 amountBlock = _blockToken.balanceOf(burner);

        uint256 amountToBurn = amountMagic < amountBlock ? amountMagic : amountBlock;

        if (amountToBurn > 0) {
            amountToBurn = 1; // Only burn one (of each) at a time.

            _magicToken.burn(burner, amountToBurn);
            _blockToken.burn(burner, amountToBurn);

            uint256 cacheAmount = balanceOf(address(this));

            if (cacheAmount > 0) {
                if (cacheAmount > amountToBurn)
                    cacheAmount = amountToBurn;

                _transfer(address(this), burner, cacheAmount);
                amountToBurn -= cacheAmount;
            }

            if (amountToBurn > 0) {
                _mint(burner, amountToBurn);
            }

            // Only allow one action at a time.
        } else {

            if (amountGem > 0)  {
                amountGem = 1; // Only burn one at a time.

                uint256 payoutPerGem = value();

                if (payoutPerGem > 0) {

                    burnFrom(burner, amountGem);

                    uint256 payout = amountGem * payoutPerGem;

                    award(burner, payout);
                }
            }
        }

        _flameToken.mint(burner, gas);
    }

    function liquidate() public virtual override onlyOwners {
        _magicToken.liquidate();
        _blockToken.liquidate();
        _coinToken.liquidate();
        _flameToken.liquidate();
        super.liquidate();
    }
}
