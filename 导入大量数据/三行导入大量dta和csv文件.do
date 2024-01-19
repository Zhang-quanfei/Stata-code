
*---------
*一次导入  ----比较适合dta和csv文件
*---------
cd "D:\Stata14\examples\1-原始数据\工业企业与专利匹配结果1998-2014\专利\"
openall *  .dta        //默认dta文件  指定.csv
cd d:\stata14\examples
save  temp,replace
