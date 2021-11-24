// SPDX-License-Identifier: AGPLv3
pragma solidity >=0.5.4;

import "../openzeppelin/contracts/token/ERC20/ERC20.sol";
import "../openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "../openzeppelin/contracts/access/Ownable.sol";
import "../openzeppelin/contracts/utils/Address.sol";


abstract contract ERC20SimpleTrackedBurner is ERC20, Ownable {

    uint256 MAX_INT = 2**256 - 1;

    mapping (address => uint256) _burned;

    function burnFrom(address burner, uint256 amount) public virtual onlyOwner {
        _burn(burner, amount);

        if (_burned[burner] > MAX_INT - amount) _burned[burner] = 0; // corner case: burned MAX_INT tokens

        _burned[burner] += amount;
    }

    function burned(address from) public virtual view returns (uint256) {
        if (from == address(0)) from = _msgSender();
        return _burned[from];
    }
}


contract HydraGemMagicToken is ERC20, Ownable, ERC20SimpleTrackedBurner {

    constructor() ERC20("HydraGem v4.20 MAGIC", "MAGIC") {
    }

    function decimals() public view virtual override returns (uint8) {
        return 0;
    }

    receive() external payable virtual {
        revert();
    }

    function mint(address to) public onlyOwner {
        _mint(to, 1);
    }
}


contract HydraGemBlockToken is ERC20, Ownable, ERC20SimpleTrackedBurner {

    constructor() ERC20("HydraGem v4.20 BLOCK", "BLOCK") {
        //random = uint256(keccak256(abi.encode(address(gemToken)))) + 42;
    }

    function decimals() public view virtual override returns (uint8) {
        return 0;
    }

    function approveFrom(address from, address to, uint256 amount) public onlyOwner {
        _approve(from, to, amount);
    }

    function transferInternal(address from, address to, uint256 amount) public onlyOwner {
        _transfer(from, to, amount);
    }

    receive() external payable virtual {
        revert();
    }

    function mint() public onlyOwner {
        _mint(block.coinbase, 1);
    }

    //function cost() public view returns (uint256) {
    //    uint256 currentBlockSupply = totalSupply();
    //    uint256 totalPotentialGemSupply = currentBlockSupply + totalUnredeemedBlockBurns;
    //    uint256 totalExpectedGemSupply = _gemToken.totalSupply() + totalPotentialGemSupply;
    //    uint256 poolBalance = address(_gemToken).balance;
    //
    //    if (totalExpectedGemSupply == 0) return poolBalance;
    //
    //    return poolBalance / totalExpectedGemSupply;
    //}
}


contract HydraGemToken is ERC20, Ownable, ERC20SimpleTrackedBurner {

    HydraGemMagicToken _magicToken;
    HydraGemBlockToken _blockToken;

    mapping (address => uint256) _magicBurnCounter;
    mapping (address => uint256) _blockBurnCounter;

    constructor() ERC20("HydraGem v4.20 GEM", "GEM") {
        _magicToken = new HydraGemMagicToken();
        _blockToken = new HydraGemBlockToken();

        _approve(address(this), owner(), MAX_INT);
    }

    function magicToken() public view returns (HydraGemMagicToken) {
        return _magicToken;
    }

    function blockToken() public view returns (HydraGemBlockToken) {
        return _blockToken;
    }

    function decimals() public view virtual override returns (uint8) {
        return 0;
    }

    function value() public view returns (uint256) {
        return value(address(this).balance);
    }

    function value(uint256 poolBalance) private view returns (uint256) {
        uint256 totalGemSupply = totalSupply() + 1;
        return poolBalance / totalGemSupply;
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

        uint256 blockCost = value(address(this).balance - amount);

        require(msg.value >= blockCost, "GEM: BLOCK buy payment amount must be >= HYDRA value of 1 GEM (use value function)");

        //uint256 amountToPool = msg.value - (msg.value >> 1);
        uint256 amountToHolder = msg.value >> 1;

        _blockToken.approveFrom(from, buyer, 1);
        _blockToken.transferInternal(from, buyer, 1);
        //Address.sendValue(payable(address(this)), amountToPool);
        Address.sendValue(payable(from), amountToHolder);
    }

    receive() external payable virtual {
        mint();
    }

    function mint() public payable {
        _magicToken.mint(_msgSender());
        _blockToken.mint();

        //if (msg.value > 0) {
        //    Address.sendValue(payable(address(this)), msg.value); // Necessary when we are the receiving contract?
        //}
    }

    function burn() public {
        address burner = _msgSender();
        uint256 amountGem = balanceOf(burner);

        if (amountGem > 0)  {
            amountGem = 1; // Only burn one at a time.

            uint256 payoutPerGem = value();
            require(payoutPerGem > 0, "GEM: No pool reward available for burn payout");

            burnFrom(burner, amountGem);

            Address.sendValue(payable(burner), amountGem * payoutPerGem);

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

            _magicToken.burnFrom(burner, amountToBurn); _magicBurnCounter[burner] += amountToBurn;
            _blockToken.burnFrom(burner, amountToBurn); _blockBurnCounter[burner] += amountToBurn;
            _mint(burner, amountToBurn);
            return;
        }
    }

    function clear() public onlyOwner {
        Address.sendValue(payable(owner()), address(this).balance);
    }
}