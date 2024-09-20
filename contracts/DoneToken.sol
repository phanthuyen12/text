// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract DoneToken is Ownable {
    IERC20 public projectToken; // Token của dự án
    IERC20 public stableCoin; // Coin stable sử dụng để quyên góp
    uint256 public rateToken; // Tỉ lệ quy đổi
    uint256 public totalStableCoins; // Tổng số Coin Stable đã nhận
    bool public fundingActive; // Trạng thái huy động vốn
    string public nameToken; // Tên token
    address public admin; // Địa chỉ admin

    struct Sponsor {
        address addr; // Địa chỉ nhà tài trợ
        uint256 stableCoinAmount; // Số lượng Coin Stable mà nhà tài trợ đã gửi
        uint256 tokensReceived; // Số lượng token mà nhà tài trợ đã nhận
    }

    mapping(address => Sponsor) public sponsors;

    event FundReceived(address indexed sponsor, uint256 stableCoin, uint256 tokensReceived);
    event FundsWithdrawn(uint256 amount);
    event FundingStatusUpdated(bool status);
    event TokensClaimed(uint256 tokensToClaim);

    constructor(
        IERC20 _projectToken,
        IERC20 _stableCoin,
        uint256 _rateToken,
        string memory _nameToken,
        address _admin // Nhận địa chỉ admin trong constructor
    ) Ownable(msg.sender) {
        projectToken = _projectToken;
        stableCoin = _stableCoin;
        rateToken = _rateToken;
        nameToken = _nameToken;
        fundingActive = true; // Kích hoạt trạng thái huy động vốn
    }


    function fundProject(uint256 stablecoinAmount) external {
        require(fundingActive, "Funding not active");
        require(stablecoinAmount > 0, "Amount must be greater than zero");
        require(rateToken > 0, "Rate must be greater than zero");

        require(stableCoin.transferFrom(msg.sender, address(this), stablecoinAmount), "Transfer failed");

        uint256 tokensToIssue = (stablecoinAmount * 10 ** 18) / rateToken;
        require(tokensToIssue > 0, "Insufficient amount for token issuance");

        totalStableCoins += stablecoinAmount;
        sponsors[msg.sender].addr = msg.sender;
        sponsors[msg.sender].stableCoinAmount += stablecoinAmount;
        sponsors[msg.sender].tokensReceived += tokensToIssue;

        emit FundReceived(msg.sender, stablecoinAmount, tokensToIssue);
    }

    function withdrawFunds() external onlyOwner {
        require(!fundingActive, "Funding is still active");
        require(totalStableCoins > 0, "No funds to withdraw");

        uint256 amount = totalStableCoins;
        totalStableCoins = 0;

        require(stableCoin.transfer(owner(), amount), "Transfer failed");
        emit FundsWithdrawn(amount);
    }

    function endFunding() external onlyOwner(){
        fundingActive = false;
        emit FundingStatusUpdated(fundingActive);
    }

    function claimTokens() external {
        require(!fundingActive, "Funding is still active");
        
        uint256 tokensToClaim = sponsors[msg.sender].tokensReceived;
        require(tokensToClaim > 0, "No tokens to claim");

        sponsors[msg.sender].tokensReceived = 0;

        require(projectToken.transfer(msg.sender, tokensToClaim), "Transfer failed");
        emit TokensClaimed(tokensToClaim);
    }

    function changeAdmin(address newAdmin) external onlyOwner {
        admin = newAdmin; // Chỉ chủ sở hữu mới có thể thay đổi admin
    }

    function someAdminFunction() external onlyAdmin {
        // Hành động dành riêng cho admin
    }
}
