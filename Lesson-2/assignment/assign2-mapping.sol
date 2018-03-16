pragma solidity ^0.4.14;

contract Payroll {
    //init
    address owner;
    uint constant payDuration = 10 seconds;
  
    struct Employee {
        uint salary;
        uint payDay;
    }
    
    mapping (address => Employee) employees;
    address[] employeeIds;

    function Payroll() {
        owner = msg.sender;
    }
    
    function addEmployee(address employeeid, uint salary) returns (address) {
        require (msg.sender == owner);
        assert (checkExists(employeeid) != true);
        
        var employee = employees[employeeid];
        employee.salary = salary*1 ether;
        employee.payDay = now;
        employeeIds.push(employeeid);
        return employeeid;
    }
    
    function removeEmployee(address employeeid) returns (address) {
        require (msg.sender == owner);
        assert (checkExists(employeeid) == true);
        delete employees[employeeid];
        return employeeid;
    }
    
    function checkExists(address employeeid) returns (bool) {
        for (uint i=0; i < employeeIds.length; i++) {
            if(employeeid == employeeIds[i]) {
                return true;
            }
        }
        return false;
    }
    
    function listEmployees() returns (address[] ) {
        return employeeIds;
    }
    
    function addFund() payable returns (uint) {
        return this.balance;
    }
    
    function calculateRunway() returns (uint) {
        uint totalSalary;
        for (uint i=0; i < employeeIds.length; i++) {
            totalSalary += employees[employeeIds[i]].salary;
        }
        assert (totalSalary != 0);
        return this.balance / totalSalary;
    }
    
    function hasEnoughFund() returns (bool) {
        return this.calculateRunway() > 0;
    }
    
    function workDays (address employeeid) returns (uint) {
        return  (now - employees[employeeid].payDay) / payDuration;
    }
    
    function checkSalary (address employeeid) returns (uint) {
        return  employees[employeeid].salary;
    }
    
    function updateEmployeeSalary (address e, uint s){
        require (msg.sender == owner);
        require (checkExists(e) == true);
        require (s != 0);
        uint payment = workDays(e) * employees[e].salary;
        assert (this.balance > payment);
        
        employees[e].payDay = now;
        e.transfer(payment);
        employees[e].salary = s * 1 ether;
    }
    
    function getPaid(){
        var employee = msg.sender;
        require (checkExists(employee) == true);
        uint nextPayDay = employees[employee].payDay + payDuration;
        assert (nextPayDay < now);
        employees[employee].payDay = nextPayDay;//must: change state before transfer
        employee.transfer(employees[employee].salary);
    }
}
