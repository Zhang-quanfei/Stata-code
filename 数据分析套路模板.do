      
*- 《我的一篇文章》一文的数据处理和模型估计

*- 2018.06.28 (with my team)  

	*-作为例子，我们这里讲一个故事：
	
	*——法治化水平、公共财政研发支出与地方污染治理


  cap log close
  
  log using paper01, text replace 
  
  		set more off
  
   
  *--------------------------------------------
  * -1- 数据处理：导入战略惯性数据和基本处理
  *--------------------------------------------


 
	*-数据导入
 
		import excel "D:\桌面\数据\数据1.xls", sheet("分省年度数据") firstrow clear
		
		reshape long price,i(pid)  j(year)
		
		save temp1.dta,replace
		
	*...............................
	 
		
	*-数据整理
		
		 destring id ,replace force
		 g year=substr(t,1,4)
		 destring year ,replace force
		 drop t 
		 
	*...............................
		 
	*-数据对接
 
		merge 1:1 id t using "D:\桌面\数据\3.dta"
		drop if _merge<3
		drop _merge
		
		merge 1:1 id t using "D:\桌面\数据\2.dta"
		drop if _merge<3
		drop _merge 
		
	*...............................
	 
	*改名并加标签
	
	 ren A inc
	 label variable inc "收入" //自己补全	 
	 

	*-把多个数据轮流按照上述处理
	 


	*-生成回归变量

		g ds=d_share/zgs
		
		g lesp= log(esp)

		g ctrl_dum = (ctrl<=1230)

		g ic_gov=lici_xm*ctrl_dum

	 save  temp.dta,replace 
	 		
  *----------------
  * -2- 基本统计量
  *----------------
  
  *-输出描述性统计
     local xx "此处放上最后回归的变量 "	
     logout, save(mytable) word replace:       ///  
            tabstat `xx', stat(N mean sd min p50 max) format(%6.3f) c(s)
            
          

	  
	  
  *--------------
  * -3- 回归分析
  *--------------  

  *---基础回归
  
  use temp,clear
  
  xtset cid year  //声明面板

		*基准回归1：OLS
		
		    reg perks_w  lesp lsa ,r clu(id)
			est store ols_1			
			
		    xtreg perks_w  lesp lsa ,fe r clu(id)
			est store fe_1				
			
		    reg perks_w  lesp lsa if ctrl_dum==1 ,r clu(id)
			est store ols_2	

		    reg perks_w  lesp lsa if ctrl_dum==0 ,r clu(id)
			est store ols_3	
			
			esttab ols_?  using final1.rtf, replace                  ///
	          mtitle(`m') compress nogap b(%6.3f)       ///
              scalars(r2_a N F) star(* 0.1 ** 0.05 *** 0.01) 
					
		*基准回归2：面板固定效应
		
		    xtreg perks_w  lesp lsa i.year,fe r clu(id)
			est store fe_1	
			
		    xtreg perks_w  lesp lsa if ctrl_dum==1 ,fe r clu(id)
			est store fe_2

		    xtreg perks_w  lesp lsa if ctrl_dum==0 ,fe r clu(id)
			est store fe_3
			
			esttab  fe_? using final1.rtf, replace                  ///
	          mtitle(`m') compress nogap b(%6.3f)       ///
              scalars(r2_a N F) star(* 0.1 ** 0.05 *** 0.01) 
		
		*机制回归：交互项分析
		
		
		
					  
					  
		*稳健性回归：分位数 
	
				sqreg perks_w lici_xm lesp power8 vol lev stdroa asset, quantile(.05 .1 .25 .5 .75 .9 .95) reps(50)
		
		*内生性控制：工具变量 
