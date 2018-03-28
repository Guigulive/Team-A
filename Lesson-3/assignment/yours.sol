/*作业请提交在这个目录下*/
pragma solidity ^0.4.14;

import './SafeMath.sol';

 contract Payroll {
   struct Employee {
     address id;
     uint salary;
     uint lastPayday;
   }
   
   using SafeMath for uint;
   
   uint constant payDuration = 10 seconds;
   uint SumofSalary;

   address owner;
   
   /* Employee[] employees; */
   mapping(address => Employee) public employees;

   function Payroll() {
     owner = msg.sender;
   }

   modifier ReqireOwnerSend {
     require(msg.sender == owner);
     _;
   }

   modifier AssertEmployeeExist(address employeeId) {
     var employee = employees[employeeId];
     assert(employee.id != 0x0);
     _;
   }

   modifier AssertAddrNotExist(address employeeId) {
     var employee = employees[employeeId];
     assert (employee.id == 0x0);
     _;
   }

   function _partialPaid(Employee employee) private {
     uint payment = employee.salary.mul(now.sub(employee.lastPayday)).div(payDuration);
     employee.lastPayday = now;
     employee.id.transfer(payment);
   }

   function addEmployee(address employeeId, uint salary) ReqireOwnerSend AssertAddrNotExist(employeeId) {
     var employee = employees[employeeId];
     employees[employeeId] = Employee(employeeId, salary, now);
     SumofSalary += salary * 1 ether;
   }

   function removeEmployee(address employeeId) ReqireOwnerSend AssertEmployeeExist(employeeId) {
     var employee = employees[employeeId];
     _partialPaid(employee);
     delete employees[employeeId];
     SumofSalary = SumofSalary.sub(employee.salary);
   }

   function updateEmployee(address employeeId, uint salary) ReqireOwnerSend AssertEmployeeExist(employeeId)  {
     var employee = employees[employeeId];
     _partialPaid(employee);
     SumofSalary = SumofSalary.sub(employee.salary);
     employees[employeeId].salary = salary.mul(1 ether);
     SumofSalary = SumofSalary.add(employee.salary);
     employees[employeeId].lastPayday = now;
   }

   function addFund() payable returns (uint) {
     return this.balance;
   }

   function calculateRunway() returns (uint) {
     assert (SumofSalary != 0);
     return this.balance.div(SumofSalary);
   }

   function hasEnoughFund() returns (bool) {
     return calculateRunway() > 0;
   }

   function getPaid() AssertEmployeeExist(msg.sender) {
     var employee = employees[msg.sender];

     uint nextPayday = employee.lastPayday + payDuration;
     assert(nextPayday < now);

     employees[msg.sender].lastPayday = nextPayday;
     employee.id.transfer(employee.salary);
   }

   function changePaymentAddress(address newAddress) AssertEmployeeExist(msg.sender) AssertAddrNotExist(newAddress) {
     var employee = employees[msg.sender];
    _partialPaid (employee);
    delete employees[msg.sender];
    employees[newAddress] = Employee(newAddress, employee.salary.mul(1 ether), now);
   }
 }
