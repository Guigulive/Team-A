/*作业请提交在这个目录下*/

pragma solidity ^0.4.14;

contract Payroll{
    uint salary;
    address payee;
    uint constant payDuration = 10 seconds;
    uint lastPayDay = now;
    
    function addFund() payable returns(uint) {
        return this.balance;
    }    
    
    function calculateRunway() returns(uint) {
        return this.balance / salary;
    }
    
    function hasEnoughFund() returns(bool) {
        return calculateRunway() > 0;
    }
    
    function getPaid() {
        if(msg.sender != payee) {
            revert();
        }
        
        uint nextPayDay = lastPayDay + payDuration;
        if(nextPayDay > now){
            revert();
        }
        
        lastPayDay = nextPayDay;
        payee.transfer(salary);
    }
    
    function setPayee(address thePayee){
        payee = thePayee;
    }
    
    function setSalary(uint theSalary){
        salary = theSalary * 1 ether;
    }
    
}