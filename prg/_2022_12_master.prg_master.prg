'***************************************************
'***************************************************
'MASTER RUN FOR MODEL BUILD
'Authors: Benoit Campagne & Charl Jooste
'***************************************************
'***************************************************
close @all
logmode l

%rootpath = @runpath
%extractpath = %rootpath + "data"
cd %rootpath

%pathxlsdata = %extractpath+"\energy.xlsx"
%pathxlsdata2 = %extractpath+"\SAM.xlsx"

%cty = "BGD"
%model = %cty
%solve_method = "g"

'Historical data
%begin_date = "1980"
%end_date = "2021"
%end_date_interface = "2030"

'Estimation period
%end_estimate = "2018"

'Solve period
%solve_start = "2014"
%solve_end = %end_date

'Forecast period
%forecast_start = "2022"
%forecast_end = "2080"

'End of data template
%template_end = %forecast_end

'Interface display
%display_start = "2012"
%display_end = "2080"

%base_year = "2006"

!fiscRule = 0 ' Enable simpler fiscal rule
'***************************************************
' Energy triggers
'***************************************************

!SR = 1 ' ECM for energy transition. IF !SR = 1 then slow transition for COL, OIL, GAS 
!SR1 = 1 ' ECM for total energy
!SACU = 0 ' Trigger for SACU countries
!natural = 0 ' Trigger for adding natural capital
!damage = 1 ' Trigger for adding damage data
!onlyNELE = 1

'***************************************************
' Check setup
'***************************************************
!check_id = 0

'***************************************************
' 2. READ DATA
'***************************************************
include .\build\02_readdata.prg
logmsg ******** 02_readdata DONE!

include .\build\031_enerdat.prg
logmsg ******** 031_enerday DONE!

'***************************************************
' 3. EQUATIONS
'***************************************************
include .\build\03_equations.prg
logmsg ******** 03_equations DONE!

'***************************************************
' 4. SOLVE
'***************************************************
include .\build\04_solve.prg
logmsg ******** 04_solve DONE!

'***************************************************
' X. ADD DAMAGES
'***************************************************

if !damage = 1 then

smpl @all

include .\build\damagenew.prg


series BGDdebt = 0 ' 
series BGDDBTS = 1 ' Financing adaptation expenditures via debt instead of reducing investment or current expenditures
series COEPINV = 1 ' Cost from wages
'
series BGDexpinv = 0 ' Pay out to investment for insurance and contingency fund

scalar BGDmarkupCF = 0 ' monitoring cost for CF
series BGDGGEXPPREMCN = 0 ' Payments into insurance and contingency fund


series BGDNEKRTPREMFR = (BGDNEKRTTOTLXN*100)/BGDNEGDIFTOTXN  - BGDINTRDFR - ( BGDDEPR  - BGDINFLEXPT)

bgd.drop BGDNEKRTTOTLXN 
bgd.append @identity BGDNEKRTTOTLXN  = BGDNEGDIFTOTXN  / 100  * (BGDINTRDFR + BGDNEKRTPREMFR  + BGDDEPR  - BGDINFLEXPT)
'' Modify equations and add identities
'
SMPL 2002 2018

if (1=0) then
equation _BGDGGEXPCAPTCN.LS BGDGGEXPCAPTCN = C(1)*dumh+0.6*(BGDGGREVTOTLCN-BGDGGEXPINTPCN(-1)-BGDPAYOUTCN)-(1-BGDDBTS)*BGDFININV*(BGDDISPREPCN)+(BGDINSU+BGDCOFU+BGDDEBT)*(BGDEXPINV)*BGDGGEXPRECVCN

equation _BGDGGEXPGNFSCN.LS BGDGGEXPGNFSCN = C(1)*dumh+0.19*(BGDGGREVTOTLCN-BGDGGEXPINTPCN(-1)-BGDPAYOUTCN)-(1-BGDDBTS)*(1-BGDFININV)*(1-COEPINV)*(BGDDISPREPCN)+(BGDINSU+BGDCOFU+BGDDEBT)*(1-BGDEXPINV)*BGDGGEXPRECVCN

