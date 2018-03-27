/*作业请提交在这个目录下*/

pragma solidity ^0.4.21;

import "./Ownable.sol";
import "./SafeMath.sol";

contract Payroll is Ownable  {

    using SafeMath for  uint;

    struct Employee {
        address id ;
        uint salary ;
        uint lastPayDay ;
    }

    //Employee [] employees;

    mapping(address => Employee ) public  employees;

    uint salary = 0 ether;

    //雇主 地址
    address owner = 0x0 ;
    //员工地址
   // address employeeAddress = 0x0 ;
    // 支付周期
    uint constant payDuration = 10 seconds ;
   //上次支付时间
    uint lastPayDay = now;

    uint totalSalary;

    // modifier onlyOwner {
    //     require(msg.sender == owner);
    //     _;
    // }

    modifier employeeExist(address employeeId) {
        var employee = employees[employeeId];
        assert(employee.id != 0x0);
        _;
    }


    modifier employeeNotExist(address employeeId) {
        var employee = employees[employeeId];
        assert(employee.id == 0x0);
        _;
    }



    // init method
    // function Payroll(){
    //     owner = msg.sender;
    // }

    // 支付 部分工资
    function _partialPay(Employee employee) private {
        //assert(employee.id != 0x0);
        uint payment = employee.salary.mul( now.sub( employee.lastPayDay ) ).div(payDuration) ;
        employee.id.transfer(payment);

    }

    /*
    function _findEmployee(address employeeId) private returns (Employee ,uint) {
          for ( uint i= 0; i< employees.length ; i++ ){
            if ( employees[i].id == employeeId ) {
                return ( employees[i] ,i);
            }
        }
    }*/

    function addEmployee( address employeeId, uint salary  ) onlyOwner  employeeNotExist(employeeId){
        // require(msg.sender == owner);
        //Employee e =_findEmployee(employeeId);
       // var (employee , index ) = employees[employeeId];
       var employee = employees[employeeId];
        //_findEmployee(employeeId);
        // 异常
        // assert(employee.id == 0x0);
        //employees.push(Employee(employeeId,salary * 1 ether,now));
        // totalSalary +=salary * 1 ether ;

        totalSalary = totalSalary.add(salary.mul(1 ether ));

        employees[employeeId]=Employee(employeeId,salary .mul(1 ether),now);
    }

    function removeEmployee(address employeeId) onlyOwner  employeeExist(employeeId) {
        // require(msg.sender == owner);

       // var (employee , index ) = _findEmployee(employeeId);
        var employee = employees[employeeId];
        // assert(employee.id != 0x0);
        _partialPay(employee);


        // totalSalary += employee.salary * 1 ether ;
        totalSalary = totalSalary.sub(salary.mul(1 ether));
        delete  employees[employeeId];

        // employees[index] = employees[employees.length - 1];
        // employees.length -= 1;


    }

    function updateEmployee(address employeeId,uint  salary )  onlyOwner  employeeExist(employeeId) {
        // require(msg.sender == owner);

        // var (employee , index ) = _findEmployee(employeeId);
        var employee = employees[employeeId];

        totalSalary = totalSalary.sub(employee.salary).add(salary.mul(1 ether));

        employees[employeeId].id = employeeId;
        employees[employeeId].salary = salary.mul(1 ether);
        employees[employeeId].lastPayDay = now;


    }

    function addFund()  payable returns (uint) {
      // add money to contract
      return this.balance ;
    }

    function  getFund () returns (uint) {
        return this.balance ;
    }

    function caculateRunaway() returns (uint){
        // uint totalSalary = 0;


        // for ( uint i= 0; i< employees.length ; i++){
        //     totalSalary += employees[i].salary ;

        // }

        assert(totalSalary !=0 );
        assert( this.balance !=0 );
        return this.balance.div(totalSalary) ;
    }



    function hasEnoughFund() returns (bool) {
        // return this.balance >= salary ;
        // this 方法 gas 高
       return  caculateRunaway()>0 ;
    }

    function checkEmployee (address employeeId ) returns (uint salary ,uint lastPayDay ) {
        var employee = employees[employeeId];
        // return (employee.salary ,employee.lastPayDay );
        salary = employee.salary ;
        lastPayDay = employee.lastPayDay;
    }

    function getPaid()   employeeExist(msg.sender)  {
        var employee = employees[msg.sender];
        //var ( employee ,index) = _findEmployee(msg.sender);

        //assert( employee.id != 0x0 );

        uint nexPayDay = lastPayDay.add( payDuration);
        // 确保 支付时间 正确
        assert(nexPayDay < now);
        /**
         * if (nexPayDay > now ) {
            revert() ;
             exception no gas
        }
        */

        lastPayDay = nexPayDay ;
        // 发钱
        employee.id.transfer(employee.salary);

    }
} 
