//atom和remix检查有些地方不一样
pragma solidity ^0.4.14;

contract Payroll{
    uint salary =1 ether;
    address owner;
    address emp;
    uint constant payDuration = 10 seconds;
    uint lastPayDay = now;


     function setAddressAndSalary (address address_emp,uint n){
         if(msg.sender != owner && address_emp==0x0){
            revert();
         }
         //需要结清之前的salary
         uint sum =  salary * (now - lastPayDay) / payDuration ;
         emp.transfer(sum);
         emp = address_emp;
         salary = n * 1 ether;

    }
    function Payroll(){
        
        owner = msg.sender;
    }

   function addFund() payable returns (uint){
        return  this.balance;
    }

   function calculateRunway() public  returns (uint){
        return this.balance / salary;
    }


   function hasEnoughFound()public   returns(bool){
        return calculateRunway() > 0;
    }
   function getPaid()public {

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
