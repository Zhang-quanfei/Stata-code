*-合成DID,sdid适用平衡面板和一刀切政策，多期DID无法制作平行趋势图,无缺失值
		*--SDID不仅通过个体权重（unit-specific weights）找到与处理组相近的控制组个体，还通过时间权重（time-specific weights）找到与政策后处理期（post-treatment）相似的政策前处理期（pre-treatment），并分别赋予他们更大的个体权重和时间权重。
		*--命令安装
		ssc install sdid, replace // https://github.com/Daniel-Pailanir/sdid
		*--命令语法
		sdid Y S T D [if] [in], vce(method) seed(#) reps(#) covariates(varlist [, method]) 
    graph g1_opt(string) g2_opt(string) unstandardized graph_export([stub] , type)
		.Y：产出变量，只能是数值型；
		.S：个体变量，可以是数值型或字符串；
		.T：时间变量，只能是数值型；
		.D：处理变量，当个体被处理时取值为 1，否则取值为 0；双重差分policy
		.vce(method)：有三种计算标准误的方法，即 bootstrap、jackknife、placebo；在使用 jackknife 时，需要保证每一个处理时期内至少要有两个处理个体。
		.seed()：设定随机数的种子；
		.reps：设定 bootstrap 和 placebo 的抽样次数；
		.covariates(varlist [, method])：用来调整 Y 的控制变量，调整方法有两种。一种是 Arkhangelsky 等提出的 optimized (默认)，另一种是 Kranz (2021) 提出的 projected，后者运算速度要更快；
		.graph：指定这一选项将会绘制出第 2 部分图形；
		.g1_opt() 和 g2_opt()：一些画图的选项 (也就是 twoway_options 中的一些选项)；
		.unstandardized：如果指定这一选项，控制变量会被标准化，避免了在最优化的过程中控制变量过度分散。如果不指定这一选项，则控制变量将以原始形态进入回归当中；
		.graph_export([stub] , type)：输出图片，命名格式为 weightsYYYY 和 trendsYYYY。其中，YYYY 指的是处理时期，如果处理时期有多起，它将会对每一个处理时期输出上述两张图。在这一选项中 type 是必须指定的，其类型可以是 Stata 支持的任何一种格式 (eps、pdf、png 等)。当然也可以指定图片名字的前缀 stub。
		
		*命令实操
		webuse set www.damianclarke.net/stata/
		webuse prop99_example.dta, clear
		sdid packspercapita state year treated, vce(placebo) seed(1213) g1_opt(xtitle("") ///
			ylabel(-35(5)10) scheme(white_tableau)) g2_opt( ytitle("Packs per capita")    ///
			xtitle("") scheme(white_tableau)) graph graph_export(lianxh, .png)
		
		use "F:\Users\zhang\Desktop\DID专题\经典DID\两控区对so2.dta",clear
		gen so2 = log(工业二氧化硫排放量_全市_吨)
		drop if missing(so2,年末总人口_全市_万人)
		xtset cid year
		xtbalance ,range(2003 2018)
		
		sdid so2 cid year policy, vce(bootstrap)	covariates(年末总人口_全市_万人) seed(1213) graph g1_opt(xtitle("") ///
		ylabel(-35(5)10) scheme(white_tableau)) g2_opt( ytitle("Packs per capita")    ///
		xtitle("") scheme(white_tableau)) 