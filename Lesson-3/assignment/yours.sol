/*作业请提交在这个目录下*/
pragma solidity ^0.4.14;

import "./SafeMath.sol";

contract Payroll {
    struct Employee {
        address id;
        uint salary;
        uint lastPayday;
    }

    uint constant PAY_DURATION = 10 seconds;

    address owner;
    uint totalSalary = 0;

    mapping(address => Employee) public employees;


    modifier employeeExist(address employeeId) {
        var employee = employees[employeeId];
        assert(employee.id != 0x0);
        _;
    }

    modifier employeeNotExist(address employeeId) {
        var employee = employees[employeeId];
        assert (employee.id == 0x0);
        _;
    }

    modifier onlyOwner {
        require (msg.sender == owner);
        _;
    }

    function Payroll() payable public {
        owner = msg.sender;
    }

    function _partialPaid(Employee employee) private {
        uint payment = SafeMath.mul(employee.salary, SafeMath.div(SafeMath.sub(now, employee.lastPayday), PAY_DURATION));
        employee.id.transfer(payment);
        employee.lastPayday = now;
    }

    function addEmployee(address employeeId, uint salary) onlyOwner employeeNotExist(employeeId)  public {
        totalSalary = SafeMath.add(totalSalary, SafeMath.mul(salary, 1 ether));
        employees[employeeId] = Employee(employeeId, SafeMath.mul(salary, 1 ether), now);
    }

    function removeEmployee(address employeeId) onlyOwner employeeExist(employeeId) public {
        var employee = employees[employeeId];
        _partialPaid(employee);
        delete employees[employeeId];
        totalSalary = SafeMath.sub (totalSalary, employee.salary);
    }

    function updateEmployee(address employeeId, uint salary) onlyOwner public {
        var employee = employees[employeeId];
        _partialPaid(employee);
        totalSalary = SafeMath.sub (totalSalary, employee.salary);

        employees[employeeId].salary = SafeMath.mul(salary, 1 ether);
        employees[employeeId].lastPayday = now;

        totalSalary = SafeMath.add (totalSalary, employee.salary);
    }

    function addFund() public payable returns (uint) {
        return this.balance;
    }

    function calculateRunway() public view returns (uint) {
        return SafeMath.div(this.balance, totalSalary);
    }

    function hasEnoughFund() private view returns (bool) { return calculateRunway() > 0; }


    function getPaid() employeeExist(msg.sender) public {
        var employee = employees[msg.sender];
        uint nextPayday = SafeMath.add(employee.lastPayday, PAY_DURATION);
        assert(nextPayday < now);
        employees[msg.sender].lastPayday = nextPayday;
        employee.id.transfer(employee.salary);
    }

    function checkEmployee (address employeeId) internal view returns (uint salary, address id, uint payDay) {
        var employee = employees[employeeId];
        return (employee.salary, employee.id, employee.lastPayday);
    }

    function changePaymentAddress (address oldEmployeeId, address newEmployeeId) onlyOwner employeeExist(oldEmployeeId) employeeNotExist(newEmployeeId) public {
        var oldEmployee = employees[oldEmployeeId];
        _partialPaid (oldEmployee);
        employees[newEmployeeId] = Employee(newEmployeeId, SafeMath.mul(oldEmployee.salary, 1 ether), now);
        delete employees[oldEmployeeId];
    }
}
