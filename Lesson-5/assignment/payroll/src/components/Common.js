import React, { Component } from 'react'

class Common extends Component {
  constructor(props) {
    super(props);
    this.state = {};
  }

  componentDidMount() {
    const { payroll, web3, account } = this.props;
    payroll.getInfo.call({
        from: account,
    }).then((result)=> {
        this.setState({
            balance: web3.fromWei(result[0].toNumber()),
            runway: result[1].toNumber(),
            employeeCount: result[2].toNumber()                           
        })
    });
  }

//     this.newFund = payroll.NewFund(updateInfo);
//     this.getPaid = payroll.GetPaid(updateInfo);
//     this.newEmployee = payroll.NewEmployee(updateInfo);
//     this.updateEmployee = payroll.UpdateEmployee(updateInfo);
//     this.removeEmployee = payroll.RemoveEmployee(updateInfo);

//     this.checkInfo();
//   }

//   componentWillUnmount() {
//     this.newFund.stopWatching();
//     this.getPaid.stopWatching();
//     this.newEmployee.stopWatching();
//     this.updateEmployee.stopWatching();
//     this.removeEmployee.stopWatching();
//   }

//   checkInfo = () => {
//     const { payroll, account, web3 } = this.props;
//     payroll.checkInfo.call({
//       from: account,
//     }).then((result) => {
//       this.setState({
//         balance: web3.fromWei(result[0].toNumber()),
//         runway: result[1].toNumber(),
//         employeeCount: result[2].toNumber()
//       })
//     });
//   }

  render() {
    const { runway, balance, employeeCount } = this.state;
    return (
      <div>
        <h2>通用信息</h2>
        <p>合约金额: {balance}</p>
        <p>员工人数: {employeeCount}</p>
        <p>可支付次数: {runway}</p>
      </div>
    );
  }
}

export default Common 