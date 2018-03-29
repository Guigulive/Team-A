pragma solidity ^0.4.14;

contract Payroll {
    //init
    uint salary = 1 ether;
    address employee = 0xca35b7d915458ef540ade6068dfe2f44e8fa733c;
    address owner;
    uint constant payDuration = 20 seconds;
    uint lastPayday = now;//deploy date

    function Payroll() {
        owner = msg.sender;
    }
    
    function addFund() payable returns (uint) {
        return this.balance;
    }
    
    function calculateRunway() returns (uint) {
        return this.balance / salary;
    }
    
    function hasEnoughFund() returns (bool) {
        return this.calculateRunway() > 0;
    }
    
    function workDays () returns (uint) {
        return  (now - lastPayday) / payDuration;
    }
    
    //assign1: update employee and salary
    function updateEmployeeSalary (address e, uint s) returns (address){
        require (msg.sender == owner);
        require (s != 0);
        require (e != 0x0);
        uint workdays = workDays();
        require (calculateRunway() > workdays);
        
        //unemploy current employee and give him payment he deserve
        lastPayday = now;
        uint payment = workdays * salary;
        employee.transfer(payment);
        
        //new employee and salary
        employee = e;
        salary = s * 1 ether;
        return e;
    }
    
    function getPaid(){
        require (msg.sender == employee);
        uint nextPayDay = lastPayday + payDuration;
        require (nextPayDay < now);
        lastPayday = nextPayDay;//must: change state before transfer
        employee.transfer(salary);
    }
}
