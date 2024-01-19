*-----------
*-绘制散点图
*-----------	
		*superscatter 命令安装：
		ssc install binscatterhist,   replace
		net install superscatter, from(http://digital.cgdev.org/doc/stata/MO/Misc)
		net install gr0002_3, from(http://www.stata-journal.com/software/sj4-3)  // 纯黑白风格, lean1, lean2 模板
		*语法
		use auto,clear
		superscatter price weight, percent color()   fittype(lfitci) fitoptions(lwidth(thick)) legend(ring(0)  cols(1) pos(5)) name(_example1, replace) title(Example 1)  //percent可以改成Kdensity