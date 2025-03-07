' ============================
' Splice forecasts from another workfile
' ============================
close @all
logmode l
%path = @runpath
cd %path
'-------------------------------------
'Settings 
'-------------------------------------

%cty = "BGD"
%solve_start = "2018"
%solve_end = "2050"
%hist_end = "2023"

%file1 = %path + "data\BGDSOLN2023.wf1"  'original file with latest historical data
%file2  = %path + "data\BGDSolnThursMorning.wf1" 'file with forecasts that we want to use

%file3 = "data\BGDSOLNNewData.wf1" 'name of output wf1 to save as
'-------------------------------------
'Open files
'-------------------------------------

wfopen %file2 
'Save the file with forecast as 'splice'
wfsave(2) data\splice

'Select original file with latest data to work with
wfopen %file1


'-------------------------------------
'Obtains list of modal endogenous and exogenous variables
'-------------------------------------
%fcst_endog = {%cty}.@stochastic
%fcst_exog = {%cty}.@exoglist
%fcst_ident = {%cty}.@identity

%fcst_all = %fcst_endog + " " + %fcst_exog +" "+%fcst_ident 

'drop variables contains zero and will cause dividing by zero issue, also skip global exog since these are more up to date
%drops = "BGDGGREVOTHRCN DUMH BGDBFFINFGAPCD WLDFALUMINUM WLDFBANANA_US WLDFBEEF WLDFCOAL_AUS WLDFCOCOA WLDFCOFFEE_COMPO WLDFCOPPER WLDFCOTTON_A_INDX WLDFCRUDE_PETRO WLDFGRNUT_OIL WLDFGRNUT WLDFGOLD WLDFIRON_ORE WLDFLEAD WLDFMAIZE MUV WLDFNICKEL WLDFORANGE WLDFNGAS_EUR WLDFPALM_OIL WLDFRICE_05 WLDFRUBBER1_MYSG WLDFSILVER WLDFSOYBEAN_MEAL WLDFSOYBEAN_OIL WLDFSOYBEANS WLDFSORGHUM WLDFISTL_JP_INDX WLDFSUGAR_WLD WLDFTEA_AVG WLDFTOBAC_US WLDFLOGS_MYS WLDFPLYWOOD WLDFWOODPULP WLDFSAWNWD_MYS WLDFWHEAT_US_HRW USAINTRFR USAPANUSATLS DEUPANUSATLS GBRPANUSATLS FRAPANUSATLS CHNPANUSATLS ESPPANUSATLS CANPANUSATLS ITAPANUSATLS TURPANUSATLS NLDPANUSATLS BELPANUSATLS INDPANUSATLS USANECONPRVTXN DEUNECONPRVTXN GBRNECONPRVTXN FRANECONPRVTXN CHNNECONPRVTXN ESPNECONPRVTXN CANNECONPRVTXN ITANECONPRVTXN TURNECONPRVTXN NLDNECONPRVTXN BELNECONPRVTXN INDNECONPRVTXN USANEIMPGNFSKD DEUNEIMPGNFSKD GBRNEIMPGNFSKD FRANEIMPGNFSKD CHNNEIMPGNFSKD ESPNEIMPGNFSKD CANNEIMPGNFSKD ITANEIMPGNFSKD TURNEIMPGNFSKD NLDNEIMPGNFSKD BELNEIMPGNFSKD INDNEIMPGNFSKD WLTNEIMPGNFSKD SAUNYGDPMKTPCD ARENYGDPMKTPCD GBRNYGDPMKTPCD KWTNYGDPMKTPCD USANYGDPMKTPCD QATNYGDPMKTPCD OMNNYGDPMKTPCD SGPNYGDPMKTPCD DEUNYGDPMKTPCD BHRNYGDPMKTPCD JPNNYGDPMKTPCD MYSNYGDPMKTPCD " 
%fcst_all = @wdrop(%fcst_all,%drops)

'-------------------------------------
'Apply the growth rates from forecast file to original file wiht latest data
'-------------------------------------

smpl %hist_end+1 @last
for %var {%fcst_all }
   {%var} = {%var}(-1) * splice::{%var}/splice::{%var}(-1)
next

'-------------------------------------
' Create new add factors
'-------------------------------------
smpl @all
delete *_A

{%cty}.update
 smpl %solve_start %solve_end
{%cty}.addassign(i,c) @stochastic
{%cty}.addinit(v=n) @stochastic

{%cty}.scenario "baseline"
{%cty}.solve(s=d,d=d,o={%s}, i=a, g=n)
logmsg "resolved baseline"

'-------------------------------------
'Save solution file
'-------------------------------------
wfsave(2) %file3


