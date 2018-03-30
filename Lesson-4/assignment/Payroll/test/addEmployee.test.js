const Payroll = artifacts.require("./Payroll.sol");

contract('Payroll', function (accounts) {
  const owner = accounts[0];
  const employeeId = accounts[1];
  const salray = 1;

  it("addEmployee test", function () {
    let payroll;
    return Payroll.deployed().then(instance => {
      payroll = instance;
      return payroll.addEmployee(employeeId, salray, { from: owner });
    }).then(() => {
      return payroll.employees(employeeId);
    }).then(employee => {
      exists = !!employee;
      assert.equal(exists, true, "addEmployee OK.");
    });
  });
});
