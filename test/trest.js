const done = artifacts.require("done");

contract("done", (accounts) => {
    let done;

    beforeEach(async () => {
        done = await done.new();
        // Nạp tiền vào hợp đồng để có số dư
        await done.sendTransaction({ from: accounts[0], value: web3.utils.toWei("1", "ether") });
    });

    it("should transfer 200000 wei to the specified address", async () => {
        const initialBalance = await web3.eth.getBalance(accounts[1]);
        
        // Gọi hàm transfer
        await done.transfer(accounts[1], { from: accounts[0] });
        
        const finalBalance = await web3.eth.getBalance(accounts[1]);
        const amountTransferred = web3.utils.toBN(finalBalance).sub(web3.utils.toBN(initialBalance));

        assert.equal(amountTransferred.toString(), "200000", "The amount transferred is not correct");
    });

    it("should emit a Transfer event", async () => {
        const result = await done.transfer(accounts[1], { from: accounts[0] });
        
        // Kiểm tra sự kiện đã được phát ra
        const event = result.logs[0];
        assert.equal(event.event, "Transfer", "The event emitted is not Transfer");
        assert.equal(event.args.from, accounts[0], "The from address is incorrect");
        assert.equal(event.args.to, accounts[1], "The to address is incorrect");
        assert.equal(event.args.amount.toString(), "200000", "The transferred amount is incorrect");
    });

    it("should fail if trying to transfer to a zero address", async () => {
        await expectRevert(
            done.transfer("0x0000000000000000000000000000000000000000", { from: accounts[0] }),
            "Invalid address"
        );
    });

    it("should fail if the contract has insufficient balance", async () => {
        // Tạo một hợp đồng mới mà không có tiền
        const newdone = await done.new();
        await expectRevert(
            newdone.transfer(accounts[1], { from: accounts[0] }),
            "Insufficient balance in contract"
        );
    });
});
