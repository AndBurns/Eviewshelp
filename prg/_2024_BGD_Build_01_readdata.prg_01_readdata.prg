
'***************************************************
' CREATE AN EMPTY WORKFILE AND MODEL
'***************************************************
%begin_temp = @str(@val(%begin_date)-1)
wfcreate a %begin_temp %forecast_end
model {%model}

'***************************************************
' DATA IMPORT
'***************************************************
	'Read data from Excel File
	cd %extractpath
	for %SHEET bgddataforupdate external commodities
		read(t=xls,B1,s={%SHEET},t) {%datafile} 400
		logmsg ***********read data {%SHEET} done
	next
 
'Delete series variables created on blank and date lines by EViews import
	delete ser*

'Delete variables imported that we dont want (these are simply section names - no actual data)
	delete(noerr) balance_of_payments__millions_of_current_usd_   balance_of_payments_capital_flows__millions_of_current_usd_  consumer_price_index  gdp__nominal__usd_ gdp_expenditure_side_values__millions_of_current_lcu_ gdp_expenditure_side_volume__millions_of_constant_lcu_ gdp_production_side_values__millions_of_current_lcu_ gdp_production_side_volume__millions_of_constant_lcu_ government_financing__millions_of_current_lcu_ imports__volume_ fiscal_accounts__millions_of_current_lcu_ external_variables exchange_rate public_debt__millions_of_current_lcu_ lcu_usd_exchange_rate labor_market money_market population 

	pagestruct(start=%begin_date)

'***************************************************
' CONSTRUCT ADDITIONAL VARIABLES
'***************************************************
	smpl @all
'********************
'Create dummies
'********************
	series DUMH = 1
	series T_LR = @TREND

'********************
'Wage bill share in potential GDP
'********************
	series BGDNYYWBTOTLCN_ = !labshare
	
'********************
'Capital stock depreciation rate
'********************
	smpl @all
	series BGDDEPR = !depreciation

'********************
'NIA
'********************
	'GDP definitions and USD
		series BGDNYGDPMKTPCD  = BGDNYGDPMKTPCN  / BGDPANUSATLS
		series BGDGDPPCKN  = (BGDNYGDPMKTPKN  / BGDSPPOPTOTL)
		series BGDNYGDPMKTPKD  = (BGDNYGDPMKTPKN  * (@ELEM(BGDNYGDPMKTPCN  , !base_year )  / (@ELEM(BGDNYGDPMKTPKN  , !base_year ))))  / @ELEM(BGDPANUSATLS  , !base_year)
		series BGDGDPPCKD  = (BGDNYGDPMKTPKD  / BGDSPPOPTOTL)
		series BGDNYGDPMKTPXD  = (BGDNYGDPMKTPCD  / BGDNYGDPMKTPKD)
	'Trade in USD
		series BGDNEEXPGNFSCD  = BGDNEEXPGNFSCN  / BGDPANUSATLS
		series BGDNEIMPGNFSCD  = BGDNEIMPGNFSCN  / BGDPANUSATLS
		series BGDNEEXPGNFSKD  = (BGDNEEXPGNFSKN  * (@ELEM(BGDNEEXPGNFSCN  , !base_year )  / (@ELEM(BGDNEEXPGNFSKN  , !base_year))))  / @ELEM(BGDPANUSATLS  , !base_year)
		series BGDNEIMPGNFSKD  = (BGDNEIMPGNFSKN  * (@ELEM(BGDNEIMPGNFSCN  , !base_year )  / (@ELEM(BGDNEIMPGNFSKN  , !base_year))))  / @ELEM(BGDPANUSATLS  , !base_year)
		series BGDNEEXPGNFSXD  = (BGDNEEXPGNFSCD  / BGDNEEXPGNFSKD)
		series BGDNEIMPGNFSXD  = (BGDNEIMPGNFSCD  / BGDNEIMPGNFSKD)
	'GDP Discrepancy
		series  BGDNYGDPDISCCN = BGDNYGDPMKTPCN  - (BGDNECONPRVTCN  + BGDNECONGOVTCN  + BGDNEGDIFTOTCN  + BGDNEGDISTKBCN + BGDNEEXPGNFSCN - BGDNEIMPGNFSCN)
		series  BGDNYGDPDISCKN = BGDNYGDPMKTPKN  - (BGDNECONPRVTKN  + BGDNECONGOVTKN  + BGDNEGDIFTOTKN  + BGDNEGDISTKBKN + BGDNEEXPGNFSKN - BGDNEIMPGNFSKN)
	'Domestic demand
		series BGDNEGDETTOTKN  = (BGDNECONPRVTKN  + BGDNECONGOVTKN  + BGDNEGDIFTOTKN  + BGDNEGDISTKBKN  + BGDNYGDPDISCKN)
		series BGDNEGDETTOTCN  = (BGDNECONPRVTCN  + BGDNECONGOVTCN  + BGDNEGDIFTOTCN  + BGDNEGDISTKBCN  + BGDNYGDPDISCCN)
		series BGDNEGDETTOTCD  = BGDNEGDETTOTCN  / BGDPANUSATLS
	

'********************
'Deflators
'********************
	for %b NYGDPMKTP NECONPRVT NECONGOVT NEGDIFTOT NEGDIFGOV NEGDIFPRV NEGDISTKB NEEXPGNFS NEIMPGNFS NYGDPFCST NVAGRTOTL NVINDTOTL NVSRVTOTL NEGDETTOT 
		series BGD{%b}XN = BGD{%b}CN/BGD{%b}KN
	next

	'New producer price data the same as GVA deflator but will be treated different in the modelling period
	series BGDNYGDPCPSHXN = BGDNYGDPFCSTXN
	
'********************
'Inflation expectation
'********************	
	pagestruct(end=%forecast_end)
	series tempinfl = @PC(BGDNYGDPFCSTXN)
	smpl %end_date+1 %forecast_end
		tempinfl =  !inflexpt 
	smpl @all
		tempinfl.hpf(100) tempinfl_sm
		series BGDINFLEXPT = tempinfl_sm
	'use 5.5 after looking at results from HP filter
	smpl 2020 %forecast_end
		BGDINFLEXPT = !inflexpt 
	smpl @all
	
'********************
' External proxies
'********************
	for %c BGD USA DEU GBR FRA CHN ESP CAN ITA TUR NLD BEL IND
		series {%c}EXR05  = {%c}PANUSATLS  / @ELEM({%c}PANUSATLS  , !base_year  )
		series {%c}PCEXN05  = {%c}NECONPRVTXN  / @ELEM({%c}NECONPRVTXN  , !base_year  )
	next
 
	series BGDNEER = 100  * (0.1976357385 * 1 / (BGDEXR05 / USAEXR05)  + 0.1462581536 * 1 / (BGDEXR05 / DEUEXR05)  + 0.08439290517 * 1 / (BGDEXR05 / GBREXR05)  + 0.06887154717 * 1 / (BGDEXR05 / FRAEXR05)  + 0.04927114879 * 1 / (BGDEXR05 / CHNEXR05)  + 0.04496640064 * 1 / (BGDEXR05 / ESPEXR05)  + 0.03717605296 * 1 / (BGDEXR05 / CANEXR05)  + 0.03359022571 * 1 / (BGDEXR05 / ITAEXR05)  + 0.03241757735 * 1 / (BGDEXR05 / TUREXR05)  + 0.02752241922 * 1 / (BGDEXR05 / NLDEXR05)  + 0.0260141169 * 1 / (BGDEXR05 / BELEXR05)  + 0.02484860441 * 1 / (BGDEXR05 / INDEXR05)) / (1-0.22703511)

	series BGDREER  = 100  * (0.1976357385 * 1 / ((BGDEXR05 / BGDPCEXN05) / (USAEXR05 / USAPCEXN05))  + 0.1462581536 * 1 / ((BGDEXR05 / BGDPCEXN05) / (DEUEXR05 / DEUPCEXN05))  + 0.08439290517 * 1 / ((BGDEXR05 / BGDPCEXN05) / (GBREXR05 / GBRPCEXN05))  + 0.06887154717 * 1 / ((BGDEXR05 / BGDPCEXN05) / (FRAEXR05 / FRAPCEXN05))  + 0.04927114879 * 1 / ((BGDEXR05 / BGDPCEXN05) / (CHNEXR05 / CHNPCEXN05))  + 0.04496640064 * 1 / ((BGDEXR05 / BGDPCEXN05) / (ESPEXR05 / ESPPCEXN05))  + 0.03717605296 * 1 / ((BGDEXR05 / BGDPCEXN05) / (CANEXR05 / CANPCEXN05))  + 0.03359022571 * 1 / ((BGDEXR05 / BGDPCEXN05) / (ITAEXR05 / ITAPCEXN05))  + 0.03241757735 * 1 / ((BGDEXR05 / BGDPCEXN05) / (TUREXR05 / TURPCEXN05))  + 0.02752241922 * 1 / ((BGDEXR05 / BGDPCEXN05) / (NLDEXR05 / NLDPCEXN05))  + 0.0260141169 * 1 / ((BGDEXR05 / BGDPCEXN05) / (BELEXR05 / BELPCEXN05))  + 0.02484860441 * 1 / ((BGDEXR05 / BGDPCEXN05) / (INDEXR05 / INDPCEXN05))) / (1-0.22703511) 

	series ROWNEIMPGNFSKD = WLTNEIMPGNFSKD - (USANEIMPGNFSKD + DEUNEIMPGNFSKD + GBRNEIMPGNFSKD + FRANEIMPGNFSKD + CHNNEIMPGNFSKD + ESPNEIMPGNFSKD + CANNEIMPGNFSKD + ITANEIMPGNFSKD + TURNEIMPGNFSKD + NLDNEIMPGNFSKD + BELNEIMPGNFSKD + INDNEIMPGNFSKD)
	
	series BGDXMKT_GR  = 0.1976357385 * @pc(USAneimpgnfskd) + 0.1462581536 * @pc(DEUneimpgnfskd) + 0.08439290517 * @pc(GBRneimpgnfskd) + 0.06887154717 * @pc(FRAneimpgnfskd) + 0.04927114879 * @pc(CHNneimpgnfskd) + 0.04496640064 * @pc(ESPneimpgnfskd) + 0.03717605296 * @pc(CANneimpgnfskd) + 0.03359022571 * @pc(ITAneimpgnfskd) + 0.03241757735 * @pc(TURneimpgnfskd) + 0.02752241922 * @pc(NLDneimpgnfskd) + 0.0260141169 * @pc(BELneimpgnfskd) + 0.02484860441 * @pc(INDneimpgnfskd) + 0.22703511 * @pc(ROWNEIMPGNFSKD)

	smpl 1980 1980
	series BGDXMKT = WLTNEIMPGNFSKD

	smpl 1981 %end_date
	series BGDXMKT  = BGDXMKT(-1)  * (1  + BGDXMKT_GR  / 100)
	smpl @all

	series BGDXMKT = BGDXMKT/@elem(BGDXMKT,!base_year ) * @elem(BGDNEEXPGNFSKD, !base_year)


	series BGDPXKEY  = MUV / @ELEM(MUV , !base_year)

	series BGDPMKEY  = ( 0.002452542217  * WLDFALUMINUM  / @ELEM(WLDFALUMINUM  , 2016)  + 0.000027200099  * WLDFBANANA_US  / @ELEM(WLDFBANANA_US  , 2016)  + 0.003404545665  * WLDFBEEF  / @ELEM(WLDFBEEF  , 2016)  + 0.247806497590  * WLDFCOAL_AUS  / @ELEM(WLDFCOAL_AUS  , 2016)  + 0.000497856374  * WLDFCOCOA  / @ELEM(WLDFCOCOA  , 2016)  + 0.000380801379  * WLDFCOFFEE_COMPO  / @ELEM(WLDFCOFFEE_COMPO  , 2016)  + 0.000013600049  * WLDFCOPPER  / @ELEM(WLDFCOPPER  , 2016)  + 3.512983391193  * WLDFCOTTON_A_INDX  / @ELEM(WLDFCOTTON_A_INDX  , 2016)  + 4.5  * WLDFCRUDE_PETRO  / @ELEM(WLDFCRUDE_PETRO  , 2016)  + 0.000026202967  * WLDFGRNUT_OIL  / @ELEM(WLDFGRNUT_OIL  , 2016)  + 0.000412534828  * WLDFGRNUT_OIL  / @ELEM(WLDFGRNUT_OIL  , 2016)  + 0.001156004187  * WLDFGOLD  / @ELEM(WLDFGOLD  , 2016)  + 0.000072533596  * WLDFGRNUT  / @ELEM(WLDFGRNUT  , 2016)  + 0.000009066700  * WLDFIRON_ORE  / @ELEM(WLDFIRON_ORE  , 2016)  + 0.010453207011  * WLDFLEAD  / @ELEM(WLDFLEAD  , 2016)  + 0.708186298485  * WLDFMAIZE  / @ELEM(WLDFMAIZE  , 2016)  + 75.46499434 * MUV  / @ELEM(MUV  , 2016)  + 0.000213458882  * WLDFNICKEL  / @ELEM(WLDFNICKEL  , 2016)  + 0.205605544733  * WLDFORANGE  / @ELEM(WLDFORANGE  , 2016)  + 0.097435286258  * WLDFNGAS_EUR  / @ELEM(WLDFNGAS_EUR  , 2016)  + 0.064586633942  * WLDFPALM_OIL  / @ELEM(WLDFPALM_OIL  , 2016)  + 1.455917006872  * WLDFRICE_05  / @ELEM(WLDFRICE_05  , 2016)  + 0.025930760592  * WLDFRUBBER1_MYSG  / @ELEM(WLDFRUBBER1_MYSG  , 2016)  + 0.000285601034  * WLDFSILVER  / @ELEM(WLDFSILVER  , 2016)  + 1.293541485392  * WLDFSOYBEAN_MEAL  / @ELEM(WLDFSOYBEAN_MEAL  , 2016)  + 0.822399512182  * WLDFSOYBEAN_OIL  / @ELEM(WLDFSOYBEAN_OIL  , 2016)  + 0.207065283353  * WLDFSOYBEANS  / @ELEM(WLDFSOYBEANS  , 2016)  + 0.000235734187  * WLDFSORGHUM  / @ELEM(WLDFSORGHUM  , 2016)  + 5.530605099306  * WLDFISTL_JP_INDX  / @ELEM(WLDFISTL_JP_INDX  , 2016)  + 2.081016071070  * WLDFSUGAR_WLD  / @ELEM(WLDFSUGAR_WLD  , 2016)  + 0.019806205074  * WLDFTEA_AVG  / @ELEM(WLDFTEA_AVG  , 2016)  + 0.043860158868  * WLDFTOBAC_US  / @ELEM(WLDFTOBAC_US  , 2016)  + 0.000022666749  * WLDFLOGS_MYS  / @ELEM(WLDFLOGS_MYS  , 2016)  + 0.044154826602  * WLDFPLYWOOD  / @ELEM(WLDFPLYWOOD  , 2016)  + 0.001310148353  * WLDFWOODPULP  / @ELEM(WLDFWOODPULP  , 2016)  + 0.250716908132  * WLDFSAWNWD_MYS  / @ELEM(WLDFSAWNWD_MYS  , 2016)  + 3.402414990698  * WLDFWHEAT_US_HRW  / @ELEM(WLDFWHEAT_US_HRW  , 2016) )  / 100
	
	series BGDTOT  = (BGDNEEXPGNFSXN  / BGDNEIMPGNFSXN)
	
'********************
'Capital stock
'********************
	series myear=@year
	!stDate1=@ifirst(BGDNEGDIFTOTKN)
	%stDate=@str(myear(!stDate1))

	smpl %stDate %end_date
	series BGDNEGDIKSTKKN_temp = NA

	smpl %stDate %stDate
	series  BGDNEGDIKSTKKN_temp = BGDNEGDIFTOTKN
	smpl %stDate+1 %end_date
	series  BGDNEGDIKSTKKN_temp = BGDNEGDIKSTKKN_temp(-1)*(1-BGDDEPR/100) + BGDNEGDIFTOTKN

	smpl %stDate %end_date
	scalar BGDratio_scalar=BGDNEGDIKSTKKN_temp(@ifirst(BGDNEGDIKSTKKN_temp)+15)/BGDNYGDPMKTPKN(@ifirst(BGDNEGDIKSTKKN_temp)+15)
	series BGDratio=BGDratio_scalar

	delete  BGDNEGDIKSTKKN_temp

	smpl %stDate %end_date
	series BGDNEGDIKSTKKN = na

	smpl %stDate %stDate
	series  BGDNEGDIKSTKKN = BGDratio*BGDNYGDPMKTPKN
	smpl %stDate+1 %end_date
	series  BGDNEGDIKSTKKN = BGDNEGDIKSTKKN(-1)*(1-BGDDEPR/100) + BGDNEGDIFTOTKN
	

'********************
'LABOR MARKET
'********************	
	'Reconstructed labor income using wage bill share
	series BGDNYYWBTOTLCN = BGDNYYWBTOTLCN_ * BGDNYGDPMKTPCN
	'Wage rate 
	series BGDNYWRTTOTLXN = BGDNYYWBTOTLCN/BGDLMEMPTOTL
	'Labor participation rate
	series BGDLMPRTTOTL_ = (BGDLMEMPTOTL/(BGDSPPOP1564TO*(1-BGDLMUNRTOTL_/100)))*100 ' Labor participation rate
	'Structural unemployment rate (history)
	BGDLMUNRTOTL_.hpf(100) BGDLMUNRSTRL_
	 'Structural participation rate (history)
	BGDLMPRTTOTL_.hpf(100) BGDLMPRTSTRL_
	' Structural employment
	series BGDLMEMPSTRL = (1-BGDLMUNRSTRL_/100)*(BGDLMPRTSTRL_/100)*BGDSPPOP1564TO 

'********************
'TFP
'********************
	pagestruct(end=%template_end)
	smpl @all
	'Raw TFP from historial data
	series BGDNYGDPTFP_raw = (BGDNYGDPMKTPKN) / (BGDLMEMPSTRL^BGDNYYWBTOTLCN_*BGDNEGDIKSTKKN(-1)^(1-BGDNYYWBTOTLCN_))
	'Extend TFP using 10 years growth
	%ser = %cty+"NYGDPTFP_raw"
	smpl @all
	series temp = @recode({%ser}<>na,@trend,na)+1 
	scalar first = @min(temp)
	scalar last = @max(temp)
	%firstdate=@otod(first)
	%lastdate=@otod(last) 
	delete temp

	smpl %end_date_interface @last
	series BGDNYGDPTFP_raw =BGDNYGDPTFP_raw(-1)*(1+(((@elem(BGDNYGDPTFP_raw,"2019")/@elem(BGDNYGDPTFP_raw,"2009"))^(1/10)-1)))

	smpl @all
	hpf(100) BGDNYGDPTFP_raw BGDNYGDPTFP
	pagestruct(end=%template_end)

	delete BGDNYGDPTFP_raw

'********************
'GDP POTENTIALS
'********************
	'GDP potentials real LCU
	series BGDNYGDPPOTLKN  = (BGDNYGDPTFP  * BGDLMEMPSTRL^BGDNYYWBTOTLCN_  * BGDNEGDIKSTKKN(-1)^(1-BGDNYYWBTOTLCN_))
	'GDP potentials real USD
	series BGDNYGDPPOTLKD  = (BGDNYGDPPOTLKN  * (@elem(BGDNYGDPMKTPCN  , 2016)  / (@elem(BGDNYGDPMKTPKN  , 2016))))  / @elem(BGDpanusatls  , 2016)
	'Output gap
	series BGDNYGDPGAP_  = (BGDNYGDPMKTPKN  / BGDNYGDPPOTLKN  - 1)  * 100
	smpl @all
	
'********************
'FISCAL
'********************
'Revenues - effective rates
	series BGDGGREVDRCTER = BGDGGREVDRCTCN / BGDNYGDPMKTPCN * 100
	series BGDGGREVTVATER = BGDGGREVTVATCN / (BGDNECONPRVTCN + BGDNECONGOVTCN) * 100
	series BGDGGREVIMPDER = BGDGGREVIMPDCN / BGDNEIMPGNFSCN * 100
	series BGDGGREVEXPDER = BGDGGREVEXPDCN / BGDNEEXPGNFSCN * 100
	series BGDGGREVEXCDER = BGDGGREVEXCDCN / (BGDNECONPRVTCN + BGDNECONGOVTCN) * 100
	series BGDGGREVSUPDER = BGDGGREVSUPDCN / (BGDNECONPRVTCN + BGDNECONGOVTCN) * 100
	series BGDGGREVOTHDER = BGDGGREVOTHDCN / BGDNYGDPMKTPCN * 100
	series BGDGGREVNNBRER = BGDGGREVNNBRCN / BGDNYGDPMKTPCN * 100
	series BGDGGREVTOTHER = BGDGGREVTOTHCN / BGDNYGDPMKTPCN * 100
	
	'Tax rates retropolation for estimation of price equations
		smpl 1995 2008
			series BGDGGREVDRCTER = @ELEM(BGDGGREVDRCTER,"2009")
			series BGDGGREVTVATER = @ELEM(BGDGGREVTVATER,"2009")
			series BGDGGREVIMPDER = @ELEM(BGDGGREVIMPDER,"2009")
			series BGDGGREVEXPDER = @ELEM(BGDGGREVEXPDER,"2009")
			series BGDGGREVEXCDER = @ELEM(BGDGGREVEXCDER,"2009")		
		smpl @all
		
'Expenditures - interest rates 
	series BGDINTRDFR = BGDGGEXPINTDCN / BGDGGDBTDOMTCN(-1) * 100
	series BGDINTREFR = BGDGGEXPINTECN / BGDGGDBTEXTLCN(-1) * 100
	series BGDINTRDDIFFFR = BGDINTRDFR - BGDFMLBLPOLYFR 
	series BGDINTREDIFFFR = BGDINTREFR - USAINTRFR
	
	series BGDBFCAFFFDICN = BGDBFCAFFFDICD * BGDPANUSATLS
	
	'Dynamic coverage ratio of fiscal to NIA accounts
		series BGDNECONGOVTCOV_ = BGDNECONGOVTCN(-1) / (BGDGGEXPGNFSCN(-1) + BGDGGEXPWAGECN(-1)) * 100
		series BGDNEGDIFGOVCOV_ = BGDNEGDIFGOVCN(-1) / (BGDGGEXPCAPTCN(-1)) * 100

'Balance
	series BGDGGBALOVRLCN_ = BGDGGBALOVRLCN  / BGDNYGDPMKTPCN  * 100

	series BGDGGBALOVRLCD = BGDGGBALOVRLCN  / BGDPANUSATLS
	series BGDGGBALOVRLCD_ = BGDGGBALOVRLCD  / BGDNYGDPMKTPCD  * 100
	series BGDGGDBTTOTLCD = (BGDGGDBTTOTLCN  / BGDPANUSATLS)
	
'Debt
	series BGDGGDBTTOTLCD = BGDGGDBTTOTLCN / BGDPANUSATLS
	
'Financing
	series BGDGGFINREQMCN = - BGDGGBALOVRLCN
	series bgdggfinfgapcn = bgdggfinreqmcn - bgdggfintotlcn
	
	series BGDGGDBTVALECN = BGDGGDBTEXTLCN - (BGDGGDBTEXTLCN(-1) + BGDGGFINEXTLCN)
	series BGDGGDBTVALDCN = BGDGGDBTDOMTCN - (BGDGGDBTDOMTCN(-1) + BGDGGFINDOMTCN)
	series BGDGGFINEXTLSHARE_ = BGDGGFINEXTLCN / BGDGGFINTOTLCN * 100
	
'********************
'BOP and EXTERNAL
'********************
	series BGDBXGSRGNFSCD = BGDBXGSRMRCHCD + BGDBXGSRNFSVCD
	series BGDBMGSRGNFSCD = BGDBMGSRMRCHCD + BGDBMGSRNFSVCD
	
	series BGDBNFSTCABTCD = BGDBXFSTCABTCD - BGDBMFSTCABTCD
	
	series BGDBNGSRGNFSCD = BGDBXGSRGNFSCD - BGDBMGSRGNFSCD
	
	series BGDBXFSTOTHRCD = BGDBXFSTCABTCD - BGDBXFSTREMTCD
	
	series BGDBMFSTINTECD = BGDGGEXPINTECN / BGDPANUSATLS
	series BGDBMFSTOTHRCD = BGDBMFSTCABTCD - (BGDBMFSTREMTCD + BGDBMFSTINTECD)
	
	series BGDBFFINAGOVCD = BGDGGFINEAMTCN / BGDPANUSATLS
	series BGDBFFINDGOVCD = BGDGGFINEDSBCN / BGDPANUSATLS
	series BGDBFFINOGOVCD = BGDGGFINEOTHCN / BGDPANUSATLS
	
	series BGDBFFINTGOVCD = BGDBFFINAGOVCD + BGDBFFINDGOVCD + BGDBFFINOGOVCD
	series BGDBFCAFOOTHCD = BGDBFCAFOTHRCD - BGDBFFINTGOVCD
	
	series BGDBFBOPTOTLCD = BGDBFCAFCAPTCD + BGDBFCAFFINXCD + BGDBNCABFUNDCD + BGDBFCAFNEOMCD
	series BGDBFFINFGAPCD = BGDBFBOPTOTLCD + BGDBFCAFRACGCD
	
	smpl 1980 1980
		series BGDREMT_IN = 1

	smpl @all
		series BGDREMT_IN_GR  = (0.22 * @pc(SAUNYGDPMKTPCD) + 0.10 * @pc(ARENYGDPMKTPCD) + 0.10 * @pc(GBRNYGDPMKTPCD) + 0.07 * @pc(KWTNYGDPMKTPCD) + 0.16 * @pc(USANYGDPMKTPCD) + 0.06 * @pc(QATNYGDPMKTPCD) + 0.04 * @pc(OMNNYGDPMKTPCD) + 0.02 * @pc(SGPNYGDPMKTPCD) + 0.004 * @pc(DEUNYGDPMKTPCD) + 0.03 * @pc(BHRNYGDPMKTPCD)+ 0.003 * @pc(JPNNYGDPMKTPCD)+ 0.05* @pc(MYSNYGDPMKTPCD)) / 0.857

	smpl 1981 %end_date 
		series BGDREMT_IN = BGDREMT_IN(-1) * (1+BGDREMT_IN_GR/100) 'Coefficients are rebalanced to account for the remittances coming from the rest of the world

'********************
'Money supply
'********************
	 'Real money supply
	series  BGDFMLBLMTWOKN = BGDFMLBLMTWOCN / BGDNECONPRVTXN
	
'********************
'Cost of capital
'********************
	' Nominal cost of capital
	series BGDNEKRTTOTLXN = (1-BGDNYYWBTOTLCN_) * BGDNYGDPMKTPCN / BGDNEGDIKSTKKN(-1)	
	' Capital cost premium
	series BGDNEKRTPREMFR = 100 * BGDNEKRTTOTLXN / BGDNEGDIFTOTXN - (BGDFMLBLPOLYFR + BGDDEPR - BGDINFLEXPT) 

'********************
'Marginal costs
'********************
	series BGDPSTAR  = (BGDNYWRTTOTLXN^BGDNYYWBTOTLCN_  * BGDNEKRTTOTLXN^(1  - BGDNYYWBTOTLCN_))  / (BGDNYGDPTFP  * BGDNYYWBTOTLCN_^BGDNYYWBTOTLCN_  * (1  - BGDNYYWBTOTLCN_)^(1  - BGDNYYWBTOTLCN_))


'logmsg readdata complete


