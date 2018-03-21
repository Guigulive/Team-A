pragma solidity ^0.4.14;

contract Payroll {
    uint constant PAY_DURATION = 10 seconds;

    address owner;

    address employee;
    uint salary;
    uint lastPayday;

    function Payroll () public payable {
        owner = msg.sender;
    }

    function updateEmployeeAddress(address e) public {
        require(msg.sender == owner);
        employee = e;
    }

    function updateEmployeeSalary(uint s) public {
        require(msg.sender == owner);
        salary = s * 1 ether;
    }

    function updateEmployee(address e, uint s) public {
        require(msg.sender == owner);

        updateEmployeeAddress(e);
        updateEmployeeSalary(s);
    }

    function addFund() public payable returns (uint) {
        return this.balance;
    }

    function calculateRunway() public view returns (uint) { return this.balance / salary; }

    function hasEnoughFund() public view returns (bool) { return calculateRunway() > 0; }

    function getPaid() public {
        require(msg.sender == employee);

        uint nextPayday = lastPayday + PAY_DURATION;
        assert(nextPayday < now);

        lastPayday = nextPayday;
        employee.transfer(salary);
    }
}
