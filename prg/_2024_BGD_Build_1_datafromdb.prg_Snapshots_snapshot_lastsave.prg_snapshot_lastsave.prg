' ======================================
' DATA PULLS AND TRANSFORMATION FROM DB
' ======================================
	close @all
	%cty = "BGD"
	%dat_start = "1980"
	%fcst_end = "2050"

	' Read exogenous as well as all MRTF related variables from the database
	wfcreate a %dat_start  %fcst_end
	wfopen W:\MFM\MacroXsupport\MODEL_EX\data\models_most_recent.wf1

	wfselect UNTITLED
	
	%temp1 = " usaneconprvtxn deuneconprvtxn DEUPANUSATLS USAPANUSATLS USAINTRFR  USAFMLBLPOLYFR DEUFMLBLPOLYFR WLTNEIMPGNFSXD WLTNEEXPGNFSXD dumh_bop dumh_fsc dumh_nia  MUV T_LR USAnvsrvtotlxn DEUnvsrvtotlxn  T_SR C_SR ZAFFMLBLPOLYFR ZAFPANUSATLS DUMH_EXR" 'USAINTRDIFF dum05 _COEFAGRP _COEFINDP C_NEGDIFTOTKN C_NEGDIFPRVKN ZAFFMLBLPOLYFR PAKGGDBTGRNTCN MKDGGBALSOEACN those are empty hence redundant C_ENGHGTESINTENSITY C_ENTESGDPINTENSITY C_ENAGRGHGEKT C_ENINDGHGEKT C_ENWSTGHGEKT C_ENFUGGHGEKT

	for %a {%temp1}
		copy models_most_recent::Untitled\{%a} *
	next

	copy models_most_recent::Untitled\*exr05 
	copy models_most_recent::Untitled\*PCEXN05 
	copy models_most_recent::Untitled\*neimpgnfskd 
	copy models_most_recent::Untitled\*NYGDPMKTPCD
	copy models_most_recent::Untitled\wldf* 
	copy models_most_recent::Untitled\{%cty}* 
	copy models_most_recent::Untitled\va_countries
	copy models_most_recent::Untitled\ff_countries

if @wfind(va_countries,%cty) then
logmsg %cty "is a va-country - no model exists"
stop
endif

	if !SACU = 1 then
		%sacus = "LSONEIMPGNFSSCCN BWANEIMPGNFSSCCN NAMNEIMPGNFSSCCN SWZNEIMPGNFSSCCN BWAGGREVCUSTSACUCN LSOGGREVCUSTSACUCN NAMGGREVCUSTSACUCN SWZGGREVCUSTSACUCN BWANYGDPFCSTCD LSONYGDPFCSTCD NAMNYGDPFCSTCD SWZNYGDPFCSTCD BWAGGREVEXCSACUCN LSOGGREVEXCSACUCN NAMGGREVEXCSACUCN ZAFGGREVEXCSACUCN SWZGGREVEXCSACUCN ZAFNEIMPGNFSSCCN ZAFGGREVCUSTSACUCN ZAFPANUSATLS ZAFNYGDPFCSTCD BWANEIMPGNFSCN BWAGGREVSACUCN LSOGGREVSACUCN NAMGGREVSACUCN SWZGGREVSACUCN ZAFGGREVSACUCN"
		
		for %aa {%sacus}
			copy models_most_recent::Untitled\{%aa} *
		next
	endif

' ====================================
' Read existing equations

	copy models_most_recent::_{%cty}* untitled::_{%cty}*

	close models_most_recent

	

string exogs={%cty}.@exoglist
string endogs={%cty}.@endoglist
delete(noerr) gms
string stoch={%cty}.@stochastic

for %var {stoch}
	if (@instr(%var,"_M")>0) then ' 
		{%cty}.droplink(NOERR) _{%var}S
	endif
next

delete *_MS

	' if %cty = "LAO" then
		' {%cty}.droplink(noerr) _LAONVINDTOTLXN_MS
	' endif


