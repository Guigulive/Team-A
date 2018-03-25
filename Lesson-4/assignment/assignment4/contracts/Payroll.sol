pragma solidity ^0.4.14;

import "./SafeMath.sol";

contract Payroll {
    //init
    address owner;
    uint constant payDuration = 10 seconds;
    uint totalSalary;
    using SafeMath for uint;
    
    struct Employee {
        address id;//could used as payment address
        uint salary;
        uint payDay;
    }
    
    mapping (address => Employee) public employees;
    //address[] employeeIds;

    function Payroll() {
        owner = msg.sender;
    }
    
    modifier onlyOwner {
        require (msg.sender == owner);
        _;
    }
    
    modifier employeeExist(address e) {
        var employee = employees[e];
        assert (employee.id != 0x0);
        _;
    }
    
    modifier indexNotUsed(address e) {
        var employee = employees[e];
        assert (employee.id == 0x0);
        _;
    }
    
    function addEmployee(address e, uint s) onlyOwner indexNotUsed(e) returns (address) {
        totalSalary = totalSalary.add (s.mul(1 ether));
        employees[e] = Employee(e, s.mul(1 ether), now);
        return e;
    }
    
    function _partialPaid (Employee e) private {
        uint payment =  e.salary.mul(now.sub(e.payDay)).div(payDuration);
        e.payDay = now;
        e.id.transfer(payment);
    }
    
    function checkSumSalary (address e) returns (uint){
        var employee = employees[e];
        uint payment =  employee.salary.mul(now.sub(employee.payDay)).div(payDuration);
        return payment;
    }
    
    function removeEmployee(address e) onlyOwner employeeExist(e) returns (address) {
        var employee = employees[e];
        _partialPaid(employee);
        totalSalary = totalSalary.sub (employee.salary);
        delete employees[e];
        return e;
    }
    
    function checkEmployee (address e) returns (uint salary, address id, uint payDay) {
        var employee = employees[e];
        return (employee.salary, employee.id, employee.payDay);
    }

    
    function addFund() payable returns (uint) {
        return this.balance;
    }
    
    function calculateRunway() returns (uint) {
        assert (totalSalary != 0);
        return this.balance.div(totalSalary);
    }
    
    function hasEnoughFund() returns (bool) {
        return this.calculateRunway() > 0;
    }
    
    function updateEmployeeSalary (address e, uint s) onlyOwner employeeExist(e) {
        var employee = employees[e];
        _partialPaid (employee);
    
        totalSalary = totalSalary.sub (employee.salary);
        employees[e].salary = s.mul(1 ether);
        totalSalary = totalSalary.add(s.mul(1 ether));
        employees[e].payDay = now;
    }
    
    //assignment3
    //Only change employee id for payment address, which may result in payment adddress conflict.
    function changeId (address eid, address payment_addr) onlyOwner employeeExist(eid) {
        var employee = employees[eid];
        _partialPaid (employee);
        employees[eid].id = payment_addr;
    }
    
    //Change employee index and id in the same time.
    function changePaymentAddress (address e_old, address e_new) onlyOwner employeeExist(e_old) indexNotUsed(e_new){
        var employee_old = employees[e_old];
        _partialPaid (employee_old);
        employees[e_new] = Employee(e_new, employee_old.salary.mul(1 ether), now);
        delete employees[e_old];
    }
    
    function getPaid() employeeExist(msg.sender) {
        var employee = employees[msg.sender];
        uint nextPayDay = employee.payDay.add(payDuration);
        assert (nextPayDay < now);
        employees[msg.sender].payDay = nextPayDay;//must: change state before transfer
        employee.id.transfer(employee.salary);
    }
}