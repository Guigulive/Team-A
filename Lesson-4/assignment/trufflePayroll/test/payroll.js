const Payroll = artifacts.require("./Payroll.sol");

contract('Payroll', function(accounts){
    const contractOwner = accounts[0];
    let newEmployee = accounts[1];
    let contract ;

    //正常新增员工
    it("add new employee ", function() {
         return Payroll.deployed({from: contractOwner }).then( instance => {
            contract = instance;
            return contract.addEmployee(newEmployee, 1, {from: contractOwner});
        }).then(() => {
            return contract.employees.call(newEmployee, {from: contractOwner});
        }).then(employee => {
            assert.equal(employee[0], newEmployee, 'the new employee added is not the one we expected');
            assert.equal(employee[1], web3.toWei(1), 'the new employee salary is not 1 eth');
        });
    });

    //新增已经存在的员工
    it("add existed employee ", function() {
         return Payroll.deployed({from: contractOwner }).then( instance => {
            contract = instance;
            return contract.addEmployee(newEmployee, 1, {from: contractOwner});
        }).then(employee => {
            return contract.addEmployee(newEmployee, 1, {from: contractOwner});
        }).catch(error => {
            assert.include(error.toString(), "VM Exception while processing transaction: invalid opcode", "employee has already existed");
        });
    
    });

    //越权新增员工
    it("other person add employee ", function() {
        let otherPerson = accounts[3];
         return Payroll.deployed({from: contractOwner }).then( instance => {
            contract = instance;
            return contract.addEmployee(newEmployee, 1, {from: otherPerson});
        }).catch(error => {
            assert.include(error.toString(), "VM Exception while processing transaction: revert", "not the contract owner");
        });
    
    });

    //删除不存在员工
    it("remove not existed employee", function(){
        let notExisted = accounts[3];
        return Payroll.deployed({from: contractOwner }).then( instance => {
            contract = instance;
            return contract.removeEmployee(notExisted, {from: contractOwner});
        }).catch(error => {
            assert.include(error.toString(), "VM Exception while processing transaction: invalid opcode", "remove not existed employee");
        });
    });

      //正常删除
      it("remove  employee", function(){
        return Payroll.deployed({from: contractOwner }).then( instance => {
            contract = instance;
            return contract.removeEmployee(newEmployee, {from: contractOwner});
        }).then(() => {
            return contract.employees.call(newEmployee, {from: contractOwner});
        }).then( employee => {
            assert.equal(employee[0],0x0,'remove employee fail');
        })
    });

    //越权删除
    it("other person remove employee ", function() {
        let otherPerson = accounts[3];
         return Payroll.deployed({from: contractOwner }).then( instance => {
            contract = instance;
            return contract.removeEmployee(newEmployee, {from: otherPerson});
        }).catch(error => {
            assert.include(error.toString(), "VM Exception while processing transaction: revert", "not the contract owner");
        });
    
    });
   
});

// 使用evm_increaseTime进行时间调整
contract('Payroll-extra', function(accounts){
    const contractOwner = accounts[0];
    let newEmployee = accounts[1];
    let contract ;

    //正常支付流程
    it('use getPaid', function(){
        let initEmployeeBalance;
        return Payroll.deployed({from: contractOwner }).then( instance => {
            contract = instance;
            return contract.addFund({value: web3.toWei('10', 'ether'), from: contractOwner});
        }).then(() => {
            return contract.addEmployee(newEmployee, 1, {from: contractOwner});
        }).then(() => {
            initEmployeeBalance = web3.eth.getBalance(newEmployee).toNumber();
            web3.currentProvider.send({jsonrpc: "2.0", method: "evm_increaseTime", params: [13], id: 0});
            return contract.getPaid({from:newEmployee});
        }).then(() => {
            let afterPaid = web3.eth.getBalance(newEmployee).toNumber();
            assert(afterPaid > initEmployeeBalance, 'employee getPaid fail');
        });
    });

    //还未到支付时间
    it('getPaid less than the payDuration', function(){
        let initEmployeeBalance;
        return Payroll.deployed({from: contractOwner }).then( instance => {
            contract = instance;
            return contract.addFund({value: web3.toWei('10', 'ether'), from: contractOwner});
        }).then(() => {
            return contract.addEmployee(newEmployee, 1, {from: contractOwner});
        }).then(() => {
            initEmployeeBalance = web3.eth.getBalance(newEmployee).toNumber();
            web3.currentProvider.send({jsonrpc: "2.0", method: "evm_increaseTime", params: [3], id: 0});
            return contract.getPaid({from:newEmployee});
        }).catch(error => {
            assert.include(error.toString(), "VM Exception while processing transaction: invalid opcode", "getPaid less than the payDuration");
        });
    });

    //冒充员工领取薪水
    it('not existed employee getPaid', function(){
        let initEmployeeBalance;
        let notExistedEmployee = accounts[2];
        return Payroll.deployed({from: contractOwner }).then( instance => {
            contract = instance;
            return contract.addFund({value: web3.toWei('10', 'ether'), from: contractOwner});
        }).then(() => {
            return contract.addEmployee(newEmployee, 1, {from: contractOwner});
        }).then(() => {
            web3.currentProvider.send({jsonrpc: "2.0", method: "evm_increaseTime", params: [11], id: 0});
            return contract.getPaid({from:notExistedEmployee});
        }).catch(error => {
            assert.include(error.toString(), "VM Exception while processing transaction: invalid opcode", "not existed employee getPaid");
        });
    });


});