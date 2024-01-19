*先把文件转移到stata14默认文件夹 example
clear
unicode encoding set gb18030
unicode analyze 2014_1.dta   //2014_1.dta是文件名
unicode translate 2014_1.dta,invalid



*强制转换
clear         // 转码前务必先清空内存，否则会提示错误信息
 *cd "D:\data"  // 待转换数据所在文件夹, 请务必事先备份一份数据
unicode retranslate 2014_1.dta, invalid(ignore) transutf8 nodata replace
