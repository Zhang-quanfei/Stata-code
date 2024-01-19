*--------------------------------------------
  * -1- 数据处理：导入战略惯性数据和基本处理
  *--------------------------------------------


 
	*-数据导入
	
	*so2
	import excel "D:\Stata14\examples\地级市宏观数据\地级市污染和排放数据.xlsx", sheet("stata1") firstrow clear
	
	replace cname = pname if cname == ""
	
	reshape long so2,i(cname)j(year)
	
	keep cname-so2
	
	save so2,replace
	
	*法制化水平
	
	import excel "D:\Stata14\examples\中国分省份市场化指数（2016）.xlsx", sheet("stata") firstrow clear
	
	save law1
	
	import excel "D:\Stata14\examples\中国市场化指数(2009版).xls", sheet("stata") firstrow clear
	
	save law2,replace
	
	*sci
	
	import excel "D:\Stata14\examples\中国市场化指数(2009版).xls", sheet("stata") firstrow clear
	
	destring year,replace force

	replace cityname = substr(cityname,1,6) if rank == "直辖市"   //三个字节一个字符

	rename cityname cname

	save "sci.dta", replace
	
	*-数据对接	
	
	use law2,clear
	
	merge 1:1 pname using "law1"
	
	drop _merge
	
	reshape long law,i(pname)j(year)
	
	save law,replace
	
	use so2,clear
	
	merge m:1 year pname using "law"   //多对一，因为so2中一个省有多个市，law里面只有省
	
	drop if _merge < 3
	
	drop _merge
	
	save temp,replace
	
	
	use temp,clear
	


	merge 1:1 cname year using "sci.dta"

	drop if _merge < 3

	drop _merge
	
	save temp2,replace
	
	
	*-数据处理
	
	gen lso2 = log(1+so2)
	gen llaw = log(1+law)
	gen lsci = log(1+sci)
	gen lfin = log(1+fin)
	gen lfout = log(1+fout)
	gen ledu = log(1+edu)
	
	
  *----------------
  * -2- 基本统计量
  *----------------
  
  *-输出描述性统计
     local xx "lso2 llaw lfin lfout lsci ledu"	
     logout, save(mytable) word replace:       ///  
            tabstat `xx', stat(N mean sd min p50 max) format(%10.3f) c(s)
	
	
  *--------------
  * -3- 回归分析
  *--------------  

  *---基础回归
  
  *1.ols
	reg lso2 llaw
			est store ols_1				

	reg lso2 llaw lfin
			est store ols_2			

	reg lso2 llaw lfin lfout
			est store ols_3			

	reg lso2 llaw lfin lfout ledu
			est store ols_4			
 
 	esttab ols_?  using final1.rtf, replace                  ///
	          mtitle(`m') compress nogap b(%6.3f)       ///
              scalars(r2_a N F) star(* 0.1 ** 0.05 *** 0.01)  
  
	*2.fe固定效应
	encode cname,gen(cid)
	
	xtset cid year
	
	xtreg lso2 llaw ,fe
			est store fe_1				

	xtreg lso2 llaw lfin,fe
			est store fe_2			

	xtreg lso2 llaw lfin lfout,fe
			est store fe_3			

	xtreg lso2 llaw lfin lfout ledu,fe
			est store fe_4			
 
 	esttab fe_?  using final2.rtf, replace                  ///
	          mtitle(`m') compress nogap b(%6.3f)       ///
              scalars(r2_a N F) star(* 0.1 ** 0.05 *** 0.01)  
  	
	*3.双固定效应+聚类稳健标准误
	xtreg lso2 llaw i.year,fe clu(cid)
			est store fee_1				

	xtreg lso2 llaw lfin i.year,fe clu(cid)
			est store fee_2			

	xtreg lso2 llaw lfin lfout i.year,fe clu(cid)
			est store fee_3			

	xtreg lso2 llaw lfin lfout ledu i.year,fe clu(cid)
			est store fee_4			
 
 	esttab fee_?  using final3.rtf, replace                  ///
	          mtitle(`m') compress nogap b(%6.3f)       ///
              scalars(r2_a N F) star(* 0.1 ** 0.05 *** 0.01)  
	
	*4二次项分析
	
	gen law2 = llaw*llaw
	
	xtreg lso2 llaw law2 i.year,fe clu(cid)
			est store feee_1				

	xtreg lso2 llaw law2 lfin i.year,fe clu(cid)
			est store feee_2			

	xtreg lso2 llaw law2 lfin lfout i.year,fe clu(cid)
			est store feee_3			

	xtreg lso2 llaw law2 lfin lfout ledu i.year,fe clu(cid)
			est store feee_4			
 
 	esttab feee_?  using final4.rtf, replace                  ///
	          mtitle(`m') compress nogap b(%6.3f)       ///
              scalars(r2_a N F) star(* 0.1 ** 0.05 *** 0.01)
			  
			  
	*5.交互项分析
	
	xtreg lso2 c.law##c.lsci##i.year,fe clu(cid)
			est store feeee_1				

	xtreg lso2 c.law##c.lsci##i.year lfin lfout,fe clu(cid)
			est store feeee_1				

	xtreg lso2 c.law##c.lsci##i.year lfin lfout,fe clu(cid)
			est store feeee_1				
	
	xtreg lso2 c.law##c.lsci##i.year lfin lfout ledu,fe clu(cid)
			est store feeee_1				
	
	 	esttab feeee_?  using final4.rtf, replace                  ///
	          mtitle(`m') compress nogap b(%6.3f)       ///
              scalars(r2_a N F) star(* 0.1 ** 0.05 *** 0.01)
