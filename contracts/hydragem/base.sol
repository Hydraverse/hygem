// SPDX-License-Identifier: AGPLv3
pragma solidity >=0.5.4;

import "./util.sol";


abstract contract HydraGemBaseToken is ERC20OwnerLiquidator, OwnerAccountant {
    HydraGemBaseToken _gemToken;

    constructor (string memory name_, string memory symbol_, HydraGemBaseToken gemToken_, address owner_)
        ERC20(concat(name_, unicode" 💎HydraGem💎 [v9.3k-test]"), symbol_)
        DualOwnable(owner_)
    {
        _gemToken = gemToken_;
    }

    function concat(string memory a, string memory b) internal pure returns (string memory) {
        return string(abi.encodePacked(a, b));
    }

    function gemToken() public view returns (HydraGemBaseToken) {
        return _gemToken;
    }

    function decimals() public view virtual override returns (uint8) {
        return 0;
    }

    receive() external payable virtual {
        revert();
    }

    function transferInternal(address from, address to, uint256 amount) public onlyOwners {
        _transfer(from, to, amount);
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
}
