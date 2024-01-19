* (1) 东部和中西部（以下城市为东部）
		gen east =pname ==  "辽宁省" |  pname ==  "北京市" | pname == "天津市" | pname == "上海市" | pname ///
	== "河北省" | pname == "山东省" | pname == "江苏省" | pname == "浙江省" | pname == "福建省" | pname ==  ///
	"广东省" | pname == "广西壮族自治区" | pname == "海南省"



*（2）高等级和低等级

		*高等级包括省会城市、副省级城市、计划单列市、直辖市

		gen gdj= cname=="石家庄市" | cname=="沈阳市" | cname=="哈尔滨市" | cname=="杭州市" | cname=="福州市"| ///
		cname=="济南市" | cname=="广州市" | cname=="武汉市" |cname=="成都市" | cname=="昆明市" |cname=="兰州市" |cname=="台北市"| ///
		cname=="南宁市"  |cname=="银川市" |cname=="太原市" |cname=="长春市" | cname=="南京市" |cname=="合肥市"| ///
		cname=="南昌市" |cname=="郑州市" | cname=="长沙市" |cname=="海口市" |cname=="贵阳市" |cname=="西安市" |cname=="西宁市" | cname=="呼和浩特市"| ///
		cname=="拉萨市" | cname=="乌鲁木齐市" | cname=="大连市" | cname=="青岛市" | cname=="宁波市"   /// 
		| cname == "厦门市" | cname=="深圳市" |rank=="直辖市"
		
		
* (3)轻工业和重工业

		gen zgy = ind2==6 | ind2==7 | ind2==8 |ind2==9 |ind2==10 | ind2==11 | ind2==12 | ///
	ind2==25 | ind2==29 | ind2==32 | ind2==33 | ind2==35 | ind2==43 | ind2==44 | ind2==45 | ind2==20 | ///
	ind2==26 | ind2==30 | ind2==31 | ind2==34 | ind2==36 | ind2==37 | ind2==39 | ind2==40 | ind2==41 | ind2==46   //重工业
	
*（4）国有和非国有
    g_control==1  //表示国有企业
	
	
	
* （5）资本密集和劳动密集

	gen qiye = 固定资产原价合计/labor  // 资本/劳动
	bys adress ind2   : egen mean = mean(qiye) //分县区行业求均值
	bys  id_n : egen jz = mean(qiye)       //求企业均值
	gen zbmj = jz>mean
	
	
* （6）省会和非省会

	gen shcs= cname=="石家庄市" | cname=="沈阳市" | cname=="哈尔滨市" | cname=="杭州市" | cname=="福州市"| ///
		cname=="济南市" | cname=="广州市" | cname=="武汉市" |cname=="成都市" | cname=="昆明市" |cname=="兰州市" |cname=="台北市"| ///
		cname=="南宁市"  |cname=="银川市" |cname=="太原市" |cname=="长春市" | cname=="南京市" |cname=="合肥市"| ///
		cname=="南昌市" |cname=="郑州市" | cname=="长沙市" |cname=="海口市" |cname=="贵阳市" |cname=="西安市" |cname=="西宁市" | cname=="呼和浩特市"| ///
		cname=="拉萨市" | cname=="乌鲁木齐市"
