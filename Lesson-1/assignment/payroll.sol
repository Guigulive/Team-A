pragma solidity ^0.4.14;

contract Payroll{
    uint constant payDuration = 30 days;
    uint lastPayday;
    address contractOwner;
    address employee;
    uint  employeeSalary;
    
    /**
     *  创建合约的时候，需要充一笔钱作为启动资金，并且指定员工收款地址和薪水数量 
     *  
     **/  
    function Payroll(address initEmployee, uint initSalary) payable {
      require(initEmployee != address(0));
      require(initEmployee != msg.sender);
      require(this.balance > initSalary);
      contractOwner = msg.sender;
      employee = initEmployee;
      employeeSalary = initSalary * 1 ether;
      lastPayday = now;
    }
    
    function addFund() payable returns (uint){
        return this.balance;
    }
    
    function calculateRunway() returns (uint){
        return this.balance / employeeSalary;
    }
    
    function hasEnoughFund() returns (bool){
        return calculateRunway() > 0;
    }
    
    /**
     *  员工获取薪水的时候需要判断: 
     *  1- 调用者必须是合约指定的员工
     *  2- 当前时间必须大于合约指定的领取时间
     *  3- 如果员工是隔了几个间隔时间来领取的时候，需要支付这几个间隔时间的总数 
     **/  
    function getPaid() returns (uint){
        require(employee == msg.sender);
        uint nextPayday = lastPayday + payDuration;
        assert(now > nextPayday);
        uint mount = (now - lastPayday) / payDuration * employeeSalary;
        lastPayday = nextPayday;
        employee.transfer(mount);
        return this.balance;
    }
    

    /**
     *  更新员工时需要判断: 
     *  1- 调用者必须是合约拥有者地址
     *  2- 新员工地址不等于旧地址
     *  3- 新地址不能等于合约拥有者地址
     *  3- 需要将旧员工之前的薪水结算完成
     **/  
    function updateEmployee(address newAddress, uint newSalary){
        require(msg.sender == contractOwner);
        require(newAddress != address(0));
        require(newAddress != contractOwner);
        require(newAddress != employee);
        
        if(employee != address(0)){
             uint mount = (now - lastPayday) / payDuration * employeeSalary;
             employee.transfer(mount);
        }
        
        employee = newAddress;
        employeeSalary = newSalary * 1 ether;
        //lastPay
        lastPayday = now;
    }

    /**
     * 更新当前员工薪水用于加薪:
     *  1- 调用者必须是合约拥有者地址
     *  2- 下次领钱的时候用新的薪水
     **/  
    function updateCurrentEmployeeSalary(uint newSalary){
        require(msg.sender == contractOwner);
        employeeSalary = newSalary * 1 ether;
    }
}