'***************** Parameters (coming from Params Sheet) ****************
%dir = """C:\WBG\LocalITUtilities\BGD\Programs"""
cd {%DIR}
%cty="BGD"
%model="BGD"
%wfile = %cty
%data_start="1960"
%data_end="2030"
%Fcst_start="2023"
%Fcst_end="2030"
%solve_start = "2014"
%solve_end = "2030"
%baseyear=" 2010 " ' This has been hardcoded in the excel
!model_suggestion = 1

'Load Solution has already opened the baseline database
wfselect BGDSoln

'****************** Set Up MS and AF ************************
string kk=@wkeep({%model}.@endoglist,"*_M")
STRING MS=@REPLACE(KK,"_M","")
'****************** Solve for baseline ************************
smpl %solve_start %solve_end
{%model}.scenario "baseline"
{%model}.addassign(i,c) @stochastic
{%model}.addinit(v=n) @stochastic
{%model}.solve(s=d,d=s)

'****************** Set all exog vars to _0 ************************
string tt=@upper({%model}.@exoglist)

smpl @all
for %var {tt}
series {%var}_0={%var}
Next
copy *_A *_A_0
'****************** Ensure AF on MS are equal to zero ************************

if @len(ms)>0 then
	smpl %FCST_START %solve_end
	for %var {ms} 'set all modelAF suggestion af to zero
		series {%var}_m_A=0'{%var}(-1) 'hold AF on MS constant = 0 is the other option
	Next
endif
'********* Solve country model with iSimulate inputs

'first delete simul2 if it exists
setmaxerrs 2
 {%model}.scenario(d) "MFMod_Sim"
 seterrcount 0
setmaxerrs 1

{%model}.scenario(n,a=2,i="baseline",c) "MFMod_Sim"
{%model}.scenario "MFMod_Sim"
'The sample size statement is NECESSARY; otherwise missing data will be generated.
'The beginning of the sample comes directly from the Params page
'which is the year when the user can overwrite exogenous variables.

smpl %fcst_start %Fcst_end
{%model}.exclude 'trying to exclude nothing except what is excluded below

'create strinsg for quasi identities and set forecast AF to zero
string c_spec_QI=@wcross(%cty,quasi_identity)
if c_spec_QI<>"" then
	For %var {c_spec_qi}
     series {%var}_A=0
	next
endif


'******************************************
'Endog all selected
{%model}.exclude 'Exclude nothing except what is excluded below
series hold 'used to transform excel entered data (%GDP g etc.) into levels 
series MShold 'used to transform excel entered data for MS 
smpl 2023 2030


'********************************************************************************************************
'***************** Writing excludes for sheet NIA-Vols *****************************************
'********************************************************************************************************
{%model}.exclude(r) BGDNECONPRVTKN
{%model}.exclude(r) BGDNEGDIFPRVKN
{%model}.exclude(r) BGDNEEXPGNFSKN
{%model}.exclude(r) BGDNEIMPGNFSKN
'The following variables were in exogenous mode but were ucnhanged
{%model}.exclude(m) BGDNECONPRVTKN_A BGDNEGDIFPRVKN_A BGDNEGDISTKBKN BGDNEEXPGNFSKN_A BGDNEIMPGNFSKN_A BGDNYGDPDISCKN BGDNYGDPTFP


'********************************************************************************************************
'***************** Writing excludes for sheet NIA-Values *****************************************
'********************************************************************************************************
'The following variables were in exogenous mode but were ucnhanged
{%model}.exclude(m) BGDNEGDISTKBCN BGDNYGDPDISCCN


'********************************************************************************************************
'***************** Writing excludes for sheet NIA-Prices, CPI *****************************************
'********************************************************************************************************
{%model}.exclude(r) BGDFPCPITOTLXN
{%model}.exclude(r) BGDNECONPRVTXN
{%model}.exclude(r) BGDNECONGOVTXN
{%model}.exclude(r) BGDNEGDIFGOVXN
{%model}.exclude(r) BGDNEGDIFPRVXN
{%model}.exclude(r) BGDNEEXPGNFSXN
{%model}.exclude(r) BGDNEIMPGNFSXN
{%model}.exclude(r) BGDPANUSATLS
{%model}.exclude(r) BGDFMLBLPOLYFR_A
'The following variables were in exogenous mode but were ucnhanged
{%model}.exclude(m) BGDFPCPITOTLXN_A BGDNECONPRVTXN_A BGDNECONGOVTXN_A BGDNEGDIFGOVXN_A BGDNEGDIFPRVXN_A BGDNEEXPGNFSXN_A BGDNEIMPGNFSXN_A BGDPANUSATLS_A BGDFMLBLPOLYFR


'********************************************************************************************************
'***************** Writing excludes for sheet NA-Prodn *****************************************
'********************************************************************************************************
{%model}.exclude(r) BGDNYTAXNINDKN
{%model}.exclude(r) BGDNVAGRTOTLKN
{%model}.exclude(r) BGDNVINDTOTLKN
{%model}.exclude(r) BGDNYGDPCPSHXN
{%model}.exclude(r) BGDNVAGRTOTLXN
{%model}.exclude(r) BGDNVINDTOTLXN
{%model}.exclude(r) BGDNYTAXNINDCN
'The following variables were in exogenous mode but were ucnhanged
{%model}.exclude(m) BGDNYTAXNINDKN_A BGDNVAGRTOTLKN_A BGDNVINDTOTLKN_A BGDNYGDPCPSHXN_A BGDNVAGRTOTLXN_A BGDNVINDTOTLXN_A BGDNYTAXNINDCN_A


'********************************************************************************************************
'***************** Writing excludes for sheet BOP - Remittances *****************************************
'********************************************************************************************************
{%model}.exclude(r) BGDBXGSRMRCHCD
{%model}.exclude(r) BGDBMGSRMRCHCD
{%model}.exclude(r) BGDBXFSTREMTCD
{%model}.exclude(r) BGDBXFSTOTHRCD
{%model}.exclude(r) BGDBMFSTREMTCD
{%model}.exclude(r) BGDBMFSTOTHRCD
{%model}.exclude(r) BGDBFCAFFFDICD
{%model}.exclude(r) BGDBFCAFFPFTCD
{%model}.exclude(r) BGDBFCAFOOTHCD
{%model}.exclude(r) BGDBFCAFRACGCD
'The following variables were in exogenous mode but were ucnhanged
{%model}.exclude(m) BGDBXGSRMRCHCD_A BGDBMGSRMRCHCD_A BGDBXFSTREMTCD_A BGDBXFSTOTHRCD_A BGDBMFSTREMTCD_A BGDBMFSTOTHRCD_A BGDBFCAFFFDICD_A BGDBFCAFFPFTCD_A BGDBFCAFOOTHCD_A BGDBFCAFCAPTCD BGDBFCAFNEOMCD BGDBFCAFRACGCD_A


'********************************************************************************************************
'***************** Writing excludes for sheet Labor *****************************************
'********************************************************************************************************
{%model}.exclude(r) BGDLMPRTTOTL_
{%model}.exclude(r) BGDLMEMPTOTL
{%model}.exclude(r) BGDNYWRTTOTLXN
'The following variables were in exogenous mode but were ucnhanged
{%model}.exclude(m) BGDSPPOPTOTL BGDSPPOP1564TO BGDLMPRTTOTL__A BGDLMEMPTOTL_A BGDLMUNRSTRL_  BGDNYWRTTOTLXN_A


'********************************************************************************************************
'***************** Writing excludes for sheet Fiscal-Summary *****************************************
'********************************************************************************************************
'The following variables were in exogenous mode but were ucnhanged
{%model}.exclude(m) BGDGGFINEXTLCN BGDGGFINEAMTCN BGDGGFINEDSBCN BGDGGFINDOMTCN BGDGGFINEXTLSHARE_ BGDGGDBTVALECN BGDGGDBTVALDCN


'********************************************************************************************************
'***************** Writing excludes for sheet Fiscal-Revenues *****************************************
'********************************************************************************************************
{%model}.exclude(r) BGDGGREVDRCTCN
{%model}.exclude(r) BGDGGREVTVATCN
{%model}.exclude(r) BGDGGREVIMPDCN
{%model}.exclude(r) BGDGGREVEXPDCN
{%model}.exclude(r) BGDGGREVEXCDCN
{%model}.exclude(r) BGDGGREVSUPDCN
{%model}.exclude(r) BGDGGREVOTHDCN
{%model}.exclude(r) BGDGGREVNNBRCN
{%model}.exclude(r) BGDGGREVTOTHCN
{%model}.exclude(r) BGDGGREVNONTCN
{%model}.exclude(r) BGDGGREVGRNTCN
'The following variables were in exogenous mode but were ucnhanged
{%model}.exclude(m) BGDGGREVDRCTCN_A BGDGGREVTVATCN_A BGDGGREVIMPDCN_A BGDGGREVEXPDCN_A BGDGGREVEXCDCN_A BGDGGREVSUPDCN_A BGDGGREVOTHDCN_A BGDGGREVNNBRCN_A BGDGGREVTOTHCN_A BGDGGREVOTHRCN BGDGGREVNONTCN_A BGDGGREVGRNTCN_A


'********************************************************************************************************
'***************** Writing excludes for sheet Fiscal-Expenditures *****************************************
'********************************************************************************************************
{%model}.exclude(r) BGDGGEXPGNFSCN
{%model}.exclude(r) BGDGGEXPWAGECN
{%model}.exclude(r) BGDGGEXPTRNSCN
{%model}.exclude(r) BGDINTRDDIFFFR
{%model}.exclude(r) BGDINTREDIFFFR
{%model}.exclude(r) BGDGGEXPCAPTCN
'The following variables were in exogenous mode but were ucnhanged
{%model}.exclude(m) BGDGGEXPGNFSCN_A BGDGGEXPWAGECN_A BGDGGEXPTRNSCN_A BGDINTRDDIFFFR_A BGDINTREDIFFFR_A BGDGGEXPCAPTCN_A BGDGGEXPOTHRCN


'********************************************************************************************************
'***************** Writing excludes for sheet Global *****************************************
'********************************************************************************************************



'Exclusion for row #20, Var:SAUNYGDPMKTPCD
'Placing raw data from excel in hold variable for later treatment, and create the shock variable (_2)

hold.fill(o=2023)   -2.97940044272459, 5.4, 4.16250772648956, 4.16250772648956, 4.16250772648956, 4.16250772648958, 4.16250772648958, 4.16250772648956
smpl @all
series SAUNYGDPMKTPCD_2 = SAUNYGDPMKTPCD
smpl %fcst_start %fcst_end

{%model}.exclude(r) SAUNYGDPMKTPCD_A

'Mode set to growth: setting shock value (_2) of series BGDSAUNYGDPMKTPCD equal to level consistent with growth rates recorded in excel sheet (hold) 
series SAUNYGDPMKTPCD_2 = SAUNYGDPMKTPCD_2(-1) * (1 + hold / 100)
{%model}.override(m) SAUNYGDPMKTPCD
{%model}.exclude(m) SAUNYGDPMKTPCD



'Exclusion for row #21, Var:ARENYGDPMKTPCD
'Placing raw data from excel in hold variable for later treatment, and create the shock variable (_2)

hold.fill(o=2023)   -3.7387056516006, 7.5, 2.1250326877591, 2.1250326877591, 2.12503268775912, 2.1250326877591, 2.1250326877591, 2.1250326877591
smpl @all
series ARENYGDPMKTPCD_2 = ARENYGDPMKTPCD
smpl %fcst_start %fcst_end

{%model}.exclude(r) ARENYGDPMKTPCD_A

'Mode set to growth: setting shock value (_2) of series BGDARENYGDPMKTPCD equal to level consistent with growth rates recorded in excel sheet (hold) 
series ARENYGDPMKTPCD_2 = ARENYGDPMKTPCD_2(-1) * (1 + hold / 100)
{%model}.override(m) ARENYGDPMKTPCD
{%model}.exclude(m) ARENYGDPMKTPCD



'Exclusion for row #23, Var:KWTNYGDPMKTPCD
'Placing raw data from excel in hold variable for later treatment, and create the shock variable (_2)

hold.fill(o=2023)   -17.7267318399846, 3, -2.33950654567906, -2.33950654567907, -2.33950654567907, -2.33950654567908, -2.33950654567907, -2.33950654567907
smpl @all
series KWTNYGDPMKTPCD_2 = KWTNYGDPMKTPCD
smpl %fcst_start %fcst_end

{%model}.exclude(r) KWTNYGDPMKTPCD_A

'Mode set to growth: setting shock value (_2) of series BGDKWTNYGDPMKTPCD equal to level consistent with growth rates recorded in excel sheet (hold) 
series KWTNYGDPMKTPCD_2 = KWTNYGDPMKTPCD_2(-1) * (1 + hold / 100)
{%model}.override(m) KWTNYGDPMKTPCD
{%model}.exclude(m) KWTNYGDPMKTPCD



'Exclusion for row #25, Var:QATNYGDPMKTPCD
'Placing raw data from excel in hold variable for later treatment, and create the shock variable (_2)

hold.fill(o=2023)   7.29101270141665, 5, 8.27573442641762, 8.2757344264176, 8.2757344264176, 8.2757344264176, 8.2757344264176, 8.2757344264176
smpl @all
series QATNYGDPMKTPCD_2 = QATNYGDPMKTPCD
smpl %fcst_start %fcst_end

{%model}.exclude(r) QATNYGDPMKTPCD_A

'Mode set to growth: setting shock value (_2) of series BGDQATNYGDPMKTPCD equal to level consistent with growth rates recorded in excel sheet (hold) 
series QATNYGDPMKTPCD_2 = QATNYGDPMKTPCD_2(-1) * (1 + hold / 100)
{%model}.override(m) QATNYGDPMKTPCD
{%model}.exclude(m) QATNYGDPMKTPCD



'Exclusion for row #26, Var:OMNNYGDPMKTPCD
'Placing raw data from excel in hold variable for later treatment, and create the shock variable (_2)

hold.fill(o=2023)   -5.33136645036646, 5, 2.39014595388991, 2.39014595388991, 2.39014595388989, 2.39014595388989, 2.39014595388989, 2.39014595388991
smpl @all
series OMNNYGDPMKTPCD_2 = OMNNYGDPMKTPCD
smpl %fcst_start %fcst_end

{%model}.exclude(r) OMNNYGDPMKTPCD_A

'Mode set to growth: setting shock value (_2) of series BGDOMNNYGDPMKTPCD equal to level consistent with growth rates recorded in excel sheet (hold) 
series OMNNYGDPMKTPCD_2 = OMNNYGDPMKTPCD_2(-1) * (1 + hold / 100)
{%model}.override(m) OMNNYGDPMKTPCD
{%model}.exclude(m) OMNNYGDPMKTPCD



'Exclusion for row #29, Var:BHRNYGDPMKTPCD
'Placing raw data from excel in hold variable for later treatment, and create the shock variable (_2)

hold.fill(o=2023)   1.76879812971349, 5, 4.57472690526275, 4.57472690526275, 4.57472690526275, 4.57472690526277, 4.57472690526277, 4.57472690526277
smpl @all
series BHRNYGDPMKTPCD_2 = BHRNYGDPMKTPCD
smpl %fcst_start %fcst_end

{%model}.exclude(r) BHRNYGDPMKTPCD_A

'Mode set to growth: setting shock value (_2) of series BGDBHRNYGDPMKTPCD equal to level consistent with growth rates recorded in excel sheet (hold) 
series BHRNYGDPMKTPCD_2 = BHRNYGDPMKTPCD_2(-1) * (1 + hold / 100)
{%model}.override(m) BHRNYGDPMKTPCD
{%model}.exclude(m) BHRNYGDPMKTPCD
'The following variables were in exogenous mode but were ucnhanged
{%model}.exclude(m) CANNEIMPGNFSKD CHNNEIMPGNFSKD DEUNEIMPGNFSKD ESPNEIMPGNFSKD FRANEIMPGNFSKD GBRNEIMPGNFSKD INDNEIMPGNFSKD ITANEIMPGNFSKD NLDNEIMPGNFSKD BELNEIMPGNFSKD ROWNEIMPGNFSKD USANEIMPGNFSKD TURNEIMPGNFSKD GBRNYGDPMKTPCD USANYGDPMKTPCD SGPNYGDPMKTPCD DEUNYGDPMKTPCD JPNNYGDPMKTPCD MYSNYGDPMKTPCD USAINTRFR


'********************************************************************************************************
'***************** Writing excludes for sheet Commodities *****************************************
'********************************************************************************************************
'The following variables were in exogenous mode but were ucnhanged
{%model}.exclude(m) WLDFCRUDE_Petro WLDFNGAS_EUR WLDFCOAL_AUS WLDFALUMINUM WLDFCOPPER WLDFIRON_ORE WLDFLEAD WLDFNICKEL WLDFGOLD WLDFSILVER WLDFCOTTON_A_INDX WLDFISTL_JP_INDX WLDFPLYWOOD WLDFWOODPULP WLDFTOBAC_US MUV WLDFMAIZE WLDFRICE_05 WLDFWHEAT_US_HRW WLDFBANANA_US WLDFBEEF WLDFCOCOA WLDFCOFFEE_COMPO WLDFGRNUT_OIL WLDFORANGE WLDFPALM_OIL WLDFSORGHUM WLDFSOYBEAN_MEAL WLDFSOYBEAN_OIL WLDFSOYBEANS WLDFSUGAR_WLD WLDFTEA_AVG
'************************** Set AddFactor for quasi identities equal to zero in forecast period **********
smpl %fcst_start @last
series {%cty}BMGSRGNFSCD_A=0
series {%cty}BXGSRGNFSCD_A=0
series {%cty}GGDBTTOTLCN_A=0


'************************** Solve User specified Solution **********
smpl %solve_start %fcst_end
{%model}.solve(s=d,d=D,o=g,i=a,c=1e-6,f=t,v=t,g=n)



'********************  Ensure that all exog variables have _2s for compares ************************
string _st_exogs=@upper(BGD.@exoglist)
group all_2s *_2
string _st_stripped=@replace(all_2s.@members,"_2","")
string _st_exogs=@wdrop(_st_exogs,_st_stripped)
' ********* do the same for AFs *******
smpl @all
group AFs *_A
setmaxerrs 2
group AF2s *_A_2
if @errorcount>0 then
     string _st_AF2s=""
     string _st_af=afs.@members
     else
         string _st_af2=@replace(AF2s.@members,"_2","")
         string _st_AF=@wdrop(AFs.@members,_st_AF2)
     endif
 seterrcount 0
setmaxerrs 1
string shold=_st_af+" " +_st_exogs

if @len(shold)>1 then 'if list is empty then shold will have length 1 of the space between its  compinents
     for %var {shold}
         series {%var}_2={%var}
     next
Endif
'delete _st_* AFs AF2s
%Fname="C:\WBG\LocalITUtilities\BGD\Data\BGDsolnMostRecent.wf1" 
wfsave(2) %Fname 
Group g2BCopied *_2
String sDest =@replace(g2Bcopied.@members, "_2", "")
'Make sure that any stray _2 in the workfile are ignored
String endog = {%model}.@endoglist
String exog = {%model}.@exoglist
String modvars = endog + " " + exog
sdest =@wintersect(sdest,modvars)

sDest =@wdrop(sdest,%cty)
For %var {sDest}
	series {%var}={%var}_2
	delete {%var}_2
Next
'
'Solve for add factors so that they add up on next load
smpl %solve_start %solve_end
{%model}.scenario "baseline"
{%model}.addassign(i,c) @stochastic
{%model}.addinit(v=n) @stochastic
{%model}.solve(s=d,d=s)
'
wfsave(2) "C:\WBG\LocalITUtilities\BGD\Data\BGDsoln.wf1" ' Now have created new XXXSolnFile
'' Re-open MostRecentsimul file so we can add into it the correctly calculated add factors
wfopen "C:\WBG\LocalITUtilities\BGD\Data\BGDsolnmostrecent"
%stt= "BGDsolnmostrecent"

'Re-open current simul file and copy the add factors from new solution into the mostrecent file
wfuse "C:\WBG\LocalITUtilities\BGD\Data\BGDsoln.wf1" 
wfselect BGDsoln
copy *_a {%stt}::*_a_2
wfselect {%stt}

'Write the most recent file and a copy with date stamp
wfsave(2) "C:\WBG\LocalITUtilities\BGD\Data\BGDsolnmostrecent.wf1"
%Fname="C:\WBG\LocalITUtilities\BGD\Data\BGD2024-05-02~10-37-21soln.wf1"
wfsave(2) %Fname
close BGD2024-05-02~10-37-21soln
wfselect BGDsoln
