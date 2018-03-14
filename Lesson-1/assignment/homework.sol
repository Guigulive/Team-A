pragma solidity ^0.4.14;
// 声明合约
contract Payroll {
    // 发钱周期
    uint constant payDuration = 10 seconds;
    // 所有者可以设定权限 
    address owner;
    // 薪水
    uint salary;
    // 员工
    address employee;
    // 上次发薪日期 
    uint lastPayday;

    function Payroll() {
        owner = msg.sender;
    }
    // 更新地址 
    function updateEmployeeAddress(address e) returns(address){
        // 验证
        require(msg.sender == owner);
        require (e != 0x0);
        employee = e;
        return employee;
    }
    // 更新薪水
    function updateEmployeeSalary( uint s) returns(uint){
        // 验证
        require(msg.sender == owner);
        require (s >= 0);
        salary = s * 1 ether;
        return salary;
    }
    // 更新地址和薪水
    function updateEmployee(address e, uint s) returns(bool){
        require(msg.sender == owner);
        // 初始化历史 
        if (employee != 0x0) {
            uint payment = salary * (now - lastPayday) / payDuration;
            employee.transfer(payment);
        }
        // 更新资料 
        employee = e;
        salary = s * 1 ether;
        lastPayday = now;
        
    }
    
    function addFund() payable returns (uint) {
        return this.balance;
    }
    // 计算还能发几次薪水
    function calculateRunway() returns (uint) {
        return this.balance / salary;
    }
    // 小金库还有足够的钱吗 
    function hasEnoughFund() returns (bool) {
        return calculateRunway() > 0;
    }
    
    function getPaid() {
        require(msg.sender == employee);
        
        uint nextPayday = lastPayday + payDuration;
        assert(nextPayday < now);

        lastPayday = nextPayday;
        employee.transfer(salary);
    }
    
    // 获取员工地址 
    function getEmployeeAddress() returns(address){
        return employee;
    }
    // 获取月薪标准  
    function getEmployeeSalary() returns(uint){
        return salary;
    }
}
