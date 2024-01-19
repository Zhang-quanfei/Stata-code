*Braghieri, Luca, Ro'ee Levy, and Alexey Makarin. 2022. "Social Media and Mental
*Health." American Economic Review , 112 (11): 3660-93.
*图二 的 代码
*******************************************************************************
**** FIGURE 2: EFFECTS OF FACEBOOK ON THE INDEX OF POOR MENTAL HEALTH BASED ON
**** DISTANCE TO/FROM FACEBOOK INTRODUCTION
* TWFE OLS
use "F:\Users\zhang\Desktop\DID专题\高铁对so2.dta",clear
	global controls 年末总人口_全市_万人
	
	preserve
	*--------回归-------*
	gen treat = birth~=.
	gen event = year - birth   //减去政策发生年份 
		
	replace event = -5 if event < -5 
	replace event = 5 if event > 5   & event~=. 
	forvalues i=5(-1)1{
	  gen pre`i'=(event==-`i'& treat==1)
	}

	gen current=(event==0 & treat==1)

	forvalues i=1(1)5{         //政策发生后
	  gen post`i'=(event==`i'& treat==1)
	}

	drop pre5    //删掉基准组
	reghdfe so2 pre* current post* ,absorb(year cid ) clu(cid)
	
	*--------提取-------*
	*-提取前十个回归系数
	forvalues i=1(1)10 {
	local b_`i'=e(b)[1,`i']  //提取自变量系数
	}
	matrix define mat1_ols= (`b_1',`b_2',`b_3',`b_4',`b_5',`b_6',`b_7',`b_8',`b_9',`b_10') //定义系数1×10矩阵
	mat colnames mat1_ols =  T-4 T-3 T-2 T-1 T+0 T+1 T+2 T+3 T+4 T+5   //更改系数矩阵列名
	*-提取变量方差，
	forvalues i=1(1)10 {
	local v_`i'=e(V)[`i',`i']  //提取方差，类似（1，2）是协方差，（1，1）是pre4方差
	}
	matrix input mat2_ols = (`v_1',`v_2',`v_3',`v_4',`v_5',`v_6',`v_7',`v_8',`v_9',`v_10') //定义1×10方差矩阵
	mat colnames mat2_ols =  T-4 T-3 T-2 T-1 T+0 T+1 T+2 T+3 T+4 T+5  //更改方差矩阵列名
	
	gen t = _n
	replace t=t-5
	replace t=. if t>5 
	gen b=.
	gen se=.
	local row = 1
	*pre提取到对应行
	forvalues x = 4(-1)1 {
	local t="pre" + "`x'"
	replace b=_b[`t'] in `row'  //提取到第几行（row）
	replace se=_se[`t'] in `row'
	local ++row
	}
	*current 提取到第五行
	replace b=_b[current] in 5
	replace se = _se[current] in 5
	*post提取到对应行
	forvalues x = 1(1)5 {
	local z = `x' + 5
	local t="post" + "`x'"
	replace b=_b[`t'] in `z'  //提取到第几行（row）
	replace se=_se[`t'] in `z'
	}
	
	gen upper95=b+1.96*se   //95%置信区间
	gen lower95=b-1.96*se
	
	//mfc(none)  表示填充为空
	twoway (rcap upper95 lower95 t , lcolor(black)) ///
	(scatter b t , msymbol(S) mfc(none) mcolor(black)), ///
	bgcolor(white) plotregion(color(white)) graphregion(color(white)) ///
	xline(0, lpattern(dash) lcolor(gs12) lwidth(thin)) legend(off) ///
	yline(0, lpattern(solid) lcolor(gs12) lwidth(thin)) legend(off) ///
	xtick(-4(1)5) xlabel( -4 -3 -2 -1 0 1 2 3 4 5) ///
	ytitle("Coefficient", height(6) size(medlarge)) title("Two Way Fixed Effect Model") ///
	xtitle("Semester to/from FB Introduction", height(6) size(medlarge)) xsize(5) ysize(4)
	graph save "$TEMP/event_study_TWFE", replace
	restore
***********************
*** Borusyak et al. ***
***********************
* 提供了一种基于插补的反事实方法解决 TWFE 的估计偏误问题。基于 TWFE，通过估计组群固定效应、时间固定效应和处理组-控制组固定效应，可以得到更准确的估计量
* For this estimator, it's important to notice that the more pre-periods one adds, the more the  
//standard errors on the pre-period coefficients explode. So, we can't use all pre-periods. We need  
//to use only a subset of them.	
	preserve
	
	did_imputation so2 cid year birth, fe(cid year) autosample horizons(0 1 2 3 4  ) pretrends(4) cluster(cid)   //horizons(0 1 2) 只汇报政策时 政策后第一期 政策第二期

	matrix define mat1_bor=e(b)
	mat colnames mat1_bor= T+0 T+1 T+2 T+3 T+4 T-1 T-2 T-3 T-4
	forvalues i=1(1)9 {
	local v_`i'=e(V)[`i',`i']
	}
	matrix input mat2_bor= (`v_1',`v_2',`v_3',`v_4',`v_5',`v_6',`v_7',`v_8',`v_9')
	mat colnames mat2_bor= T+0 T+1 T+2 T+3 T+4 T-1 T-2 T-3 T-4
	
	//支持输入mat1_bor#mat2_bor矩阵交互，mat1_ols是系数矩阵，mat2_ols是方差矩阵；trimlag(4)表示截断到后面第四期 ；ciplottype(rcap)表示置信区间样式为"帽子"；plottype(scatter)表示画图类型用"点"表示；stub_lag表示政策的后几期；stub_lead表示政策的前几期
	event_plot mat1_bor#mat2_bor, stub_lag(T+#) stub_lead(T-#) trimlag(4) ciplottype(rcap) plottype(scatter)  ///
	graph_opt(bgcolor(white) plotregion(color(white)) graphregion(color(white)) ///
	xline(0, lpattern(dash) lcolor(gs12) lwidth(thin)) legend(off) ///
	yline(0, lpattern(solid) lcolor(gs12) lwidth(thin)) legend(off) ///
	ylabel(, labsize(small)) ///
	xlabel( -4 -3 -2 -1 0 1 2 3 4, labsize(small)) ///
	ytitle("Coefficient", height(6) size(small)) title("Borusyak, Jaravel, and Spiess (2021)",size(small)) ///
	xtitle("Semester to/from FB Introduction", height(6) size(small)) xsize(6) ysize(4)) ///
	lag_opt(msymbol(D) mcolor(blue) mfc(none) msize(small)) lead_opt(msymbol(D) mfc(none) mcolor(blue) msize(small)) ///
	lag_ci_opt(lcolor(blue) lwidth(medthin)) lead_ci_opt(lcolor(blue) lwidth(medthin))
	graph save "$TEMP/event_study_BJS", replace

******************************
*** Callaway and Sant'Anna ***
******************************
	csdid so2,  time(year) gvar(birth) agg(event) method(dripw) notyetlong rseed(1) cluster(cid)  //agg(event) 估计分时期ATT,ivar(cid)要求每一年个体相同
		estat all  //列出所有组别政策效应加总
	*提取想要的系数
	matrix mat1_cs = (1, 2, 3, 4, 5, 6, 7, 8, 9, 10)  //创建1×10矩阵，储存政策前四期、政策当期和政策后五期
	mat colnames mat1_cs=  T-4 T-3 T-2 T-1 T+0 T+1 T+2 T+3 T+4 T+5
	local count = 4  //提取前几期就写几
	forvalues i = 1(1)4{ //提取前几期就写几
		local t="Tm" + "`count'"
		matrix mat1_cs[1,`i'] = _b[`t'] // 将第1行第i列的系数更改为_b[`t']
		local --count
	}
	forvalues i = 0(1)5{  //提取当期加后几期一共几期就写几
		local z = `i'+5  //提取的前几期加一
		local t="Tp" + "`i'"
		matrix mat1_cs[1,`z'] = _b[`t'] // 将第1行第i列的系数更改为_b[`t']
	}
	
	*提取想要的方差
	matrix mat2_cs = (1, 2, 3, 4, 5, 6, 7, 8, 9, 10)  //创建1×10矩阵，储存政策前四期、政策当期和政策后五期
	mat colnames mat2_cs=  T-4 T-3 T-2 T-1 T+0 T+1 T+2 T+3 T+4 T+5

	forvalues i = 1(1)4{ //提取前几期就写几
		local t=`i'+11  //从前往后数，要提取政策的第前期位于总期数的位置，例如 要提取政策前五期，则政策前的第五期期位于总期数的位置
		matrix mat2_cs[1,`i'] = e(V)[`t',`t'] 
	}
	forvalues i = 0(1)5{  //提取当期加后几期一共几期就写几
		local z = `i'+5
		local t=`i'+16  //政策当期位于总期数第16个位置
		matrix mat2_cs[1,`z'] = e(V)[`t',`t'] 
	}
	
	event_plot mat1_cs#mat2_cs , stub_lag(T+#) stub_lead(T-#) ciplottype(rcap) ///
	plottype(scatter) ///
	graph_opt(bgcolor(white) plotregion(color(white)) graphregion(color(white)) ///
	xline(0, lpattern(dash) lcolor(gs12) lwidth(thin)) legend(off) ///
	yline(0, lpattern(solid) lcolor(gs12) lwidth(thin)) legend(off) ///
	ylabel(, labsize(small)) ///
	xlabel( -4 -3 -2 -1 0 1 2 3 4 5, labsize(small)) ///
	ytitle("Coefficient", height(6) size(small)) title("Callaway and Sant'Anna (2021)",size(small)) ///
	xtitle("Semester to/from FB Introduction", height(6) size(small)) xsize(6) ysize(4)) ///
	lag_opt(msymbol(o) mcolor(orange) msize(small)) lead_opt(msymbol(o) mcolor(orange) msize(small)) ///
	lag_ci_opt(lcolor(orange) lwidth(medthin)) lead_ci_opt(lcolor(orange) lwidth(medthin))
	graph save "$TEMP/event_study_CS", replace
	
	/* 政策前后颜色不一样的模板
	event_plot mat1_cs#mat2_cs , stub_lag(T+#) stub_lead(T-#) ciplottype(rcap)
	plottype(scatter) ///
	graph_opt(bgcolor(white) plotregion(color(white)) graphregion(color(white)) ///
	xline(0, lpattern(dash) lcolor(gs12) lwidth(thin)) legend(off) ///
	yline(0, lpattern(solid) lcolor(gs12) lwidth(thin)) legend(off) ///
	ylabel(, labsize(small)) ///
	xscale(r(-4.5 5.5)) xtick(-4(1)5) xlabel( -4 -3 -2 -1 0 1 2 3 4 5, labsize(small)) ///
	ytitle("Coefficient", height(6) size(small)) title("Callaway and Sant'Anna (2021)",
	size(small)) ///
	xtitle("Semester to/from FB Introduction", height(6) size(small)) xsize(5) ysize(4)) ///
	lag_opt(msymbol(D) mcolor(black) msize(small)) lead_opt(msymbol(D) mcolor(black) // 分别设置政策前后样式
	msize(small)) ///
	lag_ci_opt(lcolor(black) lwidth(medthin)) lead_ci_opt(lcolor(black) lwidth(medthin))
	graph save "$TEMP/event_study_CS", replace
	*/
*****************************************
*** DeChaisemartin and D'Haultfeuille ***
*****************************************
	*-------DIDM：多期多个体倍分法--------*
	*De Chaisemartin 和 D`Haultfoeuille (2020) 提出通过加权计算两种处理效应的值得到平均处理效应的无偏估计，这两种处理效应为：
	*	t-1期未受处理而 t 期受处理的组与两期都未处理的组的平均处理效应；
	*	t-1期受处理而 t 期未受处理的组与两期都受处理的组的平均处理效应。
	*	该方法的前提条件是处理效应不具有动态性 (即处理效应与过去的处理状态无关)
	*文章来源：https://mp.weixin.qq.com/s/ZzYI41SHhTKLCXFGZYqvyA
	*		   https://asjadnaqvi.github.io/DiD/docs/code/06_did_multiplegt/

	did_multiplegt so2 cid year dum_ta,robust_dynamic dynamic(4) placebo(4) breps(500) cluster(cid) jointtestplacebo seed(1) covariances  //dum_ta处理变量，双重差分
	//dynamic(#)	Number of lags to be estimated,此选项指定政策后几期；placebo(#)	Number of leads to be estimated,此选项指定政策前几期
	matrix input mat1_dcdh= (1, 2, 3, 4, 5, 6, 7, 8, 9)
	mat colnames mat1_dcdh= T+0 T+1 T+2 T+3 T+4 T-1 T-2 T-3 T-4 
	matrix input mat2_dcdh= (1, 2, 3, 4, 5, 6, 7, 8, 9)
	mat colnames mat2_dcdh= T+0 T+1 T+2 T+3 T+4 T-1 T-2 T-3 T-4 
	forvalues i=1(1)5 { //当期加上政策后四期，一共五期
	matrix mat1_dcdh[1,`i'] = e(estimates)[`i',1]
	matrix mat2_dcdh[1,`i'] = e(variances)[`i',1]
	}
	forvalues i=7(1)10 { 
	local z = `i' - 1
	matrix mat1_dcdh[1,`z'] = e(estimates)[`i',1]
	matrix mat2_dcdh[1,`z'] = e(variances)[`i',1]
	}
	
	event_plot mat1_dcdh#mat2_dcdh, stub_lag(T+#) stub_lead(T-#) ciplottype(rcap) plottype(scatter) ///
	graph_opt(bgcolor(white) plotregion(color(white)) graphregion(color(white)) ///
	xline(0, lpattern(dash) lcolor(gs12) lwidth(thin)) legend(off) ///
	yline(0, lpattern(solid) lcolor(gs12) lwidth(thin)) legend(off) ///
	xlabel( -4 -3 -2 -1 0 1 2 3 4, labsize(small)) ///
	ytitle("Coefficient", height(6) size(small)) title("De Chaisemartin and D'Haultfeuille(2020)", size(small)) ///
	xtitle("Semester to/from FB Introduction", height(6) size(small)) xsize(5) ysize(4)) ///
	lag_opt(msymbol(+) mcolor(red) msize(small)) lead_opt(msymbol(+) mcolor(red) msize(small)) ///
	lag_ci_opt(lcolor(red) lwidth(medthin)) lead_ci_opt(lcolor(red) lwidth(medthin))
	graph save "$TEMP/event_study_DCDH", replace
	restore
***********************
*** Sun and Abraham ***
***********************
	*文章来源：https://asjadnaqvi.github.io/DiD/docs/code/06_eventstudyinteract/
	
	*Sun 和 Abraham (2020) 认为还能够使用后处理组作为控制组，允许使用简单的线性回归进行估计
	preserve
	gen treat = birth~=.
	gen never_treat = birth==.
	gen event = year - birth   //减去政策发生年份 
		
	replace event = -5 if event < -5 
	replace event = 5 if event > 5   & event~=. 
	forvalues i=5(-1)1{
	  gen pre`i'=(event==-`i'& treat==1)
	}

	gen current=(event==0 & treat==1)

	forvalues i=1(1)5{         //政策发生后
	  gen post`i'=(event==`i'& treat==1)
	}

	drop pre5    //删掉基准组

	eventstudyinteract so2 pre* current post*, cohort(birth) control_cohort(never_treat) absorb(i.cid i.year) vce(cluster cid)

	forvalue i=1(1)10 {
	local m_`i'=e(b_iw)[1,`i']
	local v_`i'=e(V_iw)[1,`i']
	}
	matrix input mat1_sa= (`m_1',`m_2',`m_3',`m_4',`m_5',`m_6',`m_7',`m_8',`m_9',`m_10')
	mat colnames mat1_sa=     g_m4 g_m3 g_m2 g_m1 g_0 g_1 g_2 g_3 g_4 g_5
	matrix input mat3_sa= (`v_1',`v_2',`v_3',`v_4',`v_5',`v_6',`v_7',`v_8',`v_9',`v_10')
	mat colnames mat3_sa= 	g_m4 g_m3 g_m2 g_m1 g_0 g_1 g_2 g_3 g_4 g_5

	event_plot mat1_sa#mat3_sa, stub_lag(g_#) stub_lead(g_m#) trimlag(5) ciplottype(rcap) ///
	plottype(scatter) ///
	graph_opt(bgcolor(white) plotregion(color(white)) graphregion(color(white)) ///
	xline(0, lpattern(dash) lcolor(gs12) lwidth(thin)) legend(off) ///
	yline(0, lpattern(solid) lcolor(gs12) lwidth(thin)) legend(off) ///
	ylabel(, labsize(small)) ///
	xlabel( -4 -3 -2 -1 0 1 2 3 4 5, labsize(small)) ///
	ytitle("Coefficient", height(6) size(small)) title("Sun and Abraham (2021)",size(small)) ///
	xtitle("Semester to/from FB Introduction", height(6) size(small)) xsize(6) ysize(4)) ///
	lag_opt(msymbol(Th) mcolor(green) msize(small)) lead_opt(msymbol(Th) mcolor(green) msize(small)) ///
	lag_ci_opt(lcolor(green) lwidth(medthin)) lead_ci_opt(lcolor(green) lwidth(medthin))
	graph save "$TEMP/event_study_SA", replace
	restore
	
	* Combining
	event_plot mat1_bor#mat2_bor mat1_dcdh#mat2_dcdh mat1_cs#mat2_cs mat1_sa#mat3_sa mat1_ols#mat2_ols , stub_lag(T+# T+# T+# g_# T+#) stub_lead(T-# T-# T-# g_m# T-#)  ///
	plottype(scatter) ciplottype(rcap) together trimlag(5) noautolegend graph_opt(title("Event study estimators", size(medlarge)) xtitle("Periods since the event") ytitle("Average effect (std. dev.)")  ///
	xlabel( -4 -3 -2 -1 0 1 2 3 4 5, labsize(small)) ylabel(, labsize(small))  ///
	legend(region( lc(black) ) pos(10) ring(0) order(1 "Borusyak et al." 3 "De Chaisemartin-D'Haultfoeuille" 5 "Callaway-Sant'Anna" 7  ///   //ring(1) 表示在图外面，ring(0)表示在图内部，region(style(none))表示图例边框无格式 region(color(black)) 表示填充为黑色，region( lc(black) )表示边框为黑色
	"Sun-Abraham" 9 "TWFE OLS")  rows(3) ) xline(-0.5, lcolor(gs8) lpattern(dash))  /// 
	yline(0, lcolor(gs8)) graphregion(color(white)) bgcolor(white) ylabel(-30(15)35, angle(horizontal)))  ///
	lag_opt1(msymbol(O) color(dkorange)) lag_ci_opt1(color(dkorange)) lag_opt2(msymbol(+)  ///
	color(cranberry)) lag_ci_opt2(color(cranberry)) lag_opt3(msymbol(Dh) color(navy))  ///
	lag_ci_opt3(color(navy)) lag_opt4(msymbol(Th) color(forest_green))   ///
	lag_ci_opt4(color(forest_green)) lag_opt5(msymbol(Sh) color(black)) lag_ci_opt5(color(black))  ///
	perturb(-0.325(0.13)0.325)   //表示将不同估计量的置信区间以0.13的值错开
	
	graph export "$REPLICATION/Figure 2.pdf", replace
