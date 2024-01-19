



          *     =====================================
          *              计量分析与STATA应用 
          *     =====================================
                    
          *        主讲人：连玉君 博士

          *        单  位：中山大学岭南学院金融系
          *        电  邮: arlionn@163.com
          *        主  页: http://blog.cnfol.com/arlion 

          *             ::第一部分::
          *              Stata 操作
          *         =====================
          *            第二讲  数据处理
          *         =====================

  * cd D:\stata10\ado\personal\Net_course_A\A2_data
  
    cd `c(sysdir_personal)'Net_course_A\A2_data
  

*----------------
*    本讲目录
*----------------

*  2.1  变量转换的更多技巧 
*  2.2  分位数 
*  2.3  重复样本值的处理 
*  2.4  缺漏值的处理  
*  2.5  离群值的处理 
*  2.6  资料的合并和追加 
*  2.7  重新组合样本
*  2.8  文字变量的处理
*  2.9  类别变量的分析	
*  2.10 时间序列资料的处理 
*  2.11 面板资料的处理
*  2.12 数据的查验和比较	




          *     =====================================
          *              计量分析与STATA应用 
          *     =====================================
                    
          *        主讲人：连玉君 博士

          *        单  位：中山大学岭南学院金融系
          *        电  邮: arlionn@163.com
          *        主  页: http://blog.cnfol.com/arlion 

          *             ::第一部分::
          *              Stata 操作
          *         =====================
          *            第二讲  数据处理
          *         =====================
          *        2.1 创建变量的更多技巧 
		  
		  
*------------------------
*-2.1 创建变量的更多技巧 
*------------------------

  *     ==本节目录==
		  
  *     2.1.1 _n 和 _N
  *         2.1.1.1  _n 与 _N
  *         2.1.1.2  _n 与 _N 的应用
  *     2.1.2 虚拟变量的产生  
  *         2.1.2.1 基本方式
  *         2.1.2.2 基于类别变量生成虚拟变量: -tab-命令 
  *         2.1.2.3 基于类别变量生成虚拟变量: -xi-命令	 
  *         2.1.2.4 因子变量 (stata11 的一大亮点)
  *         2.1.2.5 将连续变量转换为类别变量
  *         2.1.2.6 利用条件函数产生虚拟变量
  *     2.1.3  交乘项的产生  
  *     2.1.4  -egen- 命令  
  *         2.1.4.1 egen 与 gen 的区别
  *         2.1.4.2  产生等差数列: seq() 函数
  *         2.1.4.3  填充数据：fill() 函数
  *         2.1.4.4  产生组内均值和中位数
  *         2.1.4.5  跨变量的比较和统计
  *         2.1.4.6  变量的标准化
  *         2.1.4.7  变量的平滑化（Moving Average）
  *         2.1.4.8  更多的 egen() 函数 
  
		  
		  
*                  =本节命令=  
* =====================================================
*    _n, _N, tsset, egen, display, list, tabulate
*    xi, fvset fvvarlist, recode, recode(), irecode()
*    cond(), inlist(), inrenge(), egenmore, 
* =====================================================


*___________________
*-2.1.1  _n 和 _N

  *-2.1.1.1  _n 和 _N 的含义
     
    *-定义： 
      * _n "样本序号变量"，是一个变量，内容为 1,2,3,...,n
      * _N "样本数指标",   是一个单值，内容为 样本数

    *-说明：
      * _n 是一个永远存在，但却不能 list 出来的特殊变量
      * _n 的取值会随样本排序的变化而变化
      
      sysuse nlsw88.dta, clear
      list age wage in 1/10      // 最左边的1,2,...就是 _n 中的内容
      list _n                    // 错误

      sort hours
      gen nid_1 = _n             // 第一个 _n 的内容 
      list nid_1 hours race in  1/10 
      sort wage
      gen nid_2 = _n             // 第二个 _n 的内容         
      list nid_1 nid_2 hours race in 1/10

      dis _N                     // _N 是一个单值
      scalar obs = _N
      quietly  sum wage
      dis r(mean)*_N
      dis r(mean)*obs

	  
  *-2.1.1.2  _n 和 _N 的应用
  
      sysuse sp500.dta, clear
      sort open
      sum open
      dis r(max)
      gen o_max   = open[_N]             // 最大值
      gen o_diff  = open[_n] - open[_N]  // 与最大值的差，open[_n]表示当前数
      gen b_diff = open[_N] - open[1]    // range，open[1]表示open变量的第一个数
      list open o_max o_diff b_diff in 1/20
      
      *-差分
        sort date
        gen d_open = open[_n] - open[_n-1]
        
      *-对数差分
        gen dln_open = ln(open[_n]) - ln(open[_n-1])
        
      *-移动平均
        gen mv3_open = (open[_n-1] + open[_n] + open[_n+1]) / 3
        list open o_max o_diff dln_open mv3_open in 1/10

      *-滞后项、前推项、差分
        tsset date  /*声明数据为时间序列*/
        gen open_lag  = L.open
        gen open_lag2 = L2.open
        gen open_forward  = F.open
        gen open_diff  = D.open
        gen open_diff2 = D2.open
        list open* in 1/10
        reg close L(1/3).(close open)
        
      *-增长率
        qui tsset date
        gen r1 = D.close/L.close
        gen lnclose = ln(close)
        gen r2 = D.lnclose        // 第二种计算方法
        list date r1 r2 in 1/10
        
      *-分组进行
        sysuse nlsw88.dta, clear
        bysort industry: gen gid = _n
        list gid industry in 1/50, sepby(industry)
  

  
*_______________________
*-2.1.2  虚拟变量的产生

  *-2.1.2.1 基本方式
    
    *-使用-generate-和-replace-产生虚拟变量
      sysuse nlsw88.dta, clear
	  
      gen dum_race2=0
        replace dum_race2=1 if race==2
      gen dum_race3 = 0
        replace dum_race3=1 if race==3
		
      list race dum_race* in 1/100, sepby(race)


  *-2.1.2.2 基于类别变量生成虚拟变量: -tab-命令
  
      sysuse nlsw88.dta, clear
      tab race, gen(dum_r)
      list race dum_r1-dum_r3 in 1/100, sepby(race)
	  

  *-2.1.2.3 基于类别变量生成虚拟变量: -xi-命令	  
	
      xi i.race   //自动定义虚拟变量的名称，并附加标签
	  
      list race _Irace_2 _Irace_3 in 1/100, sepby(race)
    
      *-特别注意：再次使用-xi-命令时，此前生成的虚拟变量会被覆盖
        xi i.occupation   //*_Irace_2和_Irace_3变量不复存在
        
      *-解决方法-1-：使用 prefix(str) 选项,
        sysuse nlsw88, clear
        xi i.race, prefix(dr_) // 前缀不能超过四个字符  ，prefix前缀，postfix后缀
        xi i.occu, prefix(do_) // 不同的类别变量采用不同的前缀
		     
      *-解决方法-2-：事先修改变量名称： -renvars- (SJ 5-4)
        help renvars
        sysuse nlsw88.dta, clear
        xi i.race
        renvars _Irace* \ dum_race_2 dum_race_3 // 外部命令，批量修改变量名
        xi i.occupation 
        renvars _Ioccu*, prefix(dum)            // 批量修改变量名称的前缀
		  
        *-优点: 所有虚拟变量的前缀都可以是 "dum_"
        
      *-noomit- 选项
        sysuse nlsw88, clear
        tab race           
        xi i.race   // 只生成了两个虚拟变量,如何生成三个虚拟变量？
        des _I*
		  
        xi i.race, prefix(dum_) noomit
        des dum*     

		  
   *-2.1.2.4 因子变量 (stata11 的一大亮点)
   
     help fvvarlist    // 基本语法规则
	 help fvset        // 对照组的设定
	 
	 *-简介
	   sysuse nlsw88, clear
	   
	   list race i.race in 500/525, sep(0)
	   list race#married in 1/50 , sep(0)  // 4 组
	   list race#married in 1/100, sep(0)  // 6 组, why?
	 
	   list i.union i.married union#married in 1/50, sep(0)
	   list union##married in 1/50, sep(0) // 与上面的命令等价
	 
	 *-应用
	   reg wage  i.race
	   reg wage  i.race i.married race#married
	   reg wage  race##married   // 与上面的命令等价
	   
	   
	 *-对照组的选择
	   view help fvvarlist##bases 
	   
	   *-选择 race=other 作为对照组
	     label list racelbl   // race=1(Min) 是stata默认的对照组
		 reg wage ib3.race
		 
	   *-选择 race=other, married=1 作为对照组	
	     label list marlbl 
		 reg wage  ib3.race ib1.married 
		 reg wage  ib3.race##ib1.married  // 加入交乘项
		 
	   *-永久设定对照组
	     help fvset
		 fvset base 3 race  // 在后续使用 i.race 过程中，race=3都是对照组
		 reg wage i.race
	    
		
     *-连续变量的设定
	   help fvvarlist 
	   reg wage  i.married hours i.married#c.hours
	   reg wage  i.married##c.hours      // 等价于上述命令
	   
	   reg wage  i.married##c.hours  /// // 婚否
	             i.union##c.hours    /// // 是否工会成员 
				 i.collgrad##c.hours     // 是否大学毕业
		 
	   reg wage  hours c.hours#c.hours	 // 增加平方项 
	   reg wage  c.hours##c.hours	     // 等价于上述命令
	   
	   reg wage  c.hours##c.hours##c.hours	// 增加三次方

	   
            
  *-2.1.2.5 将连续变量转换为类别变量

    *- 等分样本              -group()-
       sysuse nlsw88.dta, clear
       sort wage                  // 这一步很重要
       gen  g_wage = group(5)     // 等分为五组
       tab g_wage
       tabstat wage, stat(N mean med min max) by(g_wage) f(%4.2f)

    *- 指定分界点的转换方式  -recode-
       sum age
       recode age (min/39 = 1) (39/42 = 2) (42/max = 3), gen(g_age) 
	   
		recode v (1/5=0) (nonmissing=1),generate(v1) //将未被前面规则改变的非缺失值改为1
		recode v (1/5=0) (missing=2),generate(v2) //将未被前面规则改变的缺失值改为2
		recode v (1/5=0) (else=1),generate(v3) //将未被前面规则改变的所有值改为1
		recode v (1/5=0) (*=1),generate(v4) //*和else作用完全一样
		recode v (1/5=0) (nonmissing=1) (missing=2),generate(v5)
		
       * 1  if  age<=39         右封闭区间
       * 2  if  39<age<=42
       * 3  if  age>42
       list  age g_age  in 1/50, sepby(g_age)

       *-Q：如果希望将 39 岁女员工归入第 2 类，该如何下达命令？
            recode age (39/42 = 2) (min/39 = 1) (42/max = 3), gen(g1_age) 
		
    *- 利用irecode() 和 recode() 函数进行转换
    
       * -irecode()- 函数
          gen g2_age = irecode(age, 39, 42)
          ttest g_age = g2_age
          
       * -recode()- 函数
          gen g3_age = recode(age, 39, 42)
          list age g_age g2_age g3_age in 1/10, sepby(g_age)
           

  *-2.1.2.6 利用条件函数产生虚拟变量
  
    *- cond() 函数
      
      * 基本语法：cond(s,a,b)  |   cond(s,a,b,c)
      * 取值：
        * a    if 表达式 s 为真；
        * b    if 表达式 s 为假；
        * c    if 表达式 s 为缺漏值
      * 示例：
	    sysuse nlsw88, clear
        gen dum1 = cond(hours>40, 1, 0, .)
          list hours dum1 in 1/20
		gen dum2 = cond(hours>40&hours!=., 1, 0, .)
          list hours dum1 dum2 in 1/20  // 注意此处的区别
		  
        gen dum_ratio = cond(wage/hours>0.5, 1, 0)
          list wage hours dum_ratio in 1/20
     
	 
    *- inlist() 函数
      
      * 基本语法：inlist(x, a,b,c,...) 
      * 取值：
        * 1    if x = a,b,c,...中的任何一个
        * 0    otherwise
      * 规则：
        * 若x为实数，则后续取值必须介于2-255
        * 若x为字符，则后续填项的个数必须介于2-10
      *
      * 示例 1：
        label list occlbl
        gen dum_occu = inlist(occu, 1,2,7,12)  
        list occu dum_occu in 1/20
        * 等价于
          gen dum_occu1 = (occ==1|occ==2|occ==7|occ==12)
      *   
      * 示例 2：
        use gdp_China.dta, clear
        sort Y
        list in 1/10     // 如何产生地区虚拟变量？
        *egen pvname = msub(prov), f(" ") //去掉省名中的空格
        gen east = inlist(prov,"北京","福建","广东","江苏", ///
                         "辽宁","山东","上海","天津","浙江") 
        sort east prov
        browse if year ==2003
     
	 
   *- inrange() 函数
   
     * 基本语法： inrange(x, a,b)
     * 取值：
       * 1    if  a<= x <= b；
       * 0    otherwise
	   
     * 示例：
	   sysuse nlsw88, clear
       gen dum_h2  = inrange(hours, 30,40)
	   
       * 等价于
         gen dum_h3 = (hours>=30 & hours<=40) 
         list hours dum_h2 dum_h3 in 1/20
     
	 
   *- clip() 函数 
 
     * 基本语法： clip(x, a,b)
     * 取值：
       * a    if x<=a;   // 截尾
       * x    if a<x<b;  // 原始值
       * b    if x>=b    // 截尾
	   
         gen g_h4 = clip(hours, 30, 40)
         list hours g_h4 in 1/100
		 
       *-以此为基础，可进一步产生虚拟变量


	   
	   
	   
	   

	   
	   


          *     =====================================
          *              计量分析与STATA应用 
          *     =====================================
                    
          *        主讲人：连玉君 博士

          *        单  位：中山大学岭南学院金融系
          *        电  邮: arlionn@163.com
          *        主  页: http://blog.cnfol.com/arlion 

          *             ::第一部分::
          *              Stata 操作
          *       ===========================
          *            第二讲  数据处理
          *       ===========================
          *        2.1 创建变量的更多技巧(续) 

		  
*______________________
*-2.1.3  交乘项的产生   

  *-stata11用户：参见"-2.1.2.4- 因子变量" 小节

  *-基本方法   -generate- 命令
  
    sysuse nlsw88, clear
	
    gen ttlexp_x_marry = ttl_exp*married
	
    reg wage married ttl_exp ttlexp_x_marry
   
   
  *-批量产生虚拟变量   -xi- 命令 
  
    *-如何得到"种族" 与"是否已婚"的交乘项
    * 两个类别变量交乘 i.v1*i.v2
      xi:reg wage married ttl_exp  i.race*i.married
       
    *-如何得到"种族" 与 "工作经验"的交乘项 ? 
    * 一个类别和一个连续变量交乘 i.v1*v2
      xi:reg wage married  i.race*ttl_exp // ttl_exp会被自动加入
   

 
*______________________
*-2.1.4  -egen- 命令

  * extended generate 的缩写
    help egen

  *-2.1.4.1 egen 与 gen 的区别
  
    *-基本差异
	  sysuse sp500, clear
      gen  sum_close0 = sum(close)  // 累加
      egen sum_close1 = sum(close)  // 总体加总
      list close sum_close0 sum_close1 in 1/10
	  
    *-对于缺漏值的处理也有差异
      clear
      input v1  v2
            1   5
            2   .
            .   3
            2   4
            4   . 
            .   6
      end
      gen mean       = (v1+v2)/2
      egen mean_egen = rmean(v1 v2)
      list


  *-2.1.4.2  产生等差数列: seq() 函数
    clear
	set obs 100
    egen x1 = seq(), from(-1)
      list x1 in 1/10
    egen year = seq(), from(2000) to(2004)
      list year in 1/20
    egen code = seq(), from(1) block(5)  //五个一组，从小到大生成
      list code in 1/20
      list code year in 1/20


  *-2.1.4.3  填充数据：fill() 函数
  
    egen r2 = fill(2 4)      // 间隔 2  的递增数列
    egen r3 = fill(6 3)      // 间隔 -3 的递减数列
    egen r4 = fill(1990 1991 1992 1990 1991 1992) // 分块重复数列
     list r2-r4 in 1/20


  *-2.1.4.4  产生组内均值和中位数
    
    sysuse nlsw88.dta, clear
    egen avg_w_r = mean(wage), by(race)
    egen med_w   = median(wage), by(race)
    list wage race avg_w_r med_w in 1/20 
    
    use xtcs.dta, clear              // 中国上市公司资本结构数据
    egen msize = mean(size),by(code) // 这样可以保证每家公司的组别一致
    sort msize
    gen gsize  = group(3)                   // 根据公司规模分组
    bysort gsize year: egen mtl = mean(tl)  // 注意 -bysort- 的使用方法
    sort gsize year
    list code year gsize tl mtl in 1/40, sep(0)
    list code year gsize tl mtl in 2500/2540, sep(0)
	
	*-应用举例
	  xtreg tl size fr ndts tobin tang, fe
	    est store full
	  xtreg tl size fr ndts tobin tang if gsize==1, fe
	    est store small
	  xtreg tl size fr ndts tobin tang if gsize==2, fe
	    est store mid
	  xtreg tl size fr ndts tobin tang if gsize==3, fe
	    est store large
	  local m "full small mid large"
	  esttab `m', mtitle(`m') s(N r2) b(%6.3f) ///
	            nogap compress
    
    *-说明：利用 egen 提供的函数，尚可计算组内s.d., Max, Min 等指标
   
 
  *-2.1.4.5  跨变量的比较和统计
    
    sysuse sp500.dta, clear
	
    egen avg_price = rmean(open close)
      list open avg_price close in 1/10
      
	  replace open = int(open)
      replace close= int(close)
	egen diff = diff(open close)
      sort diff
      list open diff close in 1/10
     

  *-2.1.4.6  变量的标准化
  
    *-定义：x_s = (x - x_m) / x_sd
      *-x_s 的均值将为 0； 标准差将为 1
      *-线性转换，并不改变变量间的相对大小
	  
	sysuse sp500.dta, clear  
    egen s_change1 = std(change)
    egen s_change2 = std(change), mean(20) std(3)
    sum change s_change*

    do A2_egen_std.do


  *-2.1.4.7  变量的平滑化（Moving Average）     
      
    sysuse sp500, clear
    tsset date
      egen mv3_open        = ma(open)   //要求是奇数
      egen mv5_open        = ma(open), t(5)  
      egen mv5_open_nomiss = ma(open), t(5) nomiss  //第一个缺失值按照前三个值的平均、第二个缺失值按照前四个值的平均
    list *open* in 1/10
    dis (1320.28+1283.27+1347.56)/3  // 第一个观察值
    dis (1320.28+1283.27+1347.56+1333.34)/4  // 第二个观察值
    
   
   *-2.1.4.8  更多的 egen() 函数 
   
     help egenmore     // 外部命令 
	 
	 *-ntos() 函数
	   sysuse auto, clear
	   tab rep78
	   egen grade = ntos(rep78), from(1/5) to("优秀" 好 较好 较差 差)
	   browse rep78 grade
       *-ston() 函数的用法与此相似
	 
	 
	 *-nvals() 函数
	 
	   *-数据描述
	     use bank_number.dta, clear   // 银企关系数目
	     browse
	     tab objbank, sort  // 任务：统计出各个年度每家公司的银企关系数目
	     drop if strmatch(objbank, "*公司*")
	     drop if strmatch(objbank, "银行")
	     tab objbank, sort
		 
	   *-统计方法
	     egen banknum = nvals(objbank), by(id year)   //统计组内非重复值个数
		 
	   *-结果
	     list, sepby(id year)
	   
	   
	   *-另一种解决方法(stata内部命令)
	     use bank_number.dta, clear 
	     egen tag = tag(id year objb) //第一个非重复值标记为1
		   list, sepby(id year)
		 bysort id year: egen banknum = total(tag)  ///
		               if strmatch(objbank,"*银行*") 		   
           list, sepby(id year)
		 drop if banknum == .
		   list, sepby(id year)

		 
     *-incss() 函数
	   use bank_number.dta, clear //删除非银行金融结构
	   egen isbank = incss(objbank), substr("银行")   //查找所有有“银行”的值，找到后赋值为1，否则为0
	   list, sep(0)
	   drop if isbank==0  
	 
	 
	 *-gmean() 函数  [geometric mean] 几何平均数
	 
	   *-定义: G = [x1*x2*...*xn]^{1/n}
	   
	   sysuse auto, clear
	   egen g_mpg = gmean(mpg), by(rep78) // 几何平均数
	   egen m_mpg = mean(mpg), by(rep78)  // 算术平均数
	     sort rep78
	     list rep78 *mpg, sepby(rep78)
		 
	
	 *-hmean() 函数  [] 调和平均数 
	 
	                            n
	   *-定义: H = --------------------------
	                1/x1 + 1/x2 + ... + 1/xn  
					
	
	 *-semean(), var(), sumoth(), xtile() 函数
	 
	
	 *-其它函数 
       * -egenms-   create a moving sum.
       * -egenmsd-  create a moving standard deviation.
       * -egenmmed- create a moving median.



	   
	   
	   
	   
	   
	   

          *     =====================================
          *              计量分析与STATA应用 
          *     =====================================
                    
          *        主讲人：连玉君 博士

          *        单  位：中山大学岭南学院金融系
          *        电  邮: arlionn@163.com
          *        主  页: http://blog.cnfol.com/arlion 

          *             ::第一部分::
          *              Stata 操作
          *         =====================
          *            第二讲  数据处理
          *         =====================
          *               2.2 分位数 
  
 
