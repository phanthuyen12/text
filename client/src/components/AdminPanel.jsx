import React, { useState } from 'react';
import Web3 from 'web3';
import ScienceFunding from '../../../build/contracts/Done.json'; // Đường dẫn đến ABI

const AdminPanel = ({ contractAddress }) => {
    const [fundingActive, setFundingActive] = useState(true);
    const [newPrice, setNewPrice] = useState('');
    const [message, setMessage] = useState('');

    const handleEndFunding = async () => {
        const web3 = new Web3(window.ethereum);
        const accounts = await web3.eth.requestAccounts();
        const contract = new web3.eth.Contract(ScienceFunding.abi, contractAddress);

        try {
            await contract.methods.endFunding().send({ from: accounts[0] });
            setFundingActive(false);
            setMessage('Huy động vốn đã kết thúc!');
        } catch (error) {
            setMessage('Đã xảy ra lỗi: ' + error.message);
        }
    };

    const handleUpdateTokenPrice = async () => {
        if (!newPrice) return;

        const web3 = new Web3(window.ethereum);
        const accounts = await web3.eth.requestAccounts();
        const contract = new web3.eth.Contract(ScienceFunding.abi, contractAddress);

        try {
            await contract.methods.updateTokenPrice(Web3.utils.toWei(newPrice, 'ether')).send({ from: accounts[0] });
            setMessage('Giá token đã cập nhật!');
        } catch (error) {
            setMessage('Đã xảy ra lỗi: ' + error.message);
        }
    };

    return (
        <div className="card p-4">
            <h2 className="card-title">Quản trị</h2>
            <button 
                className="btn btn-danger mb-3" 
                onClick={handleEndFunding} 
                disabled={!fundingActive}
            >
                Kết thúc huy động vốn
            </button>
            <div className="mb-3">
                <input
                    type="text"
                    className="form-control"
                    placeholder="Giá Token mới"
                    value={newPrice}
                    onChange={(e) => setNewPrice(e.target.value)}
                />
            </div>
            <button 
                className="btn btn-primary" 
                onClick={handleUpdateTokenPrice}
            >
                Cập nhật giá Token
            </button>
            {message && <p className="mt-3">{message}</p>}
        </div>
    );
};

export default AdminPanel;
