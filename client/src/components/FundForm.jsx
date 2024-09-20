import React, { useState } from 'react';
import Web3 from 'web3';
import ScienceFunding from '../../../build/contracts/Done.json'; // Đường dẫn đến ABI

const FundForm = ({ contractAddress }) => {
    const [amount, setAmount] = useState('');
    const [message, setMessage] = useState('');

    const handleFundProject = async () => {
        if (!amount) return;

        const web3 = new Web3(window.ethereum);
        const accounts = await web3.eth.requestAccounts();
        const contract = new web3.eth.Contract(ScienceFunding.abi, contractAddress);

        try {
            // Gửi giao dịch và chờ xác nhận
            await contract.methods.fundProject(Web3.utils.toWei(amount, 'ether')).send({ from: accounts[0] });
            setMessage('Quyên góp thành công!');
        } catch (error) {
            setMessage('Đã xảy ra lỗi: ' + error.message);
        }
    };

    return (
        <div className="card p-4">
            <h2 className="card-title">Quyên góp cho Dự án</h2>
            <div className="mb-3">
                <input
                    type="text"
                    className="form-control"
                    placeholder="Số lượng Stablecoin"
                    value={amount}
                    onChange={(e) => setAmount(e.target.value)}
                />
            </div>
            <button className="btn btn-primary" onClick={handleFundProject}>Quyên góp</button>
            {message && <p className="mt-3">{message}</p>}
        </div>
    );
};

export default FundForm;
