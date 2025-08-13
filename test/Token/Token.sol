// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract Token is ERC20 {
    constructor() ERC20("Olympus-AI", "Olympus-AI") {
        _mint(msg.sender, 1000_000e18);
    }

    function mint(address to, uint256 amount) public {
        _mint(to, amount);
    }
}
