*原理：随机选择解释变量   //https://www.zhihu.com/tardis/sogou/art/415560454
use gongqi_tfp_cx_kzbl,clear
permute dum_ta beta = _b[dum_ta] se = _se[dum_ta] df = e(df_r),  ///   *df是自由度
          reps(500) seed(123) saving("simulations.dta",replace):  ///  //重复500次
		xtreg acf dum_ta  gdp2 lgdp lnrkmd ind2 lnasset age  cwgg     i.year,fe clu(id_n)

 // 回归系数
use "simulations.dta", clear
gen t_value = beta / se
gen p_value = 2 * ttail(df, abs(beta/se))   //ttail(df,t) 表示	P{T>t}即p/2值


*-----------
*-回归系数图
*-----------
#delimit ;
dpplot beta, xline(0.027, lc(black*0.5) lp(dash)) ///
 xlabel(-0.005(0.005)0.005) ///
    xtitle("Estimator", size(*0.9) height(5)) xlabel(, format(%4.3f) labsize(small)) ///
    ytitle("Density", size(*0.9)) ylabel(, nogrid format(%4.0f) labsize(small))  ///
    note("") caption("") graphregion(fcolor(white)) 

*随机抽样系数以零为均值，呈正态分布

*----------
*- 直方图 -
*----------
twoway(kdensity beta,color(midblue))(histogram beta,color(gs6%40) lcolor(white)), ///
		legend(label(1 "{stSerif:Kdensity}") label( 2 "{stSerif:Histogram}") /// 
			  size(small) ring(0)  position(1) cols(1))  ///
			  xlabel(, labsize(small)) ///
			  ylabel(,  angle(0) labsize(small)) /// 
			  xtitle("{stSerif:Distribution of Placebo Effects}" ,size(median)) ///
			  xline(0,lwidth(thin) lp(shortdash) lcolor(black) ) ///
			  ytitle("{stSerif:Density}", orientation(horizontal)  size(median)) 
			  
			  
*------
*-t值图
*------
 // t 值
#delimit ;
dpplot t_value, 
 xline(-1.960, lc(black*0.5) lp(dash))
 xline(0, lc(black*0.5) lp(solid))
    xtitle("T Value", size(*0.8)) xlabel(, format(%4.1f) labsize(small))
    ytitle("Density", size(*0.8)) ylabel(, nogrid format(%4.1f) labsize(small)) 
    note("") caption("") graphregion(fcolor(white)) ;
#delimit cr
*大部分随机抽样结果的 t 值都位于零值附近，仅有少数估计结果的 t 值大于基准回归结果。



*----------------
*-系数和p值结合图
*----------------
 // 系数和 p 值结合

*主坐标用来标识回归系数，副坐标用来标识 p 值。绘图结果如下。 
*虽然这幅图将系数和 p 值统合在一起，但是却也牺牲了一定的美观度。因此，po 主还是倾向于仅汇报回归系数的分布图。

graph set window fontface "Times New Roman"   
graph set window fontfacesans "宋体"
  twoway (kdensity beta , color(black) yaxis(1)) ///
      (scatter p_value beta, msymbol(smcircle_hollow) mcolor(gray) yaxis(2)), ///
      xlabel(, labsize(small)) ///
      ylabel(0(1)4, axis(2)  angle(0) labsize(small)) /// 
      ylabel(, axis(1) angle(0) labsize(small)) ///
      xline(2.57, lwidth(vthin) lpattern(dash) lcolor(black)) ///
      xtitle("{stSans:估计系数}" ,size(small)) ///
      yline(0.1,lwidth(vthin) lp(shortdash) lcolor(gray) axis(2)) ///
      ytitle("{stSans:分布}", orientation(horizontal) axis(1) size(small)) ///
      ytitle("{stSans:P值}", orientation(horizontal) axis(2) size(small)) ///
      legend(label(1 "{stSans:核密度分布  }") label( 2 "{stSans:P值}") /// 
      size(vsmall) ring(0) position(1) cols(1)) ///   //cols(1)代表将图例变成一列，row(2)代表两行
      graphregion(color(white)) scheme(s1mono) //白底 
