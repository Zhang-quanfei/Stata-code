*导入公司信息表，获得公司地址

import excel "D:\Stata14\examples\1-原始数据\公司信息.xlsx", sheet("Sheet5") firstrow clear
	rename A股股票代码_A_StkCd id
	drop 城市编码_CityNum
	rename 城市名称_CityNm cityname
	gen city = subinstr(cityname,"市","",.)   //把市替换掉，subinstr （“。”表示替换所有）  
												//把cityname中的所有的市替换为空
	drop cityname
	rename city cityname
	save city,replace
	          
import excel "D:\Stata14\examples\1-原始数据\地级市与北上深地理距离.xls", sheet("Sheet1") firstrow clear
	duplicates report
	duplicates drop cityname,force
	duplicates report
	merge 1:m cityname using "city"
	drop if _merge<3
	drop _merge
	bys cityname: gen dis = min(北京,上海,广州)  //获得距离北上广距离最短的数据
	label variable dis "距离"
	save distace,replace
