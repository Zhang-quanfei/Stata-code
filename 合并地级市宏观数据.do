*-------1、导入表并保存

	*导入分城市财政收支表
	import excel "D:\Stata14\examples\地级市宏观数据\分城市财政收支1998-2015\CRE_Gfct.xls", sheet("stata") firstrow
	save  fin,replace
	
	*将第一行值作为标签
	foreach var of varlist _all {
	replace `var' = subinstr(`var',"'","",.)  //将`var' 里面的'变为空并返回剩下的字符   subinstr() 里面四个变量  .  代表遍历所有的值
	local x = `var'[1]
	label variable  `var' `x'

	}
	

	*导入分城市工业表
	import excel "D:\Stata14\examples\地级市宏观数据\分城市工业1990-2015\CRE_Industct.xls", sheet("stata") firstrow clear
	save indu,replace
	
	*将第一行值作为标签
	foreach var of varlist _all {
	replace `var' = subinstr(`var',"'","",.)  //将`var' 里面的'变为空并返回剩下的字符   subinstr() 里面四个变量  .  代表遍历所有的值
	local x = `var'[1]
	label variable  `var' `x'

	}
	

	*导入分城市国民生产总值表
	import excel "D:\Stata14\examples\地级市宏观数据\分城市国民生产总值1998-2015\CRE_Gdpct.xls", sheet("Sheet2") firstrow clear
	save gdp,replace
	
	*将第一行值作为标签
	foreach var of varlist _all {
	replace `var' = subinstr(`var',"'","",.)  //将`var' 里面的'变为空并返回剩下的字符   subinstr() 里面四个变量  .  代表遍历所有的值
	replace `var' = subinstr(`var',"(%)","",.)
	local x = `var'[1]
	label variable  `var' `x'

	}
	

	*导入分城市环境状况文件
	import excel "D:\Stata14\examples\地级市宏观数据\分城市环境状况文件2002-2015\CRE_Envirct.xls", sheet("stata") firstrow clear
	save env,replace
	
	*将第一行值作为标签
	foreach var of varlist _all {
	replace `var' = subinstr(`var',"'","",.)  //将`var' 里面的'变为空并返回剩下的字符   subinstr() 里面四个变量  .  代表遍历所有的值
	replace `var' = subinstr(`var',"(%)","",.)
	local x = `var'[1]
	label variable  `var' `x'

	}
	

	*导入分城市外商投资表
	import excel "D:\Stata14\examples\地级市宏观数据\分城市外商投资1990-2015\CRE_Finvstct.xls", sheet("stata") firstrow clear
	save fori,replace
	
	*将第一行值作为标签
	foreach var of varlist _all {
	replace `var' = subinstr(`var',"'","",.)  //将`var' 里面的'变为空并返回剩下的字符   subinstr() 里面四个变量  .  代表遍历所有的值
	replace `var' = subinstr(`var',"(%)","",.)
	local x = `var'[1]
	label variable  `var' `x'

	}
	


	
*------2、合并五大表
	use fin,clear
	merge 1:1 year cname rank pname using "indu"
	drop if _merge<3
	drop _merge
	
	merge 1:1 cid pid year cname rank pname using "gdp"
	drop if _merge<3
	drop _merge
	
	
	merge 1:1 cid pid year cname rank pname using "env"
	drop if _merge<3
	drop _merge
	
	
	merge 1:1 cid pid year cname rank pname using "fori"
	drop if _merge<3
	drop _merge
	
	
	