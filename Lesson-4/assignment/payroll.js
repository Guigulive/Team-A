var Payroll = artifacts.require("./Payroll.sol");

contract('Payroll', function(accounts) {

  it("...should add employee successful.", function() {
    return Payroll.deployed().then(function(instance) {
      payrollInstance = instance;

      return payrollInstance.addEmployee(accounts[1], 1);
    }).then(function() {
      return payrollInstance.employees.call(accounts[1]);
    }).then(function(employee) {
      exists = !!employee;
      assert.equal(exists, true, "Add employee successfully.");
    });
  });

  it("...should not add one employee twice.", function() {
    return Payroll.deployed().then(function(instance) {
      payrollInstance = instance;

      return payrollInstance.addEmployee(accounts[1], 1);
    }).then(function() {
      return payrollInstance.addEmployee(accounts[1], 1);
    }).then(function(employee) {
        
    }, function(err){
        console.log(err);
        exists = !!err;
        assert.equal(exists, true, "Should not add a employee twice.");
    });
  });

  it("...should remove existed employee successful.", function() {
    return Payroll.deployed().then(function(instance) {
      payrollInstance = instance;
      payrollInstance.addFund({from: accounts[0], value: 100});

      return payrollInstance.addEmployee(accounts[1], 1);
    }).then(function() {
      return payrollInstance.removeEmployee(accounts[1]);
    }).then(function(res) {
      exists = !!employee;
      assert.equal(exists, true, "Add employee successfully.");
    });
  });

  it("...should not remove unexisted employee.", function() {
    return Payroll.deployed().then(function(instance) {
      payrollInstance = instance;
      return payrollInstance.removeEmployee(accounts[1]);
    }).then(function() {
     
    }, function(err){
        console.log(err);
        exists = !!err;
        assert.equal(exists, true, "Should not remove unexisted employee");
    });
  });

});