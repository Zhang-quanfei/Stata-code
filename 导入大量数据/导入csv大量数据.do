
*一个股周回报率  (local 生成暂元，循环foreach  读取变量；)  //读取多个文件,很重要
import delimited using "D:\Stata14\examples\2001-2022年逐日平均气温\【2001年】逐日平均气温.csv",clear encoding(gbk)
 save temp,replace 

    cd D:\Stata14\examples\2001-2022年逐日平均气温\   
 
   local files: dir "." file "*.csv"    //*把所有文件夹下所有扩展名为 xls 的文件名存进 local files 里  ,"." 本级目录
  
  cd d:\Stata14\examples

   
 foreach file in `files'{
   
    dis "`file'"
  import delimited using D:\Stata14\examples\2001-2022年逐日平均气温\\`file',clear encoding(gbk)
  append using temp,force   //(append  纵向合并)
      
  save temp,replace
              
   
         }
  
duplicates drop Stkcd Trdwnt,force

drop in 1/2

