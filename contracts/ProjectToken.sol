// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract ProjectToken is ERC20 {
    constructor() ERC20("ProjectToken", "PGT") {
        _mint(msg.sender, 1000000 * 10 ** decimals()); // Mint 1 triệu token cho địa chỉ triển khai
    }
}
