import React, { Component } from 'react'
import { Table, Button, Modal, Form, InputNumber, Input, message, Popconfirm } from 'antd';

import EditableCell from './EditableCell';

const FormItem = Form.Item;

const columns = [ {
    title: '地址',
    dataIndex: 'address',
    key: 'address',
}, {
    title: '薪水',
    dataIndex: 'salary',
    key: 'salary',
}, {
    title: '上次支付',
    dataIndex: 'lastPaidDay',
    key: 'lastPaidDay',
}, {
    title: '操作',
    dataIndex: '',
    key: 'action'
} ];

class EmployeeList extends Component {
    constructor( props ) {
        super( props );
        
        this.state = {
            loading: true,
            employees: [],
            showModal: false
        };
        
        columns[ 1 ].render = ( text, record ) => (
            <EditableCell
                value={text}
                onChange={this.updateEmployee.bind( this, record.address )}
            />
        );
        
        columns[ 3 ].render = ( text, record ) => (
            <Popconfirm title="你确定删除吗?" onConfirm={() => this.removeEmployee( record.address )}>
                <a href="#">Delete</a>
            </Popconfirm>
        );
    }
    
    componentDidMount() {
        this.loadEmployees();
        
    }
    
    loadEmployees = async () => {
        
        // function checkInfo() returns (uint balance, uint runway, uint employeeCount)
        // function checkEmployee(uint index) returns (address employeeId, uint salary, uint lastPayday)
        const { payroll, account, web3 } = this.props;
        
        
        const info = await payroll.checkInfo.call( {
            from: account
        } )
        
        const employeeCount = info[ 2 ].toNumber()
        
        if ( employeeCount === 0 ) {
            this.setState( { loading: false } );
            return;
        }
        
        const requests = [];
        for ( let i = 0; i < employeeCount; i++ ) {
            requests.push( payroll.checkEmployee.call( i, { from: account } ) )
        }
        
        const responses = await Promise.all( requests )
        const employees = responses.map( res => ({
            key: res[ 0 ],
            address: res[ 0 ],
            salary: web3.fromWei( res[ 1 ].toNumber() ),
            lastPaidDay: new Date( res[ 2 ].toNumber() * 1000 ).toLocaleString(),
        }) )
        
        this.setState( {
            employees,
            loading: false,
        } )
        
    }
    
    addEmployee = async () => {
        
        const { payroll, account } = this.props
        const { address, salary, employees } = this.state
        
        await payroll.addEmployee( address, salary, { from: account, gas: 3000000 } )
        
        const newEmployee = {
            key: address,
            address,
            salary,
            lastPaidDay: +new Date(),
        }
        
        this.setState( {
            employees: [ ...this.state.employees, newEmployee ],
            showModal: false
        } )
        
    }
    
    updateEmployee = async ( address, salary ) => {
        const { payroll, account } = this.props
    
        // 理论上可行执行，不过合约好像有问题，revert 了，有时间再看。
        await payroll.updateEmployee( address, salary, { from: account } )
    
        this.setState( {
            employees: this.state.employees.map(e => {
                if(e.address === address) {
                    return {
                        ...e,
                        salary,
                    }
                } else {
                    return e
                }
            }),
        } )
    
    }
    
    removeEmployee = async ( employeeId ) => {
        const { payroll, account } = this.props
        const { employees } = this.state
    
        // 理论上可行执行，不过合约好像有问题，revert 了，有时间再看。
        await payroll.removeEmployee( employeeId, { from: account } )
        
        this.setState( {
            employees: this.state.employees.filter(e => e.address !== employeeId),
        } )
    
    }
    
    renderModal = () => {
        return (
            <Modal
                title="增加员工"
                visible={this.state.showModal}
                onOk={this.addEmployee}
                onCancel={() => this.setState( { showModal: false } )}
            >
                <Form>
                    <FormItem label="地址">
                        <Input
                            onChange={ev => this.setState( { address: ev.target.value } )}
                        />
                    </FormItem>
                    
                    <FormItem label="薪水">
                        <InputNumber
                            min={1}
                            onChange={salary => this.setState( { salary } )}
                        />
                    </FormItem>
                </Form>
            </Modal>
        );
        
    }
    
    render() {
        const { loading, employees } = this.state;
        return (
            <div>
                <Button
                    type="primary"
                    onClick={() => this.setState( { showModal: true } )}
                >
                    增加员工
                </Button>
                
                {this.renderModal()}
                
                <Table
                    loading={loading}
                    dataSource={employees}
                    columns={columns}
                />
            </div>
        );
    }
}

export default EmployeeList
