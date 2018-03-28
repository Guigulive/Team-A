pragma solidity ^0.4.14;

import './SafeMath.sol';

 contract Payroll {
   struct Employee {
     address id;
     uint salary;
     uint lastPayday;
   }

   uint constant payDuration = 10 seconds;
   uint totalSalary;
   using SafeMath for uint;
   address owner;
   /* Employee[] employees; */
   mapping(address => Employee) public employees;

   function Payroll() {
     owner = msg.sender;
   }

   modifier onlyOwner {
     require(msg.sender == owner);
     _;
   }

   modifier employeeExist(address employeeId) {
     var employee = employees[employeeId];
     assert(employee.id != 0x0);
     _;
   }

   modifier addressNotExist(address employeeId) {
     var employee = employees[employeeId];
     assert (employee.id == 0x0);
     _;
   }

   function _partialPaid(Employee employee) private {
     uint payment = employee.salary.mul(now.sub(employee.lastPayday)).div(payDuration);
     employee.lastPayday = now;
     employee.id.transfer(payment);
   }

   function addEmployee(address employeeId, uint salary) onlyOwner addressNotExist(employeeId) {
     var employee = employees[employeeId];
     employees[employeeId] = Employee(employeeId, salary, now);
     totalSalary += salary * 1 ether;
   }

   function removeEmployee(address employeeId) onlyOwner employeeExist(employeeId) {
     var employee = employees[employeeId];
     _partialPaid(employee);
     delete employees[employeeId];
     totalSalary = totalSalary.sub(employee.salary);
   }

   function updateEmployee(address employeeId, uint salary) onlyOwner employeeExist(employeeId)  {
     var employee = employees[employeeId];
     _partialPaid(employee);
     totalSalary = totalSalary.sub(employee.salary);
     employees[employeeId].salary = salary.mul(1 ether);
     totalSalary = totalSalary.add(employee.salary);
     employees[employeeId].lastPayday = now;
   }

   function addFund() payable returns (uint) {
     return this.balance;
   }

   function calculateRunway() returns (uint) {
     assert (totalSalary != 0);
     return this.balance.div(totalSalary);
   }

   function hasEnoughFund() returns (bool) {
     return calculateRunway() > 0;
   }

   function getPaid() employeeExist(msg.sender) {
     var employee = employees[msg.sender];

     uint nextPayday = employee.lastPayday + payDuration;
     assert(nextPayday < now);

     employees[msg.sender].lastPayday = nextPayday;
     employee.id.transfer(employee.salary);
   }

   function changePaymentAddress(address newAddress) employeeExist(msg.sender) addressNotExist(newAddress) {
     var employee = employees[msg.sender];
    _partialPaid (employee);
    delete employees[msg.sender];
    employees[newAddress] = Employee(newAddress, employee.salary.mul(1 ether), now);
   }
 }
