*3.安慰剂
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


*另一种安慰剂
use  ,clear
permute dum_ta beta = _b[dum_ta] se = _se[dum_ta] df = e(df_r),  ///   *df是自由度
          reps(500) seed(123) saving("simulations.dta",replace):  ///  //重复500次
		xtreg so2 dum_ta  i.year,fe r

 // 回归系数图
use "simulations.dta", clear

dpplot beta, xline(0.027, lc(black*0.5) lp(dash)) ///
 xlabel( ///
    xtitle("Estimator", size(*0.9) height(5)) xlabel(, format(%6.3f) labsize(small)) ///
    ytitle("Density", size(*0.9)) ylabel(, nogrid format(%4.0f) labsize(small))  ///
    note("") caption("") graphregion(fcolor(white)) 