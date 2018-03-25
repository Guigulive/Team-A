const Payroll = artifacts.require("./Payroll.sol");
const Web3 = require('web3');
const web3 = new Web3(new Web3.providers.HttpProvider("http://localhost:7545"));

// use timeTravel to change timestamp
const timeTravel = function (time) {
  return new Promise((resolve, reject) => {
    web3.currentProvider.sendAsync({
      jsonrpc: "2.0",
      method: "evm_increaseTime",
      params: [time], //86400 is num seconds in day
      id: new Date().getTime()
    }, (err, result) => {
      if(err){ return reject(err) }
      return resolve(result)
    });
  })
}

contract('Payroll', function(accounts) {
  const contractOwner = accounts[0];

  it("should add employee only by owner", async function () {
    var slave_one = accounts[1];
    var slave_two = accounts[2];

    let meta = await Payroll.deployed({from: contractOwner});

    // add employee by owner
    await meta.addEmployee(slave_one, 0.01, {from: contractOwner});

    // add duplicated employee by owner
    try {
      await meta.addEmployee(slave_one, 0.01, {from: contractOwner});
    } catch (e) {
      return true;
    }
    throw new Error("slave already exisit! wtf?");

    // add employee by another employee
    try {
      await meta.addEmployee(slave_two, 0.01, {from: slave_one});
    } catch (e) {
      return true;
    }
    throw new Error("slave is trying to add another slave!")
  });

  it("should remove employee only by owner", async function () {
    var slave_one = accounts[3];
    var slave_two = accounts[4];
    var slave_three = accounts[5];

    let meta = await Payroll.deployed({from: contractOwner });
    let addFund = await meta.addFund({ from: contractOwner, value: web3.toWei(0.1, "ether") });
    await meta.addEmployee(slave_one, 0.01, {from: contractOwner});
    await meta.addEmployee(slave_two, 0.01, {from: contractOwner});
    await meta.addEmployee(slave_three, 0.01, {from: contractOwner});

    // remove slave by owner
    await meta.removeEmployee(slave_one, {from: contractOwner});

    // remove slave again by owner
    try {
      await meta.removeEmployee(slave_one, {from: contractOwner});
    } catch (e) {
      return true;
    }
    throw new Error("slave not exsit what are you trying to do?");

    // remove slave by slave
    try {
      await meta.removeEmployee(slave_two, {from: slave_three});
    } catch (e) {
      return true;
    }
    throw new Error("slave removed another slave!");
  });

  it("should get pay in one day", async function () {
    var slave_one = accounts[6];
    var init_slave_balance = accounts[6].balance;

    let meta = await Payroll.deployed({from: contractOwner});
    let addFund = await meta.addFund({ from: contractOwner, value: web3.toWei(0.1, "ether") });
    await meta.addEmployee(slave_one, 0.01, {from: contractOwner});
    await timeTravel(86401)
    // employee get first payment
    await meta.getPaid({from: slave_one});

    // employee get second payment should fail
    try {
      await meta.getPaid({from: slave_one});
    } catch (e) {
      return true;
    }
    throw new Error("slave is sucking your blood! Can not pay him more!");

    // work one more day and get pay
    await timeTravel(86401)
    await meta.getPaid({from: slave_one});

    // to-do:
    // compare employee's slary before and after getPaid()
  });


});
