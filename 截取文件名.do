 *-------------
 *---截取文件名    gettoken函数
 *-------------
 cd D:\Stata14\examples\1-原始数据\工业企业与专利匹配结果1998-2014\专利\ 
 
   local files: dir "." file "*.dta"    //*把所有文件夹下所有扩展名为 dta 的文件名存进 local files 里  ,"." 本级目录
  
  cd D:\Stata14\examples

   gettoken x  y :files,parse(" ")     // 将files的文件名按照空格（parse(" ")的作用）为切割点，分成两部分，空格之前的存入暂元x，空格之后存入y
    dis 	"`x'"    //第一个文件的名称
	
	dis  `"`y'"'   //第二个文件的名称
   
 foreach file in `files'{
   
	gettoken x  y :file,parse(".")    
    
 dis 	`x'
   
         }
		 