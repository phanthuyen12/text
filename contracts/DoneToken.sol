// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
contract DoneToken is Ownable{
    IERC20 public projectToken; // Token của dự án
    IERC20 public stableCoin; // Coin stable sử dụng để quyên góp
    uint256 public rateToken;
    uint256 public totalNumberToken;
    string public NameToken;
    struct Sponsors {
        address addressSponsors;
        uint256 stablecoinAmount; // Số lượng Coin Stable mà nhà tài trợ đã gửi
        uint256 tokensReceived; // Số lượng token mà nhà tài trợ đã nhận
    }
    mapping (address=>Sponsors) public sponsors;
    
}
