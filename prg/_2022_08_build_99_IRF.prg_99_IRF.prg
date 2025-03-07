call ui(%forecast_start,%forecast_end)

subroutine ui(string forecast_start,string forecast_end)
	'SELECT THE SHOCK VARIABLE
	string introString = "Select the shock"
	%ShockList = "MUV WLDFSORGHUM BGDGGEXPCAPTCN BGDGGEXPGNFSCN BGDGGEXPWAGECN BGDGGREVIMPDER BGDGGREVEXPDER BGDGGREVTVATER BGDGGREVEXCDER BGDGGREVDRCTER BGDFMLBLPOLYFR BGDNYGDPTFP BGDSPPOP1564TO BGDPANUSATLS USANEIMPGNFSKD BGDNECONPRVTKN BGDNEEXPGNFSKN BGDNEGDIFPRVKN"

	string listTitle = "Please make a selection"
	!selections = 1
	scalar buffUI = @uidialog("text", introString, "list", !selections, listTitle, %ShockList)
	
	if buffUI = 0 then
		string shock = @word(%ShockList,!selections)

		'SELECT THE SHOCK SIZE
		scalar selectionz = 1
		%size = "1"
		scalar buffUI = @uidialog("radio",selectionz,"Select shock size:","Percent_of_GDP Percent_of_baseline Plus_or_minus","edit",%size, "Shock size:")
		
		if buffUI = 0 then
			scalar now = @val(%size)

			'SELECT THE SHOCK SIZE
			scalar selectiondur = 1
			scalar buffUI = @uidialog("radio",selectiondur,"Select shock duration:","Permanent Transitory")
			
			if buffUI = 0 then
				if selectiondur = 1 then
					%duration = forecast_start + " " + forecast_end
					call impulses2(shock,%duration,selectionz,now)
				else
					%duration_end = "2018"
					scalar buffUI = @uidialog("edit",%duration_end, "End of shock:")
					%duration = forecast_start + " " + %duration_end
					
					if buffUI = 0 then
						call impulses2(shock,%duration,selectionz,now)
					endif
				endif				
			endif
		endif
	endif
endsub

subroutine impulses2(string %shock, string %duration, scalar sop, scalar size)
	delete *_0 *_6 
	
	'Recompute the baseline excluding the public expenditure equations
	smpl %forecast_start %forecast_end
	{%cty}.scenario "baseline"
	
	{%cty}.exclude {%cty}GGEXPGNFSCN {%cty}GGEXPWAGECN {%cty}GGEXPTRNSCN {%cty}GGEXPCAPTCN {%cty}NEWRTGOVTXN {%cty}LMEMPGOVT {%cty}FMLBLPOLYFR '{%cty}NECONGOVTKN {%cty}NEGDIFGOVKN

	{%cty}.solve(s=d,d=D,o={%solve_method},i=a,c=1e-6,v=t,g=n)
	logmsg solved baseline {%cty}

	' group g2bcopied *_0
	' %sdest=@replace(g2bcopied.@members,"_0","")
	' for %var {%sdest}
		' series {%var} = {%var}_0
	' next
	' smpl @all

	string draw="ch4 CH4_1 ch5 ch6 ch7" 

	for %fig {draw}
		if @isobject(%fig) then
			delete {%fig}
		endif
	next

	smpl @all

	if @isobject(%shock+"_0") then
		series {%shock}_3={%shock}_0		
		series {%shock}_6={%shock}_0	
	else
		series {%shock}_0={%shock}
		series {%shock}_3={%shock}_0
		series {%shock}_6={%shock}_0

	endif

	' #####################
	' SHOCK
	' #####################
	
	if sop = 1 then
		smpl %duration
		series {%shock}_6 = {%shock}_0 + {%cty}nygdpmktpcn_0 * size/100
		
	else
		if sop = 2 then
			smpl %duration
			series {%shock}_6 = {%shock}_0 * (1 + size/100)

		else
			smpl %duration
			series {%shock}_6 = {%shock}_0 + size
		endif
	endif			

	smpl %forecast_start %forecast_end
	
	{%cty}.scenario(n,a=6) "SHOCK"		
	
	' if @wfind(%cty+"GGEXPGNFSCN",%shock) then
		' {%cty}.exclude {%cty}GGEXPTRNSCN {%cty}GGEXPCAPTCN {%cty}NEWRTGOVTXN {%cty}LMEMPGOVT {%cty}NEGDIFGOVKN 
	' else
		' if @wfind(%cty+"GGEXPCAPTCN",%shock) then
			' {%cty}.exclude {%cty}GGEXPGNFSCN {%cty}GGEXPTRNSCN {%cty}NEWRTGOVTXN {%cty}LMEMPGOVT {%cty}NECONGOVTKN
		' else
			' if @wfind(%cty+"NEWRTGOVTXN",%shock) then
				' {%cty}.exclude {%cty}GGEXPGNFSCN {%cty}GGEXPTRNSCN {%cty}GGEXPCAPTCN {%cty}LMEMPGOVT {%cty}NEGDIFGOVKN
			' else
				' if @wfind(%cty+"LMEMPGOVT",%shock) then
					' {%cty}.exclude {%cty}GGEXPGNFSCN {%cty}GGEXPTRNSCN {%cty}GGEXPCAPTCN {%cty}NEWRTGOVTXN {%cty}NEGDIFGOVKN
				' else
					' {%cty}.exclude {%cty}GGEXPGNFSCN {%cty}GGEXPTRNSCN {%cty}GGEXPCAPTCN {%cty}NEWRTGOVTXN {%cty}LMEMPGOVT {%cty}NECONGOVTKN {%cty}NEGDIFGOVKN
				' endif
			' endif
		' endif
	' endif
	
	' {%cty}.exclude(m) {%cty}FMLBLPOLYFR
	
	{%cty}.exclude {%cty}GGEXPGNFSCN {%cty}GGEXPWAGECN {%cty}GGEXPTRNSCN {%cty}GGEXPCAPTCN {%cty}NEWRTGOVTXN {%cty}LMEMPGOVT {%cty}FMLBLPOLYFR
	
	{%cty}.override(m) {%shock}		
	{%cty}.exclude(m) {%shock}
	
	' {%cty}.SCENARIO(C) "BASELINE" 
	{%cty}.solve(s=d,d=D,o={%solve_method},i=a,c=1e-6,v=t,g=n)
	'{%cty}.SOLVE
	'{%cty}.scenario(d) "gov scen"
	logmsg solved shock {%cty}

	{%shock}={%shock}_3		
	delete {%shock}_3					

	smpl 2015 %forecast_end

	
	' #####################
	' GRAPHICS
	' #####################
	
	spool graphics
		%ch="ch4"
		graph {%ch}.line ({%cty}NYGDPMKTPKN_6/{%cty}NYGDPMKTPKN_0-1)*100  ({%cty}NECONPRVTKN_6/{%cty}NECONPRVTKN_0-1)*100 ({%cty}NEEXPGNFSKN_6/{%cty}NEEXPGNFSKN_0-1)*100 ({%cty}NEIMPGNFSKN_6/{%cty}NEIMPGNFSKN_0-1)*100 ({%cty}NEGDIFTOTKN_6/{%cty}NEGDIFTOTKN_0-1)*100 ({%cty}NECONGOVTKN_6/{%cty}NECONGOVTKN_0-1)*100
		{%ch}.options linepat													
		{%ch}.setelem(1) lcolor(47,131,150) lwidth(2) lpat(1)		
		{%ch}.setelem(2) lcolor(222,110,75) lwidth(2) lpat(1) 'axis(r)
		{%ch}.setelem(3) lcolor(33,69,91) lwidth(2) lpat(1)
		{%ch}.setelem(4) lcolor(0,255,255) lwidth(2) lpat(1)
		{%ch}.setelem(5) lcolor(122,101,91) lwidth(2) lpat(1)
		{%ch}.setelem(6) lcolor(0,0,255) lwidth(2) lpat(1)
		{%ch}.name(1) GDP														
		{%ch}.name(2) Household consumption 
		{%ch}.name(3) Exports 
		{%ch}.name(4) Imports 
		{%ch}.name(5) Investment 
		{%ch}.name(6) Government
		{%ch}.addtext(t,just(c),just(c), font("Arial", 12, +b)) 1% increase in %shock
		{%ch}.legend position(.2,2) -inbox						
		{%ch}.options gridpat(1) gridl -gridb						
		graphics.append {%ch}
		
		%ch="ch4a"
		graph {%ch}.line ({%cty}NYGDPMKTPKN_6/{%cty}NYGDPMKTPKN_0-1)*100  ({%cty}NYGDPPOTLKN_6/{%cty}NYGDPPOTLKN_0-1)*100
		{%ch}.options linepat													
		{%ch}.setelem(1) lcolor(47,131,150) lwidth(2) lpat(1)		
		{%ch}.setelem(2) lcolor(222,110,75) lwidth(2) lpat(1) 'axis(r)
		{%ch}.name(1) GDP														
		{%ch}.name(2) Potential 
		{%ch}.addtext(t,just(c),just(c), font("Arial", 12, +b)) 1% increase in %shock
		{%ch}.legend position(.2,2) -inbox						
		{%ch}.options gridpat(1) gridl -gridb						
		graphics.append {%ch}
		
		%ch="ch4b"
		graph {%ch}.line ({%cty}NEGDIFTOTKN_6/{%cty}NEGDIFTOTKN_0-1)*100 ({%cty}NEGDIFGOVKN_6/{%cty}NEGDIFGOVKN_0-1)*100 ({%cty}NEGDIFPRVKN_6/{%cty}NEGDIFPRVKN_0-1)*100
		{%ch}.options linepat													
		{%ch}.setelem(1) lcolor(47,131,150) lwidth(2) lpat(1)		
		{%ch}.setelem(2) lcolor(222,110,75) lwidth(2) lpat(1) 'axis(r)
		{%ch}.setelem(3) lcolor(33,69,91) lwidth(2) lpat(1)
		{%ch}.name(1) Total investment														
		{%ch}.name(2) Public investment 
		{%ch}.name(3) Private investment
		{%ch}.addtext(t,just(c),just(c), font("Arial", 12, +b)) 1% increase in %shock
		{%ch}.legend position(.2,2) -inbox						
		{%ch}.options gridpat(1) gridl -gridb						
		graphics.append {%ch}
		
		%ch="ch5"
		graph {%ch}.line ({%cty}NECONPRVTXN_6/{%cty}NECONPRVTXN_0-1)*100 ({%cty}NYGDPFCSTXN_6/{%cty}NYGDPFCSTXN_0-1)*100 ({%cty}NEEXPGNFSXN_6/{%cty}NEEXPGNFSXN_0-1)*100 ({%cty}NEIMPGNFSXN_6/{%cty}NEIMPGNFSXN_0-1)*100 ({%cty}NEKRTTOTLXN_6/{%cty}NEKRTTOTLXN_0-1)*100
		{%ch}.options linepat
		{%ch}.setelem(1) lcolor(47,131,150) lwidth(2) lpat(1)
		{%ch}.setelem(2) lcolor(222,110,75) lwidth(2) lpat(1) 'axis(r)
		{%ch}.setelem(3) lcolor(122,101,91) lwidth(2) lpat(1)
		{%ch}.setelem(4) lcolor(0,255,255) lwidth(2) lpat(1)
		{%ch}.setelem(5) lcolor(66,69,91) lwidth(2) lpat(1)
		{%ch}.name(1) HH Deflator
		{%ch}.name(2) Producer Price
		{%ch}.name(3) Export price 
		{%ch}.name(4) Import price
		{%ch}.name(5) Price of capital
		{%ch}.addtext(t,just(c),just(c), font("Arial", 12, +b)) 1% increase in %shock 'gov cons
		{%ch}.legend position(.2,2) -inbox
		{%ch}.options gridpat(1) gridl -gridb
		graphics.append {%ch}
		
		%ch="ch5b"
		graph {%ch}.line ({%cty}NEGDIFTOTXN_6/{%cty}NEGDIFTOTXN_0-1)*100 ({%cty}NEKRTTOTLXN_6/{%cty}NEKRTTOTLXN_0-1)*100 {%cty}FMLBLPOLYFR_6-{%cty}FMLBLPOLYFR_0
		{%ch}.options linepat
		{%ch}.setelem(1) lcolor(47,131,150) lwidth(2) lpat(1)
		{%ch}.setelem(2) lcolor(0,0,180) lwidth(2) lpat(1)
		{%ch}.setelem(3) lcolor(122,101,91) lwidth(2) lpat(1)
		{%ch}.name(1) Investment deflator
		{%ch}.name(2) Price of capital
		{%ch}.name(3) Policy rate (difference)
		{%ch}.addtext(t,just(c),just(c), font("Arial", 12, +b)) 1% increase in %shock 'gov cons
		{%ch}.legend position(.2,2) -inbox
		{%ch}.options gridpat(1) gridl -gridb
		graphics.append {%ch}		


		%ch="ch6"
		graph {%ch}.line ({%cty}GGREVTOTLCN_6/{%cty}GGREVTOTLCN_0-1)*100 ({%cty}GGEXPTOTLCN_6/{%cty}GGEXPTOTLCN_0-1)*100
		{%ch}.setelem(1) lcolor(47,131,150) lwidth(2) lpat(1)
		{%ch}.setelem(2) lcolor(222,110,75) lwidth(2) lpat(1) 'axis(r)
		{%ch}.name(1) Total revenues
		{%ch}.name(2) Total expenditures
		{%ch}.addtext(t,just(c),just(c), font("Arial", 12, +b)) 1% increase in %shock 'gov cons
		{%ch}.legend position(.2,2) -inbox
		{%ch}.options gridpat(1) gridl -gridb
		graphics.append {%ch}

		%ch="ch7"
		graph {%ch}.line ({%cty}NYGDPGAP__6-{%cty}NYGDPGAP__0)  
		{%ch}.setelem(1) lcolor(47,131,150) lwidth(2) lpat(1)
		{%ch}.name(1) Output gap
		{%ch}.addtext(t,just(c),just(c), font("Arial", 12, +b)) 1% increase in %shock 'gov cons
		{%ch}.legend position(.2,2) -inbox
		{%ch}.options gridpat(1) gridl -gridb
		graphics.append {%ch}

		%ch="ch17"
		graph {%ch}.line ({%cty}NYGDPGAP__6-{%cty}NYGDPGAP__0) ({%cty}BNGSRGNFSCD_6/{%cty}NYGDPMKTPCD_6*100-{%cty}BNGSRGNFSCD_0/{%cty}NYGDPMKTPCD_0*100) ({%cty}BNCABFUNDCD_6/{%cty}NYGDPMKTPCD_6*100-{%cty}BNCABFUNDCD_0/{%cty}NYGDPMKTPCD_0*100)
		{%ch}.setelem(1) lcolor(47,131,150) lwidth(2) lpat(1)
		{%ch}.setelem(2) lcolor(0,255,255) lwidth(2) lpat(1)
		{%ch}.setelem(3) lcolor(222,110,75) lwidth(2) lpat(1) 
		{%ch}.name(1) Output gap (nool)
		{%ch}.name(2) Trade balance
		{%ch}.name(3) Current account balance
		{%ch}.addtext(t,just(c),just(c), font("Arial", 12, +b)) 1% increase in %shock 'gov cons
		{%ch}.legend position(.2,2) -inbox
		{%ch}.options gridpat(1) gridl -gridb
		graphics.append {%ch}

		%ch="ch17a"
		graph {%ch}.line ({%cty}BXGSRGNFSCD_6/{%cty}BXGSRGNFSCD_0-1)*100 ({%cty}BXGSRMRCHCD_6/{%cty}BXGSRMRCHCD_0-1)*100 ({%cty}BXGSRNFSVCD_6/{%cty}BXGSRNFSVCD_0-1)*100
		{%ch}.setelem(1) lcolor(47,131,150) lwidth(2) lpat(1)
		{%ch}.setelem(2) lcolor(0,255,255) lwidth(2) lpat(1)
		{%ch}.setelem(3) lcolor(222,110,75) lwidth(2) lpat(1) 
		{%ch}.name(1) Total exports (BOP)
		{%ch}.name(2) Exports of goods (BOP)
		{%ch}.name(3) Exports of services (BOP)
		{%ch}.addtext(t,just(c),just(c), font("Arial", 12, +b)) 1% increase in %shock 'gov cons
		{%ch}.legend position(.2,2) -inbox
		{%ch}.options gridpat(1) gridl -gridb
		graphics.append {%ch}
		
		%ch="ch17b"
		graph {%ch}.line ({%cty}BMGSRGNFSCD_6/{%cty}BMGSRGNFSCD_0-1)*100 ({%cty}BMGSRMRCHCD_6/{%cty}BMGSRMRCHCD_0-1)*100 ({%cty}BMGSRNFSVCD_6/{%cty}BMGSRNFSVCD_0-1)*100
		{%ch}.setelem(1) lcolor(47,131,150) lwidth(2) lpat(1)
		{%ch}.setelem(2) lcolor(0,255,255) lwidth(2) lpat(1)
		{%ch}.setelem(3) lcolor(222,110,75) lwidth(2) lpat(1) 
		{%ch}.name(1) Total imports (BOP)
		{%ch}.name(2) Imports of goods (BOP)
		{%ch}.name(3) Imports of services (BOP)
		{%ch}.addtext(t,just(c),just(c), font("Arial", 12, +b)) 1% increase in %shock 'gov cons
		{%ch}.legend position(.2,2) -inbox
		{%ch}.options gridpat(1) gridl -gridb
		graphics.append {%ch}
		
		%ch="ch17c"
		graph {%ch}.line ({%cty}PANUSATLS_6/{%cty}PANUSATLS_0-1)*100 {%cty}FMLBLPOLYFR_6-{%cty}FMLBLPOLYFR_0
		{%ch}.setelem(1) lcolor(47,131,150) lwidth(2) lpat(1)
		{%ch}.setelem(2) lcolor(0,255,255) lwidth(2) lpat(1)
		{%ch}.name(1) Exchange rate
		{%ch}.name(2) Policy rate (difference)
		{%ch}.addtext(t,just(c),just(c), font("Arial", 12, +b)) 1% increase in %shock 'gov cons
		{%ch}.legend position(.2,2) -inbox
		{%ch}.options gridpat(1) gridl -gridb
		graphics.append {%ch}

		%ch="c19"
		graph {%ch}.line ({%cty}GGDBTTOTLCN_6/{%cty}NYGDPMKTPCN_6*100-{%cty}GGDBTTOTLCN_0/{%cty}NYGDPMKTPCN_0*100) ({%cty}GGBALOVRLCN_6/{%cty}NYGDPMKTPCN_6*100-{%cty}GGBALOVRLCN_0/{%cty}NYGDPMKTPCN_0*100)
		{%ch}.setelem(1) lcolor(47,131,150) lwidth(2) lpat(1)
		{%ch}.setelem(2) lcolor(222,110,75) lwidth(2) lpat(1)
		{%ch}.name(1) Debt (%GDP)
		{%ch}.name(2) BB (%GDP)
		{%ch}.addtext(t,just(c),just(c), font("Arial", 12, +b)) 1% increase in %shock 'gov cons
		{%ch}.legend position(.2,2) -inbox
		{%ch}.options gridpat(1) gridl -gridb
		graphics.append {%ch}

	show graphics
endsub