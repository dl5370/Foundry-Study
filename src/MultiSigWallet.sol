// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

interface IERC20 {
    function transfer(address to, uint256 value) external returns (bool);
    function transferFrom(address from, address to, uint256 value) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
}

contract MultiSigWallet {
    event Deposit(address indexed sender, uint amount);
    event ERC20Deposit(address indexed token, address indexed sender, uint amount);
    event SubmitTransaction(uint indexed txId, address indexed token, address indexed to, uint value, bytes data);
    event ConfirmTransaction(address indexed owner, uint indexed txId);
    event RevokeConfirmation(address indexed owner, uint indexed txId);
    event ExecuteTransaction(uint indexed txId);

    address[] public owners;
    mapping(address => bool) public isOwner;
    uint public required;

    struct Transaction {
        address token; // address(0) for ETH, otherwise ERC20
        address to;
        uint value;
        bytes data;
        bool executed;
        uint numConfirmations;
    }

    Transaction[] public transactions;
    mapping(uint => mapping(address => bool)) public confirmations;

    modifier onlyOwner() {
        require(isOwner[msg.sender], "not owner");
        _;
    }

    modifier txExists(uint _txId) {
        require(_txId < transactions.length, "tx does not exist");
        _;
    }

    modifier notExecuted(uint _txId) {
        require(!transactions[_txId].executed, "tx already executed");
        _;
    }

    modifier notConfirmed(uint _txId) {
        require(!confirmations[_txId][msg.sender], "tx already confirmed");
        _;
    }

    constructor(address[] memory _owners, uint _required) {
        require(_owners.length > 0, "owners required");
        require(_required > 0 && _required <= _owners.length, "invalid required number");
        for (uint i = 0; i < _owners.length; i++) {
            address owner = _owners[i];
            require(owner != address(0), "invalid owner");
            require(!isOwner[owner], "owner not unique");
            isOwner[owner] = true;
            owners.push(owner);
        }
        required = _required;
    }

    receive() external payable {
        emit Deposit(msg.sender, msg.value);
    }

    function submitTransaction(address token, address to, uint value, bytes memory data) public onlyOwner {
        uint txId = transactions.length;
        transactions.push(Transaction({
            token: token,
            to: to,
            value: value,
            data: data,
            executed: false,
            numConfirmations: 0
        }));
        emit SubmitTransaction(txId, token, to, value, data);
    }

    function confirmTransaction(uint txId) public onlyOwner txExists(txId) notExecuted(txId) notConfirmed(txId) {
        confirmations[txId][msg.sender] = true;
        transactions[txId].numConfirmations += 1;
        emit ConfirmTransaction(msg.sender, txId);
    }

    function revokeConfirmation(uint txId) public onlyOwner txExists(txId) notExecuted(txId) {
        require(confirmations[txId][msg.sender], "tx not confirmed");
        confirmations[txId][msg.sender] = false;
        transactions[txId].numConfirmations -= 1;
        emit RevokeConfirmation(msg.sender, txId);
    }

    function executeTransaction(uint txId) public onlyOwner txExists(txId) notExecuted(txId) {
        Transaction storage txn = transactions[txId];
        require(txn.numConfirmations >= required, "cannot execute tx");
        txn.executed = true;
        if (txn.token == address(0)) {
            // ETH
            (bool success, ) = txn.to.call{value: txn.value}(txn.data);
            require(success, "eth tx failed");
        } else {
            // ERC20
            require(IERC20(txn.token).transfer(txn.to, txn.value), "erc20 tx failed");
        }
        emit ExecuteTransaction(txId);
    }

    // 查询函数
    function getOwners() public view returns (address[] memory) {
        return owners;
    }
    function getTransactionCount() public view returns (uint) {
        return transactions.length;
    }
    function getTransaction(uint txId) public view returns (
        address token, address to, uint value, bytes memory data, bool executed, uint numConfirmations
    ) {
        Transaction storage txn = transactions[txId];
        return (txn.token, txn.to, txn.value, txn.data, txn.executed, txn.numConfirmations);
    }
}
