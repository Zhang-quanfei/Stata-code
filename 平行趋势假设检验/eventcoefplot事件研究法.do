*------------------------
*-eventcoefplot事件研究法
*------------------------
	/*
	eventcoefplot 命令运行回归并生成用于事件研究分析的图表，可以设定多种选项进行比较，以及样本稳健性检验。在事件研究的背景下，研究人员经常需要对控制不同变量、固定效应或聚集标准误的回归设定进行比较。eventcoefplot 命令提供了一种简单的方法来比较最多三种设定:

multitest：允许通过一次包括一组控件来比较任意数量的组；
leaveoneouttest：允许通过在同一时间遗漏一个控制变量来检查估计的稳健性；
perturbationtest：检查结果不是由特定的子样本主导的，包括子样本结果异质性的检验结果。
	*/
	* 命令安装
	ssc install eventcoefplot, replace
	* 命令语法
	eventcoefplot varname [if] [in], window(varlist) [command event(varname) 
		gapname(string) noconstant level(#) absorb#(varlist) controls#(varlist) 
		cluster#(varname) vce#(robust) aweight#(varname) fweight#(varname) 
		display multitest(globalsnames) tuplestest(varlist) leaveoneouttest(varlist)  
		perturbationtest(varname)]
	/*
	其中，基础选项：
	varname：被解释变量；
	varlist：解释变量，例如 window(period_-2 period-1 period_0 period_1 period_2)；
	command：推荐第一次使用该命令的用户加入此选项，可以展示回归使用的命令；
	event(varname)：包含在窗口中的事件；
	gapname(string)：系数的标签；
	noconstant：不包含常数项；
	level(#)：置信区间，默认水平是 (95%)。
	进行不同的模型对比时用到的选项：

	absorb#(varlist)：回归中包含的固定效应；
	controls#(varlist)：回归中包含的控制变量；
	cluster#(varname)：聚类标准误；
	vce#(robust)：稳健标准误；
	aweight#(varname)：设置分析权数，用在加权最小二乘回归以及类似的估计程序中；
	fweight#(varname)：设置频数权数，用以对重复观测案例计数，频数权数必须是整数。
	稳健性检验选项：

	display：用于检验的时候，将具体的回归结果展示出来；
	multitest(globalsnames)：分别绘制包括列表中的每一组控制变量的回归图；
	tuplestest(varlist)：分别绘制包含 varlist 中变量的所有可能组合的回归图；
	leaveoneouttest(varlist)：绘制剔除列表中某个控制变量的回归图；
	perturbationtest(varname)：根据 # 变量的 levelsof() 每次排除一个 (类) 样本，绘制相应的回归图。
	绘图选项：

	speccolor#(color)：改变回归 # 的颜色；
	symbols：改变不同回归模型的符号；
	symbol#：改变回归模型 # 的符号，可以和 symbols 同时使用；
	testcicolor(color)：设置检验的置信区间的颜色；
	testcoecolor(color)：设置检验的系数的颜色；
	offset(filename)：设置基本比较模型的偏移量；
	legend(filename)：设置图例；
	{y|x}title(string)：设置轴标题；
	{y|x}label(string)：设置轴标签；
	{y|x}line(string)：添加 xlines 或 ylines；
	{y|x}size(string)：调节图形的长度和高度。
	保存结果选项：

	savegraph(file)：保存所有表格，文件格式必须为 path/filename.csv；
	savetex(file)：以 .tex 格式保存表格。
*/

	use "F:\Users\zhang\Desktop\DID专题\经典DID\两控区对so2.dta",clear
	gen so2 = log(工业二氧化硫排放量_全市_吨)
	reghdfe so2 policy ,absorb(year cid ) clu(cid)
	gen event = year - 2010   //减去政策发生年份 
	
	replace event = -5 if event < -5 
	replace event = 5 if event > 5   & event~=. 
	forvalues i=5(-1)1{
	  gen pre`i'=(event==-`i'& treat==1)
	}

	gen current=(event==0 & treat==1)

	forvalues i=1(1)5{         //政策发生后
	  gen post`i'=(event==`i'& treat==1)
	}

	drop pre5    //删掉基准组
	drop post
	eventcoefplot so2 , window( pre4 pre3 pre2 pre1 current post5 post4 post3 post2 post1) command   noconstant absorb(year cid) controls(年末总人口_全市_万人) vce( clu cid) symbols legend(off)   xline(5, lpattern(dash) lcolor(red) )  