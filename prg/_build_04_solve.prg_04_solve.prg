'*******************************************************************
' TEST IDENTITIES
'*******************************************************************
if !check_id=1 then
	smpl %solve_start %solve_end

		{%cty}.addassign(v=c) @identity
		{%cty}.addinit(v=n) @identity
		
		string ident = {%cty}.@identity
		string ident_a = @wcross(ident,"_a")
		
		scalar maxabs = 0
		for %var {ident_a}
			!buff = @max(abs({%var}))
			if !buff>maxabs then
				maxabs = !buff
			endif
		next
		
		freeze(_tident,mode=overwrite) {ident_a}
		_tident.setformat(@all) f.4
		show _tident 
		show maxabs
	stop
endif

'******************************************************************
' QUASI IDENTITIES
'******************************************************************
string _ms
string quasi_identity

%vars={%cty}.@stochastic
for %eqn {%vars}
	_ms = _ms + " " + %eqn

	if @isobject("_"+%eqn) then
		%tempname=_{%eqn}.@subst

		if @right(%tempname,4)="DUMH" then
			quasi_identity = quasi_identity+ " " + %eqn
		endif

	endif
next

quasi_identity = @wreplace(quasi_identity,%cty+"*","*")

'*******************************************************************
' SOLVE HISTORY
'*******************************************************************
	smpl %end_date_interface+1 %forecast_end
		series DUMH = 0
	smpl @all
	
	smpl %solve_start %solve_end
	{%cty}.scenario "baseline"
	{%cty}.addassign(i,c) @stochastic 'assign add factors to the model equations
	{%cty}.addinit(v=n) @stochastic 'set add factors
	{%cty}.solve(s=d,d=d,o={%solve_method},i=a,c=1e-6,f=t,v=t,g=n)
	logmsg Solved history {%cty} {%solve_start} {%solve_end}

'******************************************************
' SET EXOGENOUS OUT OF SAMPLE VALUES
'******************************************************
include .\extend_forecast.prg

!inflexpt = 5.5 'Inflation rate (in %)
!popgrowth = 1.46543879507417 '@elem(@PC(BGDSPPOP1564TO),"2019") 'Population growth (in %)
!tfpgrowth = 1.458361771171091 '@elem(@PC(BGDNYGDPTFP),"2019") 'TFP growth(in %)
!labshare = 0.7 '@elem(BGDNYYWBTOTLCN_,"2019") 'Labor share

'Define groups of variables to extend
	string exoglist = {%cty}.@exoglist
	
	'Constant
		%l_constant = "USAINTRFR BELPANUSATLS CANPANUSATLS CHNPANUSATLS DEUPANUSATLS ESPPANUSATLS FRAPANUSATLS GBRPANUSATLS INDPANUSATLS ITAPANUSATLS NLDPANUSATLS TURPANUSATLS USAPANUSATLS " + " " + "T_LR BGDNYYWBTOTLCN_ BGDDEPR BGDGGFINEXTLSHARE_ BGDINTRDDIFFFR BGDINTREDIFFFR BGDNEKRTPREMFR BGDNECONGOVTCOV_ BGDNEGDIFGOVCOV_" 'BGDINFLEXPT
	
	'Volume
		%l_volume = "BELNEIMPGNFSKD CANNEIMPGNFSKD CHNNEIMPGNFSKD DEUNEIMPGNFSKD ESPNEIMPGNFSKD FRANEIMPGNFSKD GBRNEIMPGNFSKD INDNEIMPGNFSKD ITANEIMPGNFSKD NLDNEIMPGNFSKD TURNEIMPGNFSKD USANEIMPGNFSKD ROWNEIMPGNFSKD BGDNYGDPDISCKN BGDNYTAXNINDKN BGDNEGDISTKBKN"

	'Price
		%l_price = "WLDFALUMINUM WLDFBANANA_US WLDFBEEF WLDFCOAL_AUS WLDFCOCOA WLDFCOFFEE_COMPO WLDFCOPPER WLDFCOTTON_A_INDX WLDFCRUDE_PETRO WLDFGOLD WLDFGRNUT WLDFGRNUT_OIL WLDFIRON_ORE WLDFISTL_JP_INDX WLDFLEAD WLDFLOGS_MYS WLDFMAIZE WLDFNGAS_EUR WLDFNICKEL WLDFORANGE WLDFPALM_OIL WLDFPLYWOOD WLDFRICE_05 WLDFRUBBER1_MYSG WLDFSAWNWD_MYS WLDFSILVER WLDFSORGHUM WLDFSOYBEAN_MEAL WLDFSOYBEAN_OIL WLDFSOYBEANS WLDFSUGAR_WLD WLDFTEA_AVG WLDFTOBAC_US WLDFWHEAT_US_HRW WLDFWOODPULP MUV" + " " + "BELNECONPRVTXN CANNECONPRVTXN CHNNECONPRVTXN DEUNECONPRVTXN ESPNECONPRVTXN FRANECONPRVTXN GBRNECONPRVTXN INDNECONPRVTXN ITANECONPRVTXN NLDNECONPRVTXN TURNECONPRVTXN USANECONPRVTXN"

	'Nominal
		%l_value = "GBRNYGDPMKTPCD INDNYGDPMKTPCD ITANYGDPMKTPCD KWTNYGDPMKTPCD MYSNYGDPMKTPCD OMNNYGDPMKTPCD PAKNYGDPMKTPCD QATNYGDPMKTPCD SAUNYGDPMKTPCD USANYGDPMKTPCD BGDNYGDPDISCCN BGDBFCAFCAPTCD BGDBFCAFNEOMCD BGDGGDBTVALDCN BGDGGDBTVALECN BGDGGEXPOTHRCN BGDGGFINEAMTCN BGDGGFINEDSBCN BGDGGREVOTHRCN BGDNEGDISTKBCN"

	'Wage
		%l_wage = ""

	'Population
		%l_population = "BGDSPPOP1564TO BGDSPPOPTOTL"
		
	'Dummies
		%l_dummy = "DUMH"
	
	'Call subtroutine
		call extend_forecast(%cty,%forecast_start,%forecast_end,%l_constant,%l_value,%l_volume,%l_price,%l_wage,%l_population,%l_dummy,!inflexpt,!popgrowth,!tfpgrowth,!labshare)

'Ad hoc
	smpl %forecast_start %forecast_end
		series BGDNECONGOVTCOV_ = 100
		series BGDNEGDIFGOVCOV_ = 100
	smpl @all
	
'Final check for variables to extend
	string remainingToExtend = @wdrop(exoglist,_extended_forecast) '_extended_forecast is returned by the subroutine as the list of all variables that have been extended
	show remainingToExtend 'string remainingToExtend should be empty
	
	string extraExtended = @wdrop(_extended_forecast,exoglist)
	show extraExtended
	
'*******************************************************************
' SOLVE
'*******************************************************************
'Create New Scenario
setmaxerrs 2
seterrcount 0
setmaxerrs 1

'SOLVE ADD-FACTORS
smpl %forecast_start %forecast_end 
group add *_a
string g_add=add.@members

smpl %forecast_start %forecast_end
for %var {g_add}
	series {%var} = 0.85 * {%var}(-1) 'Dampening add factor
next

'Force quasi_identity add-factors to 0
smpl %forecast_start %forecast_end
for %var {quasi_identity}
	series {%cty}{%var}_A = 0
next

'Force tax revenue add-factors to 0
smpl %forecast_start %forecast_end
for %var GGREVDRCTCN GGREVEXCDCN GGREVEXPDCN GGREVIMPDCN GGREVNNBRCN GGREVOTHDCN GGREVSUPDCN GGREVTOTHCN GGREVTVATCN
	series {%cty}{%var}_A = 0
next

'Ad hoc adjustments on a case by case basis
	'Constant
		for %var PANUSATLS FMLBLPOLYFR
			series {%cty}{%var} = {%cty}{%var}(-1)
			{%cty}.exclude(m) {%cty}{%var}
		next
	
	'Nominal
		for %var GGEXPCAPTCN GGEXPGNFSCN GGEXPWAGECN
			series {%cty}{%var} = {%cty}{%var}(-1) *(1+!tfpgrowth/100)^(1/!labshare)*(1+!popgrowth/100)*(1+!inflexpt/100)
			{%cty}.exclude(m) {%cty}{%var}
		next
		
	'Real
		' for %var NECONGOVTKN NEGDIFGOVKN
			' series {%cty}{%var} = {%cty}{%var}(-1) *(1+!tfpgrowth/100)^(1/!labshare)*(1+!popgrowth/100)
			' {%cty}.exclude(m) {%cty}{%var}
		' next
		
	'Additional
		' smpl 2020 2020
			series {%cty}NECONPRVTKN_A = 1 * {%cty}NECONPRVTKN_A(-1)
			series {%cty}NEIMPGNFSKN_A = 1 * {%cty}NEIMPGNFSKN_A(-1)
			series {%cty}NEGDIFPRVKN_A = 0 * {%cty}NEGDIFPRVKN_A(-1)
		
'SOLVE OUT-OF-SAMPLE
smpl %solve_start %forecast_end
{%cty}.solve(s=d,d=d,o={%solve_method},i=a,c=1e-12,v=t)	
logmsg Solved full model {%cty} {%forecast_start} {%forecast_end}
	
{%cty}.exclude

'*******************************************************************
' OUT
'*******************************************************************
group g2bcopied *_0
%sdest = @replace(g2bcopied.@members,"_0","")
for %var {%sdest}
 	series {%var}={%var}_0
next
smpl @all