/*作业请提交在这个目录下*/
pragma solidity ^0.4.14;

contract Payroll {
    uint constant payDuration = 10 seconds;

    address owner;
    uint salary;
    address employee;
    uint lastPayday;

    function Payroll() {
        owner = msg.sender;
    }
    
    //修改员工地址 
    function changeEmployee(address e) {
        //只有合约部署者才有权限改变员工地址
        require(msg.sender == owner);
        
        if (employee != 0x0) {  //员工地址地址不能是0 
            //发放未领取的工资  
            uint payment = salary * (now - lastPayday) / payDuration;
            employee.transfer(payment);
        }
        employee = e;
        lastPayday = now;
    }
    
    //更改跟员工薪水
    function changeSalary(uint money){ 
      //只有合约部署者才有权限改变员工薪水。money 默认参数是wei，需要转化。         
      require(msg.sender==owner);
       
      salary = money * 1 ether;
      
    }

    
    function addFund() payable returns (uint) {
        return this.balance;
    }
    
    function calculateRunway() returns (uint) {
        return this.balance / salary;
    }
    
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
}
