/*作业请提交在这个目录下*/
pragma solidity ^0.4.14;

contract Payroll{
    
    struct Employee{
        address id;
        uint salary;
        uint lastPayDay;
    }
    
    Employee[] employees;
    
    uint constant payDuration = 10 seconds;
    
    address owner;
    
    function Payroll(){
        owner = msg.sender;
    }
    
    function _findEmployee(address id) private returns(Employee storage, uint){
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
        
        employees.push(Employee(id, salary * 1 ether, now));
    }
    
    function removeEmployee(address id){
        require(msg.sender == owner);
        
        var (employee, index) = _findEmployee(id);
         assert(employee.id != 0x0);
        
        _partialPaid(employee);
        
        employees[index] = employees[employees.length - 1];
        employees.length -= 1;
    }
    
    function update(address id, uint salary){
        require(msg.sender == owner);
        
        var (employee, index) = _findEmployee(id);
         assert(employee.id != 0x0);
        
        _partialPaid(employee);
        
        employee.salary = salary * 1 ether;
        employee.lastPayDay = now;
    }
    
    function addFund() payable returns(uint) {
        return this.balance;
    }    
    
    function calculateRunway() returns(uint) {
        uint totalSalary = 0;
        for(uint i = 0; i < employees.length; i++){
            totalSalary += employees[i].salary;
        }
        
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
        
        employee.lastPayDay = nextPayDay;
        employee.id.transfer(employee.salary);
    }
    
}
    






    
