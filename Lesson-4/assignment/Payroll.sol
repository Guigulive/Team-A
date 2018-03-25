/*作业请提交在这个目录下*/
pragma solidity ^0.4.14;

contract Payroll {
    
    //定义变量
    address owner;
    mapping(address => Employee) public employees;
    uint constant payDuration = 100 seconds;
    uint sumSalary;
    
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
    
    modifier onlyOwner(){
         require(msg.sender == owner);
         _;
    }
    
     modifier checkEmployee(address id){
       assert(employees[id].id != 0x0);
        _;
    }
    //清算工资
    function _partialPay(Employee employee) private{
        
          uint sum =  employee.salary * (now - employee.lastPayDay) / payDuration ;
          employee.id.transfer(sum);
        
    }
    
    //添加员工
    function addEmployee(address id,uint salary)onlyOwner {
        
        assert(employees[id].id == 0x0);
        sumSalary += salary * 1 ether;
        employees[id] = Employee(id,salary * 1 ether,now);
        
    }
    
    //移除员工
    function removeEmployee(address id) public onlyOwner checkEmployee(id){
       // var(index)  = employees[empId]

        //注意这里的校验
        _partialPay(employees[id]);
        sumSalary -= employees[id].salary;
        //移除员工
        delete(employees[id]);
        
    }
  
    //更新员工信息
    function updateEmplpyee (address id,uint salary)onlyOwner checkEmployee(id){

       // var(employee,index) =  _getEmployee(empId);
        
         _partialPay(employees[id]);
         
         //warning!!!!!!!!!!!!!!!!! storage     
        employees[id].lastPayDay = now;
        employees[id].salary = salary * 1 ether;
        sumSalary += salary * 1 ether;
    }
    
    //change
    function changePaymentAddress(address oldAddress,address newAddress)onlyOwner checkEmployee(oldAddress){
        
        employees[oldAddress].id  = newAddress ; 
        employees[newAddress] = employees[oldAddress];//当我注掉 删除时,发现两个key指向的内存空间是独立存在的
        delete(employees[oldAddress]);
        
    }

    //雇主添加工资余额
   function addFund() payable returns (uint leftSalary){
        leftSalary = this.balance;
    }

    //计算能支付多少次
   function calculateRunway() public  returns (uint month){
      
      month = this.balance / sumSalary;
    }

    //是否足够支付下次工资
   function hasEnoughFound()public returns(bool enough){
        enough =  calculateRunway() > 0;
    }

    //支付工资
   function getPaid()public checkEmployee(msg.sender) {
        
        uint nextDay = employees[msg.sender].lastPayDay + payDuration;

        assert(nextDay < now);
        employees[msg.sender].lastPayDay = nextDay;
        msg.sender.transfer(employees[msg.sender].salary);

    }

}

