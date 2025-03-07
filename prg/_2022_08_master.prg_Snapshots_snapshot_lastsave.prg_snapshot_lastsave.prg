'***************************************************
'***************************************************
'MASTER RUN FOR MODEL BUILD
'Authors: Benoit Campagne

'***************************************************
'***************************************************
close @all
logmode l

%rootpath = @runpath
%extractpath = %rootpath + "data"
cd %rootpath

%cty = "BGD"
%model = %cty
%solve_method = "g"

'Historical data
%begin_date = "1980"
%end_date = "2021"
%end_date_interface = "2021"

'Estimation period
%end_estimate = "2018"

'Solve period
%solve_start = "2013"
%solve_end = %end_date

'Forecast period
%forecast_start = "2022"
%forecast_end = "2050"

'End of data template
%template_end = %forecast_end

'Interface display
%display_start = "2012"
%display_end = "2030"

'Align with MPO
!alignAM20 = 1

'***************************************************
' Check setup
'***************************************************
!check_id = 0

'***************************************************
' 2. READ DATA
'***************************************************
' include .\build\02_readdata.prg
' logmsg ******** 02_readdata DONE!

wfopen W:\MFM\MacroXsupport\BGD\2022_08\data\BGD2022-17-08~16-42-17soln_V4.wf1

smpl @all
	series dumh = 1
smpl %forecast_start %forecast_end
	dumh = 0


smpl 2022 2022
	bgdfirestotlcd.fill(o=2022) 41826.73 
	bgdBFCAFRACGCD.fill(o=2022) 1341.108559767883
smpl 2023 @last
	bgdfirestotlcd = bgdfirestotlcd(-1) - bgdBFCAFRACGCD
smpl @all


{%cty}BFFINFGAPCD = {%cty}BFBOPTOTLCD + {%cty}BFCAFRACGCD

'***************************************************
' 3. EQUATIONS
'***************************************************
' include .\build\03_equations.prg
' logmsg ******** 03_equations DONE!

{%model}.drop BGDBFCAFRACGCD

smpl %begin_date %end_estimate
c = 0
equation _{%cty}BFCAFRACGCD.LS(OPTMETHOD=LEGACY) {%cty}BFCAFRACGCD/{%cty}NYGDPMKTPCD * 100 = c(1)'+c(2)*T_LR
{%model}.merge _{%cty}BFCAFRACGCD 
	

'***************************************************
' 4. SOLVE
'***************************************************
include .\build\04_solve.prg
logmsg ******** 04_solve DONE!

'***************************************************
' 5. INTERFACE
'***************************************************
include .\build\05_interface.prg
' logmsg ******** 05_interface DONE!

cd %extractpath
	wfsave {%cty}soln_sm22.wf1
cd %rootpath

'***************************************************
' 9. CHECK
'***************************************************
 include .\build\99_convergence.prg
 logmsg ******** 99_convergence DONE!
 
'***************************************************
' 10. SHOCKS
'***************************************************
 'include  .\build\99_IRF.prg
 'logmsg ******** 99_shock DONE!


