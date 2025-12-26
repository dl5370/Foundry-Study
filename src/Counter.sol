// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

/**
 * @title Counter
 * @dev 简单的计数器合约示例
 */
contract Counter {
    uint256 public number;

    event NumberIncremented(uint256 newNumber);
    event NumberDecremented(uint256 newNumber);

    constructor() {
        number = 0;
    }

    /**
     * @dev 增加计数器
     */
    function increment() public {
        number++;
        emit NumberIncremented(number);
    }

    /**
     * @dev 减少计数器
     */
    function decrement() public {
        require(number > 0, "Number cannot be negative");
        number--;
        emit NumberDecremented(number);
    }

    /**
     * @dev 设置计数器值
     * @param _number 新的数值
     */
    function setNumber(uint256 _number) public {
        number = _number;
    }

    /**
     * @dev 获取当前计数值
     * @return 当前计数值
     */
    function getNumber() public view returns (uint256) {
        return number;
    }
}
