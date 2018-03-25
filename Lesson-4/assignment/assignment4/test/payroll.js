var Payroll = artifacts.require("./Payroll.sol");

contract('payroll', function(accounts) {
  // Test add employee
  it("add employee", function() {
    return Payroll.deployed().then(function(contract) {
      payrollInstance = contract;
      return payrollInstance.addEmployee(accounts[1], 1,{from: accounts[0]});
    }).then(function() {
      return payrollInstance.employees.call(accounts[1]);
    }).then(function(employees) {
      assert.equal(employees[0], accounts[1], "Add employee successfully.");
    });
  });

  it("remove employee", function() {
    return Payroll.deployed().then(function(contract) {
      payrollInstance = contract;
      return payrollInstance.removeEmployee(accounts[1],{from: accounts[0]});
    }).then(function() {
      return payrollInstance.employees.call(accounts[1]); 
     }).then(function(employee) {
      assert.equal(employee[0], 0, "Remove employee successfully.");
    });
  });
})