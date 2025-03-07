'***************** Parameters (coming from Params Sheet) ****************
%dir = """C:\WBG\LocalITUtilities\BGD\Programs"""
cd {%DIR}
%cty="BGD"
%model="BGD"
%wfile = %cty
%data_start="1960"
%data_end="2030"
%Fcst_start="2024"
%Fcst_end="2030"
%solve_start = "2018"
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
'Exog all selected
String ToBeExog = {%model}.@stochastic

 'catch error if the model has no _Ms
setmaxerrs 3
Group Vars_m *_M
ToBeExog =@wdrop(ToBeExog,vars_m.@members)
 seterrcount 0
setmaxerrs 1

ToBeExog =@wdrop(ToBeExog,c_spec_QI)
{%model}.exclude {ToBeExog} ' Exogenize all of the stochastic variables except model suggestions and quasi identities
series hold 'used to transform excel entered data (%GDP g etc.) into levels 
series MShold 'used to transform excel entered data for MS 
smpl 2024 2030


'********************************************************************************************************
'***************** Writing excludes for sheet NIA-Vols *****************************************
'********************************************************************************************************



'Exclusion for row #12, Var:NECONPRVTKN
'Placing raw data from excel in hold variable for later treatment, and create the shock variable (_2)

hold.fill(o=2024)   6.60000000000001, 6.7, 8.05981653339409, 7.86481199650684, 7.56726105319099, 7.18174475484437, 6.71280938127559
smpl @all
series BGDNECONPRVTKN_2 = BGDNECONPRVTKN
smpl %fcst_start %fcst_end

{%model}.exclude(r) BGDNECONPRVTKN_A

'Mode set to growth: setting shock value (_2) of series BGDNECONPRVTKN equal to level consistent with growth rates recorded in excel sheet (hold) 
series BGDNECONPRVTKN_2 = BGDNECONPRVTKN_2(-1) * (1 + hold / 100)
{%model}.override(m) BGDNECONPRVTKN
{%model}.exclude(m) BGDNECONPRVTKN
{%model}.exclude(r) BGDNECONPRVTKN_A
{%model}.exclude(r) BGDNEGDIFPRVKN_A
{%model}.exclude(r) BGDNEEXPGNFSKN_A
{%model}.exclude(r) BGDNEIMPGNFSKN_A
'The following variables were in exogenous mode but were ucnhanged
{%model}.exclude(m) BGDNYGDPTFP BGDNEGDIFPRVKN BGDNEGDISTKBKN BGDNEEXPGNFSKN BGDNEIMPGNFSKN BGDNYGDPDISCKN


'********************************************************************************************************
'***************** Writing excludes for sheet NIA-Values *****************************************
'********************************************************************************************************
'The following variables were in exogenous mode but were ucnhanged
{%model}.exclude(m) BGDNEGDISTKBCN BGDNYGDPDISCCN


'********************************************************************************************************
'***************** Writing excludes for sheet NIA-Prices, CPI *****************************************
'********************************************************************************************************
{%model}.exclude(r) BGDFPCPITOTLXN_A
{%model}.exclude(r) BGDNECONPRVTXN_A
{%model}.exclude(r) BGDNECONGOVTXN_A
{%model}.exclude(r) BGDNEGDIFGOVXN_A
{%model}.exclude(r) BGDNEGDIFPRVXN_A
{%model}.exclude(r) BGDNEEXPGNFSXN_A
{%model}.exclude(r) BGDNEIMPGNFSXN_A
{%model}.exclude(r) BGDPANUSATLS_A
{%model}.exclude(r) BGDFMLBLPOLYFR_A
'The following variables were in exogenous mode but were ucnhanged
{%model}.exclude(m) BGDFPCPITOTLXN BGDNECONPRVTXN BGDNECONGOVTXN BGDNEGDIFGOVXN BGDNEGDIFPRVXN BGDNEEXPGNFSXN BGDNEIMPGNFSXN BGDPANUSATLS BGDFMLBLPOLYFR BGDINFLEXPT


'********************************************************************************************************
'***************** Writing excludes for sheet NA-Prodn *****************************************
'********************************************************************************************************
{%model}.exclude(r) BGDNYTAXNINDKN_A
{%model}.exclude(r) BGDNVAGRTOTLKN_A
{%model}.exclude(r) BGDNVINDTOTLKN_A
{%model}.exclude(r) BGDNYGDPCPSHXN_A
{%model}.exclude(r) BGDNVAGRTOTLXN_A
{%model}.exclude(r) BGDNVINDTOTLXN_A
{%model}.exclude(r) BGDNYTAXNINDCN_A
'The following variables were in exogenous mode but were ucnhanged
{%model}.exclude(m) BGDNYTAXNINDKN BGDNVAGRTOTLKN BGDNVINDTOTLKN BGDNYGDPCPSHXN BGDNVAGRTOTLXN BGDNVINDTOTLXN BGDNYTAXNINDCN


'********************************************************************************************************
'***************** Writing excludes for sheet BOP - Remittances *****************************************
'********************************************************************************************************
{%model}.exclude(r) BGDBXGSRMRCHCD_A
{%model}.exclude(r) BGDBMGSRMRCHCD_A
{%model}.exclude(r) BGDBXFSTREMTCD_A
{%model}.exclude(r) BGDBXFSTOTHRCD_A
{%model}.exclude(r) BGDBMFSTREMTCD_A
{%model}.exclude(r) BGDBMFSTOTHRCD_A
{%model}.exclude(r) BGDBFCAFFFDICD_A
{%model}.exclude(r) BGDBFCAFFPFTCD_A
{%model}.exclude(r) BGDBFCAFOOTHCD_A
{%model}.exclude(r) BGDBFCAFRACGCD_A
{%model}.exclude(r) BGDFIRESTOTLCD_A
'The following variables were in exogenous mode but were ucnhanged
{%model}.exclude(m) BGDBXGSRMRCHCD BGDBMGSRMRCHCD BGDBXFSTREMTCD BGDBXFSTOTHRCD BGDBMFSTREMTCD BGDBMFSTOTHRCD BGDNYGDPMKTPCD BGDBFCAFFFDICD BGDBFCAFFPFTCD BGDBFCAFOOTHCD BGDBFCAFCAPTCD BGDBFCAFNEOMCD BGDBFCAFRACGCD BGDFIRESTOTLCD


'********************************************************************************************************
'***************** Writing excludes for sheet Labor *****************************************
'********************************************************************************************************
{%model}.exclude(r) BGDLMPRTTOTL__A
{%model}.exclude(r) BGDLMEMPTOTL_A
{%model}.exclude(r) BGDNYWRTTOTLXN_A
'The following variables were in exogenous mode but were ucnhanged
{%model}.exclude(m) BGDSPPOPTOTL BGDSPPOP1564TO BGDLMPRTTOTL_ BGDLMEMPTOTL BGDLMUNRSTRL_  BGDNYWRTTOTLXN


'********************************************************************************************************
'***************** Writing excludes for sheet Fiscal-Summary *****************************************
'********************************************************************************************************
'The following variables were in exogenous mode but were ucnhanged
{%model}.exclude(m) BGDGGFINEXTLCN BGDGGFINEAMTCN BGDGGFINEDSBCN BGDGGFINDOMTCN BGDGGFINEXTLSHARE_ BGDGGDBTVALECN BGDGGDBTVALDCN


'********************************************************************************************************
'***************** Writing excludes for sheet Fiscal-Revenues *****************************************
'********************************************************************************************************
{%model}.exclude(r) BGDGGREVDRCTCN_A
{%model}.exclude(r) BGDGGREVTVATCN_A
{%model}.exclude(r) BGDGGREVIMPDCN_A
{%model}.exclude(r) BGDGGREVEXPDCN_A
{%model}.exclude(r) BGDGGREVEXCDCN_A
{%model}.exclude(r) BGDGGREVSUPDCN_A
{%model}.exclude(r) BGDGGREVOTHDCN_A
{%model}.exclude(r) BGDGGREVNNBRCN_A
{%model}.exclude(r) BGDGGREVNONTCN_A
{%model}.exclude(r) BGDGGREVGRNTCN_A
'The following variables were in exogenous mode but were ucnhanged
{%model}.exclude(m) BGDGGREVDRCTCN BGDGGREVTVATCN BGDGGREVIMPDCN BGDGGREVEXPDCN BGDGGREVEXCDCN BGDGGREVSUPDCN BGDGGREVOTHDCN BGDGGREVNNBRCN BGDGGREVOTHRCN BGDGGREVNONTCN BGDGGREVGRNTCN


'********************************************************************************************************
'***************** Writing excludes for sheet Fiscal-Expenditures *****************************************
'********************************************************************************************************
{%model}.exclude(r) BGDGGEXPGNFSCN_A
{%model}.exclude(r) BGDGGEXPWAGECN_A
{%model}.exclude(r) BGDGGEXPTRNSCN_A
{%model}.exclude(r) BGDINTRDDIFFFR_A
{%model}.exclude(r) BGDINTREDIFFFR_A
{%model}.exclude(r) BGDGGEXPCAPTCN_A
'The following variables were in exogenous mode but were ucnhanged
{%model}.exclude(m) BGDGGEXPGNFSCN BGDGGEXPWAGECN BGDGGEXPTRNSCN BGDINTRDDIFFFR BGDINTREDIFFFR BGDUSAINTRFR BGDGGEXPCAPTCN BGDGGEXPOTHRCN


'********************************************************************************************************
'***************** Writing excludes for sheet Global *****************************************
'********************************************************************************************************
'The following variables were in exogenous mode but were ucnhanged
{%model}.exclude(m) CANNEIMPGNFSKD CHNNEIMPGNFSKD DEUNEIMPGNFSKD ESPNEIMPGNFSKD FRANEIMPGNFSKD GBRNEIMPGNFSKD INDNEIMPGNFSKD ITANEIMPGNFSKD NLDNEIMPGNFSKD BELNEIMPGNFSKD ROWNEIMPGNFSKD USANEIMPGNFSKD TURNEIMPGNFSKD SAUNYGDPMKTPCD ARENYGDPMKTPCD GBRNYGDPMKTPCD KWTNYGDPMKTPCD USANYGDPMKTPCD QATNYGDPMKTPCD OMNNYGDPMKTPCD SGPNYGDPMKTPCD DEUNYGDPMKTPCD BHRNYGDPMKTPCD JPNNYGDPMKTPCD MYSNYGDPMKTPCD USAINTRFR


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
%Fname="C:\WBG\LocalITUtilities\BGD\Data\BGD2024-14-02~01-10-01soln.wf1"
wfsave(2) %Fname
close BGD2024-14-02~01-10-01soln
wfselect BGDsoln
