pragma solidity ^0.4.14;

contract Payroll{
    
    struct Employee{
        address id;
        uint salary;
        uint lastPayDay;
    }
    
    uint constant payDuration = 10 seconds;
    
    Employee[] employees;

    address owner;
    
    uint totalSalary;
    
    function Payroll(){
        owner = msg.sender;
    }
    
    function _findEmployee(address id) private returns(Employee, uint){
        for(uint i = 0; i < employees.length; i++){
            if(employees[i].id == id) {
                return (employees[i], i);
            }
        }
    }
    
    function _partialPaid(Employee employee) private {
        uint payment = employee.salary * (now - employee.lastPayDay) / payDuration;
        employee.id.transfer(payment);
    }
    
    function addEmployee(address id, uint salary){
        require(msg.sender == owner);
        
        var (employee, index) = _findEmployee(id);
        assert(employee.id == 0x0);
        
        salary *= 1 ether;
        totalSalary += salary;
        employees.push(Employee(id, salary, now));
    }
    
    function removeEmployee(address id){
        require(msg.sender == owner);
        
        var (employee, index) = _findEmployee(id);
        assert(employee.id != 0x0);
        
        _partialPaid(employee);
        
        totalSalary -= employee.salary;
        employees[index] = employees[employees.length - 1];
        employees.length -= 1;
    }
    
    function update(address id, uint salary){
        require(msg.sender == owner);
        
        var (employee, index) = _findEmployee(id);
         assert(employee.id != 0x0);
        
        _partialPaid(employee);
        
        salary *= 1 ether;
        totalSalary = totalSalary - employee.salary + salary;
        employees[index].salary = salary;
        employees[index].lastPayDay = now;
    }
    
    function addFund() payable returns(uint) {
        return this.balance;
    }    
    
    function calculateRunway() returns(uint) {
        return this.balance / totalSalary;
    }
    
    function hasEnoughFund() returns(bool) {
        return calculateRunway() > 0;
    }
    
    function getPaid() {
        var (employee, index) = _findEmployee(msg.sender);
        assert(employee.id != 0x0);
        
        uint nextPayDay = employee.lastPayDay + payDuration;
        
        assert(nextPayDay < now);
        
        employees[index].lastPayDay = nextPayDay;
        employees[index].id.transfer(employee.salary);
    }
    
}