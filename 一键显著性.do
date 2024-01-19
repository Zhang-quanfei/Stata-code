	*	一键显著性
		ssc install oneclick, replace  //安装命令
		*- 基本语法
		oneclick y controls, method(regression) pvalue(p-value) fixvar(x and other FE) [
				options zvalue ]
			*y 位置用来放置你的被解释变量
			*controls 位置用来放置你的待选控制变量集合，可以是 i.var 形式，也可以是 l.var 或者 f.var 等
			*m() 位置用来放置你的回归方法，可以是 reg、logit、probit等
			*p()，在括号中输入你希望的显著性水平，一般是 0.1、0.05，以及0.01。	
				*fix()，在括号中输入你的主要解释变量以及需要每个回归中都出现的变量。比如在一些实证论文中，我们希望能够保留 size、roa 等其他常见变量，则可以写在解释变量后。注意： 第一个位置一定要放解释变量。
			*o()，用来放置其他原属于回归方法的其他选项，比如 xtreg y x, re 中的 re 选项、reghdfe y x, absorb(A B) 中的 absorb(A B) 选项
			*z，根据第一步中的判定方法考虑是否需要添加以 z-value 判别显著性的方法（logit、probit后面加z）
		*在 oneclick 运算后，屏幕上会呈现一个简单的运行过程与最后的结论摘要，并且会在当前工作路径下生成一份名为 subset.dta 的文件。
		*查看当前工作路径下的 subset.dta 文件。当前工作路径指的是你当前 Stata 窗口左下角所显示的路径。该文件中有两个变量，一个变量叫 subset 用来展示满足显著性要求的控制变量组合，一个变量叫 positive 用来展示显著的方向，1表示正向显著，0表示负向显著。
		use F:\Users\zhang\Desktop\DID专题\高铁对so2,clear
		reghdfe so2 dum_ta ,absorb(year cid) clu(cid)
		oneclick so2 人口密度_全市_人每平方公里 地区生产总值_当年价格_全市_万元 人均地区生产总值_全市_元 外商实际投资额_全市_万美元 地方一般公共预算收入_全市_万元 地方一般公共预算支出_全市_万元 科学技术支出_全市_万元, method(reghdfe) pvalue(0.01) fixvar(dum_ta) o(absorb(year cid) clu(cid))
		
		reghdfe so2 dum_ta 人口密度_全市_人每平方公里  外商实际投资额_全市_万美元 ,absorb(year cid) clu(cid)