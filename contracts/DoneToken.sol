// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
contract DoneToken is Ownable {
    IERC20 public projectToken; // Token của dự án
    IERC20 public stableCoin; // Coin stable sử dụng để quyên góp
    uint256 public rateToken;
    uint256 public totalNumberToken;
    bool public fundingActive;
    string public NameToken;
    struct Sponsors {
        address addressSponsors;
        uint256 stablecoinAmount; // Số lượng Coin Stable mà nhà tài trợ đã gửi
        uint256 tokensReceived; // Số lượng token mà nhà tài trợ đã nhận
    }
    mapping(address => Sponsors) public sponsors;
    event FundReceived(address indexed sponsors, uint256 stableCoin,uint256 tokensReceived);
    event FundsWithdrawn(uint256 amount);
    event StatusFunding();
    event StatusClaimTokens(uint256 tokensToClaim);
    constructor(
        IERC20 _projectToken,
        IERC20 _stableCoin,
        uint256 _rateToken,
        string memory _NameToken
    ) Ownable(msg.sender) {
        projectToken = _projectToken;
        stableCoin = _stableCoin;
        NameToken = _NameToken;
        fundingActive = true; // Kích hoạt trạng thái huy động vốn
    }
    function fundProject(uint256 stablecoinAmount) external {
        require(fundingActive, "funing not active");
        require(stablecoinAmount > 0, "Amount must be greater than zero"); // Kiểm tra số lượng quyên góp phải lớn hơn 0
        require(
            stableCoin.transferFrom(
                msg.sender,
                address(this),
                stablecoinAmount
            ),
            "Transfer failed"
        );
        uint256 tokensToIssue = (stablecoinAmount * 10 ** 18) / rateToken;
        require(tokensToIssue > 0, "Insufficient amount for token issuance");
        totalNumberToken += stablecoinAmount;
        sponsors[msg.sender].addressSponsors = msg.sender;
        sponsors[msg.sender].stablecoinAmount += stablecoinAmount;
        sponsors[msg.sender].tokensReceived += tokensToIssue;
        emit FundReceived(msg.sender, stablecoinAmount, tokensToIssue); // Phát sự kiện ghi nhận quỹ nhận được

    }
    function withdrawFunds() external onlyOwner {
        require(!fundingActive, "Funding is still active");
        require(totalNumberToken > 0, "no fund to withdraw");
        uint256 amount = totalNumberToken;
        totalNumberToken = 0;
        require(stableCoin.transfer(owner(), amount));
        emit FundsWithdrawn(amount);
    }
    function endFunds() external onlyOwner {
        fundingActive = false;
        emit StatusFunding();
    }
    function claimTokens() external {
        require(!fundingActive, "Funding is still active"); // Kiểm tra nếu huy động vốn đã kết thúc
        uint256 tokensToClaim = sponsors[msg.sender].tokensReceived; // Lấy số token nhà tài trợ đã nhận

        require(tokensToClaim > 0, "No tokens to claim"); // Kiểm tra nếu có token để nhận
        sponsors[msg.sender].tokensReceived = 0;

        // Chuyển token cho nhà tài trợ
        require(
            projectToken.transfer(msg.sender, tokensToClaim),
            "Transfer failed"
        ); // Kiểm tra chuyển khoản thành côngs
        emit StatusClaimTokens(tokensToClaim);
    }
}
