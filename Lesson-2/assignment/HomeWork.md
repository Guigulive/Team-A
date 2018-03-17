## 1.加入十个员工，每个员工的薪水都是1ETH 每次加入一个员工后调用calculateRunway这个函数，并且记录消耗的gas是多少？Gas变化么？如果有 为什么？

1个员工 transaction cost:22966gas; execution cost:1694gas
2个员工 transaction cost:23747gas; execution cost:2475gas
3个员工 transaction cost:24528gas; execution cost:3256gas
4个员工 transaction cost:25309gas; execution cost:4037gas
5个员工 transaction cost:26090gas; execution cost:4818gas
6个员工 transaction cost:26871gas; execution cost:5599gas
7个员工 transaction cost:27652gas; execution cost:6380gas
8个员工 transaction cost:28433gas; execution cost:7161gas
9个员工 transaction cost:29214gas; execution cost:7942gas
10个员工 transaction cost:29995gas; execution cost:8723gas

gas有变化，每增加一个员工transaction cost和executoion cost都增加了781gas
因为程序中的for循环是遍历数组 ，数组每增加一个元素都会增加计算量，而这些计算都需要消耗gas

## 2.如何优化calculateRunway这个函数来减少gas的消耗？ 提交：智能合约代码，gas变化的记录，calculateRunway函数的优化

定义一个storage变量totalSalary，在每次添加和删除员工时计算出当时的总工资。从而取消calculateRunway方法中的遍历每次消耗稳定在 transaction cost:22124gas; execution cost:852gas
