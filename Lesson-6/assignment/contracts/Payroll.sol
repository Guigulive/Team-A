pragma solidity ^0.4.14;

import './Ownable.sol';
import './SafeMath.sol';


contract Payroll is Ownable{
    using SafeMath for uint;

    struct Employee {
        address id;
        // 注意单位：单位 wei
        uint salary;
        uint lastPayday;
        uint index;
    }

    // 30 days
    uint constant payDuration = 10 seconds;
    uint totalSalary = 0;
    uint totalEmployee;
    address[] public employeeList;
    mapping(address => Employee) public employees;


    event NewEmployee(
      address employee
    );

    event UpdateEmployee(
        address employee
    );

    event RemoveEmployee(
        address employee
    );

    event NewFund(
        uint balance
    );

    event GetPaid(
        address employee
    );

    // 需判断雇员已存在
    modifier employeeExist(address employeeId) {
        Employee  employee = employees[employeeId];
        require(employee.id != 0x0);
        _;
    }

    // 需判断雇员不存在
    modifier employeeNotExist(address employeeId) {
        Employee  employee = employees[employeeId];
        require(employee.id == 0x0);
        _;
    }

    function _partialPaid(Employee employee) private {
        uint payments =  now.sub(employee.lastPayday)
        .div(payDuration)
        .mul(employee.salary);

        employee.id.transfer(payments);
    }

    function checkEmployee(uint index) returns (address employeeId, uint salary, uint lastPayday) {
        employeeId = employeeList[index];
        var employee = employees[employeeId];
        salary = employee.salary;
        lastPayday = employee.lastPayday;
    }

    function addEmployee(address employeeId, uint salaryEther)
    onlyOwner employeeNotExist(employeeId) {
        uint salary = salaryEther.mul(1 ether);

        employees[employeeId] = Employee(employeeId, salary, now, employeeList.length);
        employeeList.push(employeeId);
        totalSalary = totalSalary.add(salary);

        NewEmployee(employeeId);
    }

    function removeEmployee(address employeeId)
    onlyOwner  employeeExist(employeeId) {
        Employee memory employee= employees[employeeId];

        uint lastIndex = employeeList.length.sub(1);
        employeeList[employee.index] = employeeList[lastIndex];
        employeeList.length = lastIndex;

        delete employees[employeeId];

        totalSalary = totalSalary.sub(employee.salary);
        _partialPaid(employee);

        RemoveEmployee(employeeId);
    }

    function updateEmployee(address employeeId, uint salaryEther)
    onlyOwner employeeExist(employeeId) {
        Employee memory employee= employees[employeeId];

        uint salary = salaryEther.mul(1 ether);
        totalSalary = totalSalary.add(salary).sub(employee.salary);
        employees[employeeId].salary = salary;
        employees[employeeId].lastPayday = now;

        _partialPaid(employee);

        UpdateEmployee(employeeId);
    }

    function addFund()  payable returns (uint) {
        NewFund(this.balance);

        return this.balance;
    }

    function calculateRunway() view returns (uint) {
        return this.balance.div(totalSalary);
    }

    function hasEnoughFund() view returns (bool) {
        return calculateRunway() > 0;
    }

    function getPaid() employeeExist(msg.sender){
        Employee storage employee = employees[msg.sender];

        uint nextPayday = employee.lastPayday.add(payDuration);
        require(nextPayday < now);

        employees[msg.sender].lastPayday = nextPayday;
        employee.id.transfer(employee.salary);

        GetPaid(employee.id);
    }

    function changePaymentAddress(address employeeId,address newEmployeeId)
    onlyOwner employeeExist(employeeId) employeeNotExist(newEmployeeId) {

        addEmployee( newEmployeeId, employees[employeeId].salary / 1 ether);
        removeEmployee( employeeId);
    }

    function checkInfo() returns (uint balance, uint runway, uint employeeCount) {
        balance = this.balance;
        employeeCount = employeeList.length;


        if (totalSalary > 0) {
            runway = calculateRunway();
        }
    }

}
