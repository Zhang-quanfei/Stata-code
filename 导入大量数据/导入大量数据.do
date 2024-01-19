
*一个股周回报率  (local 生成暂元，循环foreach  读取变量；)  //读取多个文件,很重要
import excel "D:\Stata14\examples\地级市宏观数据\地级市气候数据(平均温度、降水量、日照时数、相对湿度等指标)\气象数据集合_(具体到天)\2012-2016\天气-2012_1.xlsx", sheet("sheet") firstrow clear

 save temp,replace 

    cd  "D:\Stata14\examples\地级市宏观数据\地级市气候数据(平均温度、降水量、日照时数、相对湿度等指标)\气象数据集合_(具体到天)\2012-2016\
 
 
   local files: dir "." file "*.xlsx"    //*把所有文件夹下所有扩展名为 xls 的文件名存进 local files 里  ,"." 本级目录
  
  cd d:\stata14\examples

   
 foreach file in `files'{
   
    
  import excel using D:\Stata14\examples\地级市宏观数据\地级市气候数据(平均温度、降水量、日照时数、相对湿度等指标)\气象数据集合_(具体到天)\2012-2016\\`file',   ///
      sheet(`r(worksheet_1)')   ///
      cellrange(`r(range_1)')    ///
       clear firstrow  allstring
       
  append using temp,force   //(append  纵向合并)
      
  save temp,replace
              
   
         }
  
duplicates drop Stkcd Trdwnt,force

drop in 1/2

