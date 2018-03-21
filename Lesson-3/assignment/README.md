## 硅谷live以太坊智能合约 第三课作业
这里是同学提交作业的目录

### 第三课：课后作业
- 第一题：完成今天所开发的合约产品化内容，使用Remix调用每一个函数，提交函数调用截图
- 第二题：增加 changePaymentAddress 函数，更改员工的薪水支付地址，思考一下能否使用modifier整合某个功能
- 第三题（加分题）：自学C3 Linearization, 求以下 contract Z 的继承线
- contract O
- contract A is O
- contract B is O
- contract C is O
- contract K1 is A, B
- contract K2 is A, C
- contract Z is K1, K2



L(O) := [O];
L(A) := [A] + merge(L(O), [O])
      = [A] + merge([O], [O])
      = [A, O]

L(B) :=[B,O]
L(C) :=[C,O]

L(K1) := [K1] + merge(L(A), L(B), [A, B]) //先找出L(A) L(B) 并和 [A,B]合并
	   = [K1] + merge([A, O], [B, O], [A, B]) //由于 A 只出现在第一个和最后一个list中，所以A可以胜出
	   = [K1, A] + merge([O], [B, O], [B]) // 同上 B胜出
	   = [K1, A, B] + merge([O], [O]) //只剩下 O
	   = [K1, A, B, O]

L(K2) := [K2] + merge(L(A), L(C), [A, C]) //先找出L(A) L(C) 并和 [A,C]合并
	   = [K2] + merge([A, O], [C, O], [A, C]) //由于 A 只出现在第一个和最后一个list中，所以A可以胜出
	   = [K2, A] + merge([O], [C, O], [C]) // 同上 C胜出
	   = [K2, A, C] + merge([O], [O]) //只剩下 O
	   = [K2, A, C, O]

L(Z) :=[Z] + merge(L(K1), L(K2), [K1, K2]) //先找出L(K1) L(K2) 并和 [K1,K2]合并
      =[Z] + merge([K1, A, B, O], [K2, A, C, O], [K1, K2]) //由于 K1 只出现在第一个和最后一个list中，所以K1可以胜出
      =[Z, K1] + merge([A, B, O], [K2, A, C, O], [K1, K2]) // 同上 K2 胜出
      =[Z, K1, K2] + merge([A, B, O], [A, C, O]) //A 胜出
      =[Z, K1, K2, A] + merge([B, O], [C, O]) //B 胜出
      =[Z, K1, K2, A, B] + merge([O], [C, O]) //C 胜出
      =[Z, K1, K2, A, B, C] + merge([O], [O]) //只剩下 O
      =[Z, K1, K2, A, B, C, O]

