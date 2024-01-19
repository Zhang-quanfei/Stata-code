import excel "C:\Users\zhang\Desktop\数据\上市基本情况.xls", sheet("sta") firstrow clear
rename t year
foreach v of varlist _all{
replace `v'= subinstr(`v',"'","",.)

local x = `v'[1]
label variable `v' `x'
}

drop in 1
replace year = substr(year,1,4)
destring id year  ExecutivesNumber FinanceBack,force replace
save city,replace

use "C:\Users\zhang\Desktop\数据\信用违约距离-伸长后.dta", clear

gen  id = substr(cid,1,6)
destring id ,force replace
merge 1:1 id year using "city"
drop if _merge<3
drop _merge

*destring id year,force replace ignore(".sz")
