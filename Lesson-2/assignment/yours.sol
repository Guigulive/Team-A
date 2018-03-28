/*作业请提交在这个目录下*/
pragma solidity ^0.4.14;

contract Payroll {
    struct Employee {
        address id;
        uint salary;
        uint lastPayday;
    }
    
    uint constant payDuration = 10 seconds;

    address owner;
    Employee[] employees;

    function Payroll() {
        owner = msg.sender;
    }
    
    function _partialPaid(Employee employee) private {
        require(msg.sender == employee.id);
        if (employee.id != 0x0) {
            uint nextPayday = employee.lastPayday + payDuration;
            assert(nextPayday < now);
            employee.lastPayday = nextPayday;
            employee.id.transfer(employee.salary);
        }
        
    }
    
    function _findEmployee(address employeeId) private returns (Employee, uint) {
        require(0x0 != employeeId);
        for (uint p = 0; p < employees.length; p++) {
            if (employees[p].id == employeeId) {
                return (employees[p], p);
            }
        }
    }

    function addEmployee(address employeeId, uint salary) {
        require(msg.sender == owner);
        var (employeeRslt,idx) = _findEmployee(employeeId);
        assert(employeeRslt.id == 0x0);
        employees.push(Employee(employeeId,salary,now));
    }
    
    function removeEmployee(address employeeId) {
       require(msg.sender == owner);
       var (employeeRslt,idx) = _findEmployee(employeeId);
       if (employeeRslt.id != 0x0) {
            uint payment = employees[idx].salary * (now - employees[idx].lastPayday) / payDuration;
            employeeId.transfer(payment);
        }
        
        for (uint i = idx; i<employees.length-1; i++){
            employees[i] = employees[i+1];
        }
        employees.length--;
    }
    
    function updateEmployee(address employeeId, uint salary) {
       require(msg.sender == owner);
       var (employeeRslt,idx) = _findEmployee(employeeId);
       if (employeeRslt.id != 0x0) {
            uint payment = employees[idx].salary * (now - employees[idx].lastPayday) / payDuration;
            employeeId.transfer(payment);
            employees[idx].salary = salary * 1 ether;
            employees[idx].lastPayday = now;
        } else {
            addEmployee(employeeId,salary);
        }
        
    }
    
    function addFund() payable returns (uint) {
        return this.balance;
    }
    
    function calculateRunway() returns (uint) {
        uint totalSalary = 0;
       for (uint i = 0; i < employees.length; i++) {
            totalSalary += employees[i].salary;
        }
        return this.balance / totalSalary;
    }
    
    function hasEnoughFund() returns (bool) {
        return calculateRunway() > 0;
    }
    
    
    function getPaid() {
        for (uint p = 0; p < employees.length; p++) {
            _partialPaid(employees[p]);
        }
    }
}
