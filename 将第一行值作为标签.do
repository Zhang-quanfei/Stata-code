
foreach var of varlist _all {
	
	local x = `var'[1]
	dis "`x'"
	label variable  `var' "`x'"

}

list id in 1/5  //展示id的前五行数据
