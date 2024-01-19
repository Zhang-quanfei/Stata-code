
use 地级市经纬度,clear
ren ( 城市 经度 纬度 ) (cname longitude latitude) 
cross using "地级市经纬度.dta"   //笛卡尔积

geodist latitude longitude 纬度 经度, gen(distance)  //计算距离
save 地级市_距离, replace




