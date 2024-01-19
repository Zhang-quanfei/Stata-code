use 005-核算燃气.dta,clear
		bys adress year:egen x_dco2 = mean(DCO2)
		duplicates drop adress year ,force
		
		keep adress year dum_ta x_dco2    birth 
		*reshape wide t ,i(adress)j(year)
		panelview so2 dum_ta,i( cid ) t(year) type(treat) xtitle("时间") ytitle("地区") title("处理状态") prepost 
		*补充平衡面板
		xtset adress year
		tsset adress year   //生成面板数据 id面板变量，year时间变量
		tsfill,full
		replace x_dco2 = 0 if x_dco2 == .  //补充缺失值，为0
		*培根分解
		
		bacondecomp x_dco2 dum_ta,stub(b_) ddetail 
		mat list e(sumdd)  //mat list 表示列示矩阵，培根分解的详细效应和结果都储存在e(sumdd)
		input str12 group float Beta float TotalWeight
		Early_v_Late   -.35806471    .00102952
		Late_v_Early   -8.3744764    .00117206
		Early_v_Late    2.1781926    .00234425
		Late_v_Early   -14.084171    .00216978
		Early_v_Late    .36807036    .00315021
		Late_v_Early   -3.0370705    .00259216
		Early_v_Late    2.4705992    .00278397
		Late_v_Early   -8.3673344    .00198484
		Early_v_Late    .01396965    .00487418
		Late_v_Early    3.8517482    .00324122
		Early_v_Late    9.2696514    .00326817
		Late_v_Early    22.464857    .00186232
		Early_v_Late   -3.8042572    .00480719
		Late_v_Early   -3.3772058     .0026241
		Early_v_Late   -7.3515677    .00978322
		Late_v_Early    8.7073755    .00489129
		Early_v_Late   -4.2019033    .00846291
		Late_v_Early    18.895653    .00363802
		Early_v_Late   -7.6535997    .00391115
		Late_v_Early   -.31517944    .00147688
		Early_v_Late      5.88797    .00467137
		Late_v_Early   -8.4096432    .00171033
		Early_v_Late     1.397657    .01013903
		Late_v_Early    .17021474    .00340887
		Early_v_Late    3.6124816    .01007771
		Late_v_Early    12.295782    .00292868
		Early_v_Late    15.129292    .00622657
		Late_v_Early    6.5459962    .00159409
		Early_v_Late     17.32324     .0046211
		Late_v_Early    2.3496194    .00104612
		Early_v_Late     .0035724    .01284486
		Late_v_Early    3.7920692    .00236066
		Early_v_Late   -7.7341619    .02955974
		Late_v_Early    8.4497166    .00496189
		Early_v_Late   -9.0697441    .03094809
		Late_v_Early    18.119228    .00442947
		Early_v_Late    -.9685657    .02130772
		Late_v_Early    7.8560729    .00267245
		Early_v_Late    3.3937552    .02099853
		Late_v_Early    2.9659023    .00233839
		Early_v_Late   -14.154434    .00936511
		Late_v_Early   -1.9242185    .00094649
		Always_v_timing   -24.258046     .0297251
		Never_v_timing   -6.4006815    .71105017
		end
		
		*加总效应和权重
		gen b_w = Beta*TotalWeight
		bysort group: egen b_wsum = sum(b_w)
		bysort group: egen wsum = sum(TotalWeight)
		
		duplicates drop group,force
		edit group b_wsum wsum
