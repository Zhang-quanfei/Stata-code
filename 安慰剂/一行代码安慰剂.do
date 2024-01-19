use  ,clear
permute dum_ta beta = _b[dum_ta] se = _se[dum_ta] df = e(df_r),  ///   *df是自由度
          reps(500) seed(123) saving("simulations.dta",replace):  ///  //重复500次
		xtreg so2 dum_ta  i.year,fe r

 // 回归系数图
use "simulations.dta", clear

dpplot beta, xline(0.027, lc(black*0.5) lp(dash)) ///
 xlabel( ///
    xtitle("Estimator", size(*0.9) height(5)) xlabel(, format(%6.3f) labsize(small)) ///
    ytitle("Density", size(*0.9)) ylabel(, nogrid format(%4.0f) labsize(small))  ///
    note("") caption("") graphregion(fcolor(white)) 
