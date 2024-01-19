/*
一、命令介绍
	tuples 命令的主要作用是从给定列表集合中抽取所有的真子集。例如，我们可以通过命令语句 tuples A 	B，来分别抽取集合 {A,B} 中的子集，抽取结果分别是{A} 、{B}、{A,B}。单从这里看来，或许会觉得 tuples 命令有些鸡肋，但当我们利用 tuples 命令从众多控制变量中筛选出我们满意的组合时，就能够解锁 tuples 的进阶用法了。
	
二、接着，我们介绍下如何利用 tuples 命令来筛选控制变量，以使得主要解释变量显著。具体思路如下：
	1.控制变量子集：利用 tuples 命令先返回全部控制变量的真子集；
	2.逐个回归：依次利用这些真子集作为控制变量进行回归，返回 X 对应的 t 值 (命名为 t0fIndX)；
	3.计算 t 值：通过模型的自由度 (degreeOfFreedom) 以及给定的显著性水平 (significance)，确定 t 分布下使  X显著的 t 值 (命名为 tValue)；
	4.筛选出显著的变量集：当 t0fIndX > tValue 时，则该控制变量组能够很好地保证主要解释变量 X 是显著的。
 */
 * 设定显著性水平
 global significance 001

 * 设定变量
 global dependentVariable "DigitalTransformation"    // 设置被解释变量
 global independentVariable "ldegree_m" // 设置解释变量
 global controlVariables "jlr 人均创收 人均创利 lasset lyysr ltobin llabor merge cash_rate net_syl  mgsy ind"  // 设置控制变量

 * 以下不用修改
 gen degreeOfFreedom = .
 gen tValue = .
 gen bOfIndX = .
 gen seOfIndX = .
 gen tOfIndX = .
 gen rSq = .
 gen controlVariableSet = ""
 tuples $controlVariables
 forvalues i = 1/`ntuples' {
       reghdfe $dependentVariable $independentVariable `tuple`i'', absorb(id  i.cid##c.year) clu(id)
	   replace bOfIndX = _b[$independentVariable] in `i'
       replace seOfIndX = _se[$independentVariable] in `i'
       replace tOfIndX = bOfIndX / seOfIndX in `i'
       replace degreeOfFreedom = e(df_r) in `i'        
       replace tValue = invttail(degreeOfFreedom, $significance) in `i'
       replace rSq = e(r2) in `i'
       replace controlVariableSet = "`tuple`i''" in `i'
  }
 
 preserve
     replace tOfIndX = abs(tOfIndX)
     replace tValue = abs(tValue)
     keep if tOfIndX > tValue
     gen controlVariableNumbers = wordcount(controlVariableSet) if controlVariableSet != ""
     sort controlVariableNumbers rSq
     keep if rSq != .
     list controlVariableSet tOfIndX tValue rSq
 restore

 /*
	controlVariableSet    tOfIndX     tValue        rSq
 
	controlVariableSet 第一列是控制变量的组合；
	tOfIndX 第二列是回归中主要解释变量 weight 所对应的 t 值；
	tValue 第三列是通过 invttail 的方式计算出来的 t 值；
	rSq 第四列是模型的 R2。

*/