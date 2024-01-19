use "macro_workfile.dta",replace
xtset statefip wrkyr

gen policy = wrkyr - branch_reform
replace policy = -5 if policy <= -5
replace policy = 10 if policy >= 10

gen policy_d = policy + 5
gen y = log(gini)

xtreg y ib0.policy_d i.wrkyr, fe r   //第一期作为基准组
///生成前五期系数均值
forvalues i = 0/4{
    gen b_`i' = _b[`i'.policy_d]
}
gen avg_coef = (b_0+b_4+b_3+b_2+b_1)/5
su avg_coef

coefplot, baselevels ///
   drop(*.wrkyr _cons policy_d) ///
   coeflabels(0.policy_d = "t-5" ///
   1.policy_d = "t-4" ///
   2.policy_d = "t-3" ///
   3.policy_d = "t-2" ///
   4.policy_d = "t-1" ///
   5.policy_d = "t" ///
   6.policy_d = "t+1" ///
   7.policy_d = "t+2" ///
   8.policy_d = "t+3" ///
   9.policy_d = "t+4" ///
   10.policy_d = "t+5" ///
   11.policy_d = "t+6" ///
   12.policy_d = "t+7" ///
   13.policy_d = "t+8" ///
   14.policy_d = "t+9" ///
   15.policy_d = "t+10") ///更改系数的label
   vertical ///转置图形
   yline(0, lwidth(vthin) lpattern(dash) lcolor(teal)) ///加入y=0这条虚线
   ylabel(-0.06(0.02)0.06) ///
   xline(6, lwidth(vthin) lpattern(dash) lcolor(teal)) ///
   ytitle("Percentage Changes", size(small)) ///加入Y轴标题,大小small
   xtitle("Years relative to branch deregulation", size(small)) ///加入X轴标题，大小small
   transform(*=@-r(mean)) ///去除前五期的系数均值
   addplot(line @b @at) ///增加点之间的连线
   ciopts(lpattern(dash) recast(rcap) msize(medium)) ///CI为虚线上下封口
   msymbol(circle_hollow) ///plot空心格式
   scheme(s1mono)