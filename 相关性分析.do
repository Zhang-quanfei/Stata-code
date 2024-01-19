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
		forvalues colrange = -1(0.2)0.8 { //以0.2为区间单位定义不同区间颜色
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