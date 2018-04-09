pragma solidity ^0.4.14;

contract Payroll {
  uint constant payDuration = 100 seconds;

  uint salary = 1 ether;
  address payeeAddress;
  uint lastPayday = now;

  // add funds to smart contract
  function addFund() payable returns(uint){
    return this.balance;
  }

  // 王八蛋老板黄鹤?
  function calculateRunway() returns(uint) {
    return this.balance / salary;
  }

  // has enough money to pay?
  function hasEnoughFund() returns(bool) {
    return calculateRunway() > 0;
  }

  // get salary
  function getPaid() {
    address msgSender = msg.sender;
    require(msgSender == payeeAddress);
    uint nextPayday = lastPayday + payDuration;
    assert(nextPayday < now);
    lastPayday = nextPayday;
    msgSender.transfer(salary);
  }

  // change reciever address
  function setPayeeAddress(address payee) {
    payeeAddress = payee;
  }

  // 财富自由
  function setSalary(uint money) {
    salary = money * 1 ether;
  }

  // get payeeAddress, for testing
  function getPayeeAddress() returns(address) {
    return payeeAddress;
  }

  // get contract balance, for testing
  function getContractBalance() returns(uint) {
    return this.balance;
  }

}
