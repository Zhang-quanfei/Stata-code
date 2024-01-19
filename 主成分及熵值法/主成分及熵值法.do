*-----------
*-主成分分析 - 变量个数10以下可以用主成分分析法，10以上就不建议使用了
*-----------
	/*
	主成分分析也称作主分量分析，是霍特林（Hotelling）在1933年首先提出。
	主成分分析是利用降维的思想，在损失较少信息的前提下把多个指标转化为较少的综合指标。
	转化生成的综合指标即称为主成分，其中每个主成分都是原始变量的线性组合，且各个主成分互不相关
	*/
	use auto,clear
	*数据预处理：先做标准化
	norm mpg weight headroom trunk,method(mmx)

	*第一步：检验是否适合做主成分分析 （P值显著且KMO>0.7,这个标准可以根据论文【水】的程度适当降低。）
	// 根据Kaiser（1974），一般的判断标准如下：0.00-0.49  /不能接受(unacceptable)/;0.50-0.59  /非常差（miserable）/;0.60-0.69  /勉强接受（mediocre）/;0.70-0.79  /可以接受（middling）/;0.80-0.89  /比较好（meritorious）/;0.90-1.00  /非常好（marvelous）/。
	factortest mmx_mpg mmx_weight mmx_headroom mmx_trunk
	
	*第二步：主成分分析
	*A.这步操作为了判断需要留几个主成分（Eigenvalue>1并且Cumulative>0.8,或者满足一个）
	//特征值（eigenvalue）大于1的共有一个，是Comp1；
	//特征值小于1表示解释能力还不如原变量。结果通常会排除特征值小于1的成份。
	//Comp1 解释了  2.82057 /4 = 0.7051那么多标准化方差(4是变量个数)；加上Comp2，前两个主成份共解释了0.8808的标准化方差。
	pca mmx_mpg mmx_weight mmx_headroom mmx_trunk
	*(A步操作之后判断留两个主成分)
		/*
		判断标准一共有三个。
		
		第一：pca结果第一张表第一列大于1的变量个数；
		第二：pca结果第一张表最后一列数值达到0.8左右时的变量个数；
		第三：碎石图显示大于1的变量个数。
		在进行三个判断标准之前，还需要进行主成分的适用性分析，代码：
		estat kmo
		在结果的最后一行 ，Overall的数值若大于0.7，则达到使用主成分分析的最低标准。
		但其实，这个标准可以根据论文【水】的程度适当降低。
		*/
	
	*第三步：主成分因子分析
	*B.这步计算要看uniqueness,本数据结果不需要去除变量
	*B结果(1)uniqueness<0.6的，可以继续往下做。uniqueness>0.6，需要剔除相关变量，
	//去掉不满足条件的变量，重新从检验KMO开始做）
	factor mmx_mpg mmx_weight mmx_headroom mmx_trunk ,pcf //PCF, principle component factors，主成份因子法分析。使用factor命令，加上pcf选项即可。//主成份因子法会自动删除特征值小于1的因子

	*第四步：screeplot碎石图 //也叫特征值标绘图
	screeplot, yline(1)  //图中在特征值=1处画了一个横线，强调特征值大于1的因子才是我们想要的

	*第五步：计算主成分分析
	predict f1 f2  //综合出两个主成分，计算主成分得分
	*计算（贡献率*f1+贡献率*f2）/累计贡献率
	gen ff=(  0.7051*f1+  0.1756 *f2)/ 0.8808
	
*--------------
*-熵值法/熵权法
*--------------
	/*
	熵值法/熵权法含义
熵值法与熵权法是一个含义，是一种客观赋权法，是指根据各项指标观测值所提供的信息的大小来确定指标权重。
在信息论中，熵是对不确定性信息的一种度量。从统计学角度来看（同信息学有本质区别，也不同于热力熵）：
数据离散程度越大，则信息量越大，熵值也就越小，应当赋予更大的权重；数据离散程度越小，则信息量越小，熵值也越大，应当赋予更小的权重。
	*/
	*- 导入数据

	import excel using entropy.xlsx, first clear
	  
	*- 设定指标

	// 正向指标
	global positiveVar X1 X2 X3

	// 负向指标
	global negativeVar X4 X5 X6

	*- 以下不用修改
	global allVar $positiveVar $negativeVar

	// 标准化正向指标
	foreach v in $positiveVar {
		qui sum `v'
		gen z_`v' = (`v'-r(min))/(r(max)-r(min))
		replace z_`v' = 0.0001 if z_`v' == 0
	}

	// 标准化负向指标
	foreach v in $negativeVar {
		qui sum `v'
		gen z_`v' = (r(max)-`v')/(r(max)-r(min))
		replace z_`v' = 0.0001 if z_`v' == 0
	}

	// 计算各指标比重
	foreach v in $allVar {
		egen sum_`v' = sum(z_`v')
		gen p_`v' = z_`v' / sum_`v'
	}

	// 计算熵值
	foreach v in $allVar {
		egen sump_`v' = sum(p_`v'*ln(p_`v'))
		gen e_`v' = -1 / ln(_N) * sump_`v'
	}

	// 计算信息效用值
	foreach v in $allVar {
		gen d_`v' = 1 - e_`v'
	}

	// 计算各指标权重
	egen sumd = rowtotal(d_*)
	foreach v in $allVar {
		gen w_`v' = d_`v' / sumd
	}

	// 计算各样本的综合得分
	foreach v in $allVar {
		gen score_`v' = w_`v' * z_`v'
	}
	egen score = rowtotal(score*)

	drop z_* p_* e_* d_* sum*