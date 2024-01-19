
*---------------------------------------------------------------------------------------------------------

* Enterprises' Digital Transformation and the Short-term Inclination of Enterprises' Exectives

*  Yabin Bian; Yituan Liu, Xiao Yu. 2022-10-14

*---------------------------------------------------------------------------------------------------------


*---------------------------
*	Descriptive Statistics
*---------------------------

	local xx " Shortsight DigitalTrs Size ROA Lev Age lnRev TobinQ SOE lnRDSD HHI TechRatio dum_G" 
    logout, save(Descriptive) word replace:       ///  
            tabstat `xx', stat(N mean sd min max) format(%10.4f) c(s)



*---------------------------
* 	Baseline Regression
*---------------------------
			  
	xtreg Shortsight lnDigRelAss 
		est store fee_1	
	xtreg Shortsight lnDigRelAss i.year,fe clu(id)
		est store fee_2	
	xtreg Shortsight lnDigRelAss Size i.year,fe clu(id)
		est store fee_3	
	xtreg Shortsight lnDigRelAss Size ROA i.year,fe clu(id)
		est store fee_4
	xtreg Shortsight lnDigRelAss Size ROA Lev i.year,fe clu(id)
		est store fee_5
	xtreg Shortsight lnDigRelAss Size ROA Lev Age i.year,fe clu(id)
		est store fee_6
	xtreg Shortsight lnDigRelAss Size ROA Lev Age lnRev i.year,fe clu(id)
		est store fee_7
	xtreg Shortsight lnDigRelAss Size ROA Lev Age lnRev TobinQ i.year,fe clu(id)
		est store fee_8	
	xtreg Shortsight lnDigRelAss Size ROA Lev Age lnRev TobinQ SOE i.year,fe clu(id)
		est store fee_9	
		esttab fee_*  using BaselineRegression.rtf, replace                  ///
					  mtitle(`m') compress nogap b(%6.3f)       ///
					  scalars(r2_a N F) star(* 0.1 ** 0.05 *** 0.01)

*	Event Study
					  
	foreach x in 2007 2008 2009 2010 2011 2012 2013 2014 2015 2016 2017 2018 2019 2020{
	 gen lnDigtal_`x'= lnDigRelAss*[year == `x']		
	}
	
	xtreg Shortsight lnDigtal_* Size ROA Lev Age lnRev TobinQ SOE i.year,fe clu(id)
	
	coefplot, ///
	keep( lnDigtal_2007 lnDigtal_2008 lnDigtal_2009 lnDigtal_2010 lnDigtal_2011 lnDigtal_2012 ///
		  lnDigtal_2013 lnDigtal_2014 lnDigtal_2015 lnDigtal_2016 lnDigtal_2017 lnDigtal_2018 ///
		  lnDigtal_2019 lnDigtal_2020) ///
	vertical                             ///
	yline(0)                             ///
	xtitle("lnDigital in Each Year" ,height(5))   ///
    ytitle("Estimated Coefficients of SIE") ///
	msize(small) ///plot样式
	ylabel(-0.01(0.0025)0.005 ,labsize(*0.85) angle(0)) xlabel(,labsize(*0.85)) ///                 ///
	addplot(line @b @at,lcolor(gs1) ) ///增加点之间的连线
		ciopts(recast(rcap) lwidth(thin) lpattern(solid) lcolor(gs2)) ///置信区间样式
	scheme(s1mono)				  
					  
*---------------------------
* Controlling Endogeneity
*---------------------------					  

*	IV-2SLS(Industrial Robot Penetration as an IV)	
			
	eststo:xi:xtivreg2 Shortsight Size ROA Lev Age lnRev TobinQ i.year (lnDigRelAss = lnRoIns ),fe r first
		
*	Exclusivity test of IV			  
	
	xtreg Shortsight lnRoIns Size ROA Lev Age lnRev TobinQ SOE i.year,fe r

	xtreg Shortsight lnRoIns lnDigRelAss Size ROA Lev Age lnRev TobinQ SOE i.year,fe r
	
*---------------------------
* Robustness Tests
*---------------------------

*	High-dimensions Fixed Effects

	reghdfe Shortsight lnDigRelAss Size ROA Lev Age lnRev TobinQ SOE ,absorb(year id) cluster(id)
		est store fee_1
	reghdfe Shortsight lnDigRelAss Size ROA Lev Age lnRev TobinQ SOE ,absorb(year indcode1 id cname1) cluster(id)
		est store fee_2
	reghdfe Shortsight lnDigRelAss Size ROA Lev Age lnRev TobinQ SOE ,absorb(year indcode1 id cname1 cname1#year) cluster(id)
		est store fee_3
	reghdfe Shortsight lnDigRelAss Size ROA Lev Age lnRev TobinQ SOE ,absorb(year indcode1 id cname1 cname1#year indcode1#year) cluster(id)
		est store fee_4
		esttab fee_*  using HDFE.rtf, replace                  ///
					  mtitle(`m') compress nogap b(%6.3f)       ///
					  scalars(r2_a N F) star(* 0.1 ** 0.05 *** 0.01)

					  
*	Placebo Test	

	use "C:\Users\刘亦抟Krimets16\Desktop\【主】数字化转型与高管短视.dta "	
	
	permute lnDigRelAss beta = _b[lnDigRelAss] se = _se[lnDigRelAss] df = e(df_r),  ///
			reps(1000) seed(123) saving("simulations.dta",replace):  		///  重复1000次
			xtreg Shortsight lnDigRelAss Size ROA Lev Age lnRev TobinQ SOE i.year,fe clu(id)

	use "simulations.dta", clear
	gen t_value = beta / se
	gen p_value = 2 * ttail(df, abs(beta/se))   //ttail(df,t) 表示	P{T>t}即p/2值
	
	graph set window fontface "Times New Roman"   
	twoway (kdensity beta , color(black) yaxis(1)) ///
		(scatter p_value beta, msymbol(smcircle_hollow) mcolor(gray) yaxis(2)), ///
		xlabel(, labsize(small)) ///
		ylabel(0(1)4, axis(2)  angle(0) labsize(small)) /// 
		ylabel(, axis(1) angle(0) labsize(small)) ///
		xline( -.0018742 , lwidth(vthin) lpattern(dash) lcolor(black)) ///
		xtitle("Estimated Coefficients" ,size(small)) ///
		yline(0,lwidth(vthin) lp(shortdash) lcolor(gray) axis(2)) ///
		ytitle("Distribution", orientation(horizontal) axis(1) size(small)) ///
		ytitle("p_value", orientation(horizontal) axis(2) size(small)) ///
		legend(label(1 "Density") label( 2 "p_value") /// 
		size(vsmall) ring(0) position(1) cols(1)) ///   //cols(1)代表将图例变成一列，row(2)代表两行
		graphregion(color(white)) scheme(s1mono) //白底 
		
	graph export "simulations.png", width(1000) replace 

	
*	Quantile Regression

	sqreg Shortsight lnDigRelAss Size ROA Lev Age lnRev TobinQ SOE  ,q(0.25 0.5 0.75 1) reps(5) 
	
	qregpd Shortsight lnDigRelAss Size ROA Lev Age lnRev TobinQ SOE, quantile(0.25) identifier(id) fix(year)

	bsqreg Shortsight lnDigRelAss Size ROA Lev Age lnRev TobinQ SOE i.year, q(0.75) reps(100) 
	
*---------------------------
* Heterogeneity Analysis
*---------------------------

	heatplot Shortsight lnRevenue lnDigRelAss if BLC_A1 == 2 & dum_NPBig == 0, colors(BuPu) hexagon saving(BB11)
	heatplot Shortsight lnRevenue lnDigRelAss if BLC_A1 == 2 & dum_NPBig == 1, colors(BuPu) hexagon saving(BB12)
	heatplot Shortsight lnRevenue lnDigRelAss if BLC_A1 == 1 & dum_NPBig == 0, colors(BuPu) hexagon saving(BB21)
	heatplot Shortsight lnRevenue lnDigRelAss if BLC_A1 == 1 & dum_NPBig == 1, colors(BuPu) hexagon saving(BB22)
	heatplot Shortsight lnRevenue lnDigRelAss if BLC_A1 == 3 & dum_NPBig == 0, colors(BuPu) hexagon saving(BB31)
	heatplot Shortsight lnRevenue lnDigRelAss if BLC_A1 == 3 & dum_NPBig == 1, colors(BuPu) hexagon saving(BB32)

	gr combine BB11.gph BB12.gph BB21.gph BB22.gph BB31.gph BB32.gph
	
	
	heatplot Shortsight lnRevenue lnDigRelAss, colors(YlGnBu) hexagon saving(C1)
	heatplot Shortsight lnRevenue lnDigRelAss if BLC_A1 == 2, colors(BuPu) hexagon saving(C11)
	heatplot Shortsight lnRevenue lnDigRelAss if BLC_A1 == 1, colors(BuPu) hexagon saving(C21)
	heatplot Shortsight lnRevenue lnDigRelAss if BLC_A1 == 3, colors(BuPu) hexagon saving(C31)

	gr combine C1.gph C11.gph C21.gph C31.gph 
	
	heatplot Shortsight lnDigRelAss, colors(YlGnBu) hexagon saving(D1)
	heatplot Shortsight lnDigRelAss if BLC_A1 == 2, colors(BuPu) hexagon saving(D11)
	heatplot Shortsight lnDigRelAss if BLC_A1 == 1, colors(BuPu) hexagon saving(D21)
	heatplot Shortsight lnDigRelAss if BLC_A1 == 3, colors(BuPu) hexagon saving(D31)

	gr combine D1.gph D11.gph D21.gph D31.gph 
	
*	Enterprise Life Cycle for Each Type 

	bys year:egen lnNP_median = median(lnNP)
	gen dum_NPBig = (lnNP > lnNP_median)
	
	xtreg Shortsight lnDigRelAss Size ROA Lev Age lnRev TobinQ SOE i.year if BLC_A1 == 2 & dum_NPBig == 0,fe clu(id)	// 成长期，中小型企业
		est store fee_1
	xtreg Shortsight lnDigRelAss Size ROA Lev Age lnRev TobinQ SOE i.year if BLC_A1 == 2 & dum_NPBig == 1,fe clu(id)	// 成长期，大型企业
		est store fee_2
	xtreg Shortsight lnDigRelAss Size ROA Lev Age lnRev TobinQ SOE i.year if BLC_A1 == 1 & dum_NPBig == 0,fe clu(id)	// 成熟期，中小型企业
		est store fee_3
	xtreg Shortsight lnDigRelAss Size ROA Lev Age lnRev TobinQ SOE i.year if BLC_A1 == 1 & dum_NPBig == 1,fe clu(id)	// 成熟期，大型企业
		est store fee_4
	xtreg Shortsight lnDigRelAss Size ROA Lev Age lnRev TobinQ SOE i.year if BLC_A1 == 3 & dum_NPBig == 0,fe clu(id)	// 衰退期，中小型企业
		est store fee_5
	xtreg Shortsight lnDigRelAss Size ROA Lev Age lnRev TobinQ SOE i.year if BLC_A1 == 3 & dum_NPBig == 1,fe clu(id)	// 衰退期，大型企业
		est store fee_6
		esttab fee_*  using Heterogeneity.rtf, replace                  ///
					  mtitle(`m') compress nogap b(%6.3f)       ///
					  scalars(r2_a N F) star(* 0.1 ** 0.05 *** 0.01)

					  
*---------------------------
*	PSM
*---------------------------
	
	global xlist "Size ROA Lev Age lnRev TobinQ SOE " 
	set seed 0001 			
	gen tmp = runiform()	
	sort tmp 
					
	psmatch2 Shortsight $xlist, out(lnDigRelAss) logit neighbor(5) ate common caliper(10) ties  
	
	pstest $xlist, both graph  							
	
	gen common=_support
				
	xtreg Shortsight lnDigRelAss Size ROA Lev Age lnRev TobinQ SOE i.year,fe clu(id)				est store fee_1	
		esttab fee_*  using fina1.rtf, replace                  ///
		mtitle(`m') compress nogap b(%6.3f)       ///
		scalars(r2_a N F) star(* 0.1 ** 0.05 *** 0.01)
			
					  
	drop if common == 0
	
	psgraph,bin(20)
		
	twoway 	(kdensity _ps if _treat==1,lp(solid) lw(*2.5)) ///
			(kdensity _ps if _treat==0,lp(dash) lw(*2.5)), ///
			ytitle("Density", size(*1.1))      ///
			ylabel(,angle(0) labsize(*1.1))    ///
			xtitle("Propensity Score", size(*1.1))  ///
			xscale(titlegap(2))         ///
			xlabel(0(0.2)0.8, format(%2.1f) labsize(*1.1))  ///
			legend(label(1 "Treat") label(2 "Control") row(2) ///
			position(3) ring(0) size(*1.1))   ///
			scheme(s1mono)
			graph export "Figs\kn01_large.wmf",  ///
			replace fontface("Times New Roman")         
          
	twoway 	(kdensity _ps if _treat==1,lp(solid) lw(*2.5)) ///
			(kdensity _ps if _wei!=1 & _wei!=.,lp(dash) lw(*2.5)), ///
			ytitle("Density", size(*1.1))      ///
			ylabel(,angle(0) labsize(*1.1))    ///
			xtitle("Propensity Score", size(*1.1))  ///
			xscale(titlegap(2))         ///
			xlabel(0(0.2)0.8, format(%2.1f) labsize(*1.1))  ///
			legend(label(1 "Treat") label(2 "Control") row(2) ///
			position(3) ring(0) size(*1.1))   ///
			scheme(s1mono)
			graph export "Figs\kn02_large.wmf",  ///
			replace fontface("Times New Roman")     

*---------------------------
* 	Mechanism Analysis
*---------------------------	
	
	center DigitalTrs HHI TFP

*	1. 企业研发与创新

		* 研发投入强度（中介）：数字化转型提高了企业研发投入强度
	xtreg lnRDSD lnDigRelAss Size ROA Lev Age lnRev TobinQ SOE i.year,fe clu(id)
		est store fee_1
		
		* 研发人员占比（中介）
	xtreg TechRatio lnDigRelAss Size ROA Lev Age lnRev TobinQ SOE i.year,fe clu(id) //削弱
		est store fee_2

/*	2. 行业竞争程度（HHI）

	可以基于生命周期分析，市场集中度（垄断程度）强化了数字化转型对高管短视的正向影响，即越垄断的数字化转型企业其高管越短视，数字化转型强化企业垄断势力，越垄断的企业高管越短视？
	垄断势力强化了企业利润，刺激企业进一步抢占市场，做出短期行为*/
	
		*	gen Digital_HHI = c_DigitalTrs* c_HHI
	
	xtreg Shortsight c.lnDigRelAss##c.HHI Size ROA Lev Age lnRev TobinQ SOE lnFA i.year,fe clu(id)
		est store fee_3
	
*	3. 高管特质（学历）
	
	/*keep if 具体职务1 == strmatch(message,"*董事长*") | 具体职务2 == strmatch(message,"*董事长*") | 具体职务3 == strmatch(message,"*董事长*") |  ///
			具体职务1 == strmatch(message,"*总经理*") | 具体职务2 == strmatch(message,"*总经理*") | 具体职务3 == strmatch(message,"*总经理*") |  ///
			具体职务1 == strmatch(message,"*总裁*") | 具体职务2 == strmatch(message,"*总裁*") | 具体职务3 == strmatch(message,"*总裁*") | ///
			具体职务1 == strmatch(message,"*CEO*") | 具体职务2 == strmatch(message,"*CEO*") | 具体职务3 == strmatch(message,"*CEO*") | ///
			具体职务1 == strmatch(message,"*首席执行官*") | 具体职务2 == strmatch(message,"*首席执行官*") | 具体职务3 == strmatch(message,"*首席执行官*") |  */
	
	*	国有企业高管高学历（研究生及以上）强化了数字化转型对短视的负向影响
	
	xtreg Shortsight c.lnDigRelAss##i.dum_G Size ROA Lev Age lnRev TobinQ IAR FSRatio i.year if SOE == 1,fe clu(id)
		est store fee_4
	xtreg Shortsight c.lnDigRelAss##i.dum_G Size ROA Lev Age lnRev TobinQ IAR FSRatio i.year if SOE == 0,fe clu(id)		
		est store fee_5
		esttab fee_*  using Mechanisms.rtf, replace                  ///
					  mtitle(`m') compress nogap b(%6.3f)       ///
					  scalars(r2_a N F) star(* 0.1 ** 0.05 *** 0.01)
	



