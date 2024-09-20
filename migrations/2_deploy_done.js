const DoneToken = artifacts.require("DoneToken");
const ProjectToken = artifacts.require("ProjectToken");

module.exports = async function (deployer) {
    await deployer.deploy(ProjectToken);
    const projectTokenInstance = await ProjectToken.deployed();

    // Địa chỉ của coin stable với checksum
    const stableCoinAddress = web3.utils.toChecksumAddress("0xA0b86991c6218b36c1d19d4a2e9eb0ce3606eb48");
    const rateToken = 100; // Tỉ lệ quy đổi
    const nameToken = "Thuyememe"; // Tên token

    // Địa chỉ admin (thay đổi thành địa chỉ bạn muốn chỉ định làm admin)
    await deployer.deploy(DoneToken, projectTokenInstance.address, stableCoinAddress, rateToken, nameToken);
};
