*--------------------
* 引用Stata的返回值
sysuse auto, clear
reg price weight length turn
eret list
