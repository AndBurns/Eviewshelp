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
%end_date = "2022"
%end_date_interface = "2019"

'Estimation period
%end_estimate = "2018"

'Solve period
%solve_start = "2013"
%solve_end = %end_date

'Forecast period
%forecast_start = "2023"
%forecast_end = "2050"

'End of data template
%template_end = %forecast_end

'Interface display
%display_start = "2012"
%display_end = "2030"

'***************************************************
' Check setup
'***************************************************
!check_id = 0

'***************************************************
' 2. READ DATA
'***************************************************
include .\build\02_readdata.prg
logmsg ******** 02_readdata DONE!

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
' 5. INTERFACE
'***************************************************
include .\build\05_interface.prg
logmsg ******** 05_interface DONE!

cd %extractpath
	wfsave {%cty}soln.wf1
cd %rootpath

'***************************************************
' 9. CHECK
'***************************************************
 include .\build\99_convergence.prg
 logmsg ******** 99_convergence DONE!
 
'***************************************************
' 10. SHOCKS
'***************************************************
 include  .\build\99_IRF.prg
 logmsg ******** 99_shock DONE!


