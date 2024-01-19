
 
 //1.同一城市不同时间；2.同一时间不同城市
	*	随机匹配解释变量
			
*---------------
*-安慰剂检验方法
*---------------

	*	一、DID专用
	
		*	1、随机选取每年相同数量实验组
		
			*（1）叠加样本
				 keep cid year so2 dum_ta
				 save temp,replace
				 append using temp //2
				 save temp,replace  
				 append using temp  //4
				 save temp,replace
				 append using temp  //8
				 save temp,replace
				 append using temp  //16
				 save temp,replace
				   //叠加样本量以做随机试验
			   
			 *（2）在每一个N里面随机生成实验组
				 use temp,clear
				 bys cid year : gen N=_n
				 sort N cid year   ///注意id
							 
				 *preserve 和restore 一起运行
					
				 preserve      //保存现场
				 duplicates drop N cid,force
				 bys N :gen k = uniform()
				 keep N cid k   //注意id
				 sort N k
				 bys N :gen x = _n
				 drop k
				 save tt,replace 
				 restore   //返回preserve保存的地方
					 
				 merge m:1 N cid using tt  //注意id
				 sort N x year   
			 
			 *（3）选择相同数量的实验组
				 gen after = 0
				 sort N  year x  
				 replace after=1 if year==2003 &  x<7  
				 replace after=1 if year==2004&  x<7
				 replace after=1 if year==2005 &  x<7
				 replace after=1 if year==2006&  x<7
				 replace after=1 if year==2007 &  x<7
				 replace after=1 if year==2008 &  x<15
				 replace after=1 if year==2009 &  x<33 //这里面的数字需要换成您的，运行tab  year 政策变量  将显示的数字输入这个式子即可
				 replace after=1 if year==2010 &  x<53 
				 replace after=1 if year==2011 &  x<69 
				 replace after=1 if year==2012 &  x<90 
				 replace after=1 if year==2013 &  x<107
				 replace after=1 if year==2014 &  x<145 

			 *（4）提取回归系数
				 statsby _b[after] _se[after] , clear by(N):xtreg so2 after  i.year,fe  r 
				 //此处放入基准回归，但是核心解释变量换为after                                             
				 
				 save tempp3,replace
				//需先运行  use high~到statsby _b[after]~的部分，在运行save tempp3,replace，然后在运行循环即forvalue到 } 

			  *(5)循环
				 forvalue i=1/30{  //30可以改成您想要做的试验次数，当然试验次数越多越多。
					use temp,clear
					bys cid year : gen N=_n
					sort N cid year   ///注意id
			
						preserve      //保存现场
					 
					duplicates drop N cid,force
					bys N :gen k = uniform()
					keep N cid k   //注意id
					sort N k
					bys N :gen x = _n
					drop k
					save tt,replace 
					 
						restore   //返回preserve保存的地方
					 
					merge m:1 N cid using tt  //注意id
			 
					sort N x year 
			 
			 
			 
					gen after = 0

					sort N  year x
					replace after=1 if year==2003 &  x<7  
					replace after=1 if year==2004&  x<7
					replace after=1 if year==2005 &  x<7
					replace after=1 if year==2006&  x<7
					replace after=1 if year==2007 &  x<7
					replace after=1 if year==2008 &  x<15	 
					replace after=1 if year==2009 &  x<33 //这里面的数字需要换成您的，运行tab  year 政策变量  将显示的数字输入这个式子即可	 
					replace after=1 if year==2010 &  x<53 
					replace after=1 if year==2011 &  x<69 		 
					replace after=1 if year==2012 &  x<90 
					replace after=1 if year==2013 &  x<107
					replace after=1 if year==2014 &  x<145 



					statsby _b[after] _se[after] , clear by(N):xtreg so2 after  i.year,fe  r 
					 //此处放入基准回归，但是核心解释变量换为after                                                       
					append using tempp3
					save tempp3,replace
				}  
			 
				*（6）绘制核密度图
					kdensity _stat_1 , normal xline( -5.413239  )

					//括号里填上基准回归的系数
					*计算面积 dis normal(正确回归系数/虚假回归标准误)


		*	2、一行代码安慰剂——随机匹配
					use  ,clear
					permute dum_ta beta = _b[dum_ta] se = _se[dum_ta] df = e(df_r),  ///   *df是自由度
							  reps(500) seed(123) saving("simulations.dta",replace):  ///  //重复500次
							xtreg so2 dum_ta  i.year,fe r

					 // 回归系数图
					use "simulations.dta", clear

					dpplot beta, xline(0.027, lc(black*0.5) lp(dash)) ///
					xlabel(xtitle("Estimator", size(*0.9) height(5)) xlabel(, format(%6.3f) labsize(small)) ///
					ytitle("Density", size(*0.9)) ylabel(, nogrid format(%4.0f) labsize(small))  ///
					note("") caption("") graphregion(fcolor(white)) 
		
	*	二、随机匹配(解释变量高一个维度)
	
				use  地铁_数字化转型_控制变量 ,clear 
			
			*（1）叠加样本
					 keep cipin dtmd lasset lyysr net_syl   cwgg merge own_con rkmd lgdp cid  id_n year   //保留解释、被解释、控制变量、年份、id_n
					 save temp1,replace
					 append using temp1
					 save temp1,replace
					 append using temp1
					 save temp1,replace     //叠加四次样本量以做随机试验

			*（2）生成随机排序变量，保存为temp5表
					 use temp1,clear
					 bys id_n year : gen N=_n   //N = 1 2 3 4
					 sort N id_n year         //注意id
					 
					 
					 preserve
					  duplicates drop N cid,force
					  bys N :gen k = uniform()  //分N生成随机数
					  keep N cid k          //注意id
					  sort N k				//随机排序
					  bys N :gen x = _n		//分N生成x
					  drop k
					  save tt,replace 
					 restore
					 merge m:1 N cid using tt,nogen  
					 save temp5,replace
			 
			*（3）生成随机排序的解释变量，x为随机变量，保存为ttt表
				*	副表
					use  地铁_数字化转型_控制变量 ,clear 
					preserve
						 duplicates drop  cid,force
						 gen k = uniform()
						 keep  cid k          //注意cid
						 sort  k
						 gen x = _n
						 drop k
						 save tt1,replace 
					restore
					
					duplicates drop cid year ,force
					merge m:1  cid using tt1,nogen  
					ren dtmd dtmd0  //将policy更名为policy0
					keep  year x dtmd0    
					
					save ttt,replace 
		/*	
				*	副表,这样每次生成的x都一样，不是非常假
					use gsjl_ckzl_kzbl ,clear
					egen x = group(id_n)
					keep x year policy
					ren policy policy0   
					save ttt,replace 
		  */
		  
			*（4）被解释变量和解释变量对接，对接变量x和year
				*   主表副表对接
					 use temp5,clear
					 merge m:1 x year  using"ttt"
					 //注意id
					 sort N  year x
		  
			*（5）回归提取系数
					statsby _b[dtmd0] _se[dtmd0] , clear by(N):xtreg cipin dtmd0 lasset lyysr net_syl   cwgg merge own_con rkmd lgdp   i.year,fe r    //用基准回归命令，解释变量为policy0，r代表聚类
					save temp2,replace
			 
			*（6）循环提取系数
					timer clear  //计时器清空
					timer on 1
					
					forvalue i=1/50{        //可以改成您想要做的试验次数，当然试验次数越多越多。
				 
						use  地铁_数字化转型_控制变量 ,clear 
						preserve
							 duplicates drop  cid,force
							 gen k = uniform()
							 keep  cid k          //注意cid
							 sort  k
							 gen x = _n
							 drop k
							 save tt1,replace 
						restore
						duplicates drop cid year ,force
						merge m:1  cid using tt1,nogen  
						ren dtmd dtmd0  //将policy更名为policy0
						keep  year x dtmd0       
						save ttt,replace 
						
						
						use temp1,clear
						bys id_n year : gen N=_n
						sort N id_n year         //注意id
					 
						preserve
							duplicates drop N cid,force
							bys N :gen k = uniform()
							keep N cid k          //注意id
							sort N k
							bys N :gen x = _n
							drop k
							save tt,replace 
						restore
					 
						merge m:1 N cid using tt,nogen 
						merge m:1 x year  using "ttt"
						sort N  year x
					 
						statsby _b[dtmd0] _se[dtmd0] , clear by(N):xtreg cipin dtmd0 lasset lyysr net_syl   cwgg merge own_con rkmd lgdp   i.year,fe r    //此处放入你最终的基准回归命令

						 append using temp2
						 save temp2,replace
						
						dis "这是第" string(4*`i'+4) "次" 

					 }  
					 timer off 1  //计时器关闭
					 dis "循环总时间为" r(t1)
					 kdensity _stat_1 , normal xline( 0.2  )
					 
	*	三、随机匹配（被解释变量和解释变量维度相同）
 
				use all ,clear
					xtset id_n year
				*（1）叠加样本
					keep  lacf policy    year id_n //保留解释、被解释、控制变量、年份、id_n
					save temp1,replace
					append using temp1
					save temp1,replace
					append using temp1
					save temp1,replace     //叠加样本量以做随机试验

				*（2）生成随机排序的被解释变量，保存为temp5表
					use temp1,clear

					bys id_n year : gen N=_n
					sort N id_n year         //注意id
	 
				preserve
					 duplicates drop N id_n,force
					 bys N :gen k = uniform()
					 keep N id_n k          //注意id
					 sort N k
					 bys N :gen x = _n
					 drop k
					 save tt,replace 
				restore
	 
					merge m:1 N id_n using tt,nogen  
					save temp5,replace
	 
				*（3）生成随机排序的解释变量，x为随机变量，保存为ttt表
					*副表
					use all ,clear
					
					preserve
						 duplicates drop  id_n,force
						 gen k = uniform()
						 keep  id_n k          //注意id
						 sort  k
						 gen x = _n
						 drop k
						 save tt1,replace 
					restore
					
					merge m:1  id_n using tt1,nogen  
					ren policy policy0  //将policy更名为policy0
					keep  year x policy0       
					save ttt,replace 
				*（4）被解释变量和解释变量对接，对接变量x和year
					*主表副表对接
					use temp5,clear
					merge m:1 x year using"ttt"
					sort N  year x
				
				*（5）回归提取系数
					statsby _b[policy0] _se[policy0] , clear by(N):xtreg lacf policy0    i.year, fe r  //用基准回归命令，解释变量为policy0，r代表聚类
					save temp2,replace
	  
				*（6）循环提取系数
					timer clear  //计时器清空
					timer on 1
					forvalue i=1/25{        //可以改成您想要做的试验次数，当然试验次数越多越多。
					*副表
						use all ,clear
						egen x = group(id_n)
						keep x year policy
						ren polic policy0
						save ttt,replace 
					*主表
						use temp1,clear
						bys id_n year : gen N=_n
						sort N id_n year         //注意id
						preserve
						  duplicates drop N id_n,force
						  bys N :gen k = uniform()
						  keep N id k          //注意id
						  sort N k
						  bys N :gen x = _n
						  drop k
						  save tt,replace  
						restore
						
						merge m:1 N id using tt,nogen  
						merge m:1 x year using "ttt"
						sort N  year x
						
						statsby _b[policy] _se[policy0] , clear by(N):xtreg lacf policy0  i.year, fe r   //此处放入你最终的基准回归命令
							 
							 append using temp2
							 save temp2,replace
							dis "这是第" string(4*`i'+4) "次" 
						 }  
					 timer off 1  //计时器关闭
					 timer list 1
					 dis "循环总时间为" string(r(t1)) "s"
					kdensity _stat_1 , normal xline( 0.006 )

	*	三、同一城市不同时间
	
			use  地铁_数字化转型_控制变量 ,clear 
				
			*（1）叠加样本
					 keep cipin dtmd lasset lyysr net_syl   cwgg merge own_con rkmd lgdp cid  id_n year   //保留解释、被解释、控制变量、年份、id_n
					 save temp1,replace
					 append using temp1
					 save temp1,replace
					 append using temp1
					 save temp1,replace     //叠加四次样本量以做随机试验

			*（2）同城市不同年份的解释变量，保存为temp5表（解释变量为企业，cid变成id；）
					 use temp1,clear
					 bys id_n year : gen N=_n   //N = 1 2 3 4  ，被解释变量为城市，id变成cid
					 sort N id_n year         //注意id
					 
					 //(若解释变量和被解释变量维度相同，把cid换成id)
					 preserve
					  duplicates drop N cid year,force  
					  bys N cid :gen k = uniform()  //分N生成随机数
					  ren year year0
					  keep N cid k dtmd year0        //注意cid
					  ren dtmd dtmd0
					  sort N cid k				//随机排序
					  bys N cid :gen x = _n		//分N分cid生成x
					 
					  *生成一列假的年份
					  egen s = group(N cid)
					  xtset s  x
					  bys N cid:egen m = max(x)
					  bys N cid:egen a = min(year0) 
					  bys N cid:egen b = max(year0) 
					  
					  gen  year = a if x == 1
					  replace year = b   if x == m
					  *补充平衡面板
					  xtset s  x
					  replace year = l.year+1 if year==.
					  save tt,replace
					restore
				
					 merge m:1 N cid year using tt,nogen  
					 save temp5,replace
				*（3）回归提取系数
					statsby _b[dtmd0] _se[dtmd0] , clear by(N):xtreg cipin dtmd0 lasset lyysr net_syl   cwgg merge own_con rkmd lgdp   i.year,fe r  //用基准回归命令，解释变量为policy0，r代表聚类
					save temp2,replace
					
				*（4）循环提取系数
					timer clear  //计时器清空
					timer on 1
					forvalue i=1/50{        //可以改成您想要做的试验次数，当然试验次数越多越多。
				 
						 use temp1,clear
						 bys id_n year : gen N=_n   //N = 1 2 3 4
						 sort N id_n year         //注意id
						 ren year year0
						 
						 preserve
						  duplicates drop N cid year,force
						  bys N cid :gen k = uniform()  //分N生成随机数
						  keep N cid k dtmd year0        //注意cid
						  ren dtmd dtmd0
						  sort N cid k				//随机排序
						  bys N cid :gen x = _n		//分N分cid生成x
						 
						  *生成一列假的年份
						  egen s = group(N cid)
						  xtset s  x
						  bys N cid:egen m = max(x)
						  bys N cid:egen a = min(year0) 
						  bys N cid:egen b = max(year0) 
						  
						  gen  year = a if x == 1
						  replace year = b   if x == m
						  *补充平衡面板
						  xtset s  x
						  replace year = l.year+1 if year==.
						  save tt,replace
			
						restore
					
						 merge m:1 N cid year using tt,nogen  
						 save temp5,replace
					
						statsby _b[dtmd0] _se[dtmd0] , clear by(N):xtreg cipin dtmd0 lasset lyysr net_syl   cwgg merge own_con rkmd lgdp   i.year,fe r  //用基准回归命令，解释变量为policy0，r代表聚类

						 append using temp2
						 save temp2,replace
						dis "这是第" string(4*`i'+4) "次" 
					 }  
					 timer off 1  //计时器关闭
					 timer list 1
					 dis "循环总时间为" string(r(t1)) "s"
					 kdensity _stat_1 , normal xline( 0.2  )
					 
					 
	*	四、同一时间不同城市
	
			use  地铁_数字化转型_控制变量 ,clear 
				
			*（1）叠加样本
					 keep cipin dtmd lasset lyysr net_syl   cwgg merge own_con rkmd lgdp cid  id_n year   //保留解释、被解释、控制变量、年份、id_n
					 save temp1,replace
					 append using temp1
					 save temp1,replace
					 append using temp1
					 save temp1,replace     //叠加四次样本量以做随机试验
					 
			*（2）同年份不同城市的解释变量，保存为temp5表（解释变量为企业，cid变成id；）
					 use temp1,clear
					 bys id_n year : gen N=_n   //N = 1 2 3 4  ，被解释变量为城市，id变成cid
					 sort N id_n year         //注意id
					 
					 preserve
					  bys N year :gen k = uniform()  //分N生成随机数
					  keep N year k dtmd         //注意cid
					  ren dtmd dtmd0
					  sort N year k				//随机排序
					  bys N year :gen x = _n		//分N分cid生成x
					  save tt,replace
					 restore
					 
					 bys N year :gen x = _n 
					 merge 1:1 N x year using tt,nogen  
					 save temp5,replace
					 
				*（3）回归提取系数
					statsby _b[dtmd0] _se[dtmd0] , clear by(N):xtreg cipin dtmd0 lasset lyysr net_syl   cwgg merge own_con rkmd lgdp   i.year,fe r  //用基准回归命令，解释变量为policy0，r代表聚类
					save temp2,replace
					
				*（4）循环提取系数
					timer clear  //计时器清空
					timer on 1
					forvalue i=1/50{        //可以改成您想要做的试验次数，当然试验次数越多越多。
				 
						 use temp1,clear
						 bys id_n year : gen N=_n   //N = 1 2 3 4  ，被解释变量为城市，id变成cid
						 sort N id_n year         //注意id
						 
						 preserve
						  bys N year :gen k = uniform()  //分N生成随机数
						  keep N year k dtmd         //注意cid
						  ren dtmd dtmd0
						  sort N year k				//随机排序
						  bys N year :gen x = _n		//分N分cid生成x
						  save tt,replace
						 restore
						 
						 bys N year :gen x = _n 
						 merge 1:1 N x year using tt,nogen  
						 save temp5,replace
					
						statsby _b[dtmd0] _se[dtmd0] , clear by(N):xtreg cipin dtmd0 lasset lyysr net_syl   cwgg merge own_con rkmd lgdp   i.year,fe r  //用基准回归命令，解释变量为policy0，r代表聚类

						 append using temp2	 
						 save temp2,replace
						dis "这是第" string(4*`i'+4) "次" 
					 }  
					 timer off 1  //计时器关闭
					 timer list 1
					 dis "循环总时间为" string(r(t1)) "s"
					 kdensity _stat_1 , normal xline( 0.2  ) xlabel(-0.2(0.1)0.2)	xtitle("Coefficients")
