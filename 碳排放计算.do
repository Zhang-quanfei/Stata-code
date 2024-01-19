use "D:\Stata14\examples\1-原始数据\碳排放\计算碳交易权试点.dta" ,clear		

*----------------
*---缺失值补充为0	
*----------------
	*	煤碳数据补充
		gen coal_xf = qt_mtxfl 
		replace coal_xf = 0 if coal_xf == .
		
	*	油数据补充
		gen oil_xf = qt_yxfl 
		replace oil_xf = 0 if oil_xf == .
		
	*	气数据补充
		gen gas_xf = qt_qxfl 
		replace gas_xf = 0 if gas_xf == .
		
	*	化石碳排放（单位：t）
		gen hco2_bc = coal_xf*1000*20908/1000000*25.8/1000 + oil_xf*1000*41816/1000000*20.2/1000 + gas_xf*1000*35544/1000000*15.3/1000 //根据热值核算ipcc	
		label variable hco2_bc "化石能源碳排放_缺失值为0"
		
		drop  coal_xf  oil_xf  gas_xf
		
	*	电力碳排放
		*	电力消费数据补充
			gen ele_xf =  qt_dlxfl
			replace ele_xf = 0 if ele_xf ==. //补充电力消费量为0
			
		*	方法一：根据全国电网平均排放因子核算(15年基准)
		*数据单位万千瓦时，换算单位兆瓦时，十倍换算
			gen ele2 = 	ele_xf*10*0.6101  //单位（t）
			label variable ele2 "电力碳排放"
		
		*	方法二：分年分地区电网碳排放因子核算
		
			
		*	华北地区
			gen huabei = (pname =="北京市" | pname =="天津市" | pname =="河北省" | pname =="山西省" | pname =="内蒙古自治区" | pname =="山东省" )
			
			gen dongbei = (pname =="辽宁省" | pname =="吉林省" | pname =="黑龙江省")
			
			gen huadong = (pname =="江苏省" | pname =="浙江省" | pname =="福建省" | pname =="上海市" | pname =="安徽省")

			gen huazhong = (pname =="河南省" | pname =="湖南省" | pname =="湖北省" | pname =="江西省" | pname =="四川省" | pname == "重庆市" )

			gen xibei = (pname =="陕西省" | pname =="甘肃省" | pname =="宁夏回族自治区" | pname =="新疆维吾尔自治区" | pname =="青海省" )
			
			gen nanfang = (pname =="贵州省" | pname =="云南省" | pname =="广东省" | pname =="广西壮族自治区")
			
			gen hainan = ( pname =="海南省" )
			//系数来自生态部
		*	2008
			gen ele2_bc = ele_xf*(1.1169+0.8687)/2*10 if year == 2008 & huabei == 1  //单位（t）
			label variable ele2_bc "电力碳排放_缺失值为0"
			
			replace ele2_bc = ele_xf*(1.2561+0.8068)/2*10 if year == 2008 & dongbei == 1
			replace ele2_bc = ele_xf*(0.9540+0.8236)/2*10 if year == 2008 & huadong == 1
			replace ele2_bc = ele_xf*(1.2783+0.6687)/2*10 if year == 2008 & huazhong == 1
			replace ele2_bc = ele_xf*(1.1225+0.6199)/2*10 if year == 2008 & xibei == 1
			replace ele2_bc = ele_xf*(1.0608+0.6816)/2*10 if year == 2008 & nanfang == 1
			replace ele2_bc = ele_xf*(0.8944+0.7523)/2*10 if year == 2008 & hainan == 1
			
		*	2009
			replace ele2_bc = ele_xf*(1.0069+0.7802)/2*10 if year == 2009 & huabei == 1  //单位（t）
			replace ele2_bc = ele_xf*(1.1293+0.7242)/2*10 if year == 2009 & dongbei == 1
			replace ele2_bc = ele_xf*(0.8825+0.6826)/2*10 if year == 2009 & huadong == 1
			replace ele2_bc = ele_xf*(1.1255+0.5802)/2*10 if year == 2009 & huazhong == 1
			replace ele2_bc = ele_xf*(1.0246+0.6433)/2*10 if year == 2009 & xibei == 1
			replace ele2_bc = ele_xf*(0.9987+0.5772)/2*10 if year == 2009 & nanfang == 1
			replace ele2_bc = ele_xf*(0.8154+0.7297)/2*10 if year == 2009 & hainan == 1
			
		*	2010
			replace ele2_bc = ele_xf*(0.9914+0.7495)/2*10 if year == 2010 & huabei == 1  //单位（t）
			replace ele2_bc = ele_xf*(1.1109+0.7086)/2*10 if year == 2010 & dongbei == 1
			replace ele2_bc = ele_xf*(0.8592 +0.6789)/2*10 if year == 2010 & huadong == 1
			replace ele2_bc = ele_xf*(1.0871+0.4543)/2*10 if year == 2010 & huazhong == 1
			replace ele2_bc = ele_xf*(0.9947+0.6878)/2*10 if year == 2010 & xibei == 1
			replace ele2_bc = ele_xf*(0.9762+0.4506)/2*10 if year == 2010 & nanfang == 1
			replace ele2_bc = ele_xf*(0.7972+0.7328)/2*10 if year == 2010 & hainan == 1

		*	2011
			replace ele2_bc = ele_xf*(0.9803+0.6426)/2*10 if year == 2011 & huabei == 1  //单位（t）
			replace ele2_bc = ele_xf*(1.0852+0.5987)/2*10 if year == 2011 & dongbei == 1
			replace ele2_bc = ele_xf*(0.8367+0.6622)/2*10 if year == 2011 & huadong == 1
			replace ele2_bc = ele_xf*(1.0297+0.4191)/2*10 if year == 2011 & huazhong == 1
			replace ele2_bc = ele_xf*(1.0001+0.5851)/2*10 if year == 2011 & xibei == 1
			replace ele2_bc = ele_xf*(0.9489+0.3157)/2*10 if year == 2011 & nanfang == 1
			replace ele2_bc = ele_xf*(0.9489+0.3157)/2*10 if year == 2011 & hainan == 1	
			
		*	2012
			replace ele2_bc = ele_xf*(1.0021+0.5940)/2*10 if year == 2012 & huabei == 1  //单位（t）
			replace ele2_bc = ele_xf*(1.0935+0.6104)/2*10 if year == 2012 & dongbei == 1
			replace ele2_bc = ele_xf*(0.8244+0.6889)/2*10 if year == 2012 & huadong == 1
			replace ele2_bc = ele_xf*(0.9944+0.4733)/2*10 if year == 2012 & huazhong == 1
			replace ele2_bc = ele_xf*(0.9913+0.5398)/2*10 if year == 2012 & xibei == 1
			replace ele2_bc = ele_xf*(0.9344+0.3791)/2*10 if year == 2012 & nanfang == 1
			replace ele2_bc = ele_xf*(0.9344+0.3791)/2*10 if year == 2012 & hainan == 1

		*	2013
			replace ele2_bc = ele_xf*(1.0302+0.5777)/2*10 if year == 2013 & huabei == 1  //单位（t）
			replace ele2_bc = ele_xf*(1.1120+0.6117)/2*10 if year == 2013 & dongbei == 1
			replace ele2_bc = ele_xf*(0.8100+0.7125)/2*10 if year == 2013 & huadong == 1
			replace ele2_bc = ele_xf*(0.9779+0.4990)/2*10 if year == 2013 & huazhong == 1
			replace ele2_bc = ele_xf*(0.9720+0.5115)/2*10 if year == 2013 & xibei == 1
			replace ele2_bc = ele_xf*(0.9223+0.3769)/2*10 if year == 2013 & nanfang == 1
			replace ele2_bc = ele_xf*(0.9223+0.3769)/2*10 if year == 2013 & hainan == 1

		*	2014
			replace ele2_bc = ele_xf*(1.0580+0.5410)/2*10 if year == 2014 & huabei == 1  //单位（t）
			replace ele2_bc = ele_xf*(1.1281+0.5537)/2*10 if year == 2014 & dongbei == 1
			replace ele2_bc = ele_xf*(0.8095+0.6861)/2*10 if year == 2014 & huadong == 1
			replace ele2_bc = ele_xf*(0.9724+0.4737)/2*10 if year == 2014 & huazhong == 1
			replace ele2_bc = ele_xf*(0.9578+0.4512)/2*10 if year == 2014 & xibei == 1
			replace ele2_bc = ele_xf*(0.9183+0.4367)/2*10 if year == 2014 & nanfang == 1
			replace ele2_bc = ele_xf*(0.9183+0.4367)/2*10 if year == 2014 & hainan == 1

		*	2015
			replace ele2_bc = ele_xf*(1.0416+0.4780)/2*10 if year == 2015 & huabei == 1  //单位（t）
			replace ele2_bc = ele_xf*(1.1291+0.4315)/2*10 if year == 2015 & dongbei == 1
			replace ele2_bc = ele_xf*(0.8112+0.5945)/2*10 if year == 2015 & huadong == 1
			replace ele2_bc = ele_xf*(0.9515+0.3500)/2*10 if year == 2015 & huazhong == 1
			replace ele2_bc = ele_xf*(0.9457+0.3162)/2*10 if year == 2015 & xibei == 1
			replace ele2_bc = ele_xf*(0.8959+0.3648)/2*10 if year == 2015 & nanfang == 1
			replace ele2_bc = ele_xf*(0.8959+0.3648)/2*10 if year == 2015 & hainan == 1
			
			
	*	加总碳排放数据
		gen  co2_bc = hco2_bc + ele2_bc
		label variable co2_bc "总碳排放_缺失值为0"
		drop ele_xf
*---------------
*---缺失值不补充
*---------------

*	化石碳排放
		
		gen hco2 = qt_mtxfl*1000*20908/1000000*25.8/1000 + qt_yxfl*1000*41816/1000000*20.2/1000 + qt_qxfl*1000*35544/1000000*15.3/1000 //根据热值核算ipcc
		label variable hco2 "化石能源碳排放_未补充缺失值"


*	电力碳排放
			
		*	方法一：根据全国电网平均排放因子核算(15年基准)
		*数据单位万千瓦时，换算单位兆瓦时，十倍换算
			gen ele2 = 	qt_dlxfl*10*0.6101  //单位（t）
			label variable ele2 "电力碳排放"
		
		*	方法二：分年分地区电网碳排放因子核算
		
			//系数来自生态部
		*	2008
			gen ele2 = qt_dlxfl*(1.1169+0.8687)/2*10 if year == 2008 & huabei == 1  //单位（t）
			label variable ele2 "电力碳排放_未补充缺失值"
			
			replace ele2 = qt_dlxfl*(1.2561+0.8068)/2*10 if year == 2008 & dongbei == 1
			replace ele2 = qt_dlxfl*(0.9540+0.8236)/2*10 if year == 2008 & huadong == 1
			replace ele2 = qt_dlxfl*(1.2783+0.6687)/2*10 if year == 2008 & huazhong == 1
			replace ele2 = qt_dlxfl*(1.1225+0.6199)/2*10 if year == 2008 & xibei == 1
			replace ele2 = qt_dlxfl*(1.0608+0.6816)/2*10 if year == 2008 & nanfang == 1
			replace ele2 = qt_dlxfl*(0.8944+0.7523)/2*10 if year == 2008 & hainan == 1
			
		*	2009
			replace ele2 = qt_dlxfl*(1.0069+0.7802)/2*10 if year == 2009 & huabei == 1  //单位（t）
			replace ele2 = qt_dlxfl*(1.1293+0.7242)/2*10 if year == 2009 & dongbei == 1
			replace ele2 = qt_dlxfl*(0.8825+0.6826)/2*10 if year == 2009 & huadong == 1
			replace ele2 = qt_dlxfl*(1.1255+0.5802)/2*10 if year == 2009 & huazhong == 1
			replace ele2 = qt_dlxfl*(1.0246+0.6433)/2*10 if year == 2009 & xibei == 1
			replace ele2 = qt_dlxfl*(0.9987+0.5772)/2*10 if year == 2009 & nanfang == 1
			replace ele2 = qt_dlxfl*(0.8154+0.7297)/2*10 if year == 2009 & hainan == 1
			
		*	2010
			replace ele2 = qt_dlxfl*(0.9914+0.7495)/2*10 if year == 2010 & huabei == 1  //单位（t）
			replace ele2 = qt_dlxfl*(1.1109+0.7086)/2*10 if year == 2010 & dongbei == 1
			replace ele2 = qt_dlxfl*(0.8592 +0.6789)/2*10 if year == 2010 & huadong == 1
			replace ele2 = qt_dlxfl*(1.0871+0.4543)/2*10 if year == 2010 & huazhong == 1
			replace ele2 = qt_dlxfl*(0.9947+0.6878)/2*10 if year == 2010 & xibei == 1
			replace ele2 = qt_dlxfl*(0.9762+0.4506)/2*10 if year == 2010 & nanfang == 1
			replace ele2 = qt_dlxfl*(0.7972+0.7328)/2*10 if year == 2010 & hainan == 1

		*	2011
			replace ele2 = qt_dlxfl*(0.9803+0.6426)/2*10 if year == 2011 & huabei == 1  //单位（t）
			replace ele2 = qt_dlxfl*(1.0852+0.5987)/2*10 if year == 2011 & dongbei == 1
			replace ele2 = qt_dlxfl*(0.8367+0.6622)/2*10 if year == 2011 & huadong == 1
			replace ele2 = qt_dlxfl*(1.0297+0.4191)/2*10 if year == 2011 & huazhong == 1
			replace ele2 = qt_dlxfl*(1.0001+0.5851)/2*10 if year == 2011 & xibei == 1
			replace ele2 = qt_dlxfl*(0.9489+0.3157)/2*10 if year == 2011 & nanfang == 1
			replace ele2 = qt_dlxfl*(0.9489+0.3157)/2*10 if year == 2011 & hainan == 1	
			
		*	2012
			replace ele2 = qt_dlxfl*(1.0021+0.5940)/2*10 if year == 2012 & huabei == 1  //单位（t）
			replace ele2 = qt_dlxfl*(1.0935+0.6104)/2*10 if year == 2012 & dongbei == 1
			replace ele2 = qt_dlxfl*(0.8244+0.6889)/2*10 if year == 2012 & huadong == 1
			replace ele2 = qt_dlxfl*(0.9944+0.4733)/2*10 if year == 2012 & huazhong == 1
			replace ele2 = qt_dlxfl*(0.9913+0.5398)/2*10 if year == 2012 & xibei == 1
			replace ele2 = qt_dlxfl*(0.9344+0.3791)/2*10 if year == 2012 & nanfang == 1
			replace ele2 = qt_dlxfl*(0.9344+0.3791)/2*10 if year == 2012 & hainan == 1

		*	2013
			replace ele2 = qt_dlxfl*(1.0302+0.5777)/2*10 if year == 2013 & huabei == 1  //单位（t）
			replace ele2 = qt_dlxfl*(1.1120+0.6117)/2*10 if year == 2013 & dongbei == 1
			replace ele2 = qt_dlxfl*(0.8100+0.7125)/2*10 if year == 2013 & huadong == 1
			replace ele2 = qt_dlxfl*(0.9779+0.4990)/2*10 if year == 2013 & huazhong == 1
			replace ele2 = qt_dlxfl*(0.9720+0.5115)/2*10 if year == 2013 & xibei == 1
			replace ele2 = qt_dlxfl*(0.9223+0.3769)/2*10 if year == 2013 & nanfang == 1
			replace ele2 = qt_dlxfl*(0.9223+0.3769)/2*10 if year == 2013 & hainan == 1

		*	2014
			replace ele2 = qt_dlxfl*(1.0580+0.5410)/2*10 if year == 2014 & huabei == 1  //单位（t）
			replace ele2 = qt_dlxfl*(1.1281+0.5537)/2*10 if year == 2014 & dongbei == 1
			replace ele2 = qt_dlxfl*(0.8095+0.6861)/2*10 if year == 2014 & huadong == 1
			replace ele2 = qt_dlxfl*(0.9724+0.4737)/2*10 if year == 2014 & huazhong == 1
			replace ele2 = qt_dlxfl*(0.9578+0.4512)/2*10 if year == 2014 & xibei == 1
			replace ele2 = qt_dlxfl*(0.9183+0.4367)/2*10 if year == 2014 & nanfang == 1
			replace ele2 = qt_dlxfl*(0.9183+0.4367)/2*10 if year == 2014 & hainan == 1

		*	2015
			replace ele2 = qt_dlxfl*(1.0416+0.4780)/2*10 if year == 2015 & huabei == 1  //单位（t）
			replace ele2 = qt_dlxfl*(1.1291+0.4315)/2*10 if year == 2015 & dongbei == 1
			replace ele2 = qt_dlxfl*(0.8112+0.5945)/2*10 if year == 2015 & huadong == 1
			replace ele2 = qt_dlxfl*(0.9515+0.3500)/2*10 if year == 2015 & huazhong == 1
			replace ele2 = qt_dlxfl*(0.9457+0.3162)/2*10 if year == 2015 & xibei == 1
			replace ele2 = qt_dlxfl*(0.8959+0.3648)/2*10 if year == 2015 & nanfang == 1
			replace ele2 = qt_dlxfl*(0.8959+0.3648)/2*10 if year == 2015 & hainan == 1
			
	*	加总碳排放数据
		gen  co2 = hco2 + ele2
		label variable co2 "总碳排放_未补充缺失值"
		
		drop huabei dongbei huadong huazhong xibei nanfang hainan
