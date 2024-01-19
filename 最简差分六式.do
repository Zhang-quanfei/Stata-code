*双重差分六式
*-1.基准回归系列
use nlswork,clear
gen dum_t = (coll == 1)
gen dum_a = (year>79)
gen dum_ta = dum_t*dum_a

reg ln dum_t dum_a dum_ta //最简

reg ln dum_t dum_a dum_ta i.year //加时间固定

xtreg ln dum_ta i.year,fe //加个体固定

xtreg ln dum_ta i.year,fe clu(id) //加聚类稳健

*-2.平行性假设

xtreg ln dum_t##i.year,fe clu(id) //看政策冲击前各期

reg ln i.year 
bys year:su ln   //理解一下
reg ln dum_t


*-3.三重差分

 gen dum_i = (ind == 11)

xtreg ln dum_t##dum_a##dum_i i.year,fe clu(id) //看政策冲击前各期

*-4.安慰剂

 gen dum_ft = (race == 1)
 gen dum_fa = (year > 75 )
 
 xtreg ln dum_ft##dum_a i.year,fe clu(id)

 xtreg ln dum_t##dum_fa i.year,fe clu(id)

*-5.工具变量

xi:xtivreg2 ln i.year (dum_ta = msp),first fe clu(id) //加聚类稳健


*-6.高维度固定效应

gen dum_o = 

xtreg ln dum_ta i.year##i.ind##i.occ,fe clu(id)

reghdfe ln dum_ta grade age ttl_exp tenure not_smsa south , ///
	absorb(idcode year i.year##i.ind##i.occ)













