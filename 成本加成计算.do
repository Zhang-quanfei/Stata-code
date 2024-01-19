*---------------企业成本加成的计算----------------
//help markupest此条命令可以直接计算markupest,注意命令作者的使用，lnY与lnVA的区别
//https://www.statalist.org/forums/forum/general-stata-discussion/general/1568791-new-on-ssc-markupest-module-for-markup-estimation
markupest mkupy_x, method(dlw) output(lnY) inputvar(lnL) free(lnL) state(lnK) proxy(lnM) prodestopt("poly(3) acf trans va") corrected verbose
