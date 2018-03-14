pragma solidity ^0.4.14;

contract Payroll {
  uint constant payDuration = 100 seconds;

  uint salary = 1 ether;
  address payeeAddress;
  uint lastPayday = now;

  function addFund() payable returns(uint){
    return this.balance;
  }

  function calculateRunway() returns(uint) {
    return this.balance / salary;
  }

  function hasEnoughFund() returns(bool) {
    return calculateRunway() > 0;
  }

  function getPaid() {
    address msgSender = msg.sender;
    require(msgSender == payeeAddress);
    uint nextPayday = lastPayday + payDuration;
    assert(nextPayday < now);
    lastPayday = nextPayday;
    msgSender.transfer(salary);
  }

  function setPayeeAddress(address payee) {
    payeeAddress = payee;
  }

  function setSalary(uint money) {
    salary = money * 1 ether;
  }

  function getPayeeAddress() returns(address) {
    return payeeAddress;
  }

  function getContractBalance() returns(uint) {
    return this.balance;
  }

}
