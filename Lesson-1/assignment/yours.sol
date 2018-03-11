/*作业请提交在这个目录下*/
pragma solidity ^0.4.14;

contract Payroll{
    uint salary;
    address owner = 0xca35b7d915458ef540ade6068dfe2f44e8fa733c;
    address emp = 0x14723a09acff6d2a60dcdf7aa4aff308fddc160c;
    uint constant payDuration = 10 seconds;
    uint lastPayDay = now;
    
   
     function setAddressAndSalary(address address_emp,uint n){
         if(msg.sender != owner || address_emp==0x0){
            revert();
         }
         //需要结清之前的salary
         uint sum = (now - lastPayDay) / 30 * salary;
         emp.transfer(sum);
         emp = address_emp;
         salary = n * 1 ether;
        
    }
   
    function addFund() payable returns (uint){
        return this.balance;
    }
    
    function calculateRunway() returns (uint){
        return this.balance / salary;
    }
   
    
     function hasEnoughFound() returns(bool){
        return calculateRunway() > 0;
    } 
    
    function getPaid() {
        
        if(msg.sender != emp || !hasEnoughFound()){
             revert();
        }
        uint nextDay = lastPayDay + payDuration;
        
        if(nextDay> now){
            revert();
        }
        lastPayDay = nextDay;
        emp.transfer(salary);
        
        
        
    }
   
    
}
