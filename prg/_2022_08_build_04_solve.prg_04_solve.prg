'*******************************************************************
' TEST IDENTITIES
'*******************************************************************
if !check_id=1 then
	' smpl %solve_start %solve_end
	smpl %solve_start 2024

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
string quasi_identity = ""

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
	
	smpl %solve_start %forecast_end
	{%cty}.scenario "baseline"
	{%cty}.addassign(i,c) @stochastic 'assign add factors to the model equations
	{%cty}.addinit(v=n) @stochastic 'set add factors
	{%cty}.solve(s=d,d=d,o={%solve_method},i=a,c=1e-6,f=t,v=t,g=n)
	logmsg Solved history {%cty} {%solve_start} {%forecast_end}



'*******************************************************************
' OUT
'*******************************************************************
group g2bcopied *_0
%sdest = @replace(g2bcopied.@members,"_0","")
%sdest = @replace(g2bcopied.@members, "WLDFRICE5", "WLDFRICE_05")
for %var {%sdest}
	if @isobject(%var+"_0") then
		series {%var}={%var}_0
	endif
next
smpl @all