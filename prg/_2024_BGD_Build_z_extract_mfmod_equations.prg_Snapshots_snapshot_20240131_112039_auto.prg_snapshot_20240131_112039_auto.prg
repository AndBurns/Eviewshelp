close @all
logmode l

%path=@runpath
cd %path

%cty="BGD"

wfopen ..\data\{%cty}MPOSol.wf1

%endog={%cty}.@stochastic
%endog = @wdrop(%endog, "*_M")
%endog = @wcross("_", %endog)

%idents={%cty}.@identity
%idents = @wdrop(%idents, %cty+"NYGDPMKTPKP")	

delete(noerr) mod_spec

table(1000,1) mod_spec

scalar r = 1

mod_spec(r+2,1) = "' From here build model"
mod_spec(r+4,1) = "model" + %cty

r=r+6

for %var {%endog}
	mod_spec(r,1) = "smpl "+ {%var}.@smpl
	mod_spec(r+1,1)="equation "+%var+".ls(optmethod=legacy) "+{%var}.@spec
	r=r+3
next

r=r+2

mod_spec(r,1)="     Identity equations --------------------------------------"
r=r+2

for %var {%idents}
	%temp={%cty}.@spec(%var)
	mod_spec(r,1)=%cty+".append @identity "+%temp
	r=r+2
next

'freeze mod_spec

mod_spec.save(t=txt) "Current_equations.prg"


