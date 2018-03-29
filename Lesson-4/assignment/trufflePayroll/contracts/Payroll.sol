/*作业请提交在这个目录下*/
pragma solidity ^0.4.18;
import './Ownable.sol';
import './SafeMath.sol';

/**
 *  产品化步骤
 *  1.引入ownable，删除本地构造函数使用父类的构造函数
 *  2.使用ownable 定义的 modifier 和自己定义的 modifier 进行前置判断
 *  3.使用safemath 防止溢出
 *  4.增加修改员工付款地址的方法
 **/
contract Payroll is Ownable{
	using SafeMath for uint;
    uint constant payDuration = 10 seconds;
    uint totalSalary = 0;
    address owner;
   
    struct Employee {
        address id;
        uint salary;
        uint lastPayDay;
    }

    mapping(address => Employee) public employees;
    
    
    modifier employeeExist(address empid){
       var employee = employees[empid];
       assert(employee.id != 0x0);
        _;
    }

    //新增一个判断员工是否存在的 modifier
    modifier employeeNotExist(address newEmpid){
       var employee = employees[newEmpid];
       assert(employee.id == 0x0);
        _;
    }

    function _partialPay(Employee employee) private{
          uint payment = employee.salary.mul(now.sub(employee.lastPayDay)).div(payDuration);
          employee.id.transfer(payment);
        
    }
    
    function addEmployee(address empid,uint salary) public onlyOwner employeeNotExist(empid){
        employees[empid] = Employee(empid, salary.mul(1 ether), now);
        totalSalary = totalSalary.add(employees[empid].salary);
        
    }
    
    function removeEmployee(address empid) public onlyOwner employeeExist(empid){
 		var employee = employees[empid];
 		_partialPay(employee);
 		totalSalary = totalSalary.sub(employees[empid].salary);
        delete(employees[empid]);
        
    }
  
    function updateEmplpyee (address empid,uint salary) public onlyOwner employeeExist(empid){
    	var employee = employees[empid];
      	_partialPay(employee);
      	totalSalary = totalSalary.sub(employees[empid].salary);
        employees[empid].lastPayDay = now;
        employees[empid].salary = salary.mul(1 ether);
        totalSalary = totalSalary.add(employees[empid].salary);
        
    }
    

    //增加修改员工付款地址
    function changePaymentAddress(address oldAddress,address newAddress) public onlyOwner employeeExist(oldAddress) employeeNotExist(newAddress)
    {
    	var oldSalary = employees[oldAddress].salary;
    	//addEmployee(newAddress,oldSalary.div(1 ether));
        //调用下面的代码 gas花费更少，上面代码多了除法操作需要花费gas       
         employees[newAddress] = Employee(newAddress, oldSalary, now);
         totalSalary = totalSalary.add(employees[newAddress].salary);
        removeEmployee(oldAddress);
       
        
    }

   function addFund() public payable returns (uint leftSalary){
        leftSalary = this.balance;
    }

   function calculateRunway() public view returns (uint times){
      times = this.balance / totalSalary;
    }

   function hasEnoughFound() public view returns(bool enough){
        enough =  calculateRunway() > 0;
    }

   function getPaid() public employeeExist(msg.sender) {
        var employee = employees[msg.sender];
        uint nextPayday = employee.lastPayDay.add(payDuration);
    	assert(nextPayday < now);

        employees[msg.sender].lastPayDay = nextPayday;
        employee.id.transfer(employee.salary);

    }
}