*-------------------
*-> 2.2  分位数 
*-------------------
 
  *     ==本节目录==
  
  *     2.2.1 分位数的基本概念
  *     2.2.2  -pctile- 命令
  *     2.2.3  -xtile- 命令
  *     2.2.4  -_pctile- 命令
  
		  
*                  =本节命令=  
* =====================================================
*     -pctile-  -xtile-  -_pctile-
* =====================================================


*_________________________
*-2.2.1 分位数的基本概念

    * 示例 1：
      clear
      set obs 100
      gen x = _n
      sum x, detail
	  
    * 示例 2：
      clear
      set obs 101
      gen x = _n
      sum x, detail
	  
    * 定义和公式
	
      * 第 p_th 百分位数值，记为 x_|p|，设 p = N_p/100，
	  *
      * 例如，若求取第 25 百分位的数值，则 N_p=25, p=0.25
      *
	  * 每个观察值的权重为 w(i)=1/N (N为样本数)，
      *
	  * 前 i 个观察值的权重之和为 W(i)=SUM_w(i) = i/N
      *
      * 则第 p_th 百分位的数值定义为，第一个满足 W(i)>p 的观察值，即
      *
      *           {  {x[i-1]+x[i]}/2    if W(i-1)=p
      *   x_|p| = {
      *           {   x[i]              otherwise
      *
        dis 5/101    // 条件 W(5)=0.495>0.05 不满足
        dis 6/101    // 这是第一个满足 W(6)=0.0594>0.05 的观察值的序号
        dis x[6]     // 第 5 百分位数值
		
      * 简单的处理方法：
        dis ceil(101*0.25)
        dis x[26]    // 这就是第25百分位数值，多数情况都是"otherwise"
        
    * 示例 1(回顾)：
      clear
      set obs 100          // 此例中，仅有100个观察值
      gen x = _n
      sum x, detail
      dis 5/100            //  0.05 = w(6-1) ==> i=6
      dis (x[5]+x[6])/2    // 第5百分位数值 
           

*_________________________
*-2.2.2  -pctile- 命令
  
    sysuse auto, clear
    pctile p_price = price, nq(10) 
	                // nq(#) 指定分9个百分位数,把样本切割为10组
    list p_price in 1/12, sep(0)
	sum price, detail
	
    pctile p_price2 = price, nq(10) gen(percent)  
	                      // gen() 选项用于生成对应的百分位标识
    list percent p_price2 in 1/12, sep(0)
 

*_________________________
*-2.2.3  -xtile- 命令         // 根据指定的百分位数定义类别变量
  
    use bp1.dta, clear
    xtile x_bp = bp, nq(4)
    list, sepby(x_bp)
    
    *-解释：nq(4) 创建规则如下
	
      * (-OO,x25], (x25,x50], (x50,x75], (x75,+OO)  // 右封闭区间
	  
      * 上述分位数的生成过程
        pctile xp_bp = bp, nq(4) genp(percent)
        list bp xp_bp percent
    
    * cutpiont() 选项
      input class
            100
            110
            120
            130
      end
      xtile c_bp1 = bp, cutpoints(class) //按照class分组
      list bp c_bp class, sepby(c_bp)
    

*_________________________
*-2.2.4  -_pctile- 命令     
  
    *-类似于-pctile-命令，但能够提供各个分位值的返回值
  
    sysuse auto, clear
    _pctile length, nq(10)
    return list
    sum price if (length>r(r9)) 
    
    _pctile price, p(33.3 72 90 99)  
    return list            
    *-自行指定分为点，这是该命令的最大优势
  
  

  
  
  
	   

          *     =====================================
          *              计量分析与STATA应用 
          *     =====================================
                    
          *        主讲人：连玉君 博士

          *        单  位：中山大学岭南学院金融系
          *        电  邮: arlionn@163.com
          *        主  页: http://blog.cnfol.com/arlion 

          *             ::第一部分::
          *              Stata 操作
          *         =====================
          *            第二讲  数据处理
          *         =====================
          *         2.3 重复样本值的处理 
  
  
*----------------------
*-2.3 重复样本值的处理
*----------------------

  *-类别变量中样本的重复非常普遍，也具有特殊的含义
  *-连续变量中的重复样本往往因为资料谬误所致
  
  
       *     ==本节目录==  
       
	   *     2.3.1 检查重复的样本组
	   *     2.3.2 标记和删除重复的样本组合
  

*                  =本节命令=  
* ================================================
* isid, duplicates report/examples/list/tag/drop
* egen group()
* ================================================


*___________________________
*-2.3.1 检查重复的样本组合

    sysuse nlsw88.dta, clear
    
  *-isid- 命令   学号和姓名
    isid race age
    isid idcode
	
  *-duplicates list- 命令
    duplicates list race married in 1/20

  *-duplicates report- 命令
    duplicates report race
    duplicates report race married
    duplicates report race married occupation

  *-duplicates example- 命令
    duplicates example race married
    tab race married


*_________________________________
*-2.3.2 标记和删除重复的样本组合

  *-标记重复的样本组合   
    
    *-使用 group() 函数
	
      sysuse nlsw88.dta, clear
	  
      egen rm = group(race married)
       tab rm, gen(dum_rm)  // 可以进一步用此变量创造虚拟变量
	   
      egen rm_lb = group(race married), label
       label list rm_lb
       list rm rm_lb in 1/10
       browse race married rm_lb rm
       
    *-使用 tag() 函数，第一个非重复样本为1，其他为零
	
      egen rm_tag = tag(race married) 
       list rm* in 1/20
       
    *-使用 -duplicates tag- 命令
	
      duplicates tag race married, gen(rm_dtag) //重复值的个数
       list rm* in 1/20
       
       
  *-删除重复的样本组合     
    
    duplicates drop race married, force

    *-对于 Panel Data 而言，我们可以使用如下命令删除重复的样本公司
    * duplicates drop id year, force        
    * 详见：第 2.11.1 小节           
                        
 
  
  
  
	   

          *     =====================================
          *              计量分析与STATA应用 
          *     =====================================
                    
          *        主讲人：连玉君 博士

          *        单  位：中山大学岭南学院金融系
          *        电  邮: arlionn@163.com
          *        主  页: http://blog.cnfol.com/arlion 

          *             ::第一部分::
          *              Stata 操作
          *         =====================
          *            第二讲  数据处理
          *         =====================
          *            2.4 缺漏值的处理  
		  
		  
*------------------
*-2.4 缺漏值的处理 
*------------------
  
  *     ==本节目录== 
  
  *     2.4.1 缺漏值简介 
  *     2.4.2 缺漏值的标记
  *     2.4.3 查找/删除缺漏值
  *         2.4.3.1 缺漏值的形态
  *         2.4.3.2 删除缺漏值	
  *     2.4.4 填补空缺(gap)   移动平均  线性插值 都可以
  *     2.4.5 多重补漏分析(multiple-imputation) 
  *         2.4.5.1 MI 简介
  *         2.4.5.2 实例分析
  *         2.4.5.3 MI impute regress 的假设条件
  *         2.4.5.4 其它补漏方法 
  *         2.4.5.5 假设检验    
  
   * 线性插值
   bys id : ipolate gdp year,gen(gdp1) epolate //ipolate 表示内部插值，epolate表示外部插值，gdp是插值变量，year是影响插值变量y的变量
*                  =本节命令=  
* ================================================
*   missing, mi(), mvencode, mvdecode, mistable
*   rmiss(), dropmiss, 
*   mi set, mi impute, miestimate, 
* ================================================

  
*__________________  
*-2.4.1 缺漏值简介 
  
  help missing
  
  *- "." 大于任何自然数 
  
  sysuse auto, clear
    sort rep78
    list rep78
  sum rep78 if rep78>4   // obs=11
  count if rep78>4       // obs=16, why?
  keep  if rep78>4
  list rep78
  
  *-说明：
    *-有些命令，如 sum, regress, generate 等，会自动忽略缺漏值；
    *-有些命令，如 count, keep 等，则会将 "." 视为一个无穷大的数值
    *-使用过程重要特别注意
  

*_____________________  
*-2.4.2 缺漏值的标记

  *-数值型缺漏值
    shellout d_miss.txt
    insheet using d_miss.txt, clear
	sum
    mvdecode x1, mv(-97)  // 重新定义某个变量的缺漏值，把-97转换成·
	list
	sum
	insheet using d_miss.txt, clear
	mvdecode _all, mv(-97 -999)
    sum
	
     
  *-文字型缺漏值
    type d201.txt
    insheet using d201.txt, clear
    replace x1 = .   if x1== "N/A"  // 错误方式
    replace x1 ="."  if x1== "N/A"
	des
    gen x1_new = real(x1)


*________________________  
*-2.4.3 查找/删除缺漏值       -misstable-  stata11新增功能
 
  *-2.4.3.1 缺漏值的形态
 
    *-最简单的命令: -summarize-
      sysuse nlsw88.dta, clear
      sum
 
    *-misstable summarize-命令：缺漏值的基本统计
      sysuse nlsw88.dta, clear
	  misstable summarize       // 所有变量
      misstable sum age-union   // 指定变量
 
    *-mistable pattern-命令：列示缺漏值的模式
      misstable pattern                //缺失值占比
	  misstable pattern, bypat
  
    *-mistable tree-命令：详细列示缺漏值的模式
	  misstable tree union tenure in 1/1000, freq    //uinon有或没有缺失行，对应的tenure缺失情况，识别两个变量在同一行是否都是缺失的
	  *-对照解释
      misstable summ union tenure in 1/1000

	
  
  *-2.4.3.2 删除缺漏值	
	
    *-rmiss()函数 
	  sysuse nlsw88.dta, clear
      egen miss = rmiss(wage industry occupation)   //返回由几个变量有缺失值，一个变量返回1
      list wage industry occupation miss if mis!=0  
      drop if miss!=0
 
    *-missing()函数 
      sysuse nlsw88.dta, clear
      sum
      drop if missing(grade,indus,occup,union,hours,tenure)  //任何一个变量有缺失值返回1
      sum
  
  
    *-更为简洁的命令：-dropmiss-  (外部命令)
	
      help dropmiss
	  
      sysuse nlsw88.dta, clear
        sum
        misstable sum
      dropmiss, obs   // 以观察值为单位，必须所有变量在同一行都缺失才删除
        sum
        misstable sum // nothing dropped
        
      sysuse nlsw88.dta, clear
        sum
      dropmiss, any   // 以变量为单位，删除有缺失的变量
        sum           // 6 variables dropped
        misstable sum 

	  sysuse nlsw88.dta, clear
      dropmiss, any obs  // 这或许是我们所需要的，任何一行只要有一个缺失就删除
        sum

	  
    *-另一种巧妙的方法 -regress- 命令
	
      sysuse nlsw88.dta, clear
      sum
	  
      reg wage industry occup tenure hours
	  ereturn list //返回回归参数
      gen byte nomis = e(sample)    // 标示样本的虚拟变量，回归用到的样本为1，否则为0
      sum wage industry occup tenure hours if (nomis==1)
	  keep if nomis
  
  

*_____________________  
*-2.4.4 填补空缺(gap)

  * 对于Panel Data或一些特殊的资料，可采用前向或后向非缺漏值填补
  * http://www.stata.com/support/faqs/data/missing.html
  
  * case1: 单一缺漏值之填补
    use d_miss01.dta, clear
    list
    sort t
    replace x = x[_n-1] if x==. 
    list
    
    use d_miss01.dta, clear
    list
    sort t
    replace x = x[_n+1] if missing(x)  // help missing(),若有缺失返回1，否则为0
    list
 
  * case2: 多个缺漏值之填补
    use d_miss02.dta, clear
    list
    sort t
    replace x = x[_n-1] if mi(x)  
    list
    * 解释：依次进行替换
    * 后向替换
      use d_miss02.dta, clear
      list
      gsort -t
      list 
      replace x = x[_n-1] if mi(x) 
      sort t 
      list
      
  * case3: Panel Data缺漏值之填补
    use d_miss03.dta, clear
    list , sep(4)    
    tsset id year
    by id: replace x = L.x if mi(x)
    list, sep(4)    
    
    
*-进一步阅读的资料：
  *
  *[1] How can I drop spells of missing values at 
  *    the beginning and end of panel data? 
   view browse http://www.stata.com/support/faqs/data/dropmiss.html
  *[2] How can I replace missing values with previous or 
  *    following nonmissing values or within sequences?
   view browse http://www.stata.com/support/faqs/data/missing.html
   
   
   
*______________________  
*-2.4.5 多重补漏分析    (multiple-imputation)  -mi-


   help mi         // stata11 的新功能
   
   *-2.4.5.1 MI 简介
   
     *-缺漏值的产生：随机 v.s. 非随机
	 
	 *-缺漏值的影响：
	 *   若缺漏值是非随机的，则相应的统计推断会存在严重偏误
	 *   换言之，非缺漏样本不能很好的体现母体特征
	 
	 *-多重补漏的基本思想
	 
	 *-多重补漏的特征
	   *-[1] 不对缺漏值的产生机制做任何假设(不假设其为 Random)
	   *-[2] 采用 Bayesian 或 MCMC 模拟分析
	   
	 *------------------------------------------------------------  
	 *-MI 分析的步骤
	 
	   *-step1: 声明数据结构
	   *
	   * stata命令： 
	   *   mi set
	   *   mi register
	   
	   *-step2: 补漏估计(imputation step)  [-imputation model-]
	   *   在给定假设下，使用某种模型进行 M 次插值 (imputation)
       *
	   * stata命令： 
	   *   mi impute
	   
	   *-step3: 目标模型估计(Pooling step)
	   *	   (completed-data analysis step) [-analysis model-]
	   *
	   *   利用第二步中的 M 组数据进行 M 次回归分析
	   *   并将 M 次估计结果整合起来，得到最终的结果
	   *
	   * stata命令： 
	   *   mi estimate	   
	 *------------------------------------------------------------	
	 
	 *-参考资料
   
       *-stata 手册 [MI]
         help mi_intro_substantive  //基本概念介绍
   
       *-一个精辟的介绍
         view browse http://www.stat.psu.edu/~jls/mifaq.html

		 
   *-2.4.5.2 实例分析
   *
   *------------------------实例开始------------------------------	   
   
    *-E1- 构建数据
	 
     *-Case-1-：随机缺漏(missing at random, MAR)
       sysuse auto, clear
       gen price_R = price
	   set seed 13579
	   gen random = uniform()
	   sum random
       replace price_R =. if random>0.9  
	 
     *-Case-2-：非随机缺漏(missing not at random, MNAR)
       gen price_U = price
	   replace price_U =. if price>11500	 
	   sum price price_* 
	   sum weight mpg length foreign if price_R ~=.
	   sum weight mpg length foreign if price_U ~=.
	 
	   save mi_auto, replace  // 保存数据以备后续分析
	 
     
    *-E2- 多重补漏分析
	
     *-2-1- mi set style 基本设定
	   view help mi_set##style
	   
	   use mi_auto, clear
	   mi set wide        // 设定

	 *-2-2- mi register  声明包含缺漏值的变量
	   view help mi_set##register
	   mi register imputed price_R
	   mi describe

	 *-2-3- mi impute method  补漏
	   help mi impute
	   mi impute regress price_R wei len mpg turn forei, ///
	                 add(20) rseed(1357)

	   *-补漏效果
	    egen pav_R_im = rowmean(_*_price_R)  //变量平均
	    list price pav_R_im  if price_R==., sep(0)
      
	 *-E3- mi estimate  估计模型
	   mi estimate: logit foreign price_R wei mpg turn
	   est store mi
	   *-对比结果
	   logit foreign price wei mpg turn,nolog noheader

	 *-E4-小结：完整过程   
	   use mi_auto, clear
	   mi set wide 
	   mi register imputed price_R
	   mi impute regress price_R wei len mpg turn forei, add(20)
	   mi estimate: logit foreign price_R wei mpg turn
	 
   *------------------------实例结束------------------------------

   *-说明：对结果的详细解释，参见 [MI]手册 p.46 
     
	 *-(1) average RVI: average relative variance increase
	 *     缺漏值的存在会导致模型的var增加
	 *     该指标衡量了缺漏值的影响程度，RVI越小表明影响越小
	    sysuse auto, clear
		replace price=. in 1/1   //只有一个缺漏值
		mi set wide
		mi register imputed price
		mi impute regress price wei len mpg turn forei, add(20)
		mi estimate: logit foreign price wei mpg turn
     
	 *-(2) 估计过程的公式，参见 [MI]手册, p.56
 
 
   *-2.4.5.3 MI impute regress 的假设条件
	  
	  *-要求满足正态分布假设
	  
	   use mi_auto, clear
	   
	   gen ln_price_U = ln(price_U)    // 对数转换
	   sum price_U ln_price_U, d
		 
	   mi set wide 
	   mi register imputed ln_price_U
	   
	   mi impute regress ln_price_U wei len mpg turn forei, ///
	             add(20) rseed(2468)
	   
	   *-后续分析中需要使用 price_U, 而非 ln_price_U
	   *-由于 price_U 是 ln_price_U 的函数，
	   *-而 ln_price_U 是一个 "imputed variable"，
	   *-因此，price_U 是一个 "passive variable"
	       mi register passive price_U
	   qui mi passive: replace price_U = exp(ln_price_U) //返回
	   
	   *-估计MI模型
	   mi estimate: logit foreign price_U wei mpg turn
	   * 对比真实数据
	   logit foreign price wei mpg turn, nolog noheader
	   * 对比直接删除数据的情形
	   logit foreign price_U wei mpg turn, nolog noheader
	   
	   *-说明：(1)主要的差别在于变量 -turn-
	   *       (2)本例中，MI的结果更接近直接删除的结果
	
	
   *-2.4.5.4 其它补漏方法 
 
      *-mi impute pmm
	    help mi impute pmm
		*-对模型设定和分布假设不敏感，稳健性较高
		
      *-mi impute logit
	    help mi impute logit
		*-用于填补 {0/1} 变量的缺漏值
		
      *-mi impute mlogit
	    help mi impute mlogit 
        *-用于填补 {0/1/2/3...} 序别变量的缺漏值 
		
	  *-其它
	    help mi impute
		
	  
   *-2.4.5.5 假设检验
	
	  help mi estimate postestimation


	  
 
  
  
  
	   

          *     =====================================
          *              计量分析与STATA应用 
          *     =====================================
                    
          *        主讲人：连玉君 博士

          *        单  位：中山大学岭南学院金融系
          *        电  邮: arlionn@163.com
          *        主  页: http://blog.cnfol.com/arlion 

          *             ::第一部分::
          *              Stata 操作
          *         =====================
          *            第二讲  数据处理
          *         =====================
          *            2.5 离群值的处理
		  
		  
*------------------
*-2.5 离群值的处理  
*------------------
  
  *     ==本节目录== 
  
  *     2.5.1 离群值的影响
  *     2.5.2 查找离群值
  *     2.5.3 离群值的处理
  *         2.5.3.1 删除
  *         2.5.3.2 对数转换
  *         2.5.3.3 缩尾处理
  *         2.5.3.4 截尾处理 
  
   
*                  =本节命令=  
* ================================================
*   histogram, winsor, hadimvo, egen outside()
*   qr, adjacent, fsreg, lv
* ================================================	  

 
*_____________________
*-2.5.1 离群值的影响
    
    *-例：离群值对回归结果的影响
	
      sysuse auto, clear
      histogram price
      count if price>13000

      reg price weight length foreign
       est store r1
      reg price weight length foreign if price<13000
       est store r2
	   
      esttab r1 r2, mtitle("with" "without")
	  
    *-结论：虽然离群值只有4个，但对回归结果的影响却很大


*___________________
*-2.5.2 查找离群值
  
    *                  -------------    
    *                     基本概念
    *                  -------------
	*
    * 第25、50、75百分位上的数值分别称为第1、2、3四分位
    * 四分位间距(interquartile range): iqr = p75-p25
    * 上界(upper adjacent) = p75 + 1.5*iqr
    * 下界(lower adjacent) = p25 - 1.5*iqr
    *------------------------------------------------
    
    *-adjacent- 命令
      sysuse auto, clear
      adjacent price
      adjacent price, by(foreign)
	  
	*-egenmore 提供的 outside() 函数
	  egen out  = outside(price)  
	  egen out2 = outside(price), factor(2)
	  egen outby= outside(price), by(foreign) factor(2)
	  list price out*
	  keep if outby==.  // 删除离群值

    *-箱形图
      help graph box
      graph box price
      graph box price, by(foreign)
      graph box weight, by(foreign)


	  
*_____________________
*-2.5.3 离群值的处理

    *-2.5.3.1 删除
	
      sysuse auto, clear
      adjacent price, by(foreign) 
      drop if (price>8814&foreign==0) | (price>9735&foreign==1)
	  
	  *-or            // 需要提前安装-egenmore-相关命令
	  sysuse auto, clear
	  egen outby = outside(price), by(foreign) factor(2)
	  drop if outby != .
	  
  
    *-2.5.3.2 对数转换
	
      sysuse nlsw88, clear
      gen ln_wage = ln(wage)
	  
      twoway (histogram wage,color(green))      ///
             (histogram ln_wage,color(yellow))
			 
      sum wage ln_wage, d
	  
      graph box wage
      graph box ln_wage


    *-2.5.3.3 缩尾处理
	
      sysuse nlsw88.dta, clear
      histogram wage
	  
      *-双边缩尾
        winsor wage, gen(wage_w2) p(0.025)
		
		*-图示
        twoway (histogram wage,color(green))      ///
               (histogram wage_w2,color(yellow)), ///
               legend(label(1 "wage") label(2 "wage_winsor2")) 
			   
      *-单边缩尾
        winsor wage, gen(wage_h) p(0.025) highonly
		*-图示
        twoway (histogram wage,color(green))      ///
               (histogram wage_h,color(yellow)),  ///
               legend(label(1 "wage") label(2 "wage_winsorH"))
		
		
      *-若无法下载 winsor 命令，可以采用如下处理方法：
	    
		_pctile wage, percentile(1 99)
		replace wage = r(r1) if wage<r(r1)
		replace wage = r(r2) if wage>r(r2)
		
		*-亦可采用 clip() 函数 (参见第2.1.2.6小节，第385行)
		 gen wage_w = clip(wage, r(r1), r(r2))
		 sum wage wage_w, detail

        
	
    *-2.5.3.4 截尾处理
	
      sysuse nlsw88, clear
      _pctile wage, percentile(1 99)
      return list
      drop if wage<r(r1)  // 删除小于第1百分位的样本
      drop if wage>r(r2)  // 删除大于第99百分位的样本
      
      *-说明：
      * (1) 可以先绘制直方图，进而根据分布情况选择左截尾、
	  *     右截尾还是双边截尾
      * (2) 相比于ln()处理和winsor处理，该处理会损失样本
      *     但对于大样本而言，该方法比较"干净"





	  
 
  
  
  
	   

          *     =====================================
          *              计量分析与STATA应用 
          *     =====================================
                    
          *        主讲人：连玉君 博士

          *        单  位：中山大学岭南学院金融系
          *        电  邮: arlionn@163.com
          *        主  页: http://blog.cnfol.com/arlion 

          *             ::第一部分::
          *              Stata 操作
          *         ======================
          *            第二讲  数据处理
          *         ======================
          *          2.6 资料的合并和追加  
		  
		  
*----------------------
*-2.6 资料的合并和追加           
*----------------------
  
  *     ==本节目录== 
  
  *     2.6.1 横向合并：增加变量   
  *         2.6.1.1 一对一合并 
  *         2.6.1.2 多对一合并 
  *         2.6.1.3 一对多合并 
  *         2.6.1.4 一个例子
  *     2.6.2 横向关联: -joinby-  	
  *     2.6.3 纵向合并：追加样本  	
  *     2.6.4 大型数据的处理
  *     2.6.5 一些有用的外部命令
  
   
*                  =本节命令=  
* ================================================
*   -merge-  -jionby-  -append-
* ================================================	  

  
  cd `c(sysdir_personal)'Net_course_A\A2_data


*____________________________ 
*-2.6.1 横向合并：增加变量        -merge-

    do L2_data_gr_merge.do 

  *-2.6.1.1 一对一合并  [ 1:1 ]
  
    view help merge##ii
  
    *-待合并的数据
      use merge_u.dta, clear
      browse
      use merge_m.dta, clear
      browse
	  
	*-合并方法：
	  use merge_m.dta, clear
	  merge 1:1 date using merge_u
      
    *- _merge 变量的含义：
    *
    *  _merge==1  obs. from master data                            
    *  _merge==2  obs. from only one using dataset                 
    *  _merge==3  obs. from at least two datasets, master or using
    
	*-【说明】在stata11以前，横向合并的过程要复杂一些
	*         在合并前，必须先依据 date 变量对两组数据进行排序
	
	*-其它选项
	
	   help merge
	   
	   *-keepusing(varlist) 选项 (仅合并部分数据)
	     use merge_m.dta, clear
		 merge 1:1 date using merge_u, keepusing(close)
	   
	   *-generate() 选项 v.s. nogenerate 选项
	     use merge_m.dta, clear
		 merge 1:1 date using merge_u, gen(m1)
		 
	   *-nolabel, nonotes 选项 (不拷贝被合并数据的"数字-文字对应表")
		 
	   *-update 选项 (更新主数据集中的缺漏值)
	     *-问题
		 use merge_u.dta, clear
           browse
		 use merge_m.dta, clear
		   gen close = . // merge_u.dta 中也有该变量，但取值不同
		   browse
		 *-合并方法  
	     merge 1:1 date using merge_u, update
		   browse
		   
	   *-replace 选项 ()
	     use merge_m.dta, clear
		   gen close = 0 // 注意，此例中 close=0
		   browse
	     merge 1:1 date using merge_u, update  
		   browse	     // close=0 并未发生变化
		 
		   drop _merge
		 merge 1:1 date using merge_u, update replace // 正确做法
		   browse

		   
  *-2.6.1.2 多对一合并  [ m:1 ]
  
    view help merge##mi
	
	*-数据形态
	  use GTA_FS.dta,clear     // 上市公司财务资料
          browse 
      use GTA_basic.dta,clear  // 上市公司基本资料,只有 id 没有 year
          browse 
	
	*-合并方法
	  use GTA_FS.dta, clear
	  merge m:1 id using GTA_basic.dta, nogen
	  
		   
  *-2.6.1.3 一对多合并  [ 1:m ] 
  
    view help merge##im    // 其实就是 m:1 的逆向操作
	
	*-数据形态
	  use GTA_FS.dta,clear     // 上市公司财务资料
          browse 
      use GTA_basic.dta,clear  // 上市公司基本资料,只有 id 没有 year
          browse 
	
	*-合并方法
	  use GTA_basic.dta, clear
	  merge 1:m id using GTA_FS.dta, nogen
	  browse
	  order id year
	  tsset id year
	  
	  
  *-2.6.1.4 一个例子
  
    *-数据形态：
	
      use GTA_FS.dta,clear     // 上市公司财务资料
          browse 
      use GTA_GC.dta,clear     // 上市公司治理结构信息
          browse 
      use GTA_div.dta,clear    // 上市公司股利分配、增发配股
          browse 
      use GTA_basic.dta,clear  // 上市公司基本资料,只有 id 没有 year
          browse
      
    *-合并上述数据
    
      *-基本思路：
      * (1) 先根据 id year 把前三个数据一次性合并起来；[1:1]
      * (2) 再根据 id      把GTA_basic数据合并进来     [m:1]
	  
      use GTA_FS.dta, clear
      merge 1:1 id year using GTA_GC.dta , nogen
	  merge 1:1 id year using GTA_div.dta, nogen
      merge m:1 id      using GTA_basic, nogen   

      tsset id year   
      save GTA_merge.dta, replace    // 保存合并后的数据 
  


*_________________ 
*-2.6.2 横向关联      -joinby-

  *-应用背景: 我们只需要保留两份数据中有对应关系的数据
    use child.dta, clear
       list, sepby(family_id)
       sort family_id
       save, replace
    use parent.dta, clear
       sort family_id           // 这一步很重要！
       list, sepby(family_id)
    joinby family_id using child.dta
       sort family_id parent_id child_id
       order family_id parent_id child_id
       list, sepby(fam)
	  
    
  *-与-merge- 命令的对比
     use parent, clear
       sort fam*id
     merge m:m fam using child
       sort family_id parent_id child_id
       order family_id parent_id child_id     
     list, sepby(fam)
       
    
*__________________________ 
*-2.6.3 纵向合并：追加样本      -append-

   do L2_data_gr_append.do    // 基本原理
   
   *-两个数据库中的"同名变量"会自动对应累叠
   
   *-数据形态
     use append_m.dta, clear
         browse
		 tsset date
     use append_u.dta, clear
         browse
		 tsset date
 
     use append_m.dta, clear
     append using append_u.dta
         browse
		 tsset date
		 
   *-generate() 选项
     use append_m.dta, clear
     append using append_u.dta, gen(append_id)
	     browse
		 
   *-nolabel, nonotes 选项
     
   *- 几个注意事项：
   *  (1) 两个数据库中的变量名称要相同
   *      PRICE 和 price 是不同的变量
   *  (2) 两个数据库中的同名变量要具有相同的存储类型
   *      同为文字变量或同为数值变量
   
   *-问题(2)示例：两个数据集中的变量存储类型不同
	
      sysuse auto,clear
        keep foreign
        keep if !foreign       // keep if foreign==0
      save auto_dom, replace   // 数据集1：变量foreign为数值类型
	  
      sysuse auto, clear
        keep foreign 
        keep if foreign
        rename foreign s
        gen foreign = "foreign" if s
        drop s
      save auto_for, replace   // 数据集2：变量foreign为文字类型
      
      use auto_dom, clear
      browse
      append using auto_for
      browse
      
    *-更换合并的先后顺序：于事无补！ 
      use auto_for, clear
      browse
      append using auto_dom
      browse
     
	*-增加 -force- 选项, 并无实质性改进
      use auto_dom, clear
      append using auto_for, force 
	  browse

	*-如何解决？
	  use auto_for, clear
	  rename foreign ss
	  gen byte foreign=1 
	  drop ss
	  
	  append using auto_dom
	  browse
	
	
	
*_______________________ 
*-2.6.4 大型数据的处理    

  *-范例：构建上市公司研究数据库
  
  *-数据特征描述：
    *-样本区间：1990-2008
    *-指标范围：上市公司财务资料、基本信息、治理信息、股利分配、增发配股等
    *-数据来源：CCER、GTA (每个数据库都分成了若干个字库)
    
  *-任务：把不同来源的各项数据合并起来，整合成一个完成的数据集合
  
    doedit GTA_2008.do                // 该文件历时 3 天完成 
	
	shellout 连玉君_GTA2008说明书.pdf // 说明书

	

*__________________________
*-2.6.5 一些有用的外部命令
  
  * -nearmrg-  performs nearest match merging of two datasets
  
  * -mmerge-   一个更灵活的合并命令
  
  * -reclink-  module to probabilistically match records
  
  * -xmerge-,-xmerged-,-nmerge-  批量合并命令
  
  * -mergein-  自动排序后合并 // stata11 用户已经不需要了
  
  * -mergedct- 直接将 .raw 文件合并至已有 .dta 文件中
  
  * -addinby-  对-merge-做了改进，不会生成_merge，并检查合并的配对情况
  
  * -kountry-  standardize country names across various datasets（SJ8-3）
  
  * -tvc_merge- merge two files which each contain time varying covariates



	  
 
  
  
  
	   

          *     =====================================
          *              计量分析与STATA应用 
          *     =====================================
                    
          *        主讲人：连玉君 博士

          *        单  位：中山大学岭南学院金融系
          *        电  邮: arlionn@163.com
          *        主  页: http://blog.cnfol.com/arlion 

          *             ::第一部分::
          *              Stata 操作
          *         ======================
          *            第二讲  数据处理
          *         ======================
          *            2.7 重新组合样本 
		  
  
*------------------
*-2.7 重新组合样本
*------------------
  
  *     ==本节目录== 
  
  *     2.7.1 样本的转置  
  *     2.7.2 数据的横纵变换  
  *     2.7.3 样本的交叉组合  
  *         2.7.3.1  -fillin- 命令
  *         2.7.3.2  -cross-命令
  *     2.7.4 样本的堆砌
  
   
*                  =本节命令=  
* ==================================================
*   -xpose-  -reshape-  -fillin-  -stack-  -cross-
* ==================================================	  
  

*____________________
*-2.7.1 样本的转置           -xpose-

   use d205.dta, clear
   list v1-v7
   
   xpose, clear             // clear 选项必须加
   
   rename v1 date
   rename v2 open
   rename v3 close
   save d204.dta, replace   // 另存一份数据，因为原始数据已被修改
   
   
*_______________________
*-2.7.2 数据的横纵变换      -reshape-

  *- 问题描述
     shellout reshape0.txt  // -xpose- 命令不奏效
     
  *- wide --> long
     use reshape1.dta, clear
     list
     reshape long inc ue, i(id) j(year) // sex 不发生变化，无需转换
                                        // j() 选项中填写新的变量名称
     list, sepby(id)
     replace year = real("19" + string(year))
     list, sepby(id)
     
  *- long --> wide
     reshape wide inc ue, i(id) j(year)
        
*-示例：
*-World Development Indicator 转换
 view browse ///
    http://dss.princeton.edu/online_help/analysis/reshape_wdi.htm
 
*-进一步的参考资料
 view browse ///
    http://www.stata.com/support/faqs/data/reshape3.html#
  
  
  
*_______________________   
*-2.7.3 样本的交叉组合           -fillin-  -cross-   
 
  *-2.7.3.1  -fillin- 命令
  
    *-例1：Nlogit模型中的选择行为 
    *-see SJ 5-1, p.135, Filling in the gaps 
     clear            
     input id choice
             1   -1
             2    1
             3    0
             4   -1
     end
     list
     fillin id choice
     list, sepby(id)
     *-可见，-fillin-的作用在于对原始观察值进行"组合"
     
    *-例2：建立一个Panel Data 的 id, year  
    * i = 1,2,20;  t = 2000-2008  
      clear
      set obs 20
      gen id = _n
      gen tt = _n + 2000
      list
	  
      fillin id tt
	  
      list, sepby(id)
      drop if (tt>2008)
      drop _fillin
      list, sepby(id)
 
 
  *-2.7.3.2  -cross-命令
    
    clear
    input str6 sex
               male
               female
    end
    save sex, replace
    
    clear
    input age
           20
           40
           50
    end
    
    cross using sex.dta
    
    list, sep(0)
  
    *-亦可用 -fillin- 命令加以解决
      clear
      input str6 sex     age
                 male     20
                 female   40
                   .      60
      end  
      fillin sex age
      list, sep(0)
      drop if sex == "."
      list, sep(0)
    
  *-说明：-cross-命令较少使用，SJ 6-1, p.147 提供了一个妙用
  
*-相关阅读：第 16 楼
  view browse ///
     http://www.pinggu.org/bbs/thread-436189-1-1.html
  

  
*__________________   
*-2.7.4 样本的堆砌

  *-简介
  * 基本思想：向量化
    
    use stackxmpl.dta, clear
    list
    stack a b c d, into(x) clear       // 堆砌成一列，四个变量数据都变成一个变量数据
    list, sepby(_stack)
     
    use stackxmpl.dta, clear 
    list
    stack a b c d, into(x1 x2) clear   // 堆砌成两列
    list, sepby(_stack)
      
      
  *-范例    
    
    *-原始样本
      use stack_lnexp.dta,clear
      browse
   
    *-堆砌样本 
      stack china-unitedstates, into(lnexp) clear
	  browse
   
    *-进一步美化 I: 增加年度变量  
      rename _stack id
      egen year = seq(), from(1998) to(2007)
      order id year
      tsset id year
      save lnexp_temp, replace  // 后续还要做进一步处理   
   
    *-进一步美化 II: 增加国名 
	
      *-取出国名
        use stack_lnexp.dta,clear
        drop lnexp
		browse
		
        mkmat _all, mat(a)      // 矩阵的列名(国名)就是我们需要的 ，把数据转换为矩阵
		mat list a
		
        global vn: colnames a   // 将国名存储于暂元 vn 中，colnames取出a矩阵的列名
        dis "$vn" 
		
      *-处理国名 
        use lnexp_temp, clear
        rename id id123
        gen id = "" 
        local i = 1
        foreach nn of global vn{ // 1 --> "china" 
           qui replace id="`nn'" if id123==`i++'  // `i++'，即每循环一次加1，（replace `i' = `i'+1）
        }
        
		sencode id, replace // id 是一个文字变量，现转化为数值变量
		labelbook
		
        order id year id123
        tsset id year 
		
		browse
     
        save lnexp.dta, replace
     
     

 
  
  
  
	   

          *     =====================================
          *              计量分析与STATA应用 
          *     =====================================
                    
          *        主讲人：连玉君 博士

          *        单  位：中山大学岭南学院金融系
          *        电  邮: arlionn@163.com
          *        主  页: http://blog.cnfol.com/arlion 

          *             ::第一部分::
          *              Stata 操作
          *         ======================
          *            第二讲  数据处理
          *         ======================
          *           2.8 文字变量的处理
		  
  
*--------------------
*-2.8 文字变量的处理
*--------------------
  
  *     ==本节目录== 
  
  *     2.8.1 将文字转换为数字
  *         2.8.1.1 以文字类型存储的数字之转换 
  *         2.8.1.2 纯文字类别变量之转换 
  *     2.8.2 将数字转换成文字
  *     2.8.3 文字样本值的分解
  *     2.8.4 处理文字的函数
  *         2.8.4.1 文字函数简介
  *         2.8.4.2 例-1-：上市公司日期、行业代码和所在地的处理
  *         2.8.4.3 例-2-：银企关系数据中银行名称的提取
  *         2.8.4.4 例-3-：处理不规则的日期
  
   
*                  =本节命令=  
* ==================================================
*   -destring-  -encode-  -sdecode-  -real()-
*   -tostring-  -decode-  -rdecode-  -redecodeall-
*   -substr()-  -strmatch()-  -split-
*   -regexm()-  -regexs()-  -regexr()-
* ==================================================	


*__________________________
*-2.8.1  将文字转换为数字

  *-2.8.1.1 以文字类型存储的数字之转换      -destring-

    *- 说明：
    *-   从 .txt 文档中读入数值变量之所以会以文字值方式存储，
    *-   主要原因是变量中可能包含了如下特殊符号：
    *-   金额`$'、逗号`,'、斜线`/'、百分比`%'、破折号`-'
  
    shellout d202.txt
    insheet  using d202.txt, clear names
    save d202.dta, replace
    des
    sum

    *-说明：虽然 code 变量由数字组成，但其类型为 str7,即为文字型变量
    *       leverage, size, date 都存在类似的问题
	
    use d202.dta, clear
    destring code,     gen(code1) ignore(" ")  //生成code1，把code变成数字，忽略空格，类似把空格替换为空
    destring leverage, gen(lev) percent   //把字符24%变成数字0.24
    destring year date size lev, replace ignore("-/,%") //忽略这四个字符，在原变量进行替换
    

  *-2.8.1.2 纯文字类别变量之转换       -encode-, -rdecode-
  
    use d202.dta, clear
    encode gov, gen(gov1)
    labelbook
	
    *-说明：
	*
    *- encode 命令会自动根据文字类别编号，
	*         并设定相应的[数字-文字对应表]
	*
    *  [数字-文字对应表] 按"字母顺序排列" 
                 sysuse auto, clear
                 encode make, gen(make_num)
                 order make make_num
                 labelbook
				 
    *_Q: 如何根据出现的先后顺序设定[数字-文字对应表]? [-sdecode-]  
	
    *- encode缺陷：
	*  (1) 没有 -replace- 选项                        [-rdecode-]
    *  (2) 每次只能转换一个变量，无法实现批量转换     [-rdecodeall-]
                

    *-rdecode- 命令：附加 replace 选项
	
      use d202.dta, clear
      rencode gov, replace
      labelbook
	  
      *-说明：
      *  (1) 与该命令功能相似的还有 -sencode- 命令
      *  (2) 使用 -rdecodeall- 命令可以同时转换多个变量
    
	
    *-encode 命令与 -destring- 的区别
    *
    *-(1) 若数字"误存"为文字型变量，使用-destring-命令或 real() 函数
	*
    *-(2) 若观察值均为"文字值"，则需使用-encode-或-rencode-命令，
    *     这些命令会自动产生【数字-文字对应表】
 
 
*_________________________
*-2.8.2 将数字转换成文字

  *-某些情况下，先把数字转换成文字，
  *-然后利用处理文字的函数进行处理比较方便
        
  *-eg01：年月日的组合
  
    use tostring.dta, clear
    tostring year day, replace
    gen date = year + "-" + month + "-" + day
    gen edate = date(date, "YMD")
    format edate %td
    browse
   
   
  *-eg02：年月日的分离
  
    use tostring2.dta, clear
    browse
    tostring date_pub, gen(date1)
    gen year  = substr(date1, 1, 4)
    gen month = substr(date1, 5, 2)
    gen day   = substr(date1, 7, 2)
    browse
    destring year month day, replace
    browse 
    
  *-说明：
  *   -decode-命令的缺陷同样在于没有 -replace- 选项，
  *   可以采用外部命令 -rdecode- 或 -sdecode- 代替之。    
  
 
*_________________________
*-2.8.3  文字样本值的分解

    use d202.dta,clear
    list
    
  *-从 year 变量中提取年份   -split-
    split year, parse(-)
    order year year1 year2
    list
    browse
    gen year3 = real(year1)   // year1中全为数值，但以文字型存储
	
    * destring year1, replace // 另一种方式

  *-从 date 变量中提取年份、月度和日期,并转化为数值
    split date,parse(/) destring ignore("/") 
    order date date*
    edit
    
*-Also see  一个比较复杂的例子
  view browse http://www.stata.com/support/faqs/data/splitstr.html


*_________________________
*-2.8.4  处理文字的函数

    help string functions

  *-2.8.4.1 文字函数简介
  
    dis lower("AbCDef")
    dis length("price  weight length   mpg")   //统计字符个数
    dis wordcount("price  weight length   mpg") //统计变量的个数
    dis proper("mR. joHn a. sMitH")   // 规整人名
    dis strmatch("C51", "C")
    dis strmatch("C51", "C*")         // 寻找制造业公司
    dis  trim(" I love    STATA  ")   // 去掉两端的空格
    dis ltrim(" I love    STATA  ")   // 去掉左边的空格 
    dis rtrim(" I love    STATA  ")   // 去掉右边的空格       
    dis itrim(" I love    STATA  ")   // 去掉中间的空格，仍然保留单词之间空一格           
    dis itrim("内 蒙 古 自治区")   // 去掉中间的空格，不奏效？
    dis subinstr("内 蒙 古 自治区", " ", "", .)
   *-释义：
   *  subinstr(s, s1, s2, n)
   *  s   原始字符串
   *  s1 "将被替换"的字符串
   *  s2 "替换成"的字符串
   *  n   前n个出现的目标字符，若为"."则表示全部替换
    dis subinstr("内 蒙 古 自治区", " ", "", 1)
	dis subinstr("内 蒙 古 自治区", " ", "", 3)
   
   *-说明：上述函数都可以用于 -generate- 命令来生成新的变量
       
 
  *-2.8.4.2 例-1-：上市公司日期、行业代码和所在地的处理
  
    *-a 待处理的数据
      shellout d203.txt
      insheet date sic location using d203.txt, clear
      save d203.dta, replace
      browse

    *-b 从date中分离出年、月、日
      gen year  = int(date/10000)
      tostring date, gen(date1)
      gen year1 = substr(date1,1,4)
      gen year2 = real(year1)
      gen month = substr(date1,5,2)
      gen month1= real(month)
      gen day   = substr(date1,7,2)
      gen day1  = real(day)
      browse
   
      *-更为简洁的命令
        use d203.dta, clear
        gen sdate = string(date,"%10.0g")  // help string()
        gen year  = real(substr(string(date,"%10.0g"), 1, 4))
        gen month = real(substr(sdate, 5, 2))
        gen day   = real(substr(sdate, 7, 2))
        browse
        drop sdate

    *-c 从行业大类sic中分离出行业门类
      gen sic_men0 = substr(sic,1,1)
      encode sic_men0, gen(sic_men)
      tab sic_men
      label list sic_men

    *-d 从地点中分离出省份和城市
      use d203.dta,clear
      list
      gen province1 = substr(location, 1,2)
      gen city1     = substr(location, 4,4)
      list location province1 city1
      gen province2 = word(location, 1)
      gen city2     = word(location, 2)
      list location province1 city1 province2 city2
      
      *-注意：每个英文字母占一位，但每个中文字符占三位  
      
	  
	  
  *-2.8.4.3 例-2-：银企关系数据中银行名称的提取
  
    *-数据描述
	  use bankname.dta, clear
	  tab objnm
	  list in 1/15   
	  
	*-任务：提取出关联银行总部的名称
	  keep in 1/15
	  gen bank = objnm
	  replace bank="中国农业银行" if strmatch(bank,"*农业银行*")
	  replace bank="招商银行"     if strmatch(bank,"*招商*")
	  replace bank="中国银行"     if strmatch(bank,"*中国银行*")
	  replace bank="中国工商银行" if strmatch(bank,"*工商*")
	  replace bank="兴业银行"     if strmatch(bank,"*兴业*")
	  replace bank="光大银行"     if strmatch(bank,"*光大*")
	  replace bank="交通银行"     if strmatch(bank,"*交通*")
	  replace bank="北京银行"     if strmatch(bank,"*北京*")
	  compress
	  browse

  
  *-2.8.4.4 例-3-：处理不规则的日期
  
    *- regexm(), regexs(), regexr() 函数  
  
    help regexm()
  
    *-基本语法规则
      view browse http://www.stata.com/support/faqs/data/regex.html
  
    *-示例：处理不规则的日期
      clear
      input str18 date
          20jan2007 
          16June06
          06sept1985
          21june04
          4july90
          9jan1999
          6aug99
          19august2003
      end
	  
    *-如何规整之？---正则表达式
      gen day   = regexs(0) if regexm(date, "^[0-9]+")  //^表示从首位开始，+表示	将前一个字符或子表达式匹配至少1次，例如XY+可匹配XY,XYY,XY.....Y，但不可匹配X。
      gen month = regexs(0) if regexm(date, "[a-zA-Z]+")，[a-z]可以匹配a-z范围内的任意小写字母
      gen year  = regexs(0) if regexm(date, "[0-9]*$") //$表示结尾位置，*表示将前一个字符或子表达式匹配任意次数，可以为0次，	XY*可以匹配X，也可以匹配XY,XYY,XY.....Y。
      browse
      replace year = "20"+regexs(0) if regexm(year, "^[0][0-9]$")
      replace year = "19"+regexs(0) if regexm(year, "^[1-9][0-9]$")
      gen date2 = day+month+year
      browse
	  
    *-释义：
    * (1) "^[0-9]+"  
    *      ^ 表示字符串的开头部分
    *      [0-9] 表示属于自然数0-9的任何一个
    *      + 表示有至少一个对象符合匹配条件(*任何一个；?只有一个)
    * (2) "[a-zA-Z]+"
    *     [a-zA-Z] 表示阿拉伯字母中的a-z或A-Z
    * (3) "[0-9]*$"
    *     $ 表示字符串的结尾部分
  
 *-更多示例：(1) 如何从地址中提取"邮编"？
 *           (2) 如何规整人名？
   view browse http://www.ats.ucla.edu/stat/stata/faq/regex.htm  
   view browse http://www.stata.com/support/faqs/data/regex.html
  
  
 *-Also see:
  
  * Cox, N., 2002, Speaking Stata: On getting functions to do the work, 
       STATA JOURNAL, 2 (4): 411-427. (p.414)
	   
  * 外部命令 -egenmore- 提供了大量的文字处理函数，可供参考
  
    help egenmore
  

  
  
  
	   
	   
	   

          *     =====================================
          *              计量分析与STATA应用 
          *     =====================================
                    
          *        主讲人：连玉君 博士

          *        单  位：中山大学岭南学院金融系
          *        电  邮: arlionn@163.com
          *        主  页: http://blog.cnfol.com/arlion 

          *             ::第一部分::
          *              Stata 操作
          *         ======================
          *            第二讲  数据处理
          *         ======================
          *           2.9 类别变量的分析
		  
  
*---------------------
*-2.9 类别变量的分析
*---------------------
  
  *     ==本节目录== 
  
  *     2.9.1 类别数的统计
  *     2.9.2 交叉类别变量的生成 
  *     2.9.3 分组统计量
  *         2.9.3.1 单层分组统计量 
  *         2.9.3.2 二层次和三层次分组统计量
  *         2.9.3.3 多层次分组统计量
  *     2.9.4 计算分组统计量的其它方法
  *         2.9.4.1 -egen-命令
  *         2.9.4.2 转换原资料为分组统计量：-collapse-命令
  *     2.9.5 图示分组统计量
  *         2.9.5.1 柱状图
  *         2.9.5.2 箱形图
  
   
*                  =本节命令=  
* ==================================================
*   -tab-  -distinct-  -xgroup-  -bysort-  
*   -tabstat-  -collapse-  -graph bar-  -graph box-
* ==================================================


*______________________
*-2.9.1  类别数的统计
  
  *-简单方法：-tab- 命令
  
    sysuse nlsw88, clear
    tab race
    tab occupation  // 局限：无法直接看到类别数目
    
	
  *-统计非重复值的个数
  
    distinct occupation
    ret list
    distinct married race
    distinct married race, joint  // 组合个数
    distinct married race occupation, joint
  
  
*____________________________
*-2.9.2  交叉类别变量的生成 
  
  sysuse nlsw88, clear
  tab race
  tab married
  
  *-Q：如何生成一个新的类别变量，取值为1-6，是race和married的组合
  
    xgroup race married, gen(race_marr) 
      browse race married race_marr in 1/20
    xgroup race married, gen(race_marr2) label lname(race_marr_lab)
      browse race married race_marr in 1/20
      label list race_marr_lab

  *-说明：
  *  (1) 可同时基于多个类别变量生成它们的组合类型；
  *  (2) 基于新生成的类别变量，可以进一步创建虚拟变量
  *  (3) 参见 -xi-, -fvvarlist- 帮助文件 (2.1.2小节)
  
  
  
*__________________
*-2.9.3 分组统计量
  
  *-2.9.3.1  单层分组统计量 
    
    *-bysort,sum
      sysuse nlsw88.dta,clear
      bysort race: sum wage

    *-tabstat 命令
      tabstat wage, by(race) stat(mean sd med min max) 
      tabstat wage hours ttl_exp, by(race)      ///
              stat(n mean sd med min max)       ///
              format(%6.2f) columns(statistics) 
            
    *-tabulate 命令
      tabulate industry
      tab industry, sort    // 可简写为 -tab-
      tab industry, summarize(wage) 


  *-2.9.3.2  二层次和三层次分组统计量
    
    bysort race married: sum wage
    bysort race married: tabstat wage,   ///
           by(union) s(n mean sd p50 min max)
    tabstat wage, by(race married union)  ///
           s(n mean sd p50 min max) // 错误方式
    bysort race married: tab union, sum(wage)


  *-2.9.3.3  多层次分组统计量
    
    *-基本架构：table var1 var2 var3, by(var4) contents(...)
    
    table race married union,       ///
          by(collgrad) c(mean wage) format(%4.2f)
    table race married union,       ///
          by(collgrad) c(mean wage freq) format(%4.2f)


*_________________________________
*-2.9.4  计算分组统计量的其它方法

  *-2.9.4.1 egen 命令
  
    bysort industry: egen wage_ind = mean(wage)
    bysort industry: egen wage_p50 = pctile(wage), p(50)
    list wage indust wage_ind wage_p50 in 1/30

	
  *-2.9.4.2 转换原资料为分组统计量：collapse 命令
  
    help collapse
    
    *-语法：collapse (统计量1) 新变量名=原变量名 (统计量2) ...
    
    sysuse nlsw88.dta,clear
    collapse (mean)  wage hours          ///
	         (count) n_w=wage n_h=hours, ///
	          by(industry)
    browse
    
    sysuse nlsw88.dta,clear
    collapse (mean)  wage hours          ///
	         (count) n_w=wage n_h=hours, ///
	          by(industry race) 
    browse
    
    * 几点说明：
    *   (1) 经常保存do文档，但不要轻易选择保存数据文件
    *   (2) by() 选项是必填选项，不可省略
    
    * collapse 后，原始变量的标签会丢失，处理方法如下：
      view browse ///
	  "http://www.stata.com/support/faqs/data/variables.html#"


	  
*________________________
*-2.9.5  图示分组统计量

  *-2.9.5.1 柱状图
  
    *-纵向柱状图
      sysuse nlsw88.dta, clear
      graph bar (mean) wage, over(smsa) over(married) over(collgrad)
      do     L2_data_gr_bar1.do  // 更完整的图示
      doedit L2_data_gr_bar1.do
	  *- 说明：over() 选项的呈现顺序是从内到外

    *-横向柱状图
      graph hbar (mean) hours, over(union) over(industry)
      *-note：over() 选项的顺序决定了分组的层次关系，
      graph hbar (mean) hours, over(union) over(industry) asyvars 
	                 //asyvars-把第一个over()选项中的变量视为纵轴
      graph hbar (mean) hours, over(union) over(married)  ///
                               over(race) percent asyvars
						   
    *-多变量柱状图
      graph bar wage hours, over(race) over(married)
      graph bar wage hours, over(race) over(married) stack
	  
      *-over() 选项的子选项
        graph bar wage hours, stack                       ///
          over(race, relabel(1 "白人" 2 "黑人" 3 "其他")) ///
          over(married, relabel(1 "单身" 2 "已婚"))       ///
          legend(label(1 "工资水平") label(2 "工作时数")) 


  *-2.9.5.2  箱形图

    *-箱形图能较清晰的呈现各组样本值的分布情况              
    
	  sysuse nlsw88, clear
      
	  graph box wage,  over(race)
      graph box hours, over(race) over(married)
      graph box hours, over(race) over(married) nooutsides


  *-Also see:
  * 
  *  Cox,N., 2003,Speaking Stata: Problems with tables, Part I, 
  *          SJ,3(3):309-324.
  *  Cox,N., 2003,Speaking Stata: Problems with tables, Part II,
  *          SJ,3(4):420-439.
  *  Cox,N., D.City,2007,Stata tip 52: 
  *          Generating composite categorical variables, 
  *          SJ,7(4):582-583. (复杂类别变量的产生)


  
	   
	   
	   
	   
	   

          *     =====================================
          *              计量分析与STATA应用 
          *     =====================================
                    
          *        主讲人：连玉君 博士

          *        单  位：中山大学岭南学院金融系
          *        电  邮: arlionn@163.com
          *        主  页: http://blog.cnfol.com/arlion 

          *               ::第一部分::
          *                Stata 操作
          *         =========================
          *             第二讲  数据处理
          *         =========================
          *         2.10  时间序列资料的处理
		  
  
*--------------------------
*-2.10  时间序列资料的处理 
*--------------------------
  
  *     ==本节目录== 
  
  *     2.10.1  简介
  *         2.10.1.1 声明时间序列：tsset 命令
  *         2.10.1.2 检查是否有断点
  *         2.10.1.3 填充缺漏的日期
  *         2.10.1.4 追加样本
  *     2.10.2 时序变量的生成
  *         2.10.2.1 滞后项、超前项和差分项
  *         2.10.2.2 产生增长率变量: 对数差分
  *         2.10.2.3 日期变量的处理
  
   
*                  =本节命令=  
* ==================================================
*   -tsset-  -tsreport-  -tsappend-  -tsvarlist- 
*   -
* ==================================================



*______________
*-2.10.1  简介

  *-2.10.1.1 声明时间序列：tsset 命令
  
    use gnp96.dta, clear
    list in 1/20
    gen Lgnp = L.gnp   // 错误
	
    tsset date
    list in 1/20
    gen Lgnp = L.gnp
    *-说明：若希望清除时间标示，可采用
      tsset, clear

	  
  *-2.10.1.2 检查是否有断点
  
    use gnp96.dta, clear
    tsset date
    tsreport, report
    drop in 10/10
    list in 1/12
    tsreport, report
    tsreport, report list  // 列出存在断点的样本信息

	
  *-2.10.1.3 填充缺漏的日期
  
    list in 1/12           // 缺少 1969q2
    tsfill                 // 填充之
    tsreport, report list  
    list in 1/12           // 参见 2.4 小节

	
  *-2.10.1.4 追加样本
  
    use gnp96.dta, clear
    tsset date
    list in -10/-1
    sum
    tsappend , add(5)      // 追加5个观察值
    list in -10/-1
    sum

    *-应用：样本外预测
      reg gnp96 L.gnp96
      predict gnp_hat
      list in -10/-1
	  

*_________________________
*-2.10.2 时序变量的生成

  *-2.10.2.1 滞后项、超前项和差分项  
    
    help tsvarlist
    
    use gnp96.dta, clear
    tsset date
	
    gen Lgnp  = L.gnp96   // 一阶滞后
    gen L2gnp = L2.gnp96  // 二阶滞后
    gen Fgnp  = F.gnp96
    gen F2gnp = F2.gnp96
    gen Dgnp  = D.gnp96
    gen D2gnp = D2.gnp96
    list in 1/10
    list in -10/-1


  *-2.10.2.2 产生增长率变量: 对数差分
  
    gen lngnp = ln(gnp96)
    tsset date
    gen growth = D.lngnp 
    gen growth2 = (gnp96-L.gnp96)/L.gnp96
    gen diff = growth - growth2
    list date gnp96 lngnp growth* diff in 1/10
    
    
  *-2.10.2.3 日期变量的处理
  
    help dates_and_times
    
    *- 参见 stata高级视频 B6_TimeS
    *- Also see
    *   Cox, N., D. City, 2006, 
    *     Speaking Stata: Time of day, SJ, 6(1): 124-137.

 
 
 
 
 
	   
	   

          *     =====================================
          *              计量分析与STATA应用 
          *     =====================================
                    
          *        主讲人：连玉君 博士

          *        单  位：中山大学岭南学院金融系
          *        电  邮: arlionn@163.com
          *        主  页: http://blog.cnfol.com/arlion 

          *             ::第一部分::
          *              Stata 操作
          *         ======================
          *            第二讲  数据处理
          *         ======================
          *         2.11 面板资料的处理(I)  
		  
  
*-------------------------
*-2.11  面板资料的处理(I)  
*-------------------------
  
  *     ==本节目录== 
  
  *     2.11.1  声明面板资料：xtset 命令
  *     2.11.2  公司数目和年度的统计  
  *         2.11.2.1 面板资料的基本描述：xtdes 命令
  *         2.11.2.2 记录面板的资料形态：xtpattern 命令
  *         2.11.2.3 统计公司数目：panels 命令
  *     2.11.3  产生连续的公司代码     
  *     2.11.4  处理为平行面板  
  *     2.11.5  剔除IPO当年的数据
  *     2.11.6  行业发生变更的公司

   
   
*                  =本节命令=  
* ==================================================
*   -xtset-  -xtpattern-  -panels-  -xtbalance-
*   -panelthin-  -enlarge-  -paverage-  -center-
* ================================================== 



*__________________________________
*-2.11.1 声明面板资料：xtset 命令 
  
  use xtcs.dta, clear
  browse              // code+year 才能够唯一标示每个观察值
  xtset code year
  xtdes
  gen tl_lag = L.tl   
  
  *-说明：
  *  (1) xtset 与 tsset 等价，但只能用于stata9以上版本
  *  (2) 如何处理错误信息"repeated time values within panel"？
     use xtcs.dta, clear
     replace year=2003 if year==2004   // 伪造一份年度重复的样本
       list code year in 1/30, sepby(code)
     tsset code year                   // 错误
     duplicates report code year       // 查验 code-year 是否能唯一识别样本
     duplicates drop code year, force  // 删除重复样本
     tsset code year                   // 正确
	 xtdes
     

*______________________________
*-2.11.2  公司数目和年度的统计    -xtdes-  -panels-  -xtpattern-

  *-2.11.2.1  面板资料的基本描述：xtdes 命令
    use gta_sample.dta, clear
    tsset id year
    xtdes                   // 默认：仅呈现9种频率最高的形态
    xtdes, patterns(20) 
    xtdes, p(30)
    xtdes if sicmen_str == "C", p(25)  // 制造业
    
  *-2.11.2.2 记录面板的资料形态：xtpattern 命令
    use gta_sample.dta, clear
    tsset id year 
    xtpattern , gen(pp)
    tab pp, sort
    browse id year pp
    *-应用
      drop if year<1999
      xtpattern, gen(pat)
      tab pat, sort
      keep if pat == "1111111111"  // 平行面板的简单处理方式
	  xtdes
    
  *-2.11.2.3  统计公司数目：panels 命令
    use gta_sample.dta, clear
    tsset id year
    panels id 
	
    label list province_lab
    panels id if province==5  // 广东上市公司
    
	tab province              // 以观察值为单位进行统计 
    panels id: tab province   // 以公司为单位进行统计
    
	tabstat size tl roa tobin,   ///
         format(%6.3f) c(s) stat(N mean sd p50 min max)
    panels id: tabstat size tl roa tobin, c(s) stat(N)
	     // 进一步统计每个变量对应的公司数目
    
    
*____________________________
*-2.11.3  产生连续的公司代码    -egen- group()
  
  use xtcs.dta, clear
  xtset code year
  tab code in 1/100            // 公司代码不连续
  egen code_123 = group(code)  // 产生连续编号的公司代码
  list code code_123 year in 1/50, sepby(code)
  
  *-用途：你可以使用forvalues等循环命令针对每家公司进行分析
    xtdes
	gen b = .
	forvalues i=1/438{
	  qui reg tl size tang tobin if code_123==`i'
	  replace b = _b[tobin] in `i'
	}
	gen i = _n
    browse i b in 1/20
	
	
*_________________________
*-2.11.4  处理为平行面板      -xtbalance-

  use gta_sample.dta, clear
  xtdes 
  
  help xtbalance      // Given by Yu-Jun Lian
  
  xtbalance, range(2000 2008)
  xtdes

  *-缺漏值的处理：miss() 选项
    sum id year cflow cash invt tl size
    drop if invt==.
    xtdes
  
    xtbalance, r(2000 2008) miss(cflow cash invt tl size)
    xtdes
    
    *-一次性处理	
    use gta_sample.dta, clear
    keep id year cflow cash invt tl size roa tobin
    xtbalance, r(2000 2008) miss(_all)  
    xtdes
    
     
*___________________________
*-2.11.5  剔除IPO当年的数据

  *-由于缺少公司IPO的年份，本例中假设公司首次有记录的年份即为IPO年度
  
  *-方法1：利用 xtdes 命令的返回值 和 egen 命令的 min() 函数 
     use GTA_sample.dta, clear
       tsset id year
       xtdes
     bysort id: egen Tmin = min(year)
       list id year Tmin in 1/50, sepby(id)
     drop if (year-Tmin==0)
       list id year Tmin in 1/50, sepby(id)
       xtdes
       
  *-方法2：巧妙使用差分运算和 _n     
     use GTA_sample.dta, clear
       tsset id year  
     gen Dyear = D.year
	   list id year Dyear in 700/900, sepby(id)  
     bysort id (year): drop if (Dyear==. & _n==1)
       list id year Dyear in 700/900, sepby(id)        


*_____________________________
*-2.11.6  行业发生变更的公司

    use GTA_sample.dta, clear
    label list sicmen_lab
    
    *-人为生成行业变更数据(因为我们这份数据有局限)
      replace sicmen=4 if (sicmen==5 & year>2006)
      
    *-查找行业发生变更的公司
      qui tsset
      gen sic_dif = D.sicmen   // 若发生变更，则此变量不为零
      bysort id: egen sic_change = sum(sic_dif) 
                               // 统计变更的次数,以公司为单位进行标记
        order id year sicmen sic_dif sic_change
        list id year sicmen sic_dif sic_change if sic_change!=0, sepby(id)

    *-删除行业发生变更的公司
      drop if sic_change != 0  // 若不发生行业变更，则该值不等于0   
      
	   

	   
	   




	   
          *     =====================================
          *              计量分析与STATA应用 
          *     =====================================
                    
          *        主讲人：连玉君 博士

          *        单  位：中山大学岭南学院金融系
          *        电  邮: arlionn@163.com
          *        主  页: http://blog.cnfol.com/arlion 

          *             ::第一部分::
          *              Stata 操作
          *         ======================
          *            第二讲  数据处理
          *         ======================
          *         2.11 面板资料的处理(II)  
  
*-------------------------
*-2.11  面板资料的处理(II)  
*-------------------------
  
  *     ==本节目录== 
            
  *     2.11.7  如何删除面板资料首尾的缺漏值?
  *     2.11.8  仅保留连续 T 年以上可获得资料的公司
  *     2.11.9  面板资料瘦身 I： 每隔 T 年保留一次资料   
  *     2.11.10 面板资料瘦身 II：采用 P 年平均值进行估计   
  *     2.11.11 面板缺漏值的扩充
  *     2.11.12 变量的"去均值"和标准化处理 
  *     2.11.13 面板资料处理的其他主题  
  
  
*________________________________________
*-2.11.7  如何删除面板资料首尾的缺漏值?

    *-数据
      use xtmiss, clear
      list, sepby(id)
    
    *-问题：只删除首尾的缺漏值，中间的不删(可以采取其他方法插值)
    
    *-S1: 删除"首部"缺漏值
      bysort id (year): drop if sum(mi(x))==_n
      list, sepby(id)
      
      *-解析
        use xtmiss, clear
        bysort id (year): gen n123 = _n
        gen miss = mi(x)
        bysort id: gen summis = sum(miss)  // 注意：是 gen，而不是 egen
        list, sepby(id)
        drop if n123==summis
        list
  
    *-S2: 删除"尾部"缺漏值
      use xtmiss, clear
      gen nyear = -year
      list, sepby(id)
      bysort id (nyear): drop if sum(mi(x))==_n
      list, sepby(id)
      tsset id year
      list, sepby(id)
      
    *-汇总：
      use xtmiss, clear
      bysort id (year): drop if sum(mi(x))==_n
      gsort id -year    // 注意此行和下一行的变化
      bysort id: drop if sum(mi(x))==_n 
      qui tsset id year
      list, sepby(id)
    
    *-egen 命令提供了更为直接的解决办法
      use xtmiss, clear
      by id, sort: egen firstnonmis = min(cond(!missing(x), year, .))
      by id:       egen lastnonmis  = max(cond(!missing(x), year, .))
      drop if (year<firstnonmis) | (year>lastnonmis)
      list, sepby(id)
      
      *-解析
        help cond()
        * cond(x, a, b)
        *   若 x=true,  返回 a；
        *   若 x=false, 返回 b；
            dis cond(1, 5, -5)
            dis cond(0, 5, -5)
        * !missing(x)
        *   若 x != ., 返回 1
        *   若 x == ., 返回 0
            dis !missing(.)
            dis !missing(9)
      
	  *-回顾
        use xtmiss, clear
        by id, sort: gen condyear = cond(!missing(x), year, .)
		list, sepby(id)
		by id, sort: egen firstnonmis = min(condyear)
		by id, sort: egen lastnonmis  = max(condyear)
		list, sepby(id)
        drop if (year<firstnonmis) | (year>lastnonmis)
        list, sepby(id)			
 
 
 
*_____________________________________________
*-2.11.8  仅保留连续 T 年以上可获得资料的公司

  *-问题：在有些分析中，需要差分处理，或需要考察公司行为的延续性
  *       此时便需要筛选出连续多年有观察值的公司
  
  *-示例：保留连续六年有样本的公司
  
    use gta_sample.dta, clear
    keep id year tl cash tobin size
    drop if tl>1
    tsset id year
    xtdes 
    xtpattern, gen(pp)          // 记录每家公司的样本形态
    tab pp
    *browse
    
    gen p6 = strpos(pp, "111111")   //strpos寻找"111111"在pp变量中的位置
    sort p6
    *browse
    drop if p6==0               // 仅保留连续六年有资料的公司
    tab pp
    save xtcontinue_temp, replace
    
    *-如何执行如下两种处理方式：
    * Q1：如何删除所有"退市"或部分年度资料缺失的公司？
    *     即 "....1111111........" 或 "....11111111..11111"
    * Q2：如何删除某个间断年份以后的所有数据？
    *     即 "....11111111..11111" --> "....11111111......."
    *     或 "...1111111111111.1." --> "...1111111111111..."
    * 注：后一种方式有助于保留尽可能多的样本
    
    *-S1：去掉"退市"或部分年度资料缺失的公司
      use xtcontinue_temp, clear
      xtdes      // 140 家
      tab pp
      gen pbreak1 = strpos(pp,"1.")
      order id year pp p6 pbreak1
      browse
      drop if pbreak>0
      tab pp, sort
      xtdes       // 123 家
      *-说明：亦可采用 strmatch()，indexnot() 函数完成上述处理 
          
    *-S2: 如何删除某个间断年份以后的所有数据
      use xtcontinue_temp, clear
      tab pp
      *-简化数据(便于解释而已)
      keep if   pp=="........11111111..1"  ///
              | pp=="...1111111111111.1."  ///
              | pp=="......1111111111.11"  ///
              | pp==".111111111111111111"
      keep id year pp
      qui tsset id year
      gen Dyear = D.year
      order id year Dyear
      list, sepby(id)     // 第一年的缺漏值并非真正的"间断"
      bysort id (year): replace Dyear=1 if _n==1
      list, sepby(id) 
      bysort id: egen firstyear_mis = min(cond(missing(Dyear), year, .))
      bysort id: drop if year>=firstyear_mis
      xtdes
      
      *--------------------------------------------------------------
      *-练习1：你可以把 keep 开头的那两条语句删除后对样本整体进行处理   

      *--------------------------------------------------------------            
      *-练习2：使用 gta_sample.dta 样本，要求处理后的数据符合如下条件：
      *  (1) 样本是连续的
      *  (2) 删除负债率大于1的观察值
      *  (3) 可以是非平行面板，但时间跨度至少是 2003-2008 年 
      
      *-解答方案 -I-
        use gta_sample.dta, clear
        tsset id year
        drop if tl>1        // 满足第二个条件
        drop if year<1997   // 初步满足第三个条件
        xtpattern , gen(pp)
           tab pp
        gen Dyear = D.year
        bysort id: replace Dyear=1 if _n==1
        bysort id: egen miss = max(cond(Dyear==.), 1, 0)  
                   // 若某家公司存在断点，则miss变量的所有年度都标示为1
        drop if miss==1
           tab pp
        bysort id: egen Tmin = min(year)   // 每家公司的最小年份
        bysort id: egen Tmax = max(year)   // 每家公司的最大年份
        drop if Tmin>2003   // 满足第四个条件
        drop if Tmax<2008   // 满足第三、四个条件
		xtdes
     
     *-解答方案 -II-   
     *-思路：统计每个公司的最大年度和最小年度之差，
     *       然后计算该公司共有多少年的观察值，
     *       若二者不一致，则剔除该公司
       use gta_sample.dta, clear
       tsset id year
       drop if tl>1
       drop if year<1997
       xtpattern , gen(pp)
       cap dropvars Tmin Tmax Tsum Tdif Tmis
       bysort id: egen Tmin = min(year)
       gen Tmax = 2008
       bysort id: egen Tsum = count(year)  
	                           // 统计每家公司实际有多少年的观察值
       gen Tdif = Tmax-Tmin+1  // 若样本连续，应该有这么多年的观察值  
       gen Tmis = Tsum-Tdif
       drop if Tmis != 0       // 删除样本不连续的公司
       drop if Tmin>2003       // 删除2003年以后上市的公司
       order id year pp Tmin Tmax Tsum Tdif Tmis
       tab pp
      *--------------------------------------------------------------    
    


*_______________________________________________
*-2.11.9 面板资料瘦身 I：每隔 T 年保留一次资料      -panelthin-

  *-目的：若我们想考察某些变量的长期变化，
  *       需要拉长时间间隔来分析
                
  *-基本用法
    use GTA_sample.dta, clear
    tsset id year
    xtdes
    list id year in 1/50, sepby(id) 
    panelthin, min(3) gen(OK)     // 每隔 3 年保留一次资料 
    xtdes if OK, p(30)
    list id year OK in 1/50, sepby(id)
    list id year if OK in 1/50, sepby(id)
   
  *-示例：现金持有权衡理论的检验
    use GTA_sample.dta, clear
    tsset id year  
    xtabond cash size tang roa tobin  // 动态面板
    est store m_0
    panelthin, min(2) gen(OK)          // 每隔两年瘦身一次
    xtabond cash size tang roa tobin if OK
    est store m_thin
    esttab m_0 m_thin, mtitle(m_0 m_thin) stat(N) // 结果对比
    *-解释和评述：
    * (1) 记 L.cash 的系数为 b，则 (1-b) 表示"调整速度"；
    * (2) 本例结果表明，若以一个年度为考察单位，则调整速度为 0.453
    *     若以两个年度为考察单位，则调整速度为 0.809
    *     这意味着，当时间跨度较长时，公司有能力向目标值调整
    *     从本例来看，公司基本上可以在两个会计年度内完成调整。
    * (3) 这种处理方法在日资料和月度资料中更为常用：
    *     对于日资料，min(5) 可能比较常用
    *     对于月资料，min(3) 或 min(5) 会比较常用
          


*__________________________________________________
*-2.11.10 面板资料瘦身 II：采用 P 年平均值进行估计   -paverage-

  *-目的：克服经济周期和衡量偏误的影响 
  *-适用于平行面板资料
  
  *-基本用法：
    use xtcs, clear
    drop if year==1998
    xtdes    // 平行面板
    paverage tl-tobin, p(2) ind(code) yr(year)
    xtdes
    
    
  *-示例：两种处理方式结果的对比  
     use GTA_sample.dta, clear
     tsset id year 
    
    *-仅保留待分析的变量
      keep id year tl tang roa tobin
       
    *-删除缺漏值并处理为平行面板
      xtbalance, range(1999 2008) miss(tl tang roa tobin)
      xtreg tl tang roa tobin, fe
      est store m_0
      
    *-计算 2 年平均值，并估计
      preserve
        paverage tl tang roa tobin, p(2) ind(id) yr(year)
        xtreg tl tang roa tobin, fe
        est store m_av2
      restore
      
    *-计算 5 年平均值，并估计
      preserve
        paverage tl tang roa tobin, p(5) ind(id) yr(year)
        xtreg tl tang roa tobin, fe
        est store m_av5
      restore      
      
    *-结果对比
      esttab m_0 m_av2 m_av5,    ///
	         mtitle(m_0 m_av2 m_av5) stat(N r2_w r2_o)
  
  

*___________________________
*-2.11.11  面板缺漏值的扩充

  *-问题 I ：
    *-如何生成一个新变量：只要这家公司曾经发放过至少一次股利就标记为 1
      use GTA_sample.dta, clear
      tsset id year 
      list id year div_yes in 100/130, sepby(id)
  
    *-思路：若某家公司曾经发放过股利，则该公司的 div_yes 均值不为零
      bysort id: egen div_mean = mean(div_yes)
      gen div_s = 0
      replace div_s = 1 if div_mean != 0
      list id year div_yes div_s in 100/130, sepby(id)
      
      
  *-问题 II ：
    *-假设我们只有2005年的行业分类数据，
    *     如何扩充以便各个年度都共享这一信息？
    *-假设所有公司的行业归属在样本区间内不发生变更
    
    *-S1：伪造一份数据
      use GTA_sample.dta, clear
      tsset id year
      drop if year<2000
      keep id year sicda
      replace sicda = . if year!=2005
      list in 1/100, sepby(id)
      clonevar sicda_s1 = sicda  // 克隆两份，以备后用
      clonevar sicda_s2 = sicda
      
    *-S2：思路：我们可以对这个唯一数据随意排序
      sort id sicda_s1
         list in 1/70, sepby(id)
      bysort id: replace sicda_s1 = sicda_s1[1] if _n>1
         list in 1/70, sepby(id)
      
    *-S3：简洁命令 -enlarge-
      enlarge sicda_s2, by(id)
         list in 1/70, sepby(id)
      

*______________________________________
*-2.11.12  变量的"去均值"和标准化处理 

   help center  // 外部命令
   use xtcs.dta, clear
   bysort code: center tl fr size ndts tang tobin, prefix(c_)
   
   *-应用：估计FE模型
     reg c_tl c_fr-c_tobin
       est store ols_fe
     xtreg tl fr size ndts tang tobin, fe
       est store fe
       esttab ols_fe fe, nogap compress

   *-说明：该命令尚可进行标准化和quasi-demeaning处理，请查阅帮助文件
	  
	  
*_________________________________
*-2.11.13  面板资料处理的其他主题

  *-[s1] How can I identify first and last occurrences 
  *      systematically in panel data? 
  *  http://www.stata.com/support/faqs/data/firstoccur.html
  *-[s2] How can I generate a variable relating panel data 
  *      to a reference panel? 
  *  http://www.stata.com/support/faqs/stat/panelref.html


 
	   
	   
	   
	   
	   
	   

          *     =====================================
          *              计量分析与STATA应用 
          *     =====================================
                    
          *        主讲人：连玉君 博士

          *        单  位：中山大学岭南学院金融系
          *        电  邮: arlionn@163.com
          *        主  页: http://blog.cnfol.com/arlion 

          *             ::第一部分::
          *              Stata 操作
          *         ======================
          *            第二讲  数据处理
          *         ======================
          *         2.12 数据的查验和比较
		  
   cd `c(sysdir_personal)'Net_course_A\A2_data 
   
*----------------------
*-2.12 数据的查验和比较
*----------------------
  
  *     ==本节目录== 
  
  *     2.12.1 查验变量
  *         2.12.1.1 计数  
  *         2.12.1.2 条件确认   
  *         2.12.1.3 比较变量的大小
  *     2.12.2 查验两组数据  
  *         2.12.2.1 查验两笔数据的观察值是否一致 
  *         2.12.2.2 查验两笔数据的变量是否一致   

  
*                  =本节命令=  
* ==================================================
*   -assert-  -count-  -compare-  -cf-  -cfvar-
* ================================================== 


*___________________
*-2.12.1 查验变量        -assert-  -count-  -compare-


  *-2.12.1.1 计数               -count-
  
    sysuse nlsw88, clear
    count if (hours<10 | hours>70)
    count if race >=2
    count if hours == .
      list wage race if hours == .
	  

  *-2.12.1.2 条件确认          -assert-

    sysuse nlsw88, clear
	sum wage age
    assert  wage>0
    assert  wage<0
    assert  wage<20
	  count if wage<20
    assert  age<40
	  count if age<40
    assert  (hours<10 | hours>70)
	  count (hours<10 | hours>70)
      list hours if (hours<10 | hours>70)


  *-2.12.1.3 比较变量的大小      -compare-

    sysuse sp500.dta, clear
    compare open close


	
*______________________
*-2.12.2 查验两组数据  
	

  *-2.12.2.1 查验两笔数据的观察值是否一致  -cf- 

  clear
  input id str8 name  age ht  wt income
        11      john  23  68 145 23000
        12   charlie  25  72 178 45000
        13     sally  21  64 135 12000
        4       mike  34  70 156  5600
        43      paul  30  73 189 15600
  end
  sort id
  save person1, replace

  clear
  input id str8 name  age ht  wt income
        11      john  28  68 145 23000
        12   charles  25  52 178 45000
        13     sally  21  64  .  12000
        4     michael 34  70 156  5600
        43       Paul 30  73 189  5600
  end
  sort id
  save person2, replace
  
  use person1, clear
  cf _all using person2
  cf _all using person2, verbose      // 详细呈现
  cf _all using person2, verbose all  // 列出所有不一致的cases
  

  *-2.12.2.2 查验两笔数据的变量是否一致     -cfvars-  
  
    sysuse xtcs, clear
    drop tl
    cfvars xtcs.dta
    ret list


	
	
	
	