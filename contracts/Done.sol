// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Done is Ownable {
    IERC20 public projectToken; // Token của dự án
    IERC20 public stableCoin; // Coin stable sử dụng để quyên góp
    uint256 public tokenPrice; // Giá của token dự án
    uint256 public totalFunds; // Tổng số tiền quyên góp
    bool public fundingActive; // Trạng thái huy động vốn
    string public projectName; // Tên của dự án
    address[] public donorAddresses; // Danh sách địa chỉ của các nhà tài trợ
    address public tokenAdmin;

    // Cấu trúc lưu thông tin nhà tài trợ
    struct Donor {
        address donorAddress;      // Địa chỉ ví của nhà tài trợ
        uint256 stablecoinAmount;  // Số lượng Coin Stable mà nhà tài trợ đã gửi
        uint256 tokensReceived;    // Số lượng token mà nhà tài trợ đã nhận
    }
    
    mapping(address => Donor) public donors; // Lưu thông tin nhà tài trợ

    // Sự kiện ghi lại thông tin khi nhận được quỹ
    event FundReceived(address indexed donor, uint256 stablecoinAmount, uint256 tokensReceived);
    event FundsWithdrawn(uint256 amount); // Sự kiện ghi lại thông tin khi rút quỹ
    event FundingEnded(); // Sự kiện ghi lại thông tin khi kết thúc huy động vốn

    // Constructor khởi tạo hợp đồng với các tham số đầu vào
    constructor(IERC20 _projectToken, IERC20 _stableCoin, uint256 _tokenPrice, string memory _projectName) Ownable(msg.sender) {
        projectToken = _projectToken; // Khởi tạo token dự án
        stableCoin = _stableCoin; // Khởi tạo stablecoin
        tokenPrice = _tokenPrice; // Khởi tạo giá token
        projectName = _projectName; // Khởi tạo tên dự án
        fundingActive = true; // Kích hoạt trạng thái huy động vốn
        tokenAdmin = msg.sender; // Địa chỉ của người triển khai hợp đồng
        
    }

    // Modifier để chỉ cho phép nhà tài trợ gọi hàm
    modifier onlyDonor() {
        require(donors[msg.sender].stablecoinAmount > 0, "You are not a donor"); // Kiểm tra nếu địa chỉ gọi hàm là nhà tài trợ
        _;
    }
    modifier  checkAdmin(address tokenuser) {
 require(msg.sender == tokenuser, "Not an admin"); // Kiểm tra xem người gọi có phải là admin không
        _;
    }
    // Hàm cho phép nhà tài trợ quyên góp quỹ cho dự án
    function fundProject(uint256 stablecoinAmount) external {
        require(fundingActive, "Funding is not active"); // Kiểm tra nếu huy động vốn đang hoạt động
        require(stablecoinAmount > 0, "Amount must be greater than zero"); // Kiểm tra số lượng quyên góp phải lớn hơn 0

        // Chuyển stablecoin từ nhà tài trợ vào hợp đồng
        require(stableCoin.transferFrom(msg.sender, address(this), stablecoinAmount), "Transfer failed");

        // Tính toán số token sẽ phát hành dựa trên số tiền quyên góp và giá token
        uint256 tokensToIssue = (stablecoinAmount * 10**18) / tokenPrice;
        require(tokensToIssue > 0, "Insufficient amount for token issuance"); // Kiểm tra số token phát hành phải lớn hơn 0
        
        totalFunds += stablecoinAmount; // Cập nhật tổng quỹ quyên góp
        if (donors[msg.sender].stablecoinAmount == 0) {
            donorAddresses.push(msg.sender); // Thêm địa chỉ nhà tài trợ mới vào mảng
        }

        // Cập nhật thông tin nhà tài trợ
        donors[msg.sender].donorAddress = msg.sender; // Lưu địa chỉ nhà tài trợ
        donors[msg.sender].stablecoinAmount += stablecoinAmount; // Cập nhật số lượng stablecoin đã gửi
        donors[msg.sender].tokensReceived += tokensToIssue; // Cập nhật số lượng token đã nhận

        emit FundReceived(msg.sender, stablecoinAmount, tokensToIssue); // Phát sự kiện ghi nhận quỹ nhận được
    }

    // Hàm cho phép admin rút quỹ sau khi huy động vốn kết thúc
    function withdrawFunds() external onlyOwner {
        require(!fundingActive, "Funding is still active"); // Kiểm tra nếu huy động vốn đã kết thúc
        require(totalFunds > 0, "No funds to withdraw"); // Kiểm tra có quỹ để rút

        uint256 amount = totalFunds; // Lưu tổng quỹ để rút
        totalFunds = 0; // Đặt lại tổng quỹ về 0

        // Chuyển stablecoin đến chủ sở hữu
        require(stableCoin.transfer(owner(), amount), "Transfer failed"); // Kiểm tra chuyển khoản thành công
        emit FundsWithdrawn(amount); // Phát sự kiện ghi nhận quỹ đã rút
    }

    // Hàm kết thúc huy động vốn, chỉ admin mới có thể gọi
    function endFunding() external onlyOwner {
        fundingActive = false; // Đặt trạng thái huy động vốn thành không hoạt động
        emit FundingEnded(); // Phát sự kiện ghi nhận kết thúc huy động vốn
    }

    // Hàm cập nhật giá token, chỉ admin mới có thể gọi
    function updateTokenPrice(uint256 newPrice) external onlyOwner {
        tokenPrice = newPrice; // Cập nhật giá token
    }

    // Hàm lấy thông tin nhà tài trợ theo địa chỉ ví
    function getDonorInfo(address donor) external view returns (address, uint256, uint256) {
        return (donors[donor].donorAddress, donors[donor].stablecoinAmount, donors[donor].tokensReceived);
    }

    // Hàm lấy danh sách tất cả các nhà tài trợ
    function getAllDonors() external view returns (address[] memory) {
        return donorAddresses; // Trả về danh sách địa chỉ nhà tài trợ
    }

    // Hàm cho phép nhà tài trợ nhận token sau khi huy động vốn kết thúc
    function claimTokens() external onlyDonor {
        require(!fundingActive, "Funding is still active"); // Kiểm tra nếu huy động vốn đã kết thúc
        uint256 tokensToClaim = donors[msg.sender].tokensReceived; // Lấy số token nhà tài trợ đã nhận
        require(tokensToClaim > 0, "No tokens to claim"); // Kiểm tra nếu có token để nhận

        // Reset số token đã nhận để tránh việc rút lại
        donors[msg.sender].tokensReceived = 0;

        // Chuyển token cho nhà tài trợ
        require(projectToken.transfer(msg.sender, tokensToClaim), "Transfer failed"); // Kiểm tra chuyển khoản thành công
    }
}
