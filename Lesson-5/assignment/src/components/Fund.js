import React, { Component } from 'react'
import { Form, InputNumber, Button, message } from 'antd';

import Common from './Common';

const FormItem = Form.Item;

class Fund extends Component {
  constructor(props) {
    super(props);

    this.state = {
      loading: false
    }; // state component
  }

  handleSubmit = (ev) => {
    ev.preventDefault();
    this.setState({ loading: true });
    const { payroll, account, web3 } = this.props;
    payroll.addFund({
      from: account,
      value: web3.toWei(this.state.fund)
    }).then(res => {
      this.refs.common.checkInfo();
      this.setState({ loading: false });
    }).catch(err => {
      this.setState({ loading: false });
      message.error(err.message);
    });
  }

  render() {
    const { account, payroll, web3 } = this.props;
    return (
      <div>
        <Common account={account} payroll={payroll} web3={web3} ref="common"/>

        <Form layout="inline" onSubmit={this.handleSubmit}>
          <FormItem>
            <InputNumber
              min={1}
              onChange={fund => this.setState({fund})}
            />
          </FormItem>
          <FormItem>
            <Button
              type="primary"
              htmlType="submit"
              disabled={!this.state.fund}
              loading={this.state.loading} onClick={this.enterLoading}
            >
              增加资金
            </Button>
          </FormItem>
        </Form>
      </div>
    );
  }
}

export default Fund