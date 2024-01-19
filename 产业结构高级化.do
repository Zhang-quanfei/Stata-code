*	借鉴《仇什.统一市场建设、产业转型升级与城市高质量发展——基于京津冀协同发展视角的实证研究[J].云南财经大学学报,2022,38(12):16-32.》计算了产业高级化指标
			*---------------
			*-产业结构合理化
			*---------------
				*	RIS
					use "F:\Users\zhang\Desktop\新旧动能转换\新旧动能转换_财政金融协同.dta",clear
					gen RIS = ((第一产业增加值/GRP) * ((((第一产业增加值/GRP)/(第一产业从业人员数/就业人数))-1)^2)^0.5)^(-1)

			*---------------
			*-产业结构高级化
			*---------------
				*	2011年为基期
					use "F:\Users\zhang\Desktop\新旧动能转换\新旧动能转换_财政金融协同.dta",clear
				*	非标准化劳动生产率
					gen lp1 = 第一产业增加值 / 就业人数
					gen lp2 = 第二产业增加值 / 就业人数
					gen lp3 = 第三产业增加值 / 就业人数
					
				*	2011年产业最小值
					egen x1 = min(lp1) if year == 2012 
					egen min1 = min(x1)
					
					egen x2 = min(lp2) if year == 2012 
					egen min2 = min(x2)
					
					egen x3 = min(lp3) if year == 2012 
					egen min3 = min(x3)
					drop x1 x2 x3
				*	2011年产业最大值
					egen x1 = max(lp1) if year == 2012 
					egen max1 = min(x1)
					
					egen x2 = max(lp2) if year == 2012 
					egen max2 = min(x2)
					
					egen x3 = max(lp3) if year == 2012 
					egen max3 = min(x3)
					
				*	产业标准化劳动生产率
					gen LP1 = (lp1 - min1) / (max1 - min1)
					gen LP2 = (lp2 - min2) / (max2 - min2)
					gen LP3 = (lp3 - min3) / (max3 - min3)
					
				*	产业结构高级化（OIS）
					gen OIS = (第一产业增加值 / GRP)*LP1 + (第二产业增加值 / GRP)*LP2 + (第三产业增加值 / GRP)*LP3
