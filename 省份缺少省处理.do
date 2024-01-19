
gen pname = 省份 + "省"
replace pname = "北京市" if pname == "北京省" 
replace pname = "天津市" if pname == "天津省" 
replace pname = "重庆市" if pname == "重庆省" 
replace pname = "上海市" if pname == "上海省" 
replace pname = "宁夏回族自治区" if pname == "宁夏省" 
replace pname = "广西壮族自治区" if pname == "广西省" 
replace pname = "新疆维吾尔自治区" if pname == "新疆省" 
replace pname = "内蒙古自治区" if pname == "内蒙古省" 
replace pname = "西藏自治区" if pname == "西藏省" 

