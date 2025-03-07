' ======================================
' Pull exogenous projections for your country external variables
' ======================================
close @all
logmode l

%path = @runpath
%file = %path + "..\data\BGDSoln.wf1"
'Include "splice_routine.prg" 'subroutines are below
'------------------------------------------------------
'Settings - USER to enter the following options
'------------------------------------------------------
%wfname = "BGDSoln"
wfopen %file

'Option to automatically save workfile after adjustment in this program (0 = no save manually, 1 = yes auto save)
!savewf = 0

'Enter country main training partner (for its imports demand and trade weighted exchange rate)
string trading = "CAN CHN DEU ESP FRA GBR  ITA NLD BEL  USA TUR  IND" 

'Enter country's main source of remittances (for its inward remittances)
string remittances = " ITA GBR KWT MYS OMN QAT SAU  USA IND PAK" 

'Commodity price used in the moel
string commodity = "CRUDE_Petro NGAS_EUR COAL_AUS ALUMINUM COPPER IRON_ORE LEAD NICKEL GOLD SILVER COTTON_A_INDX ISTL_JP_INDX PLYWOOD WOODPULP TOBAC_US MAIZE RICE_05 WHEAT_US_HRW BANANA_US BEEF COCOA COFFEE_COMPO GRNUT_OIL ORANGE PALM_OIL SORGHUM SOYBEAN_MEAL SOYBEAN_OIL SOYBEANS SUGAR_WLD TEA_AVG MUV ITIMBER MAIZE IMETMIN CRUDE_BRENT "

'These are high income countries where we will fetch data from the IMF instead of using MPO
string hiy_cty = @wsort("AUS AUT BEL CAN CHE CYP DEU DNK ESP FIN FRA GBR HKG IRL ISL ISR ITA JPN KOR MLT NLD NOR NZL PRT SGP SWE USA GRC LUX TWN CZE EST LVA LTU HUN SVK SVN")

'File path of projection sources **shouldn't have to change except you would like to use difference projection version**
%mpo_path = "W:\MFM\MacroXsupport\MODEL_EX\data\models_most_recent.wf1"
%weo_path =  "W:\MFM\ds\imf\weo\weo_int.edb"
%comm_path = "W:\MFM\ds\compricea\compricea.edb"

'End date of different data sources
%fcst_end = "2080"  'main solution forecast end period
%comm_end = @str(2035 +1)   'raw commodity price projection end period
%weo_end = @str(2027 +1)  'raw IMF WEO projection end period
%mpo_end = @str(2024 +1) 'MPO projection end period


'------------------------------------------------------
'MAIN PROGRAM - Fetch projections from difference sources
'-------------------------------------------------------

'1. Imports, trade exchange rates, and GDP from MPO projections - projections end in 2024
wfopen %mpo_path
wfselect {%wfname}
for %a {trading}
	copy models_most_recent::Untitled\{%a}NEIMPGNFSKD
	copy models_most_recent::Untitled\{%a}EXR05
	copy models_most_recent::Untitled\{%a}PCEXN05
    
     'extend projections to 2100 (use last year of projection growth rate, exchange rate set constant)
     smpl %mpo_end %fcst_end
	{%a}NEIMPGNFSKD = {%a}NEIMPGNFSKD(-1) * ({%a}NEIMPGNFSKD(-1)/{%a}NEIMPGNFSKD(-2))
 	{%a}EXR05 = {%a}EXR05(-1) 
	{%a}PCEXN05 = {%a}PCEXN05(-1) * ({%a}PCEXN05(-1)/{%a}PCEXN05(-2))   
next
for %b {remittances}
	copy models_most_recent::Untitled\{%b}NYGDPMKTPCD
	'extend projections to 2100 (use last year of projection growth rate, exchange rate set constant)
     smpl %mpo_end %fcst_end
	{%b}NYGDPMKTPCD = {%b}NYGDPMKTPCD(-1) * ({%b}NYGDPMKTPCD(-1)/{%b}NYGDPMKTPCD(-2))
next
close models_most_recent

'3. Replace high income country imports and GDP with IMF projections - projections end in 2027
dbopen %weo_path as WEO
for %c {hiy_cty}
     'delete data for high income coutries
      delete(noerr) {%c}NEIMPGNFSKD
      delete(noerr) {%c}NYGDPMKTPCN
      'replace them with WEO
	fetch WEO::{%c}NM_R
	rename {%c}NM_R {%c}NEIMPGNFSKD
	fetch WEO::{%c}NGDP
	rename {%c}NGDP {%c}NYGDPMKTPCN

     'extend projections to 2100 (use last year of projection growth rate)
     smpl %weo_end %fcst_end
     {%c}NEIMPGNFSKD = {%c}NEIMPGNFSKD(-1) * ({%c}NEIMPGNFSKD(-1)/{%c}NEIMPGNFSKD(-2))
     {%c}NYGDPMKTPCN = {%c}NYGDPMKTPCN(-1) * ({%c}NYGDPMKTPCN(-1)/{%c}NYGDPMKTPCN(-2))
next
close WEO

'4. World commodity price from latest commodity price database - projections end in 2035
dbopen %comm_path as CommData

for %d {commodity}
	fetch CommData::WLDF{%d}

     'extend projections to 2100 (use last year of projection growth rate)
     smpl %comm_end %fcst_end
     WLDF{%d} = WLDF{%d}(-1) * (WLDF{%d}(-1)/WLDF{%d}(-2))
next
close CommData

'***********************************************
'Fixes WLDFCRUDE_Petro, WLDFPLYWOOD, WLDFWOODPULP, WLDFISTL_JP_INDX use growth rates from other commodity series
'***********************************************
smpl 2021 %fcst_end
call splice(WLDFPLYWOOD,WLDFITIMBER,"a","pop")  'period-over-period splice (same as yoy here because annual data)
call splice(WLDFWOODPULP,WLDFITIMBER,"a","pop")
call splice(WLDFSORGHUM,WLDFMAIZE,"a","pop")
'call splice(WLDFGRNUT,WLDFGRNUT_OIL,"a","pop")
call splice(WLDFCRUDE_PETRO,WLDFCRUDE_BRENT,"a","pop")

smpl 2011 %fcst_end
call splice(WLDFISTL_JP_INDX,WLDFIMETMIN,"a","pop")

smpl @all
'***********************************************

'------------------------------------------------------
'Save the workfile
'-------------------------------------------------------
if !savewf = 1 then
	wfsave(2)  C:\WBG\LocalITUtilities\BGD\Data\{%wfname}.wf1
endif 


' ===============================
' SPLICE ROUTINES
' ==============================

subroutine splice (series x, series y, string %fr, string %method)
' to be read as "Splice X using Y" which means X is extended using Y 

' example: call splice(AUSx,AUSy,"m","yoy")

' frequency can be: "a" = annual
'			 "q" = quarterly
'			 "m" = monthly
'			 "d" = daily
' method can be: "yoy" = %ch year-over-year 
'				 "pop" = %ch period-over-period
'				 "lev" = directly use levels 

' NOTE: if method is specified incorrectly,the program performs lev splicing


    series temp_splice = @recode(x <> na and x <> 0,@trend,na)+1 
    !xfirst_splice = @min(temp_splice)
    !xlast_splice = @max(temp_splice)
	delete temp_splice
     series temp_splice = @recode(y <> na and y<>0,@trend,na)+1 
	!yfirst_splice = @min(temp_splice)
    !ylast_splice = @max(temp_splice)
	delete temp_splice
	
	'this section calculates the lag and stores it in variable lagP
	' for "lev" we don't need lagP
	' for "pop",lagP is always = 1
	' for "yoy",it depends on the frequency	
	if %method = "pop" then
		!lagP_splice = 1
	else
		if %method = "yoy" then
			' now it means method = yoy
			if %fr = "a" then
				!lagP_splice = 1
			else
				if %fr = "q" then
					!lagP_splice = 4
				else
					if %fr = "m" then
						!lagP_splice = 12
					else
						if %fr = "d" then
							!lagP_splice = 365
						endif
					endif
				endif
			endif
		endif
	endif
	

	' this section does the splicing
	' procedure is the same for pop and yoy so long as lagP is defined correctly above
	' the else loop does the splice for "lev"
	
	!executed_splice = 0
	
	if (%method = "pop" or %method = "yoy") then
	
		if !yfirst_splice<!xfirst_splice then  'Splice Back
			!executed_splice = 1
			for !i_splice = !xfirst_splice-1 to !yfirst_splice step -1
				!lag_splice = !i_splice+!lagP_splice
				x(!i_splice) = x(!lag_splice) / ( y(!lag_splice) / y(!i_splice))
			next
		endif

		if !ylast_splice> !xlast_splice then 'Splice forward(Present)
			!executed_splice = 1
			for !i_splice =!xlast_splice+1 to !ylast_splice step 1
				!shift_splice = !i_splice-!lagP_splice
				x(!i_splice) = x(!shift_splice) * y(!i_splice) / y(!shift_splice)
			next
		endif

	else
	
		if !yfirst_splice<!xfirst_splice then  'Splice Back
			!executed_splice = 1
			for !i_splice = !xfirst_splice-1 to !yfirst_splice step -1 '1/3/2022 5:30 AM: was !xfirst_splice instead of !xfirst_splice-1 (same below with +1). 
				x(!i_splice) = y(!i_splice)
			next
		endif

		if !ylast_splice> !xlast_splice then 'Splice forward(Present)
			!executed_splice = 1
			for !i_splice =!xlast_splice+1 to !ylast_splice step 1
				x(!i_splice) = y(!i_splice)
			next
		endif
	endif
	
	call doc_splice(x, y, @otod(!xfirst_splice), @otod(!xlast_splice), %method, !executed_splice, "")

	'Some documentation needs to be done
	'%startSplice = @str(!xfirst)
	'%endSplice= @str(!xlast)

	'x.label(r) Spliced from {%startSplice} to {%endSplice} using series {%yname}
endsub

subroutine doc_splice(series s, series partner, string %start, string %end, string %method, scalar executed, string %comment)
    text documentation
    %temp_country = @left(s.@name,3)
    %temp_variable = @mid(s.@name,4)
    %partner_name = partner.@name
    %timestamp = @strnow("yyyy-MM-DD HH:mi:ss.sss")
    %executed_str = @str(executed)
    %comment = """" + %comment + """"
    documentation.append splice,{%temp_country},{%temp_variable},{%start},{%end},{%partner_name},{%method},{%executed_str},{%comment},{%timestamp}
endsub


