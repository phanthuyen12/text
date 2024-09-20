import Web3 from 'web3';

let web3;

if (window.ethereum) {
    // Kết nối với MetaMask
    web3 = new Web3(window.ethereum);
    try {
        // Yêu cầu người dùng cho phép kết nối
        await window.ethereum.request({ method: 'eth_requestAccounts' });
    } catch (error) {
        console.error("User denied account access", error);
    }
} else {
    alert('Please install MetaMask!');
}

export default web3;
