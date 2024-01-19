*1、平行趋势
	use 地铁_数字化转型_控制变量,clear
	 
	 
	 bys cid:egen sum=total(dtmd)    // 每一年都没有改变
	 gen dum_t = sum!=0      // 生成实验组
	 
	 bys cid : gen t = year if dtmd!=0
	 bys cid : egen birth = min(t)
	 
	 gen event = year - birth
	 
	 
	 *	一行代码实现平行性
	  eventdd cipin lasset lyysr net_syl   cwgg merge own_con rkmd lgdp , timevar(event)  ///
		 method(hdfe, absorb(sid year) cluster(sid))  ///
		 inrange leads(4) lags(6)    ///
		 baseline(0) noline     /// 
		 coef_op(m(oh) c(l) color(black) lcolor(black))   ///
		 graph_op(ytitle("系数")    ///
		 color(black)   ///
		 xline(0, lc(black*0.5) lp(dash))  ///
		 graphregion(fcolor(white)))
