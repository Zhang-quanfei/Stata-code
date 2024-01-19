*3个被解释变量在一列，补充id
destring id ,force replace
gen x = _n
tsset x
replace id = l.id if l.id~=. & id ==.

*把3个被解释变量分成3列
reshape long  sh,i( x ) j(year)
drop x

reshape wide sh,i(year id) j(\) s
