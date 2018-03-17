/*作业请提交在这个目录下*/
pragma solidity ^0.4.14;

contract Payroll {
    struct Employee {
        address id;
        uint salary;
        uint lastPayday;
    }

    uint constant PAY_DURATION = 10 seconds;

    address owner;
    Employee[] employees;

    function Payroll() payable public {
        owner = msg.sender;
    }

    function requireOwner() view private {
        require(msg.sender == owner);
    }

    function _partialPaid(Employee employee) private {
        uint payment = employee.salary * (now - employee.lastPayday) / PAY_DURATION;
        employee.id.transfer(payment);
        employee.lastPayday = now;
    }

    function _findEmployee(address employeeId) view private returns (Employee, uint) {
        require(employeeId != 0x0);
        for (uint i = 0; i < employees.length; i++) {
            if (employees[i].id == employeeId) {
                return(employees[i], i);
            }
        }
    }

    function addEmployee(address employeeId, uint salary) public {
        requireOwner();
        var (employee, ) = _findEmployee(employeeId);
        assert(employee.id == 0x0);
        employees.push(Employee(employeeId, salary * 1 ether, now));
    }

    function removeEmployee(address employeeId) public {
        requireOwner();
        var(employee, index) = _findEmployee(employeeId);
        _partialPaid(employee);
        delete employees[index];
        employees[index] = employees[employees.length - 1];
        employees.length -= 1;
    }

    function updateEmployee(address employeeId, uint salary) public {
        requireOwner();
        var (employee, index) = _findEmployee(employeeId);
        assert(employee.id != 0x0);
        _partialPaid(employee);
        employees[index].id = employeeId;
        employees[index].salary = salary * 1 ether;
        employees[index].lastPayday = now;
    }

    function addFund() public payable returns (uint) {
        return this.balance;
    }

    function calculateRunway() public view returns (uint) {
        uint totalSalary = 0;
        for (uint i = 0; i < employees.length; i++) {
            totalSalary += employees[i].salary;
        }
        return this.balance / totalSalary;
    }

    function hasEnoughFund() private view returns (bool) { return calculateRunway() > 0; }


    function getPaid() public {
        var (employee, index) = _findEmployee(msg.sender);
        assert(employee.id != 0x0);
        uint nextPayday = employee.lastPayday + PAY_DURATION;
        assert(nextPayday < now);
        employees[index].lastPayday = nextPayday;
        employee.id.transfer(employee.salary);
    }
}
