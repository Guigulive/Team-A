/*作业请提交在这个目录下*/
pragma solidity ^0.4.14;

contract Payroll{
    
    //定义变量
    address owner;
    Employee[] employees;
    uint constant payDuration = 10 seconds;
    
    //初始化构造
    function Payroll(){
        
        owner= msg.sender;
    }
    //对象
    struct Employee {
        
        address id;
        uint salary;
        uint lastPayDay;
    }
    
    //根据地址获得雇员
    function _getEmployee(address empId)private returns (Employee,uint){
        
        for(uint i = 0; i<employees.length; i++){
             
            if(employees[i].id == empId){
                
                return(employees[i],i);       
            }   
        }        
    }
    
    //清算工资
    function _partialPay(Employee emp,uint salary) private{
        
          uint sum =  emp.salary * (now - emp.lastPayDay) / payDuration ;
          emp.id.transfer(sum);
        
    }
    
    //添加员工
    function addEmployee(address empId,uint s){
        require(msg.sender == owner);
        var(employee,index) = _getEmployee(empId);
        
        //tips :check
        assert(employee.id == 0x0);
        employees.push(Employee(empId,s * 1 ether,now));
        
    }
    
    //移除员工
    function removeEmployee(address empId) public{
        require(msg.sender == owner);
        var(employee,index)  = _getEmployee(empId);

        //注意这里的校验
        assert(employee.id != 0x0);
        _partialPay(employee,employee.salary);
        
        //移除员工
        delete(employees[index]);
        employees[index] =employees[employees.length -1];
        employees.length-=1;
        
    }
  
    //更新员工信息
    function updateEmplpyee (address empId,uint n){
        
        require(msg.sender == owner);
        
        var(employee,index) =  _getEmployee(empId);
        
        assert(employee.id!= 0x0);
         _partialPay(employee,employee.salary);
         
         //warning!!!!!!!!!!!!!!!!! storage     
        employees[index].lastPayDay = now;
        employees[index].salary = n * 1 ether;
    }

    //雇主添加工资余额
   function addFund() payable returns (uint){
        return  this.balance;
    }

    //计算能支付多少次
   function calculateRunway() public  returns (uint){
       uint sumBalance = 0;
        for(uint i = 0; i<employees.length; i++){
           
           sumBalance += employees[i].salary;
       }
        return this.balance / sumBalance;
    }

    //是否足够支付下次工资
   function hasEnoughFound()public returns(bool){
        return calculateRunway() > 0;
    }

    //支付公资
   function getPaid()public {

        var(employee,index) = _getEmployee(msg.sender);
        
        assert(employee.id != 0x0);
        uint nextDay = employee.lastPayDay + payDuration;

        assert(nextDay < now);
        employee.lastPayDay = nextDay;
        employee.id.transfer(employee.salary);

    }
}
