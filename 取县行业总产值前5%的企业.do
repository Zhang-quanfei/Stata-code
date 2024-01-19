	*取县行业总产值前5%的企业
		gsort adress ind2 year -zongchanzhi
		bys adress ind2 year : gen t = _n
		bys adress ind2 year : gen n = _N 
		gen i = ceil(n*0.05)   //向上取整函数
		bys adress ind2 year : gen bfs = (t > 0 & t<=i )
		