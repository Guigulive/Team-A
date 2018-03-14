/*作业请提交在这个目录下*/
pragma solidity ^0.4.14;

contract Payroll{
    uint salary;
    address owner = this;
    address emp;
    uint constant payDuration = 10 seconds;
    uint lastPayDay = now;


     function setAddressAndSalary (address address_emp,uint n)public{
         if(msg.sender != owner || address_emp==0x0){
            revert();
         }
         //需要结清之前的salary
         uint sum = (now - lastPayDay) / 30 * salary;
         emp.transfer(sum);
         emp = address_emp;
         salary = n * 1 ether;

    }

   function addFund() public payable returns (uint){
        return  owner.balance;
    }

   function calculateRunway()public view returns (uint){
        return owner.balance / salary;
    }


   function hasEnoughFound()public view  returns(bool){
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
