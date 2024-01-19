*-----------------DID专题课----------------*
*---目录---

*-经典DID

*-交错DID

*-连续DID

*-截面DID

*-模糊DID

*-空间DID

*-三重差分DDD

*-合成DID

*-断点回归DID

*--------------------经典DID---------------------*

*-------------
*-模型选择问题
*-------------
	*-随机效应回归：误差项与解释变量不相关，无内生性问题
	*-Tobit 偏态分布，数据集中在某一端或两端
	*-Logit 两值选择模型，概率回归
	*-Probit 计数模型、两值选择模型
	*-OLS 残差和因变量服从正态分布
	*-计数模型：泊松回归、负二项回归（零膨胀）

*---------------
*-聚类稳健误问题
*---------------
	*聚类：缓解自相关；稳健标准误：缓解异方差
	*稳健误影响t值，不影响系数
	*有时候我们没有甚至不能将标准误聚类到更高层级。除了显著性与稳健性之间的权衡，更多的原因在于聚类层级越高聚类数目越少，而大样本理论要求聚类数目足够大，这样才能保证所估计的标准误收敛到真实值（Petersen，2009[1]），根据拇指法则，聚类数少于30可能就不太合适了。
	
	*-倾向于聚类在一个大的层面
	*为了同时兼顾聚类层级与聚类数目，有些文献将标准误聚类到行业-年份层面（在Stata中可以利用分组函数group生成聚类变量再在回归中进行聚类调整，即：先egen ind_year = group(industry year)，然后reghdfe y xlist, absorb(id year)cluster(ind_year)），如李青原和章尹赛楠（2021）[2]、邵朝对等（2021）[3]，即假定同一年同一行业之间存在自相关，而不同年或不同行业之间不存在自相关。
	

*-------------------
*-reghdfe和xtreg区别
*-------------------
	*-reghdfe适用于有大量高维固定效应模型，速度更快			
	*-xtreg命令默认报告的是经过修正的R2，而reghdfe默认报告的是没有经过修正的R2（控制变量和固定效应加的越多，R2越大）。
*-----------------------
*-固定效应和交互固定效应
*-----------------------
	*文章来源：https://zhuanlan.zhihu.com/p/420524355
	*一般意义上的控制变量是根据经济学理论甚至常识来引入的，这些变量可观测、可度量，并且由于大多数情况是"基于×××和×××的研究"，因此可信服。但是，除了这部分可观测、可度量的控制变量，影响结果变量的经济要素是复杂多样的，其中就包括许多不可观测且不可度量的因素，比如某年实施的经济政策、地区的风俗文化、行业的典型特征、个体的性格认知等等。为了控制住这些不可观测因素对研究结果的干扰，就需要额外在回归方程中引入FE，比如常见的年份FE、地区FE、行业FE和个体FE等等。
	
*年份FE的同质性就是假定在同一年份某一不可观测因素（如政策冲击、经济周期等）对所有企业的结果变量的作用方向、作用大小是一样的。但是，现实的经济冲击并不会对所有企业产生一致的同质性影响，不同企业因自身实力、价值链地位、所有者性质等的不同在面对同一经济冲击时做出的战略性反应不同，从而导致最终的结果不同。

*比如2012年出台的《绿色信贷指引》，这一自上而下的环境规制政策（或者，信贷政策）虽然是在全国层面实施的，但是对不同行业企业的影响不同。具体而言，制造业企业由于"高污染、高能耗、产能过剩"的典型特征最易受到绿色信贷政策的影响，金融机构在《绿色信贷指引》下将直接缩减对"两高一剩"企业的信贷供给，如果这些企业本身就面临严峻的融资约束压力，并且没有其他可供替代的融资渠道（如内源融资、商业信用等），信贷渠道受阻将最终反映到企业的生产经营活动。

*总结来说就是，控制时间FE仅仅考虑到了时间维度上的同质性经济冲击，但现实中的经济冲击将对不同类型企业产生异质性影响，为将这些不可观测的异质性冲击因素控制住，回归方程需要引入交互FE，比如说这里的ind - year FE。

*传统的面板固定效应，仅仅考虑的是二维(时间效应和个体效应)效应，以揭示样本中不随个体变化的时间差异（如时间固定）和不随时间变化的个体差异（如个体固定、行业固定、省份固定）。但是，随时间变化的个体差异却没控制，故而改进产生——交互固定效应。
	
*----------------
*-DID控制变量选取
*----------------
	*文章来源：https://mp.weixin.qq.com/s/ViTEBkLgp4Y8evbYGW6m3w
	*-遗漏变量导致系数不是无偏的，但控制变量过多会导致多重共线性升高（方差增大）
	*-在回归方程中加入控制变量起到两个作用。第一，保证条件独立假设（conditional independence assumption，CIA）成立。条件独立假设成立意味着给定控制变量时处理变量D与误差项不相关，从而保证了 OLS 估计量 b 是我们所关心的因果效应的一致估计。这是观测性研究的因果推断中控制变量所发挥的最核心作用。第二，减小误差，提高估计精度。如果处理变量D与误差项已经不相关，无论是否加入控制变量，b都是因果效应的一致估计。此时加入合理的控制变量可以降低误差从而提高估计精度。
	*-第一类控制变量
		*--为了保证 CIA（条件独立，方差与解释变量无关）成立而控制的变量（称为好控制变量，good control），必须在回归方程中加以控制。这类变量既影响Y又影响D。首先通常个体固定效应和时间固定效应必须加以控制，其次是既影响Y又影响D的可观测变量X。不过，发生在处理时点之后的X作为事后变量（可能受到D影响），很有可能是一个"坏"控制变量（见下文）。影响D，并且通过机制变量M影响Y的变量也是“好”控制变量
	*-第二类控制变量
		*--第二类控制变量是可能导致 CIA 不成立的变量（称为坏控制变量，bad control），必须排除在回归方程之外。受到D影响的结果变量一般都是坏控制变量，加入回归方程会使得估计系数b 不再具有因果解释力。在处理时点之后产生变化的变量都可能受到D 的影响，很可能是坏控制变量。在过去相当长一段时期内有一种看法认为"凡是与Y和D相关的变量均应该作为控制变量纳入回归方程"，这种看法忽略了坏控制变量的存在。“差”控制变量：X变量是机制变量、X变量是Y的后代变量（Y影响X）
	*-第三类控制变量
		*--第三类控制变量是不影响 CIA 是否成立的变量（称为中性控制变量，neutral control），在回归方程中可加可不加。从因果效应识别的角度而言，这类变量是否加入回归方程并不影响对因果效应估计的一致性，控制或不控制均可。从统计推断的角度来看，合理地控制这类变量有助于减小残差从而提高估计精度，但是与坏控制变量问题类似，选取不当的中性控制变量反而会使得估计偏误增加。判断中性控制变量是否应该控制的一个经验法则是：(1)影响被解释变量Y(直接影响Y，或者通过影响机制M影响Y)的中性控制变量可以加入回归方程中以减小误差，提高估计精度；(2)影响D的中性控制变量一般不控制，因为若控制则会减小D的变动性（variation），降低估计精度。

	*-------控制变量问题------*
		1、控制变量少数显著可以吗？：可以
		2、加入控制变量后系数变大？：可以
		3、加入控制变量后符号改变？：考虑更换控制变量
		4、控制变量选取问题？	   :核心是自变量显著
*-----------
*-取对数问题
*-----------
	*文章来源1：https://mp.weixin.qq.com/s/ViTEBkLgp4Y8evbYGW6m3w
	*文章来源2：https://mp.weixin.qq.com/s/r2zUkgprfv4mSe9vi_---Q
		1、取对数的变量形式？	   ：变化值很大的数据或者有量纲的数据，相对值一般不取对数，例如百分比、人口占比
		2、取对数方法：（1）无零值：log(x);(2)有零值：log(1+x);(3)有负数和零值：sign(x)*log(1+x)
		注意：零值取对数无意义，当有较多零值时，建议考虑probit、tobit、零膨胀模型。《Count (and count-like) data in finance》这篇文章认为，log(1+x)会产生没有自然解释的估计量(例如0)（他的危害会比遗漏最重要的控制变量还要大），他认为一个简单的固定效应泊松回归可以产生更有效的估计值
*------------------------
*-一键显著性-控制变量选取1
*------------------------
	*文章来源：https://mp.weixin.qq.com/s/9mMCj1xObjW9oufUU3v_XA
	ssc install gsreg,replace
	
	/*
	gsreg y x1 x2 x3 x4 x5, fixvar(x) replace ncomb(n) cmdest(reghdfe) cmdoptions(absorb(year id) vce(cluster id))
	gsreg 因变量 可能待控制的混淆变量 , fixvar( 自变量) replace ncomb(n) cmdest(回归模型)  	cmdoptions(回归模型的附加选项)，其中ncomb(n)为需要筛选的控制变量个数，此处也能以区间形式表示，例如ncomb(1-4)
	fix(x)是自变量，x是需要被固定住的，毕竟我们主要筛选出控制变量的组合
	cmdest()填入使用的回归模型，此处选择的是reghdfe，其他备选项包括 regress, xtreg, probit, logit, areg, qreg 和plreg之类的回归模型
	cmdoption()是回归模型的附加选项，例如此处用到了双重固定效应absorb(year id) 和聚类标准误vce(cluster id)，也可以使用稳健标准误vce(robust)。
	*/
	use F:\Users\zhang\Desktop\DID专题\高铁对so2,clear
	reghdfe so2 dum_ta ,absorb(year cid) clu(cid)
	gsreg so2 人口密度_全市_人每平方公里 地区生产总值_当年价格_全市_万元 人均地区生产总值_全市_元 外商实际投资额_全市_万美元 地方一般公共预算收入_全市_万元 地方一般公共预算支出_全市_万元 科学技术支出_全市_万元, fixvar(dum_ta) replace  cmdest(reghdfe) cmdoptions(absorb(year cid) vce(cluster cid))
*------------------------
*-一键显著性-控制变量选取2
*------------------------
	ssc install oneclick, replace  //安装命令
	*- 基本语法
	oneclick y controls, method(regression) pvalue(p-value) fixvar(x and other FE) [
			options zvalue ]
		*y 位置用来放置你的被解释变量
		*controls 位置用来放置你的待选控制变量集合，可以是 i.var 形式，也可以是 l.var 或者 f.var 等
		*m() 位置用来放置你的回归方法，可以是 reg、logit、probit等
		*p()，在括号中输入你希望的显著性水平，一般是 0.1、0.05，以及0.01。			*fix()，在括号中输入你的主要解释变量以及需要每个回归中都出现的变量。比如在一些实证论文中，我们希望能够保留 size、roa 等其他常见变量，则可以写在解释变量后。注意： 第一个位置一定要放解释变量。
		*o()，用来放置其他原属于回归方法的其他选项，比如 xtreg y x, re 中的 re 选项、reghdfe y x, absorb(A B) 中的 absorb(A B) 选项
		*z，根据第一步中的判定方法考虑是否需要添加以 z-value 判别显著性的方法（logit、probit后面加z）
	*-在 oneclick 运算后，屏幕上会呈现一个简单的运行过程与最后的结论摘要，并且会在当前工作路径下生成一份名为 subset.dta 的文件。
	*-查看当前工作路径下的 subset.dta 文件。当前工作路径指的是你当前 Stata 窗口左下角所显示的路径。该文件中有两个变量，一个变量叫 subset 用来展示满足显著性要求的控制变量组合，一个变量叫 positive 用来展示显著的方向，1表示正向显著，0表示负向显著。
	use F:\Users\zhang\Desktop\DID专题\高铁对so2,clear
	reghdfe so2 dum_ta ,absorb(year cid) clu(cid)
	oneclick so2 人口密度_全市_人每平方公里 地区生产总值_当年价格_全市_万元 人均地区生产总值_全市_元 外商实际投资额_全市_万美元 地方一般公共预算收入_全市_万元 地方一般公共预算支出_全市_万元 科学技术支出_全市_万元, method(reghdfe) pvalue(0.01) fixvar(dum_ta) o(absorb(year cid) clu(cid))
	
	reghdfe so2 dum_ta 人口密度_全市_人每平方公里  外商实际投资额_全市_万美元 ,absorb(year cid) clu(cid)
	
*--------------经典DID一个例子---两控区对so2-------------------*

*----------------
*双重差分满足假设
*----------------
	*-平行趋势假设和SUTVA假设（无溢出效应）
	
*------------
*--描述性统计
*------------
	use "F:\Users\zhang\Desktop\DID专题\经典DID\两控区对so2.dta",clear
	
	gen so2 = log(工业二氧化硫排放量_全市_吨)
	collapse (mean)so2,by(year)
	twoway area so2 year   //面积图
	twoway spike so2 year //尖峰图
	reghdfe so2 policy 人口密度_全市_人每平方公里  外商实际投资额_全市_万美元 ,absorb(year cid) clu(cid)
	keep if e(sample)
	local xx "  so2 policy 人口密度_全市_人每平方公里  外商实际投资额_全市_万美元    "	
     logout, save(mytable) word replace:       ///  
            tabstat `xx', stat(N mean sd min p50 max) format(%10.3f) c(s)

*-------------
*--相关性分析1
*-------------
	use "F:\Users\zhang\Desktop\DID专题\经典DID\两控区对so2.dta",clear
	gen so2 = log(工业二氧化硫排放量_全市_吨)
	logout, save(相关性分析) word replace : pwcorr_a so2 policy 人口密度_全市_人每平方公里  外商实际投资额_全市_万美元 ,format(%6.2f)
									
*-------------
*--相关性分析2
*-------------
		ssc install schemepack, replace
		ssc install palettes, replace
		ssc install labutil, replace
		* 在绘图之前设定绘图模板
		set scheme white_tableau
		* 在 twoway 选项 scheme() 中指定绘图模板
		twoway (scatter so2 policy), scheme(white_tableau) 
		
		*实例演示
		sysuse auto, clear
		* 定义存放变量暂元
		local var_corr price mpg trunk weight length turn foreign 
		* 定义存放变量个数暂元
		local countn : word count `var_corr'  
		
		* 计算相关系数矩阵
		quietly correlate `var_corr'
		matrix C = r(C)  //在执行quietly correlate var_corr命令后，r(C)会自动存储相关系数矩阵，并在后续的计算中被调用
		mat list C  //矩阵如下
		
		local rnames : rownames C  // 存放行名
		dis "`rnames'"
		
		* 现在从相关系数矩阵中生成变量
		local tot_rows : display `countn' * `countn'
		clear
		set obs `tot_rows' // 生成7*7个观察值
		
		* 生成字符型变量 corrname1、corname2，和数值型变量 y、x、corr、abs_corr
		generate corrname1 = ""
		generate corrname2 = ""
		generate y = .
		generate x = .
		generate corr = .
		generate abs_corr = .              
		local row = 1
		local y = 1
		local rowname = 2                    
		foreach name of local var_corr {
		forvalues i = `rowname'/`countn' { 
			local a : word `i' of `var_corr'
			replace corrname1 = "`name'" in `row'
			replace corrname2 = "`a'" in `row'
			replace y = `y' in `row'
			replace x = `i' in `row'
			replace corr = round(C[`i',`y'], .01) in `row' //.01保存两位小数
			replace abs_corr = abs(C[`i',`y']) in `row'
			local ++row                     
			}
		local rowname = `rowname' + 1
		local y = `y' + 1               
		}
		drop if missing(corrname1)  // 去除多余的观察值
		replace abs_corr = 0.1 if abs_corr < 0.1 & abs_corr > 0.04
		list in 1/10
		
		* 其中 y 和 corrname1，以及 x 和 corrname2 的对应关系如下：
		list corrname1 y corrname2 x in 1/10
		
		*利用 colorpalette 设置图像颜色，并利用返回值 r(p#) 对不同区间中的相关系数 corr 定义不同的颜色。
		colorpalette HCL pinkgreen, n(10) nograph intensity(0.65) // 调色板颜色CET CBD1和HCL pinkgreen
		colorpalette CET CBD1, n(10) nograph // 此处对应着最后相关系数图的图像颜色。
		generate colorname = ""
		local col = 1
		forvalues colrange = -1(0.2)0.8 {  //以0.2为区间单位定义不同区间颜色
			replace colorname = "`r(p`col')'" if corr >= `colrange' & corr < `=`colrange' + 0.2'
			replace colorname = "`r(p10)'" if corr == 1
			local ++col
		}       
		list corr colorname in 1/10 // 不同区间的corr对应不同的颜色
		
		* 利用暂元保存绘图命令
		forvalues i = 1/`=_N' {
			   local slist "`slist' (scatteri `=y[`i']' `=x[`i']' "`: display %3.2f corr[`i']'", mlabposition(0) msize(`=abs_corr[`i']*15') mcolor("`=colorname[`i']'"))"
			   }   
		* 保存纵轴标签
		labmask y, val(corrname1)
		labmask x, val(corrname2)      
		levelsof y, local(yl)
		foreach l of local yl {
			local ylab "`ylab' `l'  `" "`:lab (y) `l''" "'"         
		}       
		* 保存横轴标签
		levelsof x, local(xl)
		foreach l of local xl {
			local xlab "`xlab' `l'  `" "`:lab (x) `l''" "'"     
		}     
		* 利用上述保存的暂元绘制图像
		twoway `slist', title("Correlogram of Auto Dataset Cars", size(3) pos(11)) ///
			note(, size(2) margin(t=5))                 ///
			xlabel(`xlab', labsize(2.5) angle()) ylabel(`ylab', labsize(2.5))              ///
			xscale(range(1.75)) yscale(range(0.75)) ytitle("") xtitle("")          ///
			legend(off) aspect(1) scheme(white_tableau)

		* 以 PNG 格式输出图像            
		graph export "correlogram_stata_cbf.png", as(png) width(1920) replace 
		
*------------
*-绘制散点图1
*------------	
		*superscatter 命令安装：
		ssc install binscatterhist,   replace
		net install superscatter, from(http://digital.cgdev.org/doc/stata/MO/Misc)
		net install gr0002_3, from(http://www.stata-journal.com/software/sj4-3)  // 纯黑白风格, lean1, lean2 模板
		*语法
		use auto,clear
		superscatter price weight, percent color()   fittype(lfitci) fitoptions(lwidth(thick)) legend(ring(0)  cols(1) pos(5)) name(_example1, replace) title(Example 1)  //percent可以改成Kdensity
		
*---------------------
*-散点与分组密度函数图
*---------------------	
		//grc1leg 用于组合图形，在具体用法上与 graph combine 相同，只是它为所有组合图形显示一个公共图例，该公共图例是组合图形中的图例之一。
		* 命令安装
		net install grc1leg, from("http://www.stata.com/users/vwiggins")
		* 命令语法
		grc1leg name [name ...] [, combine_options legend_options ]
			/*
			其中，name 是图片名称。combine_options 包括：

				选项 colfirst、rows、cols、holes：用于指定在最终生成的组合图中各图的排列顺序，colfirst表 示该图片显示在下面一列；rows() 和 cols() 指定图片显示在具体的行和列中；holes 指定留出空白的区域。
				选项 iscale 可用于指定文本和标志的字体大小。
				选项 imargin 用于确定单个图表的边缘长度。
				选项 ycommon 和 xcommon 为 X 轴和 Y 轴指定常用刻度。
				选项 scheme 为图片设定特定模板。
				选项 name 指定组合图的名称。
				legend_options 包括：

				选项 legendfrom 指定要从中获取组合图例的图形，默认值为列表中的第一个图形。
				选项 position 和 ring 用于覆盖图例的默认位置，该位置通常位于绘图区域下方的居中。
				使用 position 可以使图例位于绘图区域本身内，并允许将图例放置在绘图内。根据 12 小时制表盘上的小时指定图例放置方向，如 position(12) 意为将图例添加在绘图区域正上方。
				使用 ring 可以指定图例与绘图区域间的距离。ring(0) 表示可将图例放置于绘图区域内部；ring(k) 当 k>0 时，图例被放置在绘图区域以外。
				选项 span 将图例放置在跨越整个图片宽度或高度的区域。
				schemepack命令

				schemepack 命令包括许多 Stata 预设图片方案，如 white_tableau、black_tableau、gg_tableau、white_cividis、black_cividis、gg_cividis 等。
			*/
		* 命令安装
		ssc install schemepack, replace
		* 命令安装
		ssc install palettes, replace
		ssc install colrspace, replace
*--------------命令实操------------------*
		clear all
		* Necessary Package Installations (One time only)
		* net install grc1leg, from("http://www.stata.com/users/vwiggins") replace
		* ssc install schemepack, replace
		* ssc install palettes, replace
		* ssc install colrspace, replace
		* Loading the example dataset from GitHub
		lxhget mpg.txt, replace
		import delimited using mpg.txt, clear

		* Using loop to write and store the plotting commands and syntax by class
		levelsof class, local(classes)  //分组变量
		*`"2seater"' `"compact"' `"midsize"' `"minivan"' `"pickup"' `"subcompact"' `"suv"' 
		foreach class of local classes {
			  local sctr `sctr' scatter cty hwy if class == "`class'",    /// 
			   mcolor(%60) mlwidth(0) ||   //这个语句创建了一个新的本地宏sctr`，它将当前值与现有值连接起来。这很可能用于存储散点图。local sctr `sctr'是在一个循环内部执行的，循环每次迭代时会对 `sctr' 进行重新定义，以便在每次迭代中计算不同类别的均值，并且将其存储在一个本地宏 `sctr' 中，这个宏将在下一次迭代中使用。这行代码是对不同种类汽车输出不同颜色散点图并绘制在一张表上
			   quietly summarize cty if class == "`class'"  //cty被解释变量
			   local cty `cty' function normalden(x, `r(mean)', `r(sd)'),  ///  //这个语句定义了一个新的函数normalden，它计算正态分布在给定均值和标准差下的概率密度函数。
			  horizontal range(cty) base(0) n(500) xlabel(, nogrid)       ///  //这个语句创建一个水平方向的密度图，以变量cty的值为x轴。range参数指定x轴的范围，base参数指定y轴的起始值，n参数指定图形中的点数，xlabel参数指定x轴的标签。nogrid选项表示不显示网格线
			   recast(area) fcolor(%50) lwidth(0) ||  //这个语句将密度图重新绘制为一个面积图，设置颜色和线条宽度
			   quietly summarize hwy if class == "`class'"  //hwy解释变量
			   local hwy `hwy' function normalden(x, `r(mean)', `r(sd)'),  ///
			   range(hwy) base(0) n(500) ylabel(, nogrid) recast(area)     ///
			   fcolor(%50) lwidth(0) ||        
		   } //双竖线 || 可以用来分隔命令并将它们连接在一起，以构建复合图形。它们将命令分组，并将它们视为单个命令，以便将它们传递给Stata的图形绘制引擎进行处理。每个竖线之间的命令将作为单独的绘图层进行绘制，因此可以在同一个图形中绘制多个层。

		* Plotting each of the above saved commands and storing them for combining later using name()
		twoway `sctr' || lowess cty hwy || , legend(off) name(lowess) ///
			ytitle("City MPG") xtitle("Highway MPG") ysc(r(10(5)35)) ///
		   xsc(r(10(10)40)) xlabel(, nogrid) ylabel(, nogrid) 
		twoway `cty', graphregion(margin(b=0)) name(cty) leg(off)    ///
			fxsize(25) ytitle("") ylabel(none) xtitle("") ysc(r(10(5)35))
		twoway `hwy', graphregion(margin(b=0)) name(hwy) leg(label(1 "2 Seater") ///
			label(2 "Compact") label(3 "Mid-Size") label(4 "Minivan")            ///
			label(5 "Pickup") label(6 "Sub-Compact") label(7 "SUV") size(2)      ///
			row(2) col(4)) fysize(25) xtitle("") xla(none) ytitle("⠀") xsc(r(10(10)50))
		  
		* Combining all the plots saved above
		grc1leg hwy lowess cty, title("{bf}Fuel Economy by Vehicle Type", color(navy) ///
			size(3) j(left) pos(11) margin(l=6)) subtitle("Side plots for density",   ///
			size(2) pos(11) margin(l=6)) legendfrom(hwy) span hole(2) rows(3)         ///
			imargin(zero) commonscheme scheme(white_tableau)
			  
		* Exporting the visual 
		graph export "Sideplots_Distribution_by_Group_Stata.png", ///
			as(png) name("Graph") width(1920) replace
		
*-------------
*-平行趋势检验
*-------------
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
	reghdfe so2 pre* current post* ,absorb(year cid ) clu(cid)
	coefplot,  ///
	keep(  pre*  current post*) ///
	vertical                             ///
	yline(0)                             ///
	xtitle("年份" ,height(5))   ///
    msize(small)  ///plot样式
	xline(5,lwidth(thin) lpattern(solid) ) /// 
	ylabel(,labsize(*0.85) angle(0)) xlabel(,labsize(*0.85)) ///     
	ytitle("系数",orientation(vertical)) ///
	addplot(line @b @at,lcolor(gs1) ) ///增加点之间的连线
	ciopts(recast(rcap) lwidth(thin) lpattern(dash) lcolor(gs2)) //置信区间样式,dash或者solid
	*需要强调的是，事前平行趋势通过检验并不意味着平行趋势假设一定成立。平行趋势假设本身不可检验（事后无法观测），而事前平行趋势只是整个平行趋势假设的一部分，即使事前平行趋势通过检验也只是表明处理组和控制组在干预发生前保持相同时间趋势，并不能确保事后趋势也一定平行，所以"事前平行趋势检验通过，平行趋势假设成立"说法并不准确
	
*--------------------------------
*-平行趋势检验-Beck et al. (2010) 
*--------------------------------
	*Beck T, Levine R, Levkov A. Big bad banks? The winners and losers from bank deregulation in the United States[J]. The Journal of Finance, 2010, 65(5): 1637-1667.
	*标准的事件分析方法，但需要注意的是本文的样本中所有州最终都成为了处理组样本,无对照组
	*文章介绍：https://zhuanlan.zhihu.com/p/453044386
	use "macro_workfile.dta",replace
	xtset statefip wrkyr

	gen policy = wrkyr - branch_reform
	replace policy = -5 if policy <= -5
	replace policy = 10 if policy >= 10

	gen policy_d = policy + 5
	gen y = log(gini)

	xtreg y ib5.policy_d i.wrkyr, fe r  //将第五期作为对照组

	///生成前五期系数均值
	forvalues i = 0/4{
		gen b_`i' = _b[`i'.policy_d]
	}

	gen avg_coef = (b_0+b_4+b_3+b_2+b_1)/5
	su avg_coef

	coefplot, baselevels ///
	   drop(*.wrkyr _cons policy_d) ///
	   coeflabels(0.policy_d = "t-5" ///
	   1.policy_d = "t-4" ///
	   2.policy_d = "t-3" ///
	   3.policy_d = "t-2" ///
	   4.policy_d = "t-1" ///
	   5.policy_d = "t" ///
	   6.policy_d = "t+1" ///
	   7.policy_d = "t+2" ///
	   8.policy_d = "t+3" ///
	   9.policy_d = "t+4" ///
	   10.policy_d = "t+5" ///
	   11.policy_d = "t+6" ///
	   12.policy_d = "t+7" ///
	   13.policy_d = "t+8" ///
	   14.policy_d = "t+9" ///
	   15.policy_d = "t+10") ///更改系数的label
	   vertical ///转置图形
	   yline(0, lwidth(vthin) lpattern(dash) lcolor(teal)) ///加入y=0这条虚线
	   ylabel(-0.06(0.02)0.06) ///
	   xline(6, lwidth(vthin) lpattern(dash) lcolor(teal)) ///
	   ytitle("Percentage Changes", size(small)) ///加入Y轴标题,大小small
	   xtitle("Years relative to branch deregulation", size(small)) ///加入X轴标题，大小small
	   transform(*=@-r(mean)) ///去除前五期的系数均值,在某些情况下，个体固定可能并不适用或不足以消除趋势因素，比如存在季节性或周期性的时间序列数据。此时，仍然需要考虑采用去除前五期系数均值等方法来预处理数据，以确保检验结果的准确性
	   addplot(line @b @at) ///增加点之间的连线
	   ciopts(lpattern(dash) recast(rcap) msize(medium)) ///CI为虚线上下封口
	   msymbol(circle_hollow) ///plot空心格式
	   scheme(s1mono)

	
*---------------
*-平行趋势不满足
*---------------
	
	/*
	*-时间趋势项和时间虚拟变量区别
	1、在程序语句上，时间趋势项在 Stata 因子分析中被标示为连续变量，运算符为 c.x，如 c.year；而时间虚拟变量在 Stata 因子分析中被标示为类别变量，运算符为 i.x，如 i.year。		2、在经济含义上，时间趋势项通常近似代表了社会中所发生的技术进步；而时间虚拟变量的目的是控制住某些特殊年份造成的影响，例如严重的自然灾害、战争以及金融危机，参见 ResearchGate Question: Is anyone familiar with Time Trends vs Time Dummies?
		3、在适用范围上，时间虚拟变量因其所受约束更少所以应用更加广泛。当把时间趋势项纳入模型时，实际上我们隐含假设了某些单调性 (线性趋势) 或某种函数形式；但是时间虚拟变量则不受此约束，它可以表现为毫无规律的 "锯齿" 形态，也可以表现为时间趋势项那样的函数形式。在某种程度上，时间虚拟变量可以吸收掉所有的特定时间效应，包括时间趋势，参见 Economics Job Market Rumors 。
4、时间序列所具有时间趋势是可以定量度量的 (通过 t=1,2,3,...)，但也存在一些影响经济变量的因素无法定量度量，比如季节对某些产品 (如冷饮) 销售的影响，战争、金融危机对 GDP 的影响等。为了在模型中反映这些因素的影响，并提高模型的精度，我们需要引入时间虚拟变量 (time dummies)，根据这些因素的属性类型人工取值为 "0" 或 "1" (李子奈, 潘文卿, 2010)
	总结以上，时间趋势项相当于赋予了给定年份一个时间指数（如果样本区间是 2000-2010 年，则时间趋势变量给 2000 年赋值为 1，2001 年赋值为 2 等），它可以解释其他自变量解释不了的因变量的外生增加或下降。时间虚拟变量则是当观测值在指定的月份/季度/年份时等于 1，否则等于 0，它控制住了特定时间的固定效应，比如指定时间段的冲击影响。
		*--当然，假如有明确的需要以及可靠的理论依据，那么模型就可以同时纳入时间趋势项与时间虚拟变量
		*/
	*-控制组间趋势差异
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
	reghdfe so2 pre* current post* ,absorb(year c.year##cid ) clu(cid)
	coefplot,  ///
	keep(  pre*  current post*) ///
	vertical                             ///
	yline(0)                             ///
	xtitle("年份" ,height(5))   ///
    msize(small)  ///plot样式
	xline(5,lwidth(thin) lpattern(solid) ) /// 
	ylabel(,labsize(*0.85) angle(0)) xlabel(,labsize(*0.85)) ///     
	ytitle("系数",orientation(vertical)) ///
	addplot(line @b @at,lcolor(gs1) ) ///增加点之间的连线
	ciopts(recast(rcap) lwidth(thin) lpattern(dash) lcolor(gs2)) //置信区间样式,dash或者solid
	
		*--Angrist & Pischke (2008) 指出，在各州具有不同 (但较有规律) 的变动趋势时，模型包含年份虚拟变量也包含了时间趋势项的 DID 模型，仍然可以对政策效应进行有效识别。原因是年份虚拟变量吸收了每个州时间上所受的共同冲击，时间趋势项又可以解决各州趋势不一致的问题。  Angrist J D, Pischke J S. Mostly harmless econometrics: An empiricist's companion[M]. Princeton university press, 2008: pp.221-248.

*-------------------------
*-时间固定效应与时间趋势项
*-------------------------
	*一、时间FE & 时间trend
		在LSDV法下，时间固定效应（time FE）表现为一系列的时间虚拟变量，对于特定年份，若样本所处年份是则记为1，否则记为0。在Stata中，这一系列的时间虚拟变量引入方式有两种：
		一是直接在回归命令中加入类别变量，如i.year，使用这种方式无需生成额外的变量，节约内存。
		二是生成额外的时间虚拟变量并加入回归命令中，如先tabulate year, gen(fe_)，然后在回归命令中写入fe_*。
	控制时间FE的用意在于吸收时间维度上不可观测的同质性冲击的影响，即所有个体共有的时间因素，如宏观经济冲击、财政货币政策等等，假定这些因素在特定年份对不同个体的影响是一致的。此外，如果考虑到异质性，即考虑到这些因素可能对不同组别（如省、城市、行业等）的个体影响不一致，则可以在模型中引入交互FE，如行业-时间FE。这种交互FE在reghdfe命令下有两种引入方式（以行业-时间FE为例）：
		一是首先egen ind_year = group(ind year)，其次在reghdfe命令的选择项中写入absorb(ind_year)。
		二是使用因子表达式直接在选择项中写入，如absorb(ind#year)。
		模型引入时间趋势项（time trend）一般有三种方法：
		法一：直接在回归命令中写入c.year或year。
		法二：假设样本数据集（而不是各个样本！）的最小年份为year_min，则首先生成trend = year - year_min + 1，然后再在模型中引入trend。
		法三：首先bysort id (year): gen trend = _n，其中，(year)是为了保证样本按照id - year进行升序排序。其次再在回归命令中写入trend。
			.推文利用法三生成trend，法三的缺陷在于，如果样本存续年份中断，如2012、2014、2018，法三将视这三年为连续年份，并分别记为1、2、3。

		加入时间趋势项是为了控制不同个体的被解释变量可能存在的并且尚未被其他控制变量和FE所覆盖/解释的增减趋势，因为不同组别（规模、性质、政策分组、生命周期等）个体的被解释变量的时间趋势或许存在一定程度的差异，并且在控制已有的解释变量之后依然可能存在较为明显的时间趋势。

		以上内容可总结为以下几点：
		第一，在LSDV法下时间FE为一系列的虚拟变量，而时间trend为一个变量。
			第二，时间FE用来吸收不随个体但随时间而变的不可观测因素冲击的影响，而时间trend则用来控制被解释变量可能存在的增减趋势。
		第三，时间FE本质上是包括trend了的，trend可由FE线性表出，因此如果在方程中同时加入FE和trend，trend可能由于出现多重共线性而被omitted，但是两者同时加入模型可使得估计结果更稳健
		第四，在整体序列较长的长面板中，很大可能需要控制时间trend对回归结果的影响。
	*二、时间trend的识别
		下面将对模型中可能存在的时间趋势进行识别，推文提供两种思路：
		
		一是直接在回归模型中加入trend，如果trend不显著，说明不需要引入。
		二是在控制除trend外所有的变量及FE后，观察残差中是否仍旧存在trend，如果存在，说明被解释变量的增减趋势不能完全被变量和FE所吸收，模型须额外引入trend。
		根据以上两种识别思路设计出两种识别方法：一是回归法，二是图形法。
		
		copy  https://www.stata-press.com/data/r17/nlswork.dta nlswork.dta, replace
		clear all
		use   nlswork.dta, clear
		xtset idcode year
		gl    regst   "qui reghdfe ln_w grade age c.age#c.age ttl_exp c.ttl_exp#c.ttl_exp tenure c.tenure#c.tenure not_smsa south"
		gl    regopt  "absorb(idcode year) resid"
		**# 生成时间趋势项
			bys idcode (year): gen t = _n
		*	gen t = year
		*	gen t = year - 67  // 另外两种 t 的生成方法
		*--回归法
		**# 法一：回归
			$regst t, $regopt
			dis "系数(Total) = " %6.4f _b[t] "；t值(Total) = " %6.4f _b[t] / _se[t]
			
			$regst t if race == 1, $regopt
			dis "系数(White) = " %6.4f _b[t] "；t值(White) = " %6.4f _b[t] / _se[t]
			
			$regst t if race != 1, $regopt
			dis "系数(Other) = " %6.4f _b[t] "；t值(Other) = " %6.4f _b[t] / _se[t]
			//运行以上代码可以观察到，无论是在总体样本、白人群体还是其他人种群体，时间趋势项t的回归系数均不显著（5%的显著水平下），且系数大小接近于0，这说明原模型中无须引入trend，trend对回归结果的干扰较小。
		*--图形法
		
			**# 法二：画图
				frame dir  //frame dir命令用于显示当前正在使用的数据集的结构信息，例如数据集中的变量名、变量类型和变量标签等。
				frame rename default a
				frame copy   a b
				
				frame a {
					$regst , $regopt
					predict r, resid
					drop if mi(r) //这行代码将从数据集中删除任何包含缺失值的观测值。这是因为后续的代码需要对"r"变量进行统计汇总，而缺失值会影响计算结果。
					gcollapse (mean) r_mean = r (sd) r_sd = r, by(t)
					gen upper = r_mean + 1.65 * r_sd //90%置信区间
					gen lower = r_mean - 1.65 * r_sd
					gen race1 = 2
				}
				
				frame b {
					gen race1 = (race == 1)
					$regst if  race1, $regopt
					predict r, resid
					$regst if !race1, $regopt
					predict r1, resid
					replace r = r1 if !race1
					drop if mi(r)
					gcollapse (mean) r_mean = r (sd) r_sd = r, by(race1 t)
					gen upper = r_mean + 1.65 * r_sd
					gen lower = r_mean - 1.65 * r_sd
				}
				
				frame a {
					frame append b
					label define race 0 "Other" 1 "White" 2 "Total"
					label values race1 race
					
					#d  ;
						twoway  (con r_mean t, m(o))
								(rcap upper lower t, msiz(vsmall)),
									yline(0 , lc(red))
									by(race1, note("") rows(1))
									legend(label(1 "Mean of residuals")
										   label(2 "90% confidence interval"))
									xlabel(, labs(medsmall) format(%4.0f))
									ylabel(, labs(medsmall) format(%4.1f))
									xtitle("Trend") ytitle("Residuals")
									scheme(qleanmono)
									saving(time_trend, replace)
						;
					#d cr
					
					graph export "time_trend.emf", replace
				}
				//观察图 1可知，无论是总体、白人群体还是其他人种群体样本，回归残差的均值均在0值附近上下波动，90%的置信区间跨越了0值线，并且随着时间趋势的推移，残差均值并未表现出明显的增减趋势，这些都同样说明了原模型中无须引入trend，trend对回归结果的干扰较小。
		
	*-----so2例子------*
	**# 生成时间趋势项
		use "F:\Users\zhang\Desktop\DID专题\经典DID\两控区对so2.dta",clear
		gen so2 = log(工业二氧化硫排放量_全市_吨)
		gl regst "qui reghdfe so2 policy "
		gl regopt "absorb(i.year i.cid) clu(cid) resid"
			bys cid (year): gen t = _n
		*	gen t = year
		*	gen t = year - 67  // 另外两种 t 的生成方法
		*--回归法
		**# 法一：回归
			$regst t, $regopt
			dis "系数(Total) = " %6.4f _b[t] "；t值(Total) = " %6.4f _b[t] / _se[t]
		**# 法二：画图
				frame dir  //frame dir命令用于显示当前正在使用的数据集的结构信息，例如数据集中的变量名、变量类型和变量标签等。
				frame rename default a

				
				frame a {
					$regst , $regopt
					predict r, resid
					drop if mi(r) //这行代码将从数据集中删除任何包含缺失值的观测值。这是因为后续的代码需要对"r"变量进行统计汇总，而缺失值会影响计算结果。
					gcollapse (mean) r_mean = r (sd) r_sd = r, by(t)
					gen upper = r_mean + 1.96 * r_sd //95%置信区间
					gen lower = r_mean - 1.96 * r_sd
				}
					
				frame a {

					#d  ;
						twoway  (con r_mean t, m(o))
								(rcap upper lower t, msiz(vsmall)),
									yline(0 , lc(red))
									legend(label(1 "Mean of residuals")
										   label(2 "95% confidence interval"))
									xlabel(, labs(medsmall) format(%4.0f))
									ylabel(, labs(medsmall) format(%4.1f))
									xtitle("Trend") ytitle("Residuals")
									scheme(qleanmono)
									saving(time_trend, replace)
						;
					#d cr
					
					*graph export "time_trend.emf", replace
				}
				
	*-合成DID,sdid适用平衡面板和一刀切政策，多期DID无法制作平行趋势图,无缺失值
		*--SDID不仅通过个体权重（unit-specific weights）找到与处理组相近的控制组个体，还通过时间权重（time-specific weights）找到与政策后处理期（post-treatment）相似的政策前处理期（pre-treatment），并分别赋予他们更大的个体权重和时间权重。
		*在估计外部冲击或政策变化的影响时，研究者常用合成控制法（SCM）与双重差分法（DID）去评估该冲击或政策变化的影响。
		//在实证中，若处理组拥有大量个体且数据满足平行趋势假设时，通常使用DID方法；
		//若处理组仅含有一个个体（或非常少个体），无法满足平行趋势假定时，则可以使用SCM方法。正如我们前面已经说过的那样，DID与SCM两种方法实际上非常相关，都是在寻找一个最优的参照组或者说控制组，然后求出政策处理效应。
		//Arkhangelsky等（2021）干脆将这两种方法结合起来，充分利用他们各自的优点估计政策处理效应，从而形成了一种新的合成双重差分法（SDID）。考虑到政策实施的分布在地区与时间上并不是随机出现的，
		//SDID不仅通过个体权重（unit-specific weights）找到与处理组相近的控制组个体，还通过时间权重（time-specific weights）找到与政策后处理期（post-treatment）相似的政策前处理期（pre-treatment），并分别赋予他们更大的个体权重和时间权重。
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
		*-三重差分DDD
		*假设美国 B 州针对 65 岁或以上的老年人 (实验组，Treat = 1) 引入一项新的医疗保健政策，其他年龄群体不适用。
		//考察此政策对健康状况的影响，选用 B 州 65 岁以下群体 (old = 0) 作为对照组。
		//由于人的健康状况随时间的变化并不是线性的，而不同年年龄组的个体的健康状况变化的时间趋势也存在差异，这会导致传统 DID 方法的前提条件——共同趋势假设 (Common Trend) 无法得到满足。
		//简言之，实验组和对照组人群的健康状况随时间的变化趋势不一致。这种时间趋势差异的影响可以通过计算相邻的 A 州 65 岁及以上老年人和年轻群体相对健康情况变化差异来捕捉 (相当于再用一次 DID)。
	2007 年，中国开始实行 SO2 碳排放权交易试点政策，先后批复了江苏、天津、浙江、河北、山西等 11 个排放权交易试点省份，但是还有很多省份没有作为试点地区。
	任胜钢等 (2019) 收集了不同地区不同行业在实施试点政策前后多年全要素增长率的数据，并使用双重差分法 (DID) 估计排污权对上市企业全要素的影响：
	下面我们通过使用 任胜钢等 (2019) 在「中国工业经济」期刊主页上提供的数据 http://www.ciejournal.org/Magazine/show/?id=61750 对这一回归过程进行分析。
	*-Notes:
		* (1) tt 为试点前后和处理效应的交乘项，
		* (2) zcsy-lnzlb 为控制变量，
		* (3) SO2 ==1 表明样本均为排放 SO2 的上市企业
		use "F:\Users\zhang\Desktop\DID专题\三重差分\基准回归数据.dta" ,clear
		xtset company year
		gen lnzjz=ln(zjz+1)
		gen lnlabor=ln(labor+1)
		gen lnzjtr=ln(zjtr+1)
		gen lncapital=ln(capital1+1)
		levpet lnzjz, free(lnlabor) proxy(lnzjtr) capital(lncapital)
		predict tfp,omega
		gen lntfp=ln(tfp)
		gen tt=time*treat
		gen lnzc=ln(zc+1)
		gen lnzlb=ln(zlb+1)
		gen lnaj=ln(aj+1)
		gen ttt=tt*so2
		gen times=time*so2
		gen treats=treat*so2
		xtreg lntfp tt zcsy lf age owner sczy lnaj lnlabor lnzlb i.year   if so2==1,fe cluster(area)
		回归结果显示排污权交易制度对全要素生产率的回归系数为 0.2768 (在 1% 的水平上显著)，表明中国 SO2	排污权交易试点政策显著提高了上市企业的全要素生产率。
		然而，双重差分估计策略存在潜在的问题，因为除了  SO2排放权交易试点之外，还可能存在其他政策对试点地区和非试点地区产生不一致影响，从而使估计结果进行偏差。需要用三重差分来克服这一问题，即需要找到另外一对不受 SO2 排放权交易试点政策影响的"处理组"和"对照组"，因为非  SO2排放行业不受  SO2排污权交易政策影响，此时第二对处理组和对照组的差异只来源于其他政策的影响，将第一对处理组和对照组的差异(包含 SO2 排污权交易政策和其他政策的差异)减去第二对处理组和对照组的其他政策的差异，得到  SO2排污权交易政策的净效应。基于以上分析，构建三重差分模型 (DDD) ：
		*-Notes:
			*  ttt 为 time*treat*group 交乘项
			*  tt  为 time*treat 交乘项
			*  treats 为 treat*group 交乘项
			*  times  为 time*group  交乘项
			*  so2    代表 group 变量
		xtreg lntfp ttt tt treats times so2 zcsy lf owner age sczy lnaj ///
			lnlabor lnzlb i.year ,fe cluster(area)
	回归系数为 0.45 以上(在1%的水平上显著)，表明三重差分估计  排污权交易试点政策对企业全要素生产率的平均促进效应要高于双重差分估计结果，说明双重差分估计可能低估了政策对企业生产效率的提高。
	
*---------
*-门槛回归
*---------	
	*xthreg,结果修改：修改trim值、变量取对数，是否缩尾处理、控制变量是否进行统一单位转换、时间段的选取能否拉长或缩短、核心变量的选取是否有替代。
	xthreg 被解释变量 解释变量1 解释变量2..., rx(门槛变量影响到的核心变量) qx (门槛变量) thnum(设定的门槛个数，需要大于1小于等于3) grid(交叉点的个数一般设定为400或者300) trim(削减估计每一门槛的部分一般设定为0.01) bs(重复的次数 一般设定为300) thlevel(默认是95%) gen(newvarname) noreg nobslog thgiven options]：
	*二、门槛变量选择
	目前针对门槛变量的选择没有具体的理论支持，总的来讲选的有意义就行，但是这个有意义有时候反而是最难的，个人觉得门槛变量的选择需要从以下两个方面来考量。
	*-（一）门槛变量本身
	前面提到门槛变量可以看做将门槛回归模型分为了两部分，且两部分中X对Y会产生不同的影响。实际分析中，有一些经济模型不是简单的线性回归，而是呈现"倒U型"的，即随着X的变化，在某一个具体的数值左右两端X对Y的影响会存在不同的变化趋势。以库兹涅茨倒u型曲线为例，曲线表示收入不均的程度随着经济增长，在G点两端曲线呈现不同的趋势，那么G点对应的收入值就可以作为门槛值，收入就可以试做门槛变量。如果曲线有多个转折点，那就可以选择加入多个门槛值进行分析。
	*-（二）门槛变量与解释变量的关系
	前面提到库兹涅茨倒u型曲线可以将收入作为门槛变量进行分析，但同时收入是曲线的X轴，也就是自变量，那么就会产生一个疑问自变量能不能作为门槛变量呢？开头也讲了目前选择门槛变量没有具体的理论支持，有意义即可，主要的选择有两种：（1）核心变量做门槛变量，如库兹涅茨倒u型曲线中的收入既是自变量也是门槛变量；（2）会影响核心变量的变量做门槛变量，门槛变量通过作用在核心变量上来影响因变量。如库兹涅茨倒u型曲线中的收入可能受到当地经济发展情况的影响，那就可以选择GDP作为门槛变量。

	*【代码示例1】
	use thresholddata,clear
	xthreg pollution population urbanization_level industrialization_level, rx(pgdp) qx(fdi) thnum(1) bs(300) trim(0.01) grid(100)
	*【代码示例2】
	use hansen1999,clear
	xthreg i q1 q2 q3 d1 qd1, rx(c1) qx(d1)  thnum(1) grid(100) trim(0.01) bs(100)
	*_matplot e(LR), columns(1 2) yline(7.35, lpattern(dash)) connect(direct) msize(small) mlabp(0) mlabs(zero) ytitle("LR Statistics") xtitle("单一门槛") recast(scatter) graphregion(color(white)) ylabel(,nogrid)
		outreg2 using 门槛回归结果2.doc, replace tstat bdec(3) tdec(2) ctitle(单一门槛)
	xthreg i q1 q2 q3 d1 qd1, rx(c1) qx(d1)  thnum(2) grid(100) trim(0.01 0.05) bs(100 100)
		outreg2 using 门槛回归结果2.doc, append tstat bdec(3) tdec(2) ctitle(双重门槛)
	xthreg i q1 q2 q3 d1 qd1, rx(c1) qx(d1) thnum(3) grid(400) trim(0.01 0.01 0.05) bs(100 100 100) thgiven nobslog noreg
		outreg2 using 门槛回归结果.doc, append tstat bdec(3) tdec(2) ctitle(三重门槛)
	*绘制三重门槛图:
	_matplot e(LR21), columns(1 2) yline(7.3523, lpattern(dash)) connect(direct) recast(line) ytitle("LR Statistics") xtitle("First Threshold") name(LR21)
	_matplot e(LR22), columns(1 2) yline(7.3523, lpattern(dash)) connect(direct) recast(line) ytitle("LR Statistics") xtitle("2nd Threshold Parameter") name(LR22)
	_matplot e(LR3), columns(1 2) yline(7.3523, lpattern(dash)) connect(direct) recast(line) ytitle("LR Statistics") xtitle("3rd Threshold Parameter") name(LR3)
	graph combine LR21 LR22 LR3, cols(1) //1.门槛值点是LR图的最低点。2. 7.35临界线下是置信区间。3.若门槛估计值的LR值明显小于7.35临界线，那么所得的门槛估计是真实有效。

*---------
*-调节效应
*---------
	*-调节变量选择问题 （外生的，X Y不太能直接影响M）
		其实，很多TOP5刊并没有做过多的异质性分析，而就已知的异质性检验来看，选取的调节变量M主要是一些外生变量，例如个体特征变量或宏观变量。这里的外生调节变量M，是相对于自变量X和因变量Y而言的，即X和Y至少不太直接影响到M，M可以说是一个前定变量Predetermined variable。道理很简单，在方程Y=a+bX+cX*M+dM+control+error中，若X或Y会直接影响M，那M以及X*M本身就不是一个好的控制变量，必定会使感兴趣的变量的估计系数产生偏误。
	另外，调节变量M可以是之前方程Y=a+bX+control+error里的控制变量吗？根据TOP5刊里的文献，答案是可以的。作者在原方程中控制了性别、年龄、种族等人口特征，而后在异质性部分还是选取了性别、年龄和种族等人口特征作为调节变量，分析X对Y的影响可能在不同性别、年龄和种族群体中产生的异质性。更有文章，例如Daron Acemogul et al (2020, RES) 直接将因变量X与所有基准特征变量（也是文章中的控制变量）进行交叉相乘，以考察人口对国家内部冲突的异质性影响。
	举个例子，当你考察手机使用X对人们思想观念Y的影响时，收入和教育就不是好的调节变量M，因为很明显X可能会影响收入和教育，而户籍、性别、区域、省份或14岁时经历等前定变量是更好的调节变量M。
	
	*-交乘项偏误
		*介绍：https://mp.weixin.qq.com/s/RukuHMXTBQu_GYY4Fweo-g
				https://blog.csdn.net/arlionn/article/details/89944541
		*Hainmueller, J., Mummolo, J., & Xu, Y. (2019). How Much Should We Trust Estimates from Multiplicative Interaction Models? Simple Tools to Improve Empirical Practice. Political Analysis, 27(2), 163-192.
		*传统交乘项得到的估计结果很有可能存在偏误，这种偏误来源于对线性假设和共同支持假设的违背，很多研究都存在这一问题。对此，我们可以通过画散点图来诊断偏误程度。
		*--（一）线性假设
		首先，D（自变量）对于Y（因变量）的影响随X（调节变量）线性变化，即X增加一单位，D对Y的影响增加β单位；其次，在整个X的取值范围内，这种线性影响都是存在的。这两个假设太强了，很难给出足够的理论或经验证据。
		
		*--（二）共同支持假设
	对于任意一个给定的调节变量X的值，x0，必须再满足以下两个假设才能得到准确的估计：首先，在x0的邻域，必须有足够的数据点，这是估计的基础；其次，在x0的邻域，观测值需要同时接受不同的处理强度，比方说，尽量不要出现x0邻域内只有未接受处理样本的情况。这两个假设同样很强，如果存在一个样本量很少或者处理强度相同的X的邻域，那这部分的推断就依赖于已估计出的函数的插值（interpolation）或者外推（extrapolation）了，而这种插值或者外推本身还需要依赖很强的模型假定。
		以上就是关于传统交乘项准确估计依赖的假设，两个大假设套着一堆假设，很显然，这些假设不容易满足。
		*--偏误诊断
		
			*---D是虚拟变量
			（Stata代码：twoway (sc Y X) (lowess Y X), by(D)）
			sysuse nlswork.dta, clear
			graph  twoway (sc ln_wage tenure if msp == 1)(lfit ln_wage tenure if msp == 1) (lowess ln_wage tenure if msp == 1),title("msp==1") legend(off) xtitle("")
			graph save "1", replace
			twoway (sc ln_wage tenure if msp == 0)(lfit ln_wage tenure if msp == 0) (lowess ln_wage tenure if msp == 0),title("msp==0")
			graph save "2", replace
			graph combine "1" "2",cols(1)
		//我们根据D分为两组，在不同的组别内画Y与X的散点图，并加上①Y与X的线性拟合线②Y与X的LOESS（locally weighted regression；看起来复杂，其实就是一种拟合非线性数据的一种方法）拟合线。左侧图中两种线给了两个证据：首先，由于LOESS与OLS拟合线重合程度很高，因此有一定理由相信线性假设满足；其次，两幅图斜率完全不同，说明调节效应可能确实存在。
			*---（二）D为连续变量
//相较于D为虚拟变量，连续变量情形稍微复杂一点。作者建议，可以手动将X分组，比如按照分位数分为高中低三等份，在每等份中再画D与Y的散点图、拟合线。
				//（Stata代码：egen Xbin = cut(X), group(3)
				//	twoway (sc Y D) (lowess Y D), by(Xbin) ）
					
					sysuse nlswork.dta, clear
					egen Xbin = cut(age), group(3)
					twoway (sc ln_wage tenure) (lfit ln_wage tenure )(lowess ln_wage tenure ), by(Xbin)
		*-解决方法
			*--分箱估计量
				*按照连续变量的分组方法进行估计，得到低中高(每个区间观察值相同)（L,M,H）三个边际效应估计系数和相应的置信区间。
					如果
					（1）线性回归线与 L,M,H 不存在显著差异（可根据 Wald 检验判断）
					（2）L,M,H 在整个数据区间内分布比较均匀，不是集中在某个区域
					说明满足 LIE 假设和共同支持条件，线性模型提供的是一致和有效估计量。

					如果箱型估计量 L,M,H 偏离原模型的拟合线，分布在其两侧，说明条件边际作用非线性，拒绝 LIE 假设。
			//（Stata操作：提前安装命令，ssc install interflex, replace all 即可
			//当使用 interflex 检查LIE和共同支持假设时，其命令结构是在后面顺次加上被解释变量Y，处理变量 D，调节变量 X，以及控制变量。
			//	分箱估计量：interflex Y D X Z1, vce(r)
			//	若想单独估计传统交乘项估计量：interflex Y D X Z1, vce(r) type(linear)）
				ssc install interflex, replace all
				interflex ln_wage msp tenure  , vce(r) n(3)  //n表示区间个数
				//当线性交互模型不正确时，箱型估计量与模型的拟合结果（黑色直线及阴影区域）相去甚远。
				//注意图底部的堆积柱状图，它显示了调节变量 X 的分布。柱体的总高度是调节变量 X 在整个样本中的分布，红色和灰色阴影条分别是 X 	在处理组和控制组中的分布。若某一个柱体中只有红色或灰色，则该区域缺乏共同支持。
				//与此同时，Stata 报告了 Wald 检验的 p 值。其原假设为：交互作用是线性的。拒绝原假设说明存在非线性影响，但接受原假设不一定满足LIE 假设，尤其是在小样本的情况下。

			*--（二）核估计量（Kernel estimator）
				*箱型估计量只有三个点，核估计量则呈现了数据区间内的完整曲线。如下图所示，其判断依据为：
					如果核估计量结果接近一条直线，则满足 LIE 假设；如果弯曲程度很大，那么 LIE 假设不满足，线性模型结果不一致。
					置信区间越宽的区域，越缺乏共同支持。
				//在选项中设定 type(kernel) 会自动通过交叉验证选择最佳带宽，但程序运行比较费时。在第一次运行结束后复制好带宽的值，放入 bw() 选项中可以提高效率。
			//（Stata代码：interflex Y D X Z1, type(kernel) bw(0.345) 其中bw为核估计的带宽）
				interflex ln_wage msp tenure  , type(kernel) bw( 2.5917) xlab("tenure") ylab(ln_wage) dlab(msp) 
	*-用-bytwoway-实现快速分组绘图
一般我们在检验交互（调节）作用的时候，一般选择纳入交乘项或者分组进行系数差异性检定判断，然而还有第三种更加直观的方法就是通过分组绘图的方法，有的时候你可以在还没有进行实证前通过分组绘图的方法就可以直接征服论文评审，说明这确实是存在调节作用的。
		net install bytwoway, ///
		from(https://github.com/matthieugomez/stata-bytwoway/raw/master)
		
		*--twoway命令
		sysuse auto.dta, clear
		twoway (line price weight if foreign==1, sort ) ///
       (line price weight if foreign==0, sort) , legend(order(1 "外国" 2 "本国" ) row(2))
	   . 特别提示： 当分组变量大于 1 个或者分组类别为 2 时，官方命令 twoway 不再适用，而只能用 bytwoway。
	   *--bytwoway命令
	   sysuse auto.dta, clear
		collapse (mean) price, by(weight foreign)
		bytwoway (line price weight), by(foreign) aes(color lpattern)
		
		sysuse nlsw88.dta, clear
		collapse (mean) wage, by(grade race)
		bytwoway (line wage grade),   ///
		by(race) aes(color lpattern)
		*--根据分组变量 race 绘图，改变了分组线条的类型
		bytwoway (scatter wage grade, connect(l)), ///
         by(race) aes(color msymbol)

*------------------内生性问题分析-------------------*
样本选择性偏差和自选择偏差都属于选择偏差（Selection Bias），只是侧重的角度不同，一个侧重的是样本的选择不随机，一个侧重的是变量的选择不随机，但都表明一个观点：非随机化实验将导致内生性。  （介绍：https://zhuanlan.zhihu.com/p/392443329）

非随机选择机制的不同是两者最大的区别，体现在具体回归方程中就是，样本选择偏差中被解释变量y是否被观测到或是否取值（而非取值大小）是非随机的；而自选择偏差中哑元解释变量D的取值是非随机的

Heckman两步法主要是解决样本选择问题，因为调查设计原因，有些样本无法观测到，我们分析的样本是有选择性的（比如说，分析培训对就业的影响时候，有些人没有参加培训进而未被调查到，导致样本中没有这个群体的信息，从而使得估计结果无法反映参与培训与未参与培训的个体之间真实差异），进而导致估计结果有偏。其因变量中有一些缺失值。
PSM方法主要解决自选择问题，也即观测到的个体选择性进入实验组或者对照组（比如说，分析培训对就业的影响，有些竞争力强、教育程度高的个体不需要参与培训可以直接就业，而那些竞争力弱的人主动选择参与培训，估计结果发现不参与培训的人就业率更高，而出现这个结果，实际上是因为存在自选择问题），进而导致估计结果有偏。其因变量中基本没有缺失值。另外，PSM方法假设处理变量受可观测因素的影响。	
		 
*--------
*-PSM-DID
*--------
	*文章来源1：https://zhuanlan.zhihu.com/p/392443329
	*文章来源2：https://zhuanlan.zhihu.com/p/392447531
	*-优点
	现实中的政策本质上是一种非随机化实验（或称，准自然实验），因此政策效应评估所使用的DID方法难免存在自选择偏差，而使用PSM方法可以为每一个处理组样本匹配到特定的控制组样本，使得准自然实验近似随机，注意是近似，因为影响决策的不可观测因素在两组间仍然存在差异。
	*-缺点
	从本质上来说，PSM适用于截面数据，而DID仅仅适用于时间 - 截面的面板数据。
	. 对于PSM，每一个处理组样本匹配到的都是同一个时点的控制组样本，相应得到的ATT仅仅是同一个时点上的ATT。下文psmatch2的输出结果中，ATT那一行结果就仅仅代表同一个时点上的参与者平均处理效应。
	.对于DID，由于同时从时间与截面两个维度进行差分，所以DID本身适用的条件就是面板数据。因此，由PSM匹配到的样本原本并不能直接用到DID中做回归。
	*-解决方法
	面对两者适用数据类型的不同，现阶段的文献大致有两种解决思路。
	第一，将面板数据视为截面数据再匹配。如下文参考文献中的绝大多数。
		([4] 石大千, 丁海, 卫平, 刘建江. 智慧城市建设能否降低环境污染[J]. 中国工业经济, 2018(06): 117-135.
		[5] 王雄元, 卜落凡. 国际出口贸易与企业创新——基于"中欧班列"开通的准自然实验研究[J]. 中国工业经济, 2019(10): 80-98.
		[6] 丁宁, 任亦侬, 左颖. 绿色信贷政策得不偿失还是得偿所愿?——基于资源配置视角的PSM-DID成本效率分析[J]. 金融研究, 2020(04): 112-130.
		[7] 郭晔, 房芳. 新型货币政策担保品框架的绿色效应[J]. 金融研究, 2021(01): 91-110.
		[8] 孙琳琳, 杨浩, 郑海涛. 土地确权对中国农户资本投资的影响——基于异质性农户模型的微观分析[J]. 经济研究, 2020, 55(11): 156-173.
		[9] 陆菁, 鄢云, 王韬璇. 绿色信贷政策的微观效应研究——基于技术创新与资源再配置的视角[J]. 中国工业经济, 2021(01): 174-192.
		[10] 余东升, 李小平, 李慧. "一带一路"倡议能否降低城市环境污染?——来自准自然实验的证据[J]. 统计研究, 2021, 38(06): 44-56.)
	第二，逐期匹配。如，Heyman et al.（2007）[11]、Bockerman & Ilmakunnas（2009）[12]等。
	[11] Heyman F, Sjoholm F, Tingvall P G. Is There Really a Foreign Ownership Wage Premium? Evidence from Matched Employer-Employee Data[J]. Journal of International Economics, 2007, 73(02): 355-376.
[12] Bockerman P, Ilmakunnas P. Unemployment and Self-Assessed Health: Evidence from Panel Data[J]. Health Economics, 2009, 18(02): 161-179.

	然而，谢申祥等（2021）[13]指出了这两种方法的不足。
		*[13] 谢申祥, 范鹏飞, 宛圆渊. 传统PSM-DID模型的改进与应用[J]. 统计研究, 2021, 38(02): 146-160.
	第一，将面板数据转化为截面数据进行处理存在"自匹配"问题。
	第二，逐期匹配将导致匹配对象在政策前后不一致。

*--------------
*-Heckman两步法
*--------------
	*文章来源1：https://zhuanlan.zhihu.com/p/397399681
	*文章来源2：https://zhuanlan.zhihu.com/p/397400061
	*文章来源3：https://zhuanlan.zhihu.com/p/397400188
	*文章来源4：https://zhuanlan.zhihu.com/p/397401072
