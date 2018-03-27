var Payroll = artifacts.require("./Payroll.sol");

contract('payroll', function(accounts) {

  it("add employee", function() {
    return Payroll.deployed().then(function(instance) {
      payrollInstance = instance;
      return payrollInstance.addEmployee(accounts[1], 1,{from: accounts[0]});

    }).then(function() {
      return payrollInstance.employees.call(accounts[1]);

    }).then(function(employees) {
+     assert.equal(employees[0], accounts[1], "Add employee successfully.");
    });
  });

  it("add employee and remove", function() {
    return Payroll.deployed().then(function(instance) {

      payrollInstance = instance;
      return payrollInstance.addEmployee(accounts[2], 1,{from: accounts[0]});
    // }).then(function() {
    //   return payrollInstance.employees.call(accounts[2]);   
    // }).then(function(employee) {
    //   account = employee[0];
    }).then(function() {
      return payrollInstance.removeEmployee(accounts[2],{from: accounts[0]});

    }).then(function() {
      return payrollInstance.employees.call(accounts[2]); 
       
    }).then(function(employee) {
      // assert.equal(account, accounts[2], "Add employee \\");
+     assert.equal(employee[0], 0, "Remove employee successfully.");
    });
  });

//   it("Pay", function() {
//     return Payroll.deployed().then(function(instance) {

//       payrollInstance = instance;
//       return payrollInstance.addEmployee(accounts[3], 1,{from: accounts[0]});
//      }).then(function() {
//       return payrollInstance.employees.call(accounts[3]);   
//     }).then(function(employee) {
//       mowtime = employee[2];
//     }).then(function() {
//       return payrollInstance.getPaid({from: accounts[3]});
//     }).then(function() {
//       return payrollInstance.employees.call(accounts[3]); 
//     }).then(function(employee) {

// +     assert(1!=2, "Pay.");
//     });
//   });


});

