pragma solidity ^0.4.14;

contract Payroll {
    struct Employee {
        address id;
        uint salary;
        uint lastPayday;
    } 
    
    uint constant payDuration = 10 seconds;
    uint  totalSalary;

    address owner;
    Employee[] employees;
    
    function Payroll() {
        owner = msg.sender;
    }
    
    function _partialPaid(Employee employee) private{
        uint payment = employee.salary * (now - employee.lastPayday) / payDuration;
        employee.lastPayday = now;
        employee.id.transfer (payment);
    }
    
    function _findEmployee(address e) private returns (Employee, uint) {
        for (uint i; i < employees.length; i++) {
            if (e == employees[i].id) {
                return (employees[i], i);
            }
        }
    }
    
    function addEmployee (address e, uint s){
        require (msg.sender == owner);
        var (employee, index) = _findEmployee(e);
        assert(employee.id == 0x0);
        employees.push(Employee(e, s*1 ether, now));
        totalSalary += s*1 ether;
    }
    
    function removeEmployee (address e) {
        require (msg.sender == owner);
        var (employee, index) = _findEmployee(e);
        assert(employee.id != 0x0);
        
        _partialPaid (employees[index]);
        totalSalary -= employee.salary;
        delete employees[index];
        employees[index] = employees[employees.length - 1];
        employees.length -=1;
        
    }
    
    function updateEmployee(address e, uint s) {
        require(msg.sender == owner);
        var (employee, index) = _findEmployee(e);
        assert(employee.id != 0x0);
        _partialPaid (employees[index]);
        employees[index].salary = s*1 ether;
        employees[index].lastPayday = now;
    }
    
    function addFund() payable returns (uint) {
        return this.balance;
    }
    
    function calculateRunway() returns (uint) {
        assert (totalSalary != 0);
        return this.balance / totalSalary;
    }
    
    function hasEnoughFund() returns (bool) {
        return calculateRunway() > 0;
    }
    
    function getPaid() {
        var (employee, index) = _findEmployee(msg.sender);
        assert(employee.id != 0x0);
        
        uint nextPayday = employee.lastPayday + payDuration;
        assert(nextPayday < now);

        employee.lastPayday = nextPayday;
        employee.id.transfer(employee.salary);
    }
}
