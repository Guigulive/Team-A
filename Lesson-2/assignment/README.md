## 硅谷live以太坊智能合约 第二课作业
这里是同学提交作业的目录

### 第二课：课后作业
完成今天的智能合约添加100ETH到合约中
- 加入十个员工，每个员工的薪水都是1ETH
每次加入一个员工后调用calculateRunway这个函数，并且记录消耗的gas是多少？Gas变化么？如果有 为什么？

1.
transaction cost 	23568 gas
execution cost 	696 gas
2.
transaction cost 	23722 gas
execution cost 	2450 gas
3.
transaction cost 	24503 gas
execution cost 	3231 gas
4.
transaction cost 	25284 gas
execution cost 	4012 gas
5.
transaction cost 	26065 gas
execution cost 	4793 gas
6.
transaction cost 	26846 gas
execution cost 	5574 gas
7.
transaction cost 	27627 gas
execution cost 	6355 gas
8.
transaction cost 	28408 gas
execution cost 	7136 gas
9.
transaction cost 	29189 gas
execution cost 	7917 gas
10.
transaction cost 	29970 gas
execution cost 	8698 gas

因为现在调用calculateRunway时每次employees的长度有变化，都要重新遍历employees

- 如何优化calculateRunway这个函数来减少gas的消耗？
提交：智能合约代码，gas变化的记录，calculateRunway函数的优化
把totalSalary定义在storage里面，在对employees更改时都要更新这个数

```
contract Payroll {
    uint totalSalary;

    function addEmployee(address employeeId, uint salary) public {
        ...
        totalSalary += salary * 1 ether;
    }

    function removeEmployee(address employeeId) public {
        ...
        totalSalary -= employee.salary;
    }

    function updateEmployee(address employeeId, uint salary) public {
        ...
        totalSalary -= employee.salary;
        employees[index].id = employeeId;
        employees[index].salary = salary * 1 ether;
        employees[index].lastPayday = now;
        totalSalary -= salary * 1 ether;;
    }

    function calculateRunway() public view returns (uint) {
        return this.balance / totalSalary;
    }
}
```

这样修改以后gas保持不变
transaction cost 	22099 gas
execution cost 	827 gas