equation _BGDGGEXPWAGECN.LS BGDGGEXPWAGECN = C(1)*dumh+0.19*(BGDGGREVTOTLCN-BGDGGEXPINTPCN(-1)-BGDPAYOUTCN)-(1-BGDDBTS)*(1-BGDFININV)*(COEPINV)*(BGDDISPREPCN)+(BGDINSU+BGDCOFU+BGDDEBT)*(1-BGDEXPINV)*BGDGGEXPRECVCN

else

equation _BGDGGEXPCAPTCN.LS DLOG(BGDGGEXPCAPTCN) = C(1) - C(2) * (LOG(BGDGGEXPCAPTCN(-1)) - LOG(BGDNYGDPMKTPCN(-1)-BGDPAYOUTCN(-1)-(1-BGDDBTS)*BGDFININV*(BGDDISPREPCN)+(BGDINSU+BGDCOFU+BGDDEBT)*(BGDEXPINV)*BGDGGEXPRECVCN(-1))) +DLOG(BGDNYGDPMKTPCN-BGDPAYOUTCN-(1-BGDDBTS)*BGDFININV*(BGDDISPREPCN)+(BGDINSU+BGDCOFU+BGDDEBT)*(BGDEXPINV)*BGDGGEXPRECVCN)

equation _BGDGGEXPGNFSCN.LS DLOG(BGDGGEXPGNFSCN) = C(1) - C(2) * (LOG(BGDGGEXPGNFSCN(-1)) - LOG(BGDNYGDPMKTPCN(-1)-BGDPAYOUTCN(-1)-(1-BGDDBTS)*BGDFININV*(BGDDISPREPCN)+(BGDINSU+BGDCOFU+BGDDEBT)*(BGDEXPINV)*BGDGGEXPRECVCN(-1))) +DLOG(BGDNYGDPMKTPCN-BGDPAYOUTCN-(1-BGDDBTS)*BGDFININV*(BGDDISPREPCN)+(BGDINSU+BGDCOFU+BGDDEBT)*(BGDEXPINV)*BGDGGEXPRECVCN)

equation _BGDGGEXPWAGECN.LS DLOG(BGDGGEXPWAGECN) = C(1) - C(2) * (LOG(BGDGGEXPWAGECN(-1)) - LOG(BGDNYGDPMKTPCN(-1)-BGDPAYOUTCN(-1)-(1-BGDDBTS)*BGDFININV*(BGDDISPREPCN)+(BGDINSU+BGDCOFU+BGDDEBT)*(BGDEXPINV)*BGDGGEXPRECVCN(-1))) +DLOG(BGDNYGDPMKTPCN-BGDPAYOUTCN-(1-BGDDBTS)*BGDFININV*(BGDDISPREPCN)+(BGDINSU+BGDCOFU+BGDDEBT)*(BGDEXPINV)*BGDGGEXPRECVCN)

endif

equation _BGDNECONPRVTKN.LS DLOG(BGDNECONPRVTKN) = C(1) +  C(2) * (LOG(BGDNECONPRVTKN(-1)) - LOG((BGDNYYWBTOTLCN(-1)*(1-BGDGGREVDRCTER(-1)/100)+BGDBXFSTREMTCD(-1)*BGDPANUSATLS(-1)+BGDGGEXPTRNSCN(-1))/BGDNECONPRVTXN(-1))) + C(3) * DLOG((BGDNYYWBTOTLCN*(1-BGDGGREVDRCTER/100)+BGDBXFSTREMTCD*BGDPANUSATLS+BGDGGEXPTRNSCN)/BGDNECONPRVTXN)+C(10)*(BGDINTRDFR/100-0.04-@PC(BGDNECONPRVTXN)/100)

SMPL 2002 2018
equation _BGDINTRDDIFFFR.LS BGDINTRDDIFFFR = C(1)+0.05*((BGDGGDBTTOTLCN(-1)/BGDNYGDPMKTPCN(-1))*100-60)
BGD.merge _BGDINTRDDIFFFR
equation _BGDINTREDIFFFR.LS BGDINTREDIFFFR = C(1)+0.05*((BGDGGDBTTOTLCN(-1)/BGDNYGDPMKTPCN(-1))*100-60)
BGD.merge _BGDINTREDIFFFR

' Change energy consumption equations
smpl 2006 2018

%laz1 = "NECOLCONEL NEOILCONEL NEGASCONEL" 

%laz2 = "NECOLCONNE NEOILCONNE NEGASCONNE"

for %a {%laz1}
	BGD.DROP BGD{%a}KN	

	equation _BGD{%a}KN.LS DLOG(BGD{%a}KN) = C(1)-0.3*(LOG(BGD{%a}KN(-1))-BGDCESECOMYCON*LOG(BGDNECONELEXN (-1)/BGD{%a}XN(-1))-LOG(BGDNECONELEKN(-1)))+0.4*DLOG(BGDNECONELEXN/BGD{%a}XN)+0.7*DLOG(BGDNECONELEKN)

	BGD.merge _BGD{%a}KN
next

for %b {%laz2}
	BGD.DROP BGD{%b}KN	

	equation _BGD{%b}KN.LS DLOG(BGD{%b}KN) = C(1)-0.3*(LOG(BGD{%b}KN(-1))-BGDCESECOMYCON*LOG(BGDNECONNELXN (-1)/BGD{%b}XN(-1))-LOG(BGDNECONNELKN(-1)))+0.4*DLOG(BGDNECONNELXN/BGD{%b}XN)+0.7*DLOG(BGDNECONNELKN)

	BGD.merge _BGD{%b}KN
next

' Change energy production equations

%laz3 = "NVCOLPROD NVOILPROD NVGASPROD"

for %c {%laz3}
	BGD.DROP BGD{%c}KN	

	equation _BGD{%c}KN.LS DLOG(BGD{%c}KN) = C(1)-0.3*(LOG(BGD{%c}KN(-1))-BGDCESENGYPROD*LOG(BGDNVENGTOTLXN (-1)/BGD{%c}XN(-1))-LOG(BGDNVENGTOTLKN(-1)))+0.4*DLOG(BGDNVENGTOTLXN/BGD{%c}XN)+0.7*DLOG(BGDNVENGTOTLKN)

	BGD.merge _BGD{%c}KN
next

equation _BGDNECONELEKN.LS DLOG(BGDNECONELEKN) = C(1)-0.3*(LOG(BGDNECONELEKN(-1))-BGDCESENGYCON*LOG(BGDNECONENGYXN(-1)/BGDNECONELEXN(-1))-LOG(BGDNECONENGYKN(-1)))+0.4*DLOG(BGDNECONENGYXN/BGDNECONELEXN)+0.7*DLOG(BGDNECONENGYKN)  

BGD.DROP BGDNECONELEKN
BGD.merge _BGDNECONELEKN

equation _BGDNECONENGYKN.LS DLOG(BGDNECONENGYKN) = C(1)-0.3*(LOG(BGDNECONENGYKN(-1))-BGDCESENGYCON*LOG(BGDNECONPRVTXN(-1)/BGDNECONENGYXN(-1))-LOG(BGDNECONPRVTKN(-1)))+0.4*DLOG(BGDNECONPRVTXN/BGDNECONENGYXN)+0.7*DLOG(BGDNECONPRVTKN)  

BGD.DROP BGDNECONENGYKN
BGD.merge _BGDNECONENGYKN

{%cty}.update
smpl @all
delete *_a *_0
smpl %solve_start %forecast_end  ' %end_dat
{%cty}.addassign(i,c) @stochastic  
{%cty}.addinit(v=n) @stochastic
{%cty}.scenario "baseline"
BGD.solve(s=d,d=d,o={%s}, i=a, g=n)
logmsg "solved baseline"

%endos={%cty}.@endoglist

smpl %solve_start %forecast_end


for %var {%endos}
	series {%var}={%var}_0
next

smpl @all

endif

'***************************************************
' 5. INTERFACE
'***************************************************
include .\build\05_interface.prg
logmsg ******** 05_interface DONE!

if (1=0) then
	cd %extractpath
		wfsave(2) {%cty}soln.wf1
	cd %rootpath
endif
'***************************************************
' 9. CHECK
'***************************************************
 include .\build\99_convergence.prg
 logmsg ******** 99_convergence DONE!
 stop
'***************************************************
' 10. SHOCKS
'***************************************************
 include  .\build\99_IRF.prg
 logmsg ******** 99_shock DONE!


