const Done = artifacts.require("Done");
const ProjectToken = artifacts.require("ProjectToken"); // Thay 'YourTokenContract' bằng tên hợp đồng token của bạn

module.exports = async function (deployer) {
    // Triển khai hợp đồng token trước
    await deployer.deploy(ProjectToken);
    const projectToken = await ProjectToken.deployed();
    
    // Triển khai hợp đồng Done với địa chỉ token và giá token
    const tokenPrice = web3.utils.toWei("0.1", "ether"); // Thay đổi giá token nếu cần
    await deployer.deploy(Done, projectToken.address, tokenPrice);
};
