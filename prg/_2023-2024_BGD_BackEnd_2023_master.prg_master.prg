'***************************************************
'***************************************************
'MASTER RUN FOR MODEL BUILD - Bangladesh MFMSA
'Authors: Benoit Campagne & Charl Jooste
'Last update: Unnada Chewpreecha 
'Date: November 2023
'Comments: streamline model to cover economy only
'***************************************************
'***************************************************
close @all
logmode l

'Save solution option (1=save, 0 = no)
!savesoln = 1

'change directory to current run pate
%rootpath = @runpath
%extractpath = %rootpath + "data"
cd %rootpath

'Settings
%cty = "BGD" 
%model = %cty
%solve_method = "g"

'Data input file name
%datafile = "BGDdataforupdateNOV2022.xls"

'Key model assumptions
!labshare = 0.5  'labor share of income
!depreciation = 5.0 'capital stock depreciation rate
!inflexpt  = 5.5  'inflation expectation

'Historical data
%begin_date = "1980"
%end_date = "2021"

'Forecast period
%forecast_start = "2022"
%forecast_end = "2050"

'Estimation period
%end_estimate = "2019"

'Historial solve period
%solve_start = "2014"
%solve_end = %end_date

'End of data template
%template_end = %forecast_end

'Interface display
%display_start = "2012"
%display_end = "2030"
%end_date_interface = "2030"

'Baseyear of data
!base_year = 2016
%base_year = @str(!base_year)

'Switch to enable simpler fiscal rule
!fiscRule = 0 

'***************************************************
' 0. Check setup
'***************************************************
!check_id =0

'***************************************************
' 1. READ DATA
'***************************************************
include .\build\01_readdata.prg
logmsg ******** 01_readdata DONE!

'***************************************************
' 2. EQUATIONS
'***************************************************
include .\build\02_equations.prg
logmsg ******** 02_equations DONE!

'***************************************************
' 3. SOLVE
'***************************************************
include .\build\03_solve.prg
logmsg ******** 03_solve DONE!

'***************************************************
' 4. INTERFACE
'***************************************************
include .\build\04_interface.prg
logmsg ******** 04_interface DONE!

'***************************************************
' 5. CONVERGANCE CHECK
'***************************************************
 include .\build\05_convergence.prg
 logmsg ******** 05_convergence DONE!

'***************************************************
'6. SAVE SOLUTION
'***************************************************
if (!savesoln=1) then
	cd %extractpath
		wfsave(2) {%cty}soln.wf1
	cd %rootpath
endif


