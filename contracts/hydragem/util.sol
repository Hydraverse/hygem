// SPDX-License-Identifier: AGPLv3
pragma solidity >=0.5.4;

import "../../openzeppelin/contracts/token/ERC20/ERC20.sol";
import "../../openzeppelin/contracts/access/Ownable.sol";
import "../../openzeppelin/contracts/utils/Address.sol";


abstract contract ERC20SimpleTrackedBurner is ERC20 {

    mapping (address => uint256) _burned;

    function burnFrom(address burner, uint256 amount) internal virtual {
        if (amount == 0)
            amount = balanceOf(burner);

        _burn(burner, amount);
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
        liquidate(_msgSender());
    }

    function liquidate(address from) internal virtual onlyOwners {
        if (balanceOf(from) > 0)
            burnFrom(from, balanceOf(from));
    }
}

abstract contract OwnerAccountant is Context {

    function withdraw(address to, uint256 amount) internal {
        return Address.sendValue(payable(to), amount);
    }

    function withdraw(address to) internal {
        return Address.sendValue(payable(to), address(this).balance);
    }

    function withdraw(uint256 amount) internal {
        return Address.sendValue(payable(_msgSender()), amount);
    }

    function withdraw() internal {
        return Address.sendValue(payable(_msgSender()), address(this).balance);
    }

    function forward() internal {
        return forward(_msgSender());
    }

    function forward(address to) internal {
        return forward(to, address(this).balance);
    }

    function forward(address to, uint256 amount) internal {
        if (to != address(this) && amount > 0) {
            return withdraw(to, amount);
        }
    }
}
