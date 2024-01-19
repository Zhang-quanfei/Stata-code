
import excel "D:\Stata14\examples\地级市宏观数据\土地出让2009-2013\2009.xlsx", sheet("Sheet2") firstrow clear

 save temp,replace 

    cd D:\Stata14\examples\地级市宏观数据\土地出让2009-2013\   
 
   local files: dir "." file "*.xlsx"    //*把所有文件夹下所有扩展名为 xls 的文件名存进 local files 里  ,"." 本级目录
  
  cd d:\stata14\examples

   
 foreach file in `files'{
   
  import excel using D:\Stata14\examples\地级市宏观数据\土地出让2009-2013\\`file', describe
    
  import excel using D:\Stata14\examples\地级市宏观数据\土地出让2009-2013\\`file',   ///
      sheet(`r(worksheet_2)')   ///
      cellrange(`r(range_2)')    ///
       clear firstrow  allstring
       
  append using temp,force   //(append  纵向合并)
      
  save temp,replace
              
         }
