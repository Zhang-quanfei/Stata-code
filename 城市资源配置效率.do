  *-资源配置效率计算

	*-劳动权重
	   
		gen Wcji = acf //调整变量名,acf是TFP

		bys ind2 cid year:egen Wcj = mean(Wcji) //分行业分城市分年的效率均值
		
		bys ind2 cid year:egen Xcj = total(labor) //labor为劳动人数，分行业分县区分年的员工数合计
		
		gen THcji = labor/Xcj //企业占行业人数比重
		
		bys ind2 cid year:egen THcj = mean(THcji) //分行业分城市分年的平均比重
		
		bys ind2 cid year:egen Ycj = total((Wcji-Wcj)*(THcji-THcj)) //协方差 计算城市行业层面资源配置效率指标 (企业TFP-该行业该城市该年TFP均值)*（企业人数比重-该行业该城市该年人数均值）
			
		bys cid year:egen Xc = total(labor) //分城市分年的员工合计
		
		gen Tcj = Xcj/Xc //计算每个行业员工数占县区全部员工数比
		
		preserve //保存现场
		
			duplicates drop ind2 cid year,force //剔除数据为分行业分城市分年
			
			*histogram Ycj if Ycj<0.25 & Ycj>-0.2 & Ycj~=0, bin(40) normal kdensity //画图
			
			keep Ycj ind2 year cid Tcj
			
			bys cid year:egen Yc = total(Tcj*Ycj)	//加权平均 城市企业间资源配置效率
			
			duplicates drop cid year,force	
			
			drop ind2
			
			save temp,replace
			
		restore
		
		merge m:1 cid year using "temp",nogen //合并回源数据
	

		
		   
		
		*histogram Yc if Yc<1 & Yc>-0.2, bin(40) normal  //画图
					
  
				
		
*-资本权重
		
		bys ind2 cid year:egen Xcj1 = total(固定资产原价合计) //分行业分城市分年资本合计
		
		gen THcji1 = 固定资产原价合计/Xcj1 //企业占行业资本比重
		
		bys ind2 cid year:egen THcj1 = mean(固定资产原价合计) //分行业分城市分年的平均比重
		
		bys ind2 cid year:egen Ycj1 = total((Wcji-Wcj)*(THcji1-THcj1)) //计算城市行业层面资源配置效率指标
			
		bys cid year:egen Xc1 = total(固定资产原价合计) //分城市分年的资本合计
		
		gen Tcj1 = Xcj1/Xc1 //计算每个行业资本数占城市全部资本数比
		
		preserve //保存现场
		
			duplicates drop ind2 cid year,force //剔除数据为分行业分城市分年
			
			keep Ycj1 ind2 year cid Tcj1
			
			bys cid year:egen Yc1 = total(Tcj1*Ycj1)	//城市企业间资源配置效率
			
			duplicates drop cid year,force	
			
			drop ind2
			
			save temp,replace
			
		restore
		
		merge m:1 cid year using "temp",nogen //合并回源数据
		
		histogram Yc1 if Yc1<2 & Yc1>-0.2, bin(40) normal  //画图
					

	/*
	egen id = group(frdm)
	
	xtset id year
	
		gen wk= ldzchj- ldfzhj
		gen iwk=d.wk
		gen fa= zczj- ldzchj
		gen y = iwk/l.fa
		gen lnas=log( zczj+1 )

		gen incr=d.zysr/l.zysr

		reg y lnas age lev incr gov pri frn i.year i.ind2 
		predict resid,stdp
		bys id:egen temp=total((lrze-yjsds+bnzj)/fa)
		gen temp1=((lrze-yjsds+bnzj)/fa)/temp
		bys id:egen temp2=total(temp1*resid)
		bys id:egen temp3=mean(resid)
		bys id: gen wks=temp2-temp3
	
	  */ 
	   