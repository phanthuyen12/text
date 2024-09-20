import React from 'react';
import { BrowserRouter as Router, Route, Routes, Link } from 'react-router-dom';
import FundForm from './components/FundForm';
import AdminPanel from './components/AdminPanel';
import 'bootstrap/dist/css/bootstrap.min.css';

const App = () => {
    const contractAddress = '0xD6D99ee3Cf1a875dC81B9725e71b178F336BfC62'; // Địa chỉ hợp đồng của bạn

    return (
        <Router>
            <div className="container">
                <h1 className="text-center my-4">Science Funding DApp</h1>
                <nav className="navbar navbar-expand-lg navbar-light bg-light mb-4">
                    <div className="container-fluid">
                        <Link className="navbar-brand" to="/">DApp</Link>
                        <button className="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#navbarNav" aria-controls="navbarNav" aria-expanded="false" aria-label="Toggle navigation">
                            <span className="navbar-toggler-icon"></span>
                        </button>
                        <div className="collapse navbar-collapse" id="navbarNav">
                            <ul className="navbar-nav">
                                <li className="nav-item">
                                    <Link className="nav-link" to="/">Quyên góp</Link>
                                </li>
                                <li className="nav-item">
                                    <Link className="nav-link" to="/admin">Quản trị</Link>
                                </li>
                            </ul>
                        </div>
                    </div>
                </nav>

                <div className="card p-4">
                    <Routes>
                        <Route path="/" element={<FundForm contractAddress={contractAddress} />} />
                        <Route path="/admin" element={<AdminPanel contractAddress={contractAddress} />} />
                    </Routes>
                </div>
            </div>
        </Router>
    );
};

export default App;
