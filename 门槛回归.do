xthreg y c1 c2 c3 c4,rx(x1) qx(x2) thnum(1) bs(300) trim(0.01) grid(100) r
/*

其中，y表示被解释变量，
c1-c4表示核心解释变量，
qx表示门槛变量，
thnum表示门槛个数，
bs表示自举次数（理论上越多越好，但是考虑到效率，一般设置成300以上）
trim表示门槛分组内异常值去除比例（一般选0.01或0.05），
grid表示样本网格计算的网格数（一般设置成100或300），
r表示用聚类稳健标准误。

1.单一门槛
xthreg y c1 c2 ,rx(x1) qx(x2) thnum(1) bs(300) trim(0.01) grid(100) r


2.双门槛
xthreg y c1 c2 ,rx(x1) qx(x2) thnum(2) bs(300 300) trim(0.01 0.01) grid(100) r

3.三门槛
xthreg y c1 c2 ,rx(x1) qx(x2) thnum(2) bs(300 300 300) trim(0.01 0.01 0.01) grid(100) r

*/
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
