pragma solidity ^0.4.14;

contract Payroll{
    uint constant payDuration = 30 days;
    address contractOwner;
    uint totalSalary = 0;

    Employee[] employees;

    struct Employee {
      address id;
      uint salary;
      uint lastPayday;
    }


    /**
     *  封装一个函数用来进行部分付款
     *  
     **/  
    function _partialPaid(Employee employee) private {
        uint mount = employee.salary * (now - employee.lastPayday) / payDuration ;
        employee.lastPayday = now;
        employee.id.transfer(mount);
    }

    /**
     *  封装一个函数用来进行员工查找
     *  
     **/  
    function _findEmployee(address employeeId) private returns (Employee, uint) {
       for(uint i=0; i < employees.length; i++){
          if(employees[i].id == employeeId) {
            return (employees[i], i);
          }
       }
    }

  

    /**
     *  新增员工
     *  
     **/  
    function addEmployee(address employeeId, uint salary) {
       require(employeeId != contractOwner);
       require(msg.sender == contractOwner);
       var (employee, index) = _findEmployee(employeeId);

       assert(employee.id == 0x0);
       employees.push(Employee(employeeId, salary * 1 ether, now));
       totalSalary += salary * 1 ether;
    }

    /**
     *  删除员工
     *  
     **/  
    function removeEmployee(address employeeId) {
       require(msg.sender == contractOwner);
       var (employee, index) = _findEmployee(employeeId);
       assert(employee.id != 0x0);

       _partialPaid(employee);
       delete employees[index];
       employees[index] = employees[employees.length-1];
       employees.length -= 1;
       totalSalary -= employee.salary;

    }

    /**
     *  更新员工时需要判断: 
     *  1- 调用者必须是合约拥有者地址
     *  3- 新地址不能等于合约拥有者地址
     *  3- 需要将旧员工之前的薪水结算完成
     **/  
    function updateEmployee(address newAddress, uint newSalary){
        require(newAddress != address(0));
        require(newAddress != contractOwner);
        require(msg.sender == contractOwner);
        var (employee, index) = _findEmployee(newAddress);
        assert(employee.id != 0x0);

        _partialPaid(employee);

        employees[index].salary = newSalary * 1 ether;
        employees[index].lastPayday = now;  

        totalSalary += (employees[index].salary -  employee.salary );

    }
    
    
    /**
     *  创建合约的时候，需要充一笔钱作为启动资金，并且指定员工收款地址和薪水数量 
     *  
     **/  
    function Payroll(address initEmployee, uint initSalary) payable {
      require(initEmployee != address(0));
      require(initEmployee != msg.sender);
      require(this.balance > initSalary);
      contractOwner = msg.sender;

      addEmployee(initEmployee, initSalary);
    }
    
    function addFund() payable returns (uint){
        return this.balance;
    }
    
    /**
     *  当员工个数增加，调用calculateRunway 花费gas 增加，猜测原因为 每次都重新计算totalSalary，每次都进行循环
     *  修改为定义一个成员变量 totalSalary，在人员变化的时候相应的修改
     **/
    function calculateRunway() returns (uint){
       // uint totalSalary = 0;
       // for(uint i=0; i < employees.length; i++){
       //   totalSalary += employees[i].salary;
       // }
        return this.balance / totalSalary;
    }
    
    function hasEnoughFund() returns (bool){
        return calculateRunway() > 0;
    }
    
    /**
     *  员工获取薪水的时候需要判断: 
     *  1- 调用者必须是合约指定的员工
     *  2- 当前时间必须大于合约指定的领取时间
     **/  
    function getPaid() {
      var (employee, index) = _findEmployee(msg.sender);
      assert(employee.id != 0x0);

        uint nextPayday = employee.lastPayday + payDuration;
        assert(now > nextPayday);
        employees[index].lastPayday = nextPayday;
        employee.id.transfer(employee.salary);
    }
    
}