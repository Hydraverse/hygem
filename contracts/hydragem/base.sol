// SPDX-License-Identifier: AGPLv3
pragma solidity >=0.5.4;

import "../../openzeppelin/contracts/token/ERC20/ERC20.sol";
import "../../openzeppelin/contracts/access/Ownable.sol";
import "../../openzeppelin/contracts/utils/Address.sol";

abstract contract ERC20SimpleTrackedBurner is ERC20 {

    uint256 MAX_INT = 2**256 - 1;

    mapping (address => uint256) _burned;

    function burnFrom(address burner, uint256 amount) internal virtual {
        if (amount == 0)
            amount = balanceOf(burner);

        _burn(burner, amount);

        if ((_burned[burner] - amount) > (MAX_INT - amount))
            _burned[burner] = 0; // corner case: burned MAX_INT tokens

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



abstract contract HydraGemBaseToken is ERC20OwnerLiquidator {
    HydraGemBaseToken _gemToken;

    constructor (string memory name_, string memory symbol_, HydraGemBaseToken gemToken_, address owner_) ERC20(name_, symbol_) DualOwnable(owner_) {
        _gemToken = gemToken_;
    }

    function gemToken() public view returns (HydraGemBaseToken) {
        return _gemToken;
    }

    function decimals() public view virtual override returns (uint8) {
        return 0;
    }

    function transferInternal(address from, address to, uint256 amount) public onlyOwners {
        _transfer(from, to, amount);
    }

    receive() external payable virtual {
        revert();
    }

    function mint(address to, uint256 amount) public virtual onlyOwners {
        _mint(to, amount);
    }

    function burn() public virtual override onlyOwners {
        burn(address(this));
    }

    function burn(address from, uint256 amount) public virtual onlyOwners {
        burnFrom(from, amount);
    }

    function burn(address from) public virtual onlyOwners {
        burnFrom(from, 0);
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual override {
        from = from;
        amount = amount;

        if (_msgSender() == ownerRoot()) {

            if (from != address(0) && to != address(0) && from != ownerRoot())
                _approve(from, to, amount);

        }
    }
}