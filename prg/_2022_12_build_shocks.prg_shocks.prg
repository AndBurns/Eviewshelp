'============================
' SIMPLE SHOCK PROGRAM
'============================

	close @all
	logmode l
	%path = @runpath
	cd %path
	%pathdat = %path+"BGDSOLNCC.WF1" 
	wfopen C:\WBG\LocalITUtilities\BGD\Climate\build\data\BGDSOLNCC.WF1 '%pathdat

	%sim_start = "2025" '  2022
	%sim_end = "2050"
	%sim_end1 = "2040" '  "2030" ' last perio of the simulation
	%solve_start = "2013"
	%solve_end = "2050"

	!growth = 0 ' Chart in growth =1 else in levels
	!changeMod = 0' If you want to add hardcore fiscal rule
	!noFisc = 1 ' if you want to exogenize the fiscal responses
	!cut = 0 ' 60 ' The number of periods to cut from the end of the charts
	%cty = "BGD"
	%s = "g" ' Solver
	!scen = 4 ' Chart scenario

' =================================================
	!transfer = 0 ' If you want to transfer to households
	!transSHARE = 0 ' 0.65 ' 0.65 ' (0.83 for low CP ; 0.65 for high CP) : Note (1-share) affects taxes - so make zero for pure tax
	!RD = 0 ' R&D expenditures (need !transfer = 1)
' =================================================
	!tax = 0 ' If you want to reduce income taxes
' =================================================
	scalar coalE = 1
	scalar oilE = 1
	scalar gasE = 1

' =================================================
	scalar CPIGR = 1 ' Make 1 if you want carbon price to grow in line with CPI - i.e., real carbon price
	scalar cpinit= 20*82 ' 1 USD = 82 BGD RINGIT; base year is 2005 then *0.89 for EURO amount (41 for 40 euro UN) (11 for 10 euro)
	scalar cpgrowth= 4.5' 
	scalar cpgrowth1 = 0 ' 
' =================================================

	string revExog = "GGREVOTHRCN GGREVNONTCN GGREVGRNTCN"
	string exos="GGEXPOTHRCN GGEXPWAGECN GGEXPGNFSCN GGEXPTRNSCN GGEXPCAPTCN HEAPCN GGEXPINTECN GGEXPINTDCN NEGDIPUBXN NECONGOVTXN BXFSTREMTCD" ' GGEXPINTPCN NEGDIPUBXN NECONGOVTXN GGDBTVALTCN BXFSTREMTCD GGEXPINTECN GGEXPINTDCN

	revExog = @wcross(%cty,revExog)
	exos = @wcross(%cty,exos)
'=====================================

'include generateTable.prg

	spool charl

	if !changeMod = 1 then
		if (1=0) then
			scalar pers = 0 ' level of persistence
			scalar {%cty}CGBALRULECN_ = 0.03 '  Deficit rule
			
			smpl @first 2019
			scalar CAPT = 0.11 
			scalar GNFS = 0.11
			scalar OTHR = 0.001
			scalar TRNS = 0.61
			scalar WAGE = 0.22
			
			for %ac CAPT GNFS OTHR TRNS WAGE
				equation _{%cty}GGEXP{%ac}CN.ls {%cty}GGEXP{%ac}CN = PERS*{%cty}GGEXP{%ac}CN(-1) + (1-PERS) *{%ac}*(1-{%cty}CGBALRULECN_)*({%cty}GGREVTOTLCN -{%cty}GGEXPINTPCN) +C(1)*@DURING("2010")
			next
		
			equation _{%cty}NECONPRVTKN.LS DLOG({%cty}NECONPRVTKN) = -0.2*(LOG({%cty}NECONPRVTKN(-1))-LOG((({%cty}GGEXPTRNSCN(-1)+{%cty}NYYWBTOTLCN(-1))*(1-{%cty}GGREVDRCTXN(-1)/100)+({%cty}BXFSTREMTCD(-1))*{%cty}PANUSATLS(-1))/{%cty}NECONPRVTXN(-1))) +C(2)*DLOG((({%cty}GGEXPTRNSCN+{%cty}NYYWBTOTLCN)*(1-{%cty}GGREVDRCTXN/100)+({%cty}BXFSTREMTCD)*{%cty}PANUSATLS)/{%cty}NECONPRVTXN) -0.3*D({%cty}FMLBLPOLYXN/100-DLOG({%cty}NECONPRVTXN)) +C(4)

		else
			smpl @first 2019
			'equation _{%cty}NEWRTTOTLCN.LSDLOG({%cty}NEWRTTOTLCN) = 0.2*DLOG({%cty}NEWRTTOTLCN(-1))+(1-0.2)*(DLOG({%cty}NYGDPTFP)/{%cty}NYYWBTOTLCN_+0.5*DLOG({%cty}NYGDPFCSTXN(-1)+0.5*{%cty}INFLEXPT/100) +0.3*({%cty}LMUNRTOTLCN-{%cty}LMUNRSTRLCN)/100+C(10)*@DURING("2009")+C(11)*@DURING("2012") 
		
			equation _{%cty}NYGDPFCSTXN.LS DLOG({%cty}NYGDPFCSTXN) = -0.4*(LOG({%cty}NYGDPFCSTXN(-1))-LOG({%cty}PSTAR(-1))) +0.5*DLOG({%cty}NYGDPFCSTXN(-1))+(1-0.5)*(0.5*{%cty}INFLEXPT/100 + (1-0.5)*DLOG({%cty}PSTAR)) +0.4*{%cty}NYGDPGAP_/100 + C(4)

			equation _{%cty}NEIMPGSNEKN.LS DLOG({%cty}NEIMPGSNEKN) =-0.68*(LOG({%cty}NEIMPGSNEKN(-1))-LOG({%cty}NEGDETTOTKN(-1))+0.3*LOG({%cty}NEIMPGSNEXN(-1)/({%cty}NYGDPFCSTXN(-1))))+0.08*DLOG({%cty}NEIMPGSNEXN/{%cty}NYGDPFCSTXN)+C(5)+1*DLOG({%cty}NEGDETTOTKN)+C(10)*@DURING("2009")

			equation _{%cty}NEGDIFPRVXN.LS	DLOG({%cty}NEGDIFPRVXN) = C(1)*(LOG({%cty}NEGDIFPRVXN(-1))-LOG({%cty}NECONPRVTXN(-1))) + 1*DLOG({%cty}NECONPRVTXN) + C(10)

		endif

		smpl @all
		delete *_A
		{%cty}.update

		{%cty}.exclude
		smpl %solve_start %solve_end
		{%cty}.addassign(i,c) @stochastic
		{%cty}.addinit(v=n) @stochastic

		{%cty}.scenario "baseline"
		{%cty}.solve(s=d,d=d,o={%s}, i=a, g=n)
		logmsg "resolved baseline"
	endif

' ===========================================================
' ONLY CLIMATE (use this for fiscal revenues and transfers)

	{%cty}.scenario(n,a=3,i="Baseline",c) "simple"
	{%cty}.scenario "simple"

	smpl @all 
	series {%cty}GGREVCO2CER_3={%cty}GGREVCO2CER
	series {%cty}GGREVCO2OER_3={%cty}GGREVCO2OER
	series {%cty}GGREVCO2GER_3={%cty}GGREVCO2GER

	series {%cty}GGREVCO2CKN_3 = {%cty}GGREVCO2CER*{%cty}PANUSATLS/{%cty}NVCOLPRODXN 'Initialize variable
	series {%cty}GGREVCO2OKN_3 = {%cty}GGREVCO2OER*{%cty}PANUSATLS/{%cty}NVOILPRODXN
	series {%cty}GGREVCO2GKN_3 = {%cty}GGREVCO2GER*{%cty}PANUSATLS/{%cty}NVGASPRODXN

	smpl %sim_start %sim_end
	{%cty}GGREVCO2CKN_3 = cpinit 'Initial carbon price in RINGIT
	{%cty}GGREVCO2OKN_3 = cpinit
	{%cty}GGREVCO2GKN_3 = cpinit

	smpl %sim_start+1 %sim_end1
	{%cty}GGREVCO2CKN_3 = {%cty}GGREVCO2CKN_3(-1)*(1+cpgrowth/100+CPIGR*@PC({%cty}NECONPRVTXN)/100) 
	{%cty}GGREVCO2OKN_3 = {%cty}GGREVCO2OKN_3(-1)*(1+cpgrowth/100+CPIGR*@PC({%cty}NECONPRVTXN)/100)
	{%cty}GGREVCO2GKN_3 = {%cty}GGREVCO2GKN_3(-1)*(1+cpgrowth/100+CPIGR*@PC({%cty}NECONPRVTXN)/100)

	if cpgrowth1 > 2 then
		smpl 2026 %sim_end1+15
		{%cty}GGREVCO2CKN_3 = {%cty}GGREVCO2CKN_3(-1)*(1+cpgrowth1/100+CPIGR*@PC({%cty}NECONPRVTXN)/100) 'Growth rate in the carbon price in Denar
		{%cty}GGREVCO2OKN_3 = {%cty}GGREVCO2OKN_3(-1)*(1+cpgrowth1/100+CPIGR*@PC({%cty}NECONPRVTXN)/100)
		{%cty}GGREVCO2GKN_3 = {%cty}GGREVCO2GKN_3(-1)*(1+cpgrowth1/100+CPIGR*@PC({%cty}NECONPRVTXN)/100)

		smpl %sim_end1+16 @last
		{%cty}GGREVCO2CKN_3 = {%cty}GGREVCO2CKN_3(-1)*(1+CPIGR*@PC({%cty}NECONPRVTXN)/100)
		{%cty}GGREVCO2OKN_3 = {%cty}GGREVCO2OKN_3(-1)*(1+CPIGR*@PC({%cty}NECONPRVTXN)/100)
		{%cty}GGREVCO2GKN_3 = {%cty}GGREVCO2GKN_3(-1)*(1+CPIGR*@PC({%cty}NECONPRVTXN)/100)

		else
		smpl %sim_end1+1 @last
		{%cty}GGREVCO2CKN_3 = {%cty}GGREVCO2CKN_3(-1)*(1+CPIGR*@PC({%cty}NECONPRVTXN)/100)
		{%cty}GGREVCO2OKN_3 = {%cty}GGREVCO2OKN_3(-1)*(1+CPIGR*@PC({%cty}NECONPRVTXN)/100)
		{%cty}GGREVCO2GKN_3 = {%cty}GGREVCO2GKN_3(-1)*(1+CPIGR*@PC({%cty}NECONPRVTXN)/100)

	endif

	smpl %sim_start %sim_end
	{%cty}GGREVCO2CER_3={%cty}GGREVCO2CKN_3/@ELEM({%cty}PANUSATLS,"2005")*coalE 'Conversion of carbon price to USD
	{%cty}GGREVCO2OER_3={%cty}GGREVCO2OKN_3/@ELEM({%cty}PANUSATLS,"2005")*oilE
	{%cty}GGREVCO2GER_3={%cty}GGREVCO2GKN_3/@ELEM({%cty}PANUSATLS,"2005")*gasE

	smpl %sim_start %sim_end 

	{%cty}.exclude(m) {%cty}GGREVCO2OER {%cty}GGREVCO2CER {%cty}GGREVCO2GER {revExog} {exos}

	{%cty}.override(m) {%cty}GGREVCO2OER {%cty}GGREVCO2CER {%cty}GGREVCO2GER

	smpl %solve_start %solve_end
	{%cty}.solve(s=d,d=d,o={%s}, i=a, g=n)


' ===========================================================
' Climate Carbon SHOCK (with different scenarios) - 

	{%cty}.scenario(n,a=4,i="Baseline",c) "oil simple"
	{%cty}.scenario "oil simple"

	smpl @all 
	series {%cty}GGREVCO2CER_4={%cty}GGREVCO2CER
	series {%cty}GGREVCO2OER_4={%cty}GGREVCO2OER
	series {%cty}GGREVCO2GER_4={%cty}GGREVCO2GER

	series {%cty}GGREVCO2CKN_4 = {%cty}GGREVCO2CER*{%cty}PANUSATLS/{%cty}NVCOLPRODXN 'Initialize variable
	series {%cty}GGREVCO2OKN_4 = {%cty}GGREVCO2OER*{%cty}PANUSATLS/{%cty}NVOILPRODXN
	series {%cty}GGREVCO2GKN_4 = {%cty}GGREVCO2GER*{%cty}PANUSATLS/{%cty}NVGASPRODXN

	smpl %sim_start %sim_end
	{%cty}GGREVCO2CKN_4 = cpinit 'Initial carbon price in Rand
	{%cty}GGREVCO2OKN_4 = cpinit
	{%cty}GGREVCO2GKN_4 = cpinit


	smpl %sim_start+1 %sim_end1
	{%cty}GGREVCO2CKN_4 = {%cty}GGREVCO2CKN_4(-1)*(1+cpgrowth/100+CPIGR*@PC({%cty}NECONPRVTXN)/100) 
	{%cty}GGREVCO2OKN_4 = {%cty}GGREVCO2OKN_4(-1)*(1+cpgrowth/100+CPIGR*@PC({%cty}NECONPRVTXN)/100)
	{%cty}GGREVCO2GKN_4 = {%cty}GGREVCO2GKN_4(-1)*(1+cpgrowth/100+CPIGR*@PC({%cty}NECONPRVTXN)/100)

	if cpgrowth1 > 2 then
		smpl 2026 %sim_end1+15
		{%cty}GGREVCO2CKN_4 = {%cty}GGREVCO2CKN_4(-1)*(1+cpgrowth1/100+CPIGR*@PC({%cty}NECONPRVTXN)/100) 
		{%cty}GGREVCO2OKN_4 = {%cty}GGREVCO2OKN_4(-1)*(1+cpgrowth1/100+CPIGR*@PC({%cty}NECONPRVTXN)/100)
		{%cty}GGREVCO2GKN_4 = {%cty}GGREVCO2GKN_4(-1)*(1+cpgrowth1/100+CPIGR*@PC({%cty}NECONPRVTXN)/100)

		smpl %sim_end1+16 @last
		{%cty}GGREVCO2CKN_4 = {%cty}GGREVCO2CKN_4(-1)*(1+CPIGR*@PC({%cty}NECONPRVTXN)/100)
		{%cty}GGREVCO2OKN_4 = {%cty}GGREVCO2OKN_4(-1)*(1+CPIGR*@PC({%cty}NECONPRVTXN)/100)
		{%cty}GGREVCO2GKN_4 = {%cty}GGREVCO2GKN_4(-1)*(1+CPIGR*@PC({%cty}NECONPRVTXN)/100)

		else

		smpl %sim_end1+1 @last
		{%cty}GGREVCO2CKN_4 = {%cty}GGREVCO2CKN_4(-1)*(1+CPIGR*@PC({%cty}NECONPRVTXN)/100)
		{%cty}GGREVCO2OKN_4 = {%cty}GGREVCO2OKN_4(-1)*(1+CPIGR*@PC({%cty}NECONPRVTXN)/100)
		{%cty}GGREVCO2GKN_4 = {%cty}GGREVCO2GKN_4(-1)*(1+CPIGR*@PC({%cty}NECONPRVTXN)/100)
	endif


	smpl %sim_end1+1 @last
	{%cty}GGREVCO2CKN_4 = {%cty}GGREVCO2CKN_4(-1)*(1+CPIGR*@PC({%cty}NECONPRVTXN)/100)
	{%cty}GGREVCO2OKN_4 = {%cty}GGREVCO2OKN_4(-1)*(1+CPIGR*@PC({%cty}NECONPRVTXN)/100)
	{%cty}GGREVCO2GKN_4 = {%cty}GGREVCO2GKN_4(-1)*(1+CPIGR*@PC({%cty}NECONPRVTXN)/100)


	smpl %sim_start %sim_end
	{%cty}GGREVCO2CER_4={%cty}GGREVCO2CKN_4/@ELEM({%cty}PANUSATLS,"2005")*coalE 'Conversion of carbon price to USD
	{%cty}GGREVCO2OER_4={%cty}GGREVCO2OKN_4/@ELEM({%cty}PANUSATLS,"2005")*oilE
	{%cty}GGREVCO2GER_4={%cty}GGREVCO2GKN_4/@ELEM({%cty}PANUSATLS,"2005")*gasE


	if !transfer = 1 then
		if !RD = 1 then
			smpl @all
			series {%cty}RANDD_4 = {%cty}RANDD  
			series {%cty}GGEXPTRNSCN_4 = {%cty}GGEXPTRNSCN_0
			series {%cty}GGEXPRANDDCN_4 = {%cty}GGEXPRANDDCN_0
			series {%cty}NYGDPTFP_4 = {%cty}NYGDPTFP

			smpl %sim_start %sim_end 
			{%cty}RANDD_4 = 0.3 ' elasticity of TFP to R&D
			{%cty}GGEXPTRNSCN_4 = {%cty}GGEXPTRNSCN_0+!transSHARE*{%cty}GGREVEMISCN_3  ' NOTE THAT TRANSFERS IS 18% OF GDP AND R&D EXPENSES  0.3% OF GDP
			{%cty}GGEXPRANDDCN_4 = {%cty}GGEXPRANDDCN_0+!transSHARE*{%cty}GGREVEMISCN_3
			{%cty}NYGDPTFP_4 = {%cty}NYGDPTFP*(1+@elem({%cty}GGEXPRANDDCN/{%cty}TFPRANDDCN,"2019")*0.3*(0.1*({%cty}GGEXPRANDDCN_4/{%cty}GGEXPRANDDCN_0-1)+0.3*0.95*({%cty}GGEXPRANDDCN_4(-1)/{%cty}GGEXPRANDDCN_0(-1)-1)+0.3*0.8*({%cty}GGEXPRANDDCN_4(-2)/{%cty}GGEXPRANDDCN_0(-2)-1)+0.3*0.6*({%cty}GGEXPRANDDCN_4(-3)/{%cty}GGEXPRANDDCN_0(-3)-1)))

		else
			smpl @all
			series {%cty}GGEXPTRNSCN_4 = {%cty}GGEXPTRNSCN_0
		
			smpl %sim_start %sim_start  '%sim_end 
			smpl %sim_start %sim_end 
			{%cty}GGEXPTRNSCN_4 = {%cty}GGEXPTRNSCN_0+!transSHARE*{%cty}GGREVEMISCN_3 
		endif
	endif

	if !tax = 1 then
		smpl @all
		series {%cty}GGREVDRCTER_4 = {%cty}GGREVDRCTER

		smpl %sim_start %sim_end 
		{%cty}GGREVDRCTER_4 = (({%cty}ggrevdrctcn_0-(1-!transSHARE)*{%cty}GGREVEMISCN_3)/{%cty}nygdpmktpcn_0)*100
	endif

	 ' ALL THE OVERRIDES
	if !transfer = 1 then
		' OVERRIDES FOR TRANSFERS BUT USED FROM R&D
		if !RD = 1 then
			{%cty}.override(m) {%cty}GGREVCO2OER {%cty}GGREVCO2CER {%cty}GGREVCO2GER {%cty}GGEXPTRNSCN {%cty}GGEXPRANDDCN {%cty}RANDD {%cty}NYGDPTFP
		else
		' OVERRIDES FOR TRANSFERS BUT USED FROM HH CONS
			{%cty}.override(m) {%cty}GGREVCO2OER {%cty}GGREVCO2CER {%cty}GGREVCO2GER {%cty}GGEXPTRNSCN 
	else
		' OVERRIDES BUT NO TRANSFERS
		if !tax = 1 then
		' OVERRIDES BUT NO TRANSFERS; HOWEVER TAX REDUCTION
			{%cty}.override(m) {%cty}GGREVCO2OER {%cty}GGREVCO2CER {%cty}GGREVCO2GER {%cty}GGREVDRCTER
		else
		' OVERRIDES BUT NO TRANSFERS; HOWEVER BUDGET SAVINGS
			{%cty}.override(m) {%cty}GGREVCO2OER {%cty}GGREVCO2CER {%cty}GGREVCO2GER
		endif
		endif
	endif

	 ' ALL THE EXCLUDES
	if !noFisc = 1 then
	 ' ALL THE EXCLUDES: WHEN FISCAL POLICY IS EXOGENIZED
		if !tax = 1 then 
	 ' ALL THE EXCLUDES: WHEN TAXES ARE USED FOR RECYCLING
			{%cty}.exclude(m) {%cty}GGREVCO2OER {%cty}GGREVCO2CER {%cty}GGREVCO2GER {exos} {revExog} 
		else
	 ' ALL THE EXCLUDES: WHEN EITHER TRANSFERS OR SAVINGS ARE USED
			{%cty}.exclude(m) {%cty}GGREVCO2OER {%cty}GGREVCO2CER {%cty}GGREVCO2GER {exos} {revExog} 
		endif

	else
	 ' ALL THE EXCLUDES: WHEN FISCAL POLICY IS ENDOGIZED
		{%cty}.exclude(m) {%cty}GGREVCO2OER {%cty}GGREVCO2CER {%cty}GGREVCO2GER {%cty}GGEXPRANDDCN {exos} {revExog} 
	endif

	smpl %solve_start %solve_end
	{%cty}.solve(s=d,d=d,o={%s}, i=a, g=n)

	'call tabres("{%cty}","4","0","CO2","2020", "2030","Carbon Price (EURO 20)","level") 'Level of GDP
	'show _t1CO2
	logmsg REAL CARBON TAX SCENARIO SOLVED!!!

'charl.add _T1CO2
'charl.name untitled01 "CO2Vanilla"

'===================================================
' SPOOLS
'===================================================

	show charl

'===================================================
' CHARTS
'===================================================

' oil
	smpl %sim_start-1 %sim_end-!cut
	if !growth = 1 then
		group OIL @PC({%cty}NYGDPMKTPKN_4)-@PC({%cty}NYGDPMKTPKN_0) @PC({%cty}NECONPRVTKN_4)-@PC({%cty}NECONPRVTKN_0) @PC({%cty}negdifprvkn_4)-@PC({%cty}negdifprvkn_0) 
	else
		group OIL ({%cty}NYGDPMKTPKN_4/{%cty}NYGDPMKTPKN_0-1)*100 ({%cty}NECONPRVTKN_4/{%cty}NECONPRVTKN_0-1)*100 ({%cty}negdifprvkn_4/{%cty}negdifprvkn_0-1)*100 
	endif

	freeze(graph3a) OIL.line
	graph3a.options fillcolor(WHITE) backcolor(WHITE) -INBOX  BACKFADE(NONE) frameaxes(all)
	graph3a.setelem(1) linecolor(148,190,255) lwidth(2) lpat(1) 'symbol(15)
	graph3a.setelem(2) linecolor(255,0,0) lwidth(2) lpat(1) 'symbol(15)
	graph3a.setelem(3) linecolor(128,0,64) lwidth(2) lpat(1) 'symbol(15)
	graph3a.NAME(1) GDP ' GDE
	graph3a.NAME(2) HH. Consumption
	graph3a.NAME(3) Prvt. Investment

	graph3a.addtext(4.61,-0.75) Real EURO 20 increase in Carbon Taxes
	if !growth = 1 then
		'graph3a.addtext(-.44, -.25) % pt. change dev. from baseline
		graph3a.addtext(l) % pt. change dev. from baseline
	else
		'graph3a.addtext(-.67, 0.98) % level dev. from baseline
		graph3a.addtext(l) % level dev. from baseline
	endif
	graph3a.legend font("Times", 16)
	graph3a.legend position(3.42,2.04) -inbox
	graph3a.addtext(2,-0.4,font(16)) GDP responses

	group OIL1 {%cty}LMUNRTOTL__4-{%cty}LMUNRTOTL__0 ({%cty}NYGDPGAP__4-{%cty}NYGDPGAP__0) @PC({%cty}NECONPRVTXN_4)-@PC({%cty}NECONPRVTXN_0) 

	freeze(graph3b) OIL1.line
	graph3b.options fillcolor(WHITE) backcolor(WHITE) -INBOX  BACKFADE(NONE) frameaxes(all)
	graph3b.setelem(1) linecolor(148,190,255) lwidth(2) lpat(1) 'symbol(15)
	graph3b.setelem(2) linecolor(255,0,0) lwidth(2) lpat(1) 'symbol(15)
	graph3b.setelem(3) linecolor(128,0,64) lwidth(2) lpat(1) 'symbol(15)
	graph3b.NAME(1) Unemployment Rate
	graph3b.NAME(2) Output Gap
	graph3b.NAME(3) Inflation
	graph3b.addtext(l) % pt. change
	graph3b.legend font("Times", 16)
	graph3b.legend position(3.21,0.20) -inbox
	graph3b.addtext(2,-0.4,font(16)) Gaps

	group OIL2 ({%cty}ggbalovrlcn_4/{%cty}nygdpmktpcn_4-{%cty}ggbalovrlcn_0/{%cty}nygdpmktpcn_0)*100 ({%cty}bncabfundcd_4/{%cty}nygdpmktpcd_4-{%cty}bncabfundcd_0/{%cty}nygdpmktpcd_0)*100

	freeze(graph3c) OIL2.line
	graph3c.options fillcolor(WHITE) backcolor(WHITE) -INBOX  BACKFADE(NONE) frameaxes(all)
	graph3c.setelem(1) linecolor(148,190,255) lwidth(2) lpat(1) 'symbol(15)
	graph3c.setelem(2) linecolor(0,0,0) lwidth(2) lpat(1) 'symbol(15)
	graph3c.NAME(1) Budget (%GDP)
	graph3c.NAME(2) Current Account Balance (%GDP)
	graph3c.addtext(l) % pt. change
	graph3c.legend font("Times", 16)
	graph3c.legend position(1.45,1.02) -inbox
	graph3c.addtext(2,-0.4,font(16)) Budgets

	if !growth = 1 then
		group OIL3 @PC({%cty}NEEXPGNFSKN_4)-@PC({%cty}NEEXPGNFSKN_0) @PC({%cty}NEIMPGNFSKN_4)-@PC({%cty}NEIMPGNFSKN_0)
	else 
		group OIL3 ({%cty}NEEXPGNFSKN_4/{%cty}NEEXPGNFSKN_0-1)*100 ({%cty}NEIMPGNFSKN_4/{%cty}NEIMPGNFSKN_0-1)*100
	endif

	freeze(graph3d) OIL3.line
	graph3d.options fillcolor(WHITE) backcolor(WHITE) -INBOX  BACKFADE(NONE) frameaxes(all)
	graph3d.setelem(1) linecolor(148,190,255) lwidth(2) lpat(1) 'symbol(15)
	graph3d.setelem(2) linecolor(0,0,0) lwidth(2) lpat(1) 'symbol(15)
	graph3d.NAME(1) Export volumes
	graph3d.NAME(2) Import volumes

	if !growth = 1 then
		graph3d.addtext(l) % pt. dev. change from baseline
	else
		graph3d.addtext(l) %GDP dev. from baseline
	endif
	graph3d.legend font("Times", 16)
	graph3d.legend position(0.4,0.31) -inbox
	graph3d.addtext(2,-0.4,font(16)) Trade

	group VA_BLOCK ({%cty}NYGDPFCSTKN_4/{%cty}NYGDPFCSTKN_0-1)*100 100*(({%cty}NVAGRTOTLKN_4-{%cty}NVAGRTOTLKN_0)/{%cty}NYGDPFCSTKN_0) 100*(({%cty}NVINDOTHRKN_4-{%cty}NVINDOTHRKN_0)/{%cty}NYGDPFCSTKN_0) 100*(({%cty}NVENGTOTLKN_4-{%cty}NVENGTOTLKN_0)/{%cty}NYGDPFCSTKN_0) 100*(({%cty}NVSRVTOTLKN_4-{%cty}NVSRVTOTLKN_0)/{%cty}NYGDPFCSTKN_0)
	delete graph3e graph3h

	freeze(graph3e) VA_BLOCK.mixed stackedbar(2,3,4,5) line(1) ' bar(s)
	graph3e.options fillcolor(WHITE) backcolor(WHITE) -INBOX  BACKFADE(NONE) linepat
	graph3e.options stackposneg
	graph3e.setelem(1) linecolor(0,0,0) lwidth(2) lpat(2) 'symbol(15)
	graph3e.setelem(1) fillcolor(0,171,255)
	graph3e.setelem(2) fillcolor(0,64,128) 'fillhatch(DIAGCROSS)
	graph3e.setelem(3) fillcolor(128,0,64)
	graph3e.setelem(4) fillcolor(255,255,0)
	graph3e.NAME(1) GVA
	graph3e.NAME(2) AGR
	graph3e.NAME(3) IND (OTHR)
	graph3e.NAME(4) IND (ENE)
	graph3e.NAME(5) SRV
	graph3e.addtext(2,-0.4,font(16)) Value added composition
	graph3e.addtext(l) % contribution to GVA (deviation from baseline)
	graph3e.legend font("Times", 16) 
	graph3e.legend position(3,0) -inbox

	group EMIS_BLOCK ({%cty}NVINDELECKN_4/{%cty}NVINDELECKN_0-1)*100 ({%cty}NVINDENGYSKN_4/{%cty}NVINDENGYSKN_0-1)*100 ({%cty}CCEMISCO2Q_4/{%cty}CCEMISCO2Q_0-1)*100

	freeze(graph3f) EMIS_BLOCK.line
	graph3f.options fillcolor(WHITE) backcolor(WHITE) -INBOX  BACKFADE(NONE) frameaxes(all)
	graph3f.setelem(1) linecolor(148,190,255) lwidth(2) lpat(1) 'symbol(15)
	graph3f.setelem(2) linecolor(255,0,0) lwidth(2) lpat(1) 'symbol(15)
	graph3f.setelem(3) linecolor(128,0,64) lwidth(2) lpat(1) 'symbol(15)
	graph3f.NAME(1) Electricity VA
	graph3f.NAME(2) Other Energy VA
	graph3f.NAME(3) Fossil-fuel emissions
	graph3f.addtext(2,-0.4,font(16)) Energy and emissions
	graph3f.addtext(l) % deviation from baseline
	graph3f.legend font("Times", 16)
	graph3f.legend position(0.46,0.02) -inbox


	graph co2merge.merge graph3a graph3b graph3c graph3d graph3e graph3f 

	charl.add co2merge
	'charl.name untitled02 "GDPEmis"

	'smpl 2019 2019
	'group ENE_BLOCK2021 ({%cty}nvcolconsqn_4/({%cty}nvcolconsqn_4+{%cty}nvoilconsqn_4+{%cty}nvgasconsqn_4+{%cty}nvrenconsqn_4))*100 ({%cty}nvoilconsqn_4/({%cty}nvcolconsqn_4+{%cty}nvoilconsqn_4+{%cty}nvgasconsqn_4+{%cty}nvrenconsqn_4))*100 ({%cty}nvgasconsqn_4/({%cty}nvcolconsqn_4+{%cty}nvoilconsqn_4+{%cty}nvgasconsqn_4+{%cty}nvrenconsqn_4))*100 ({%cty}nvrenconsqn_4/({%cty}nvcolconsqn_4+{%cty}nvoilconsqn_4+{%cty}nvgasconsqn_4+{%cty}nvrenconsqn_4))*100 

	group ENE_BLOCK2021 ({%cty}nvcolprodqn_4/({%cty}nvcolprodqn_4+{%cty}nvoilprodqn_4+{%cty}nvgasprodqn_4+{%cty}nvrenprodqn_4))*100 ({%cty}nvoilprodqn_4/({%cty}nvcolprodqn_4+{%cty}nvoilprodqn_4+{%cty}nvgasprodqn_4+{%cty}nvrenprodqn_4))*100 ({%cty}nvgasprodqn_4/({%cty}nvcolprodqn_4+{%cty}nvoilprodqn_4+{%cty}nvgasprodqn_4+{%cty}nvrenprodqn_4))*100 ({%cty}nvrenprodqn_4/({%cty}nvcolprodqn_4+{%cty}nvoilprodqn_4+{%cty}nvgasprodqn_4+{%cty}nvrenprodqn_4))*100 

	freeze(graph3g) ENE_BLOCK2021.bar(s)
	graph3g.options fillcolor(WHITE) backcolor(WHITE) -INBOX  BACKFADE(NONE) 'bar
	graph3g.setelem(1) fillcolor(0,171,255)
	graph3g.setelem(2) fillcolor(0,64,128) 'fillhatch(DIAGCROSS)
	graph3g.setelem(3) fillcolor(128,0,64)
	graph3g.setelem(4) fillcolor(255,255,0)
	graph3g.NAME(1) Coal
	graph3g.NAME(2) Oil
	graph3g.NAME(3) Gas
	graph3g.NAME(4) Ren
	graph3g.addtext(2,-0.4,font(16)) Energy composition
	graph3g.addtext(l) % total energy
	graph3g.legend font("Times", 16) 
	graph3g.legend position(3,0) -inbox
	graph3g.axis(l) range(0,100)

	group ENE_BLOCK2022 ({%cty}nvcoleleqn_4/({%cty}nvcoleleqn_4+{%cty}nvoileleqn_4+{%cty}nvgaseleqn_4+{%cty}nvreneleqn_4))*100 ({%cty}nvoileleqn_4/({%cty}nvcoleleqn_4+{%cty}nvoileleqn_4+{%cty}nvgaseleqn_4+{%cty}nvreneleqn_4))*100 ({%cty}nvgaseleqn_4/({%cty}nvcoleleqn_4+{%cty}nvoileleqn_4+{%cty}nvgaseleqn_4+{%cty}nvreneleqn_4))*100 ({%cty}nvreneleqn_4/({%cty}nvcoleleqn_4+{%cty}nvoileleqn_4+{%cty}nvgaseleqn_4+{%cty}nvreneleqn_4))*100

	freeze(graph3h) ENE_BLOCK2022.bar(s)
	graph3h.options fillcolor(WHITE) backcolor(WHITE) -INBOX  BACKFADE(NONE) 'bar
	graph3h.setelem(1) fillcolor(0,171,255)
	graph3h.setelem(2) fillcolor(0,64,128) 'fillhatch(DIAGCROSS)
	graph3h.setelem(3) fillcolor(128,0,64)
	graph3h.setelem(4) fillcolor(255,255,0)
	graph3h.NAME(1) Coal
	graph3h.NAME(2) Oil
	graph3h.NAME(3) Gas
	graph3h.NAME(4) Ren
	graph3h.addtext(2,-0.4,font(16)) Electricity composition
	graph3h.addtext(l) % total electricity
	graph3h.legend font("Times", 16) 
	graph3h.legend position(3,0) -inbox
	graph3h.axis(l) range(0,100)

	group emisLine ({%cty}CCEMISCO2Q_4) ({%cty}CCEMISCO2Q_0)

	freeze(graph3i) emisLine.line
	graph3i.options fillcolor(WHITE) backcolor(WHITE) -INBOX  BACKFADE(NONE) frameaxes(all)
	graph3i.setelem(1) linecolor(148,190,255) lwidth(2) lpat(1) 'symbol(15)
	graph3i.setelem(2) linecolor(0,0,0) lwidth(2) lpat(1) 'symbol(15)
	graph3i.NAME(1) Scenario emissions
	graph3i.NAME(2) Baseline emissions
	graph3i.addtext(l) million t
	graph3i.legend font("Times", 16)
	graph3i.legend position(1.45,1.02) -inbox
	graph3i.addtext(2,-0.4,font(16)) Emissions 

	'smpl %sim_start-1 %sim_end-!cut
	smpl 1980 %sim_end-!cut
	group EMET_BLOCK {%cty}EMCOLFULT_4/1000000 {%cty}EMOILFULT_4/1000000 {%cty}EMGASFULT_4/1000000

	freeze(graph3j) EMET_BLOCK.area
	graph3j.options fillcolor(WHITE) backcolor(WHITE) -INBOX  BACKFADE(NONE) 'bar
	graph3j.setelem(1) fillcolor(0,171,255)
	graph3j.setelem(2) fillcolor(0,64,128) 'fillhatch(DIAGCROSS)
	graph3j.setelem(3) fillcolor(128,0,64)
	graph3j.NAME(1) Coal
	graph3j.NAME(2) Oil
	graph3j.NAME(3) Gas
	graph3j.addtext(2,-0.4,font(16)) CO2 emissions
	graph3j.addtext(l) million t
	graph3j.legend font("Times", 16) 
	graph3j.legend position(3,0) -inbox

	smpl %sim_start-1 %sim_end-!cut
	group ene_int (1000*({%cty}nvcoleleqn_4/85.9845)+1000*({%cty}nvoileleqn_4/85.9845)+1000*({%cty}nvgaseleqn_4/85.9845)+1000*({%cty}nvreneleqn_4/85.9845))/@elem({%cty}NYGDPMKTPCD,"2011")  (1000*({%cty}nvcoleleqn_0/85.9845)+1000*({%cty}nvoileleqn_0/85.9845)+1000*({%cty}nvgaseleqn_0/85.9845)+1000*({%cty}nvreneleqn_0/85.9845))/@elem({%cty}NYGDPMKTPCD,"2011")  

	freeze(graph3k) ene_int.line
	graph3k.options fillcolor(WHITE) backcolor(WHITE) -INBOX  BACKFADE(NONE) frameaxes(all)
	graph3k.setelem(1) linecolor(148,190,255) lwidth(2) lpat(1) 'symbol(15)
	graph3k.setelem(2) linecolor(0,0,0) lwidth(2) lpat(1) 'symbol(15)
	graph3k.NAME(1) Scenario emissions
	graph3k.NAME(2) Baseline emissions
	graph3k.addtext(l) kWh per 2011 GDP
	graph3k.legend font("Times", 16)
	graph3k.legend position(1.45,1.02) -inbox
	graph3k.addtext(2,-0.4,font(16)) Energy inensity

	' EM = m tons; ENE = ktoe ;  1 KTOE = 85.9545 tWH 
	' EM(kg) / ENE(kwh) = [EM/10^6]

	group ene_int2 ({%cty}CCEMISCO2Q_4/1000000)/(({%cty}nvcolprodqn_4/85.9545)+({%cty}nvoilprodqn_4/85.9545)+({%cty}nvgasprodqn_4/85.9545)) ({%cty}CCEMISCO2Q_0/1000000)/(({%cty}nvcolprodqn_0/85.9545)+({%cty}nvoilprodqn_0/85.9545)+({%cty}nvgasprodqn_0/85.9545))  

	freeze(graph3l) ene_int2.line
	graph3l.options fillcolor(WHITE) backcolor(WHITE) -INBOX  BACKFADE(NONE) frameaxes(all)
	graph3l.setelem(1) linecolor(148,190,255) lwidth(2) lpat(1) 'symbol(15)
	graph3l.setelem(2) linecolor(0,0,0) lwidth(2) lpat(1) 'symbol(15)
	graph3l.NAME(1) Scenario emissions
	graph3l.NAME(2) Baseline emissions
	graph3l.addtext(l) kg/kWh
	graph3l.legend font("Times", 16)
	graph3l.legend position(1.45,1.02) -inbox
	graph3l.addtext(2,-0.4,font(16)) Carbon intensity of energy production



	graph co2merge2.merge graph3g graph3h graph3i graph3j graph3k graph3l
	charl.add co2merge2

stop
'===================================================
''show EMIS_BLOCK OIL3 OIL2 OIL1 OIL ({%cty}GGDBTTOTLCN_4/{%cty}NYGDPMKTPCN_4-{%cty}GGDBTTOTLCN_0/{%cty}NYGDPMKTPCN_0)*100 ({%cty}NEGDIKSTKKN_4/{%cty}NYGDPMKTPKN_4-{%cty}NEGDIKSTKKN_0/{%cty}NYGDPMKTPKN_0)*100 ({%cty}APDEATHS_4/{%cty}APDEATHS_0-1)*100 ({%cty}PM25_4/{%cty}PM25_0-1)*100

' show {%cty}NYGDPMKTPKN {%cty}NYGDPMKTPCN {%cty}NECONPRVTKN {%cty}LMEMPTOTLCN {%cty}LMUNRTOTLCN {%cty}NEEXPGNFSKN {%cty}NEIMPGNFSKN {%cty}CCEMISCO2Q {%cty}NVINDELECKN  {%cty}NVELCFSRTKN*{%cty}NVCOLPRODKN {%cty}NVELCFSRTKN*{%cty}NVOILPRODKN {%cty}NVELCFSRTKN*{%cty}NVGASPRODKN {%cty}NVRENPRODKN ({%cty}NVINDELECCN/{%cty}NVINDELECKN) {%cty}NVOILPRODXN {%cty}NVGASPRODXN {%cty}NVCOLPRODXN ({%cty}NVINDELECKN+{%cty}NVINDENGYSKN)

'show ({%cty}NYGDPMKTPKN_4/{%cty}NYGDPMKTPKN_0-1)*100 ({%cty}NYGDPMKTPCN_4/{%cty}NYGDPMKTPCN_0-1)*100 ({%cty}NECONPRVTKN_4/{%cty}NECONPRVTKN_0-1)*100 ({%cty}LMEMPTOTLCN_4/{%cty}LMEMPTOTLCN_0-1)*100 ({%cty}LMUNRTOTLCN_4-{%cty}LMUNRTOTLCN_0) ({%cty}NEEXPGNFSKN_4/{%cty}NEEXPGNFSKN_0-1)*100 ({%cty}NEIMPGNFSKN_4/{%cty}NEIMPGNFSKN_0-1)*100 ({%cty}CCEMISCO2Q_4/{%cty}CCEMISCO2Q_0-1)*100 ({%cty}NVINDELECKN_4/{%cty}NVINDELECKN_0-1)*100 (({%cty}NVELCFSRTKN*{%cty}NVCOLPRODKN_4)/({%cty}NVELCFSRTKN*{%cty}NVCOLPRODKN_0)-1)*100 (({%cty}NVELCFSRTKN*{%cty}NVOILPRODKN_4)/({%cty}NVELCFSRTKN*{%cty}NVOILPRODKN_0)-1)*100 (({%cty}NVELCFSRTKN*{%cty}NVGASPRODKN_4)/({%cty}NVELCFSRTKN*{%cty}NVGASPRODKN_0)-1)*100 ({%cty}NVRENPRODKN_4/{%cty}NVRENPRODKN_0-1)*100 (({%cty}NVINDELECCN_4/{%cty}NVINDELECKN_4)/({%cty}NVINDELECCN_0/{%cty}NVINDELECKN_0)-1)*100 ({%cty}NVOILPRODXN_4/{%cty}NVOILPRODXN_0-1)*100 ({%cty}NVGASPRODXN_4/{%cty}NVGASPRODXN_0-1)*100 ({%cty}NVCOLPRODXN_4/{%cty}NVCOLPRODXN_0-1)*100 (({%cty}NVINDELECKN_4+{%cty}NVINDENGYSKN_4)/({%cty}NVINDELECKN_0+{%cty}NVINDENGYSKN_0)-1)*100


''show ({%cty}NYGDPMKTPKN_4/{%cty}NYGDPMKTPKN_0-1)*100 ({%cty}NYGDPMKTPCN_4/{%cty}NYGDPMKTPCN_0-1)*100 ({%cty}NECONPRVTKN_4/{%cty}NECONPRVTKN_0-1)*100 ({%cty}LMEMPTOTLCN_4/{%cty}LMEMPTOTLCN_0-1)*100 ({%cty}LMUNRTOTLCN_4-{%cty}LMUNRTOTLCN_0) ({%cty}NEEXPGNFSKN_4/{%cty}NEEXPGNFSKN_0-1)*100 ({%cty}NEIMPGNFSKN_4/{%cty}NEIMPGNFSKN_0-1)*100 ({%cty}CCEMISCO2Q_4/{%cty}CCEMISCO2Q_0-1)*100 ({%cty}NVINDELECKN_4/{%cty}NVINDELECKN_0-1)*100 (({%cty}NVELCFSRTKN*{%cty}NVCOLPRODKN_4)/({%cty}NVELCFSRTKN*{%cty}NVCOLPRODKN_0)-1)*100 (({%cty}NVELCFSRTKN*{%cty}NVOILPRODKN_4)/({%cty}NVELCFSRTKN*{%cty}NVOILPRODKN_0)-1)*100 (({%cty}NVELCFSRTKN*{%cty}NVGASPRODKN_4)/({%cty}NVELCFSRTKN*{%cty}NVGASPRODKN_0)-1)*100 ({%cty}NVRENPRODKN_4/{%cty}NVRENPRODKN_0-1)*100 (({%cty}NVINDELECCN_4/{%cty}NVINDELECKN_4)/({%cty}NVINDELECCN_0/{%cty}NVINDELECKN_0)-1)*100 ({%cty}NVOILPRODXN_4/{%cty}NVOILPRODXN_0-1)*100 ({%cty}NVGASPRODXN_4/{%cty}NVGASPRODXN_0-1)*100 ({%cty}NVCOLPRODXN_4/{%cty}NVCOLPRODXN_0-1)*100 (({%cty}NVINDELECKN_4+{%cty}NVINDENGYSKN_4)/({%cty}NVINDELECKN_0+{%cty}NVINDENGYSKN_0)-1)*100 ({%cty}GGREVCO2CER_3*(0.89))


'show ({%cty}nvcoleleqn_4/{%cty}nvcoleleqn_0-1)*100 ({%cty}nvoileleqn_4/{%cty}nvoileleqn_0-1)*100 ({%cty}nvgaseleqn_4/{%cty}nvgaseleqn_0-1)*100 ({%cty}nvreneleqn_4/{%cty}nvreneleqn_0-1)*100 ({%cty}ggrevtotlcn_4/{%cty}ggrevtotlcn_0-1)*100 ({%cty}ggexptotlcn_4/{%cty}ggexptotlcn_0-1)*100 ({%cty}pm25_4/{%cty}pm25_0-1)*100

'show {%cty}necolconelcn/(scalingf*((wldfcoal_aus*1000)*convmttoe*{%cty}panusatls/1000000+{%cty}ggrevco2cer*(emiscoal*1000)*({%cty}panusatls/1000000))) {%cty}necolconelcn_4/(scalingf*((wldfcoal_aus*1000)*convmttoe*{%cty}panusatls_4/1000000+{%cty}ggrevco2cer_4*(emiscoal*1000)*({%cty}panusatls_4/1000000)))
'
'show {%cty}neoilconelcn/(scalingf*((wldfcrude_petro*1000)*convbbltoe*{%cty}panusatls/1000000+{%cty}ggrevco2oer*(emisoil*1000)*({%cty}panusatls/1000000))) {%cty}neoilconelcn_4/(scalingf*((wldfcrude_petro*1000)*convbbltoe*{%cty}panusatls_4/1000000+{%cty}ggrevco2oer_4*(emisoil*1000)*({%cty}panusatls_4/1000000))) '{%cty}nvoileleqn
'
'show {%cty}negasconelcn/(scalingf*((wldfngas_eur*1000)*convmmbtutoe*1*{%cty}panusatls/1000000+{%cty}ggrevco2ger*(emisgas*1000)*({%cty}panusatls/1000000))) {%cty}negasconelcn_4/(scalingf*((wldfngas_eur*1000)*convmmbtutoe*1*{%cty}panusatls_4/1000000+{%cty}ggrevco2ger_4*(emisgas*1000)*({%cty}panusatls_4/1000000)))
'
'show {%cty}nerenconelcn/(scalingf*(wldhydropower*1000)*convkwhtoe*{%cty}panusatls/1000000) {%cty}nerenconelcn_4/(scalingf*(wldhydropower*1000)*convkwhtoe*{%cty}panusatls_4/1000000)

series {%cty}nvcolconsqn_0 = {%cty}nvcolprodqn_0+{%cty}nvcolnimpqn_0
series {%cty}nvoilconsqn_0 = {%cty}nvoilprodqn_0+{%cty}nvoilnimpqn_0
series {%cty}nvgasconsqn_0 = {%cty}nvgasprodqn_0+{%cty}nvgasnimpqn_0
series {%cty}nvrenconsqn_0 = {%cty}nvrenprodqn_0+{%cty}nvrennimpqn_0

series {%cty}nvcolconsqn_4 = {%cty}nvcolprodqn_4+{%cty}nvcolnimpqn_4
series {%cty}nvoilconsqn_4 = {%cty}nvoilprodqn_4+{%cty}nvoilnimpqn_4
series {%cty}nvgasconsqn_4 = {%cty}nvgasprodqn_4+{%cty}nvgasnimpqn_4
series {%cty}nvrenconsqn_4 = {%cty}nvrenprodqn_4+{%cty}nvrennimpqn_4

show ({%cty}NYGDPMKTPKN_4/{%cty}NYGDPMKTPKN_0-1)*100 ({%cty}NYGDPMKTPCN_4/{%cty}NYGDPMKTPCN_0-1)*100 ({%cty}NECONPRVTKN_4/{%cty}NECONPRVTKN_0-1)*100 ({%cty}LMEMPTOTLCN_4/{%cty}LMEMPTOTLCN_0-1)*100 ({%cty}LMUNRTOTLCN_4-{%cty}LMUNRTOTLCN_0) ({%cty}NEEXPGNFSKN_4/{%cty}NEEXPGNFSKN_0-1)*100 ({%cty}NEIMPGNFSKN_4/{%cty}NEIMPGNFSKN_0-1)*100 ({%cty}CCEMISCO2Q_4/{%cty}CCEMISCO2Q_0-1)*100 (({%cty}NVINDELECCN_4/{%cty}NVINDELECKN_4)/({%cty}NVINDELECCN_0/{%cty}NVINDELECKN_0)-1)*100 ({%cty}NVOILPRODXN_4/{%cty}NVOILPRODXN_0-1)*100 ({%cty}NVGASPRODXN_4/{%cty}NVGASPRODXN_0-1)*100 ({%cty}NVCOLPRODXN_4/{%cty}NVCOLPRODXN_0-1)*100 (({%cty}NVINDELECKN_4+{%cty}NVINDENGYSKN_4)/({%cty}NVINDELECKN_0+{%cty}NVINDENGYSKN_0)-1)*100 ({%cty}GGREVCO2CER_3*(0.89)) ({%cty}GGREVCO2CER_3*(0.89)/({%cty}NECONPRVTXN/@elem({%cty}NECONPRVTXN,"2021"))) ({%cty}nvcoleleqn_4/{%cty}nvcoleleqn_0-1)*100 ({%cty}nvoileleqn_4/{%cty}nvoileleqn_0-1)*100 ({%cty}nvgaseleqn_4/{%cty}nvgaseleqn_0-1)*100 ({%cty}nvreneleqn_4/{%cty}nvreneleqn_0-1)*100 ({%cty}ggrevtotlcn_4/{%cty}ggrevtotlcn_0-1)*100 ({%cty}ggexptotlcn_4/{%cty}ggexptotlcn_0-1)*100 ({%cty}pm25_4/{%cty}pm25_0-1)*100 ({%cty}nvcolconsqn_4/{%cty}nvcolconsqn_0-1)*100 ({%cty}nvoilconsqn_4/{%cty}nvoilconsqn_0-1)*100 ({%cty}nvgasconsqn_4/{%cty}nvgasconsqn_0-1)*100 ({%cty}nvrenconsqn_4/{%cty}nvrenconsqn_0-1)*100 ({%cty}nvcolprodqn_4/{%cty}nvcolprodqn_0-1)*100 ({%cty}nvoilprodqn_4/{%cty}nvoilprodqn_0-1)*100 ({%cty}nvgasprodqn_4/{%cty}nvgasprodqn_0-1)*100 ({%cty}nvrenprodqn_4/{%cty}nvrenprodqn_0-1)*100 ({%cty}nvcolnimpqn_4/{%cty}nvcolnimpqn_0-1)*100 ({%cty}nvoilnimpqn_4/{%cty}nvoilnimpqn_0-1)*100 ({%cty}nvgasnimpqn_4/{%cty}nvgasnimpqn_0-1)*100 ({%cty}nvrennimpqn_4/{%cty}nvrennimpqn_0-1)*100 '{%cty}GGREVEMISCN_3


