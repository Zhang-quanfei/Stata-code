clear    //清空数据 
set obs 100    //设置100观测值
egen country_id = seq(),b(10)    //每10个重复构造整数序列，生成变量country_id
bysort country_id: gen time = _n    //根据分组country_id生成时间变量

set seed 12345   //设置种子值确保可重复
gen y = uniform()   //生成被解释变量y服从正态分布
forv i = 1/8{
gen z`i' = uniform()
}   //循环语句生成8个解释变量


xtqreg y z1 z2 z3 z4 z5 z6 z7 z8 i.time, i(country_id) quantile(.1(0.1)0.9)  //面板分位数回归


local x1 "z1 z2 z3 z4 z5 z6 z7 z8"   //局部宏定义所有解释变量
*list  `x1'   //列出所有被解释变量

local v_num : word count `x1'   //利用扩展函数 word count string 得到x1中变量的个数
di `v_num'   //v_num表示最大的循环个数,8个
est clear
mat result1 = J(`v_num',1,.) //生成空矩阵result1,8行1列
matrix rownames result1 = `x1'   //矩阵行命名为对应的被解释变量
mat list result1   //列出空矩阵 从local开始到此行，必须一次性执行

tempname a b b1   //设定临时矩阵变量名
forvalues quantile = 0.1(0.1)0.9 {   //从0.1-0.9没隔0.1开始循环 
    local wanted : di %2.1f `quantile'   //列出循环分位点长度设置为2，保留一位小数，定义为`wanted'
 local wanted = `wanted'*10    //`wanted'为每一分位点重复十次
 
    xtqreg y `x1', i(country_id) q(`quantile')   //面板分位数回归
	
    matrix `a' = r(table)   //对应各个分位点估计的`x1'系数
 mat list `a'	//列出面板分位数回归`a'矩阵
    matrix `b' = `a'[1,1..`v_num'] \ `a'[2,1..`v_num'] //仅取出面板分位数回归`a'矩阵的前两行构成`b'矩阵,第一行是系数。第二行是标准误，第四行是p值
 mat list `b'   //列出`b'矩阵
 mat `b1' = `b''   
 matrix colnames `b1' = b_q`wanted' p_q`wanted'   //`b1'为`b'矩阵的转置
 mat list `b1'   //列出`b1'矩阵
 matrix result1 = (result1, `b1')    //`b1'数据导入列出空矩阵result1
}

mat list result1
matselrc result1 cresult, c(2/19) //19列 = 2*分位个数+1列无用项（第一列），保留有用数据列
mat list cresult

local newnames : colfullnames cresult
di "`newnames'"
local cn : word count `newnames'  //此处的local和上一个local一定要一次性执行
di `cn' 
svmat cresult, names(reg)   //矩阵数据转换为变量
keep reg*

format reg* %4.3f   //设定格式为保留三位小数
drop if reg1==. //删除缺失值，放入几个解释变量，删完以后就会有几行，变量个数为18，对应不同分位点的系数和标准误 9*2=18

forv i = 1/9 {  /*9：分位个数*/
local k1 = 2*`i' - 1   //奇数列为系数
local k2 = 2*`i'       //偶数列为标准误
gen up_`i' = reg`k1' + 1.96*reg`k2'   //上界
gen low_`i' = reg`k1' - 1.96*reg`k2'  //下界
}

preserve 
keep reg1 reg3 reg5 reg7 reg9 reg11 reg13 reg15 reg17   //保留系数列
rename (reg1 reg3 reg5 reg7 reg9 reg11 reg13 reg15 reg17) (reg1 reg2 reg3 reg4 reg5 reg6 reg7 reg8 reg9)   //重命名
xpose,clear  //转置数据
renvars v*,  prefix(coef_)   //重命名加前缀coef_
save coef.dta,replace  //储存系数数据
restore   //preserve+restore运行不保存

keep up* low*   //保留上下界数据
xpose,clear   //转置数据
preserve
keep if mod(_n,2)==1   //保留奇数行作为上界数据
renvars v*,  prefix(up_)     //重命名加前缀up_
save up.dta,replace    //储存上界数据
restore

preserve   
keep if mod(_n,2)==0   //保留偶数行作为下界数据
renvars v*,  prefix(low_)   //重命名加前缀low_
save low.dta,replace   //储存下界数据
restore 

use up.dta,clear    //打开上界数据
merge 1:1 _n using low.dta   //一对一合并数据
keep if _merge==3   //合并匹配成功为_merge==3，保留合并成功行
drop _merge  //删除合并信息
merge 1:1 _n using coef.dta   //一对一合并数据
keep if _merge==3
drop _merge  //删除合并信息

matrix input myrvec = (0.10,0.20,0.30,0.40,0.50,0.60,0.70,0.80,0.90)
mat list myrvec
mat qq = myrvec'  //qq矩阵为myrvec的转置
mat list qq
svmat qq, names(qqp)  //矩阵数据转换为变量

forv i = 1/8{
twoway (line up_v`i' qqp,lc(black*1.4) lpattern(dash) xlabel(0.10 0.20 0.30 0.40 0.50 0.60 0.70 0.80 0.90)) ///
(line low_v`i' qqp,lc(black*1.4) lpattern(dash) xlabel(0.10 0.20 0.30 0.40 0.50 0.60 0.70 0.80 0.90))  ///
(line coef_v`i' qqp, lc(black*2)  lw(thick)) ,xtitle("不同水平分位数") ytitle("Coefficient(z`i')") plotregion(margin(zero)) graphregion(color(white)) legend(off)
graph save g_`i',replace  //存图时不加后缀，下面combine时必须加.gph后缀
}

graph combine g_1.gph g_2.gph g_3.gph  g_4.gph g_5.gph g_6.gph g_7.gph g_8.gph
