/*作业请提交在这个目录下*/
pragma solidity ^0.4.14;

import './SafeMath.sol';
import './Owner.sol';

contract Payroll is Ownable{
    
    using SafeMath for unit;

    struct Employee{
        address id;
        uint salary;
        uint lastPayDay;
    }
    
    uint constant payDuration = 10 seconds;
    
    mapping (address => Employee) public employees;
    
    address owner;
    
    uint totalSalary;
    
    modifier employeeExist(address id){
        Employee employee = employees[id];
        assert(employee.id != 0x0);
        _;
    }

    modifier isEmployee(){
        var employee = employees[msg.sender];
        assert(employee.id != 0x0);
        _;
    }
    
    function _partialPaid(Employee employee) private {
        uint payment = employee.salary.mul(now.sub(employee.lastPayDay)).div(payDuration);
        employee.id.transfer(payment);
    }
    
    function addEmployee(address id, uint salary) onlyOwner {
        Employee employee = employees[id];
        assert(employee.id == 0x0);
        
        salary *= 1 ether;
        employees[id] = Employee(id, salary, now);
        totalSalary = totalSalary.add(salary);
    }
    
    function removeEmployee(address id) onlyOwner employeeExist(id){
        _partialPaid(employee);
        
        totalSalary = totalSalary.sub(employee.salary);
        delete employees[id];
    }
    
    function update(address id, uint salary) onlyOwner employeeExist(id){
        Employee employee = employees[id];
        
        _partialPaid(employee);
        
        salary *= 1 ether;
        totalSalary = totalSalary.sub(employee.salary).add(salary);
        employee.salary = salary;
        employee.lastPayDay = now;
    }
    
    function changePaymentAddress(address newAddress) isEmployee {
        var employee = employees[msg.sender];
        employee.id = newAddress;
        delete employee[msg.sender];
        employee[newAddress] = employee;
    }
    
    function addFund() payable returns(uint) {
        return this.balance;
    }    

    function calculateRunway() returns(uint) {
        return this.balance.div(totalSalary);
    }
    
    function hasEnoughFund() returns(bool) {
        return calculateRunway() > 0;
    }
    
    function getPaid() employeeExist(msg.sender){
        Employee employee = employees[msg.sender];
        
        uint nextPayDay = employee.lastPayDay.add(payDuration);
        
        assert(nextPayDay < now);
        
        employee.lastPayDay = nextPayDay;
        employee.id.transfer(employee.salary);
    }
    
}