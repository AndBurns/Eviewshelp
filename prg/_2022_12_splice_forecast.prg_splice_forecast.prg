' =================================================
' COPY FORECAST OF PREVIOUS SOLVE UNTO THIS MODEL
' =================================================
close @all
logmode l
%path = @runpath
%pathfcst = %path+"..\Output\BGDTuesAMSoln.wf1" 'Previous model'
%soln_name = "BGDTuesAMSoln" ' Previous model (want this forecast)
%soln_Output = "bgdsolnnov202228" ' Current model: need previous model data to splice onto this model
%pathfcst1 = %path+"..\Output\bgdsolnnov202228.wf1"
wfopen %pathfcst
'wfopen %pathfcst1
stop
%cty = "BGD"

%SOLVE_START_Q = "2014"
%END_DATE_Q = "2021"
%forecast_end_q = "2050"

'********************************************************************************
'Copy over variables to new workfile

%fcst_endog = BGD.@stochastic
%fcst_exog = BGD.@exoglist
%fcst_ident = BGD.@identity
%fcst_all = %fcst_endog + " " + %fcst_exog + " " + %fcst_ident
'show {%fcst_all}

' -------------------------------------------------
' GROUP STOCHASTIC VARIABLES

%drops= "DUMH T_LR" ' 

' Apply growth rates
%fvars = ""

' Make sure is constant
%constant = "BGDBFCAFRACGCD BGDADAP BGDAGDAMAGE BGDAVDAMAGE BGDCOFU BGDCOVERAGE BGDDEBT BGDEXPINV BGDGGREVELECER BGDHEATLOSS BGDINSU BGDCFVOLUMECN BGDCFVOLUMEKN BGDDISPREPCN BGDDISPREPCNC BGDDISPREPCND BGDDISPREPCNI BGDDISPREPKN BGDDISPREPKNC BGDDISPREPKND BGDDISPREPKNI BGDGGREVELECER BGDFLODAMCN BGDFLODAMKN BGDFLODSTKN BGDGGEXPRECVCN BGDGGREVELECN BGDMARKUP BGDNEADPKSTGKN BGDNEFLOAVERKN BGDNEFLOPTVTKN BGDPAYOUTCN BGDRECOVINVESTKN BGDGGREVELECER_ BGDNEFLOAVERKN_ BGDGGREVELECER"

%fcst_all = @wdrop(%fcst_all,%drops)

wfselect {%soln_Output} ' Open current solution file


'making a level splice of new data to old forecast

for %var {%fcst_all}
	smpl %end_date_q+0 @last

	series {%var}_tnt = {%soln_name}::{%var} 'make the variable var in the forecast period in the defult directory 

	if @wfind(%constant,%var)>0 then
		smpl %end_date_q+1 @last
		series {%var} = {%var}_tnt ' Set your variable equal to previous model (now called TNT) in constant terms
	else
		smpl %end_date_q+1 @last
		series tnt = @pc({%var}_tnt)
		series {%var} = {%var}(-1)*(1+tnt/100) ' Set your variable equal to previous model (now called TNT) in growth terms
		'	copy(o,noerr) {%soln_Input}::{%var} {%soln_Output}::{%var}
 		delete tnt
	endif
next

wfclose {%soln_name}
wfselect {%soln_Output}

'***************************************
'Create New Scenario
setmaxerrs 2
{%cty}.scenario(n,a=3,i="baseline",c) "Splice"
{%cty}.scenario "Splice"
seterrcount 0
setmaxerrs 1
{%cty}.exclude

smpl @all
for %var {%fcst_endog} ' Create a copy of existing model vars
	series {%var}_3 = {%var}
next

smpl %end_date_q+1 @last

for %var {quasi_identity} ' Set quasi-identities to zero
	series {%cty}{%var}_A=0
next

'Exog all selected
String ToBeExog = BGD.@stochastic
ToBeExog =@wdrop(ToBeExog,quasi_identity)
BGD.exclude {ToBeExog} 

smpl @all
     'Solving the model for the new baseline
     'delete *_a


'Recalculate Add-Factors to Be Consistent With Imported Forecasts
smpl %END_DATE_Q+1 %forecast_end_q
for %var {%fcst_endog}
	if @isobject(%var+"_a") then
		BGD.exclude(r) {%var}_a
		BGD.override(m) {%var}
		BGD.exclude(m) {%var}
	endif
next

{%cty}.solve(s=d,d=d,o=g,i=a,c=1e-6,f=t,v=t,g=n)	
logmsg "Recalculated Model With Old Forecasts"+%cty

'Check Forecasts Are Same As Old After Solve
%checkvars="BGDNYGDPMKTPKN BGDNECONPRVTKN   BGDNECONGOVTKN   BGDNEGDIFTOTKN   BGDNEEXPGNFSKN  BGDNEIMPGNFSKN BGDNYGDPMKTPCN BGDNECONPRVTCN   BGDNECONGOVTCN   BGDNEGDIFTOTCN   BGDNEEXPGNFSCN  BGDNEIMPGNFSCN BGDGGEXPTOTLCN BGDGGREVTOTLCN BGDGGBALOVRLCN BGDBNCABFUNDCD"

%checkrev="GGREVTOTLCN GGDBTTOTLCN"

%checkrev=@wcross("BGD",%checkrev)

group g_checkvars
for %var {%checkvars} {%checkrev}
	series __{%var} = {%var}_3/{%var}
next

group checkvars __*
freeze(_tcheckvars,mode=overwrite) checkvars.sheet(t)
show _tcheckvars

group g2BCopied *_3
string sDest=@replace(g2Bcopied.@members,"_3","")
for %var {sDest}
     series {%var}={%var}_3
     delete {%var}_3
next

delete *_3
smpl @all

{%cty}.exclude

stop
if 1=1 then ' Test whether IDENTITIES STILL MATCH UP
	smpl %solve_start_q %END_DATE_Q+10
	{%cty}.addassign(v=c) @identity
	{%cty}.addinit(v=n) @identity
	string ident = {%cty}.@identity
	string ident_a = @wcross(ident,"_a")
	freeze(_tident,mode=overwrite) {ident_a}
	_tident.setformat(@all) f.4
	show _tident
	stop
endif

stop


