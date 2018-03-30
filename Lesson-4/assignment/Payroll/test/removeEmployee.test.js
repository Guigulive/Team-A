const Payroll = artifacts.require("./Payroll.sol");

contract('Payroll', function (accounts) {
  const owner = accounts[0];
  const employeeId = accounts[1];
  const salray = 1;

  it("removeEmployee test", function () {
    let payroll;
    return Payroll.deployed().then(instance => {
      payroll = instance;
      return payroll.addEmployee(employeeId, salray, { from: owner });
    }).then(() => {
      return payroll.removeEmployee(employeeId);
    }).then(() => {
      return payroll.employees(employeeId);
    }).then(employee => {
      assert.equal(employee[0] === '0x0000000000000000000000000000000000000000', true, "addEmployee OK.");
    });
  });
});
