*生成平衡面板数据
tsset id year   //生成面板数据 id面板变量，year时间变量
tsfill,full  //full 表示，寻找数据中时间最小的（00）和最大的（19），自动补充00-19的年份  ///
              //没有full则补充，每一个id对应最小最大年份之间的年份
mvencode _all,mv(0)  //补充缺失值，为0

bys id:fillmissing 变量名称,with(any) //以组内未缺失值，补充缺失值
