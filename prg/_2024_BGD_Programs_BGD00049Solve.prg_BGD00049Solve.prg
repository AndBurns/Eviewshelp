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
smpl 2023 2030


'********************************************************************************************************
'***************** Writing excludes for sheet NIA-Vols *****************************************
'********************************************************************************************************
{%model}.exclude(r) BGDNECONPRVTKN



'Exclusion for row #14, Var:NECONPRVTKN_A
'Placing raw data from excel in hold variable for later treatment, and create the shock variable (_2)

hold.fill(o=2023)   1.54512983095747, 0, 0, 0, 1.57859540201639, 1.57839482221502, 1.57660401593034, 1.57330590199016

MShold.fill(o=2023)   6.11878223127036, 6.65857520929956, 7.05894221221335, 6.78540962393017, 6.50034246944078, 6.14009508068911, 5.71174627249174, 5.21448606124684
series yg=mshold+hold
smpl @all
series BGDNECONPRVTKN_A_2 = BGDNECONPRVTKN_A
smpl %fcst_start %fcst_end

{%model}.exclude(r) BGDNECONPRVTKN
_BGDNECONPRVTKN.fit fit

'Prepare series necessary to calculate the add factor for this equation
'Create:
'        * _2 AF variable 
'        * store original AF For use later
'        * create y variable As RHS Of dependent variable Of equation
'        * Create equation fitted value
smpl @all
series BGDNECONPRVTKN_A_2 = BGDNECONPRVTKN_A
series orig_AF = BGDNECONPRVTKN_A
series y = BGDNECONPRVTKN_0
smpl %fcst_start %solve_end
'
'Calculate value of dependent variable that we want to reach using excelified growth add factor
smpl %fcst_start %solve_end
'
'*************************
'Front End is in qoq state
'*************************
'Calculate existing unchanged AF as add
series orig_AF_add=(y/y(-1)-1)*100-((fit/y(-1))-1)*100
series delta_AF_add=hold-orig_AF_add
'Mode set to add: add-factor is on intercept.
'Converted the orinibal problem into a level and additive problem one so can now solve using the additive methodology
'Do this because we do not know ex ante the functional form of the equation
'  * Build a small model with just teh equation and restate equation as if add-factor were additive
'  * calculate the original additive add factor consistent with the path of the LHS variable 
'  * Calculate the implicit delta in the level AF from the change in the add series 
'  * Impose this AF on the additive model to get the new path of LHS
'  * Calculate the intercept based AF consistent with this new path
'  * Impose the new intercept based AF on the full model
' 
smpl @all
series orig_AF = BGDNECONPRVTKN_A 
series  orig_ser = BGDNECONPRVTKN_0

'Create temporary model comprised of the equation being AF'd
delete(noerr) test
model test
test.merge _BGDNECONPRVTKN

'Calculate the additive AF for the dependent variable
test.scenario "baseline"
test.addassign(v, c) @stochastic
smpl %solve_start %fcst_end
test.addinit(v = n) @stochastic
test.solve(s = d, d = s)

smpl @all
'Save the AF consistent with the additive model and create a new one _S for the simul
series orig_add_AF = BGDNECONPRVTKN_A 
series BGDNECONPRVTKN_A_S = BGDNECONPRVTKN_A
'Now caculate the additive add factor _A_S consistent with the desired growth path
smpl %fcst_start %solve_end
series BGDNECONPRVTKN_A_S = BGDNECONPRVTKN_A+Y(-1)*(delta_AF_add/100)
series BGDNECONPRVTKN_A_add = BGDNECONPRVTKN_A
'Solve the additive model using the AF shock -- in order to find the pathway for LHS variable
setmaxerrs 2
test.scenario(d) "Find New Y"
seterrcount 0
setmaxerrs 1
test.scenario(n, a = s, i = "baseline", c) "Find New Y"
test.scenario "Find New Y"
test.override(m) BGDNECONPRVTKN_A
test.exclude(m)  BGDNECONPRVTKN_A

smpl %solve_start %fcst_end
test.solve(s = d, d = D, o=g, i = a, c = 0.000001, f = t, v = t, g = n)

'Have calculated the new path for the LHS variable
smpl %solve_start %solve_end
series BGDNECONPRVTKN = BGDNECONPRVTKN_s
series BGDNECONPRVTKN_A = orig_AF


'Calculate new intercept-type add factor
smpl %solve_start %solve_end
{%model}.addinit(v=n,s=a) BGDNECONPRVTKN

'Set shock veriosn of AF (_2) equal to the level of the AF consistent with new growth path and then restore old values of _A and root series
series BGDNECONPRVTKN_A_2 = BGDNECONPRVTKN_A
series BGDNECONPRVTKN_A = orig_AF
series BGDNECONPRVTKN= orig_ser
{%model}.override(m) BGDNECONPRVTKN_A
{%model}.exclude(m) BGDNECONPRVTKN_A
{%model}.exclude(r) BGDNEGDIFPRVKN



'Exclusion for row #22, Var:NEGDIFPRVKN_A
'Placing raw data from excel in hold variable for later treatment, and create the shock variable (_2)

hold.fill(o=2023)   0.844114172630704, 0, 0, 0, 2.80110645124028, 2.88592185412606, 2.98752296155829, 3.11668440111723

MShold.fill(o=2023)   10.8908342429733, 10.4176346179867, 10.3116995015854, 8.69550601993125, 6.42728888902013, 5.27219688090121, 4.45604025232711, 3.87208027375863
series yg=mshold+hold
smpl @all
series BGDNEGDIFPRVKN_A_2 = BGDNEGDIFPRVKN_A
smpl %fcst_start %fcst_end

{%model}.exclude(r) BGDNEGDIFPRVKN
_BGDNEGDIFPRVKN.fit fit

'Prepare series necessary to calculate the add factor for this equation
'Create:
'        * _2 AF variable 
'        * store original AF For use later
'        * create y variable As RHS Of dependent variable Of equation
'        * Create equation fitted value
smpl @all
series BGDNEGDIFPRVKN_A_2 = BGDNEGDIFPRVKN_A
series orig_AF = BGDNEGDIFPRVKN_A
series y = BGDNEGDIFPRVKN_0
smpl %fcst_start %solve_end
'
'Calculate value of dependent variable that we want to reach using excelified growth add factor
smpl %fcst_start %solve_end
'
'*************************
'Front End is in qoq state
'*************************
'Calculate existing unchanged AF as add
series orig_AF_add=(y/y(-1)-1)*100-((fit/y(-1))-1)*100
series delta_AF_add=hold-orig_AF_add
'Mode set to add: add-factor is on intercept.
'Converted the orinibal problem into a level and additive problem one so can now solve using the additive methodology
'Do this because we do not know ex ante the functional form of the equation
'  * Build a small model with just teh equation and restate equation as if add-factor were additive
'  * calculate the original additive add factor consistent with the path of the LHS variable 
'  * Calculate the implicit delta in the level AF from the change in the add series 
'  * Impose this AF on the additive model to get the new path of LHS
'  * Calculate the intercept based AF consistent with this new path
'  * Impose the new intercept based AF on the full model
' 
smpl @all
series orig_AF = BGDNEGDIFPRVKN_A 
series  orig_ser = BGDNEGDIFPRVKN_0

'Create temporary model comprised of the equation being AF'd
delete(noerr) test
model test
test.merge _BGDNEGDIFPRVKN

'Calculate the additive AF for the dependent variable
test.scenario "baseline"
test.addassign(v, c) @stochastic
smpl %solve_start %fcst_end
test.addinit(v = n) @stochastic
test.solve(s = d, d = s)

smpl @all
'Save the AF consistent with the additive model and create a new one _S for the simul
series orig_add_AF = BGDNEGDIFPRVKN_A 
series BGDNEGDIFPRVKN_A_S = BGDNEGDIFPRVKN_A
'Now caculate the additive add factor _A_S consistent with the desired growth path
smpl %fcst_start %solve_end
series BGDNEGDIFPRVKN_A_S = BGDNEGDIFPRVKN_A+Y(-1)*(delta_AF_add/100)
series BGDNEGDIFPRVKN_A_add = BGDNEGDIFPRVKN_A
'Solve the additive model using the AF shock -- in order to find the pathway for LHS variable
setmaxerrs 2
test.scenario(d) "Find New Y"
seterrcount 0
setmaxerrs 1
test.scenario(n, a = s, i = "baseline", c) "Find New Y"
test.scenario "Find New Y"
test.override(m) BGDNEGDIFPRVKN_A
test.exclude(m)  BGDNEGDIFPRVKN_A

smpl %solve_start %fcst_end
test.solve(s = d, d = D, o=g, i = a, c = 0.000001, f = t, v = t, g = n)

'Have calculated the new path for the LHS variable
smpl %solve_start %solve_end
series BGDNEGDIFPRVKN = BGDNEGDIFPRVKN_s
series BGDNEGDIFPRVKN_A = orig_AF


'Calculate new intercept-type add factor
smpl %solve_start %solve_end
{%model}.addinit(v=n,s=a) BGDNEGDIFPRVKN

'Set shock veriosn of AF (_2) equal to the level of the AF consistent with new growth path and then restore old values of _A and root series
series BGDNEGDIFPRVKN_A_2 = BGDNEGDIFPRVKN_A
series BGDNEGDIFPRVKN_A = orig_AF
series BGDNEGDIFPRVKN= orig_ser
{%model}.override(m) BGDNEGDIFPRVKN_A
{%model}.exclude(m) BGDNEGDIFPRVKN_A
{%model}.exclude(r) BGDNEEXPGNFSKN



'Exclusion for row #28, Var:NEEXPGNFSKN_A
'Placing raw data from excel in hold variable for later treatment, and create the shock variable (_2)

hold.fill(o=2023)   5.93701986352468, 0, 0, 8.99222260788417, 4.04821176035048, 2.02508416442833, 1.02718816866216, 1.0119376380421

MShold.fill(o=2023)   1.06298013647532, 0.438740325007902, 1.10002321281775, 0.496221276193132, 0.792863288737178, 1.17900698592852, 1.19520411018661, 0.839785594653852
series yg=mshold+hold
smpl @all
series BGDNEEXPGNFSKN_A_2 = BGDNEEXPGNFSKN_A
smpl %fcst_start %fcst_end

{%model}.exclude(r) BGDNEEXPGNFSKN
_BGDNEEXPGNFSKN.fit fit

'Prepare series necessary to calculate the add factor for this equation
'Create:
'        * _2 AF variable 
'        * store original AF For use later
'        * create y variable As RHS Of dependent variable Of equation
'        * Create equation fitted value
smpl @all
series BGDNEEXPGNFSKN_A_2 = BGDNEEXPGNFSKN_A
series orig_AF = BGDNEEXPGNFSKN_A
series y = BGDNEEXPGNFSKN_0
smpl %fcst_start %solve_end
'
'Calculate value of dependent variable that we want to reach using excelified growth add factor
smpl %fcst_start %solve_end
'
'*************************
'Front End is in qoq state
'*************************
'Calculate existing unchanged AF as add
series orig_AF_add=(y/y(-1)-1)*100-((fit/y(-1))-1)*100
series delta_AF_add=hold-orig_AF_add
'Mode set to add: add-factor is on intercept.
'Converted the orinibal problem into a level and additive problem one so can now solve using the additive methodology
'Do this because we do not know ex ante the functional form of the equation
'  * Build a small model with just teh equation and restate equation as if add-factor were additive
'  * calculate the original additive add factor consistent with the path of the LHS variable 
'  * Calculate the implicit delta in the level AF from the change in the add series 
'  * Impose this AF on the additive model to get the new path of LHS
'  * Calculate the intercept based AF consistent with this new path
'  * Impose the new intercept based AF on the full model
' 
smpl @all
series orig_AF = BGDNEEXPGNFSKN_A 
series  orig_ser = BGDNEEXPGNFSKN_0

'Create temporary model comprised of the equation being AF'd
delete(noerr) test
model test
test.merge _BGDNEEXPGNFSKN

'Calculate the additive AF for the dependent variable
test.scenario "baseline"
test.addassign(v, c) @stochastic
smpl %solve_start %fcst_end
test.addinit(v = n) @stochastic
test.solve(s = d, d = s)

smpl @all
'Save the AF consistent with the additive model and create a new one _S for the simul
series orig_add_AF = BGDNEEXPGNFSKN_A 
series BGDNEEXPGNFSKN_A_S = BGDNEEXPGNFSKN_A
'Now caculate the additive add factor _A_S consistent with the desired growth path
smpl %fcst_start %solve_end
series BGDNEEXPGNFSKN_A_S = BGDNEEXPGNFSKN_A+Y(-1)*(delta_AF_add/100)
series BGDNEEXPGNFSKN_A_add = BGDNEEXPGNFSKN_A
'Solve the additive model using the AF shock -- in order to find the pathway for LHS variable
setmaxerrs 2
test.scenario(d) "Find New Y"
seterrcount 0
setmaxerrs 1
test.scenario(n, a = s, i = "baseline", c) "Find New Y"
test.scenario "Find New Y"
test.override(m) BGDNEEXPGNFSKN_A
test.exclude(m)  BGDNEEXPGNFSKN_A

smpl %solve_start %fcst_end
test.solve(s = d, d = D, o=g, i = a, c = 0.000001, f = t, v = t, g = n)

'Have calculated the new path for the LHS variable
smpl %solve_start %solve_end
series BGDNEEXPGNFSKN = BGDNEEXPGNFSKN_s
series BGDNEEXPGNFSKN_A = orig_AF


'Calculate new intercept-type add factor
smpl %solve_start %solve_end
{%model}.addinit(v=n,s=a) BGDNEEXPGNFSKN

'Set shock veriosn of AF (_2) equal to the level of the AF consistent with new growth path and then restore old values of _A and root series
series BGDNEEXPGNFSKN_A_2 = BGDNEEXPGNFSKN_A
series BGDNEEXPGNFSKN_A = orig_AF
series BGDNEEXPGNFSKN= orig_ser
{%model}.override(m) BGDNEEXPGNFSKN_A
{%model}.exclude(m) BGDNEEXPGNFSKN_A
{%model}.exclude(r) BGDNEIMPGNFSKN_A
'The following variables were in exogenous mode but were ucnhanged
{%model}.exclude(m) BGDNYGDPTFP BGDNEGDISTKBKN BGDNEIMPGNFSKN BGDNYGDPDISCKN


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
{%model}.exclude(m) BGDFPCPITOTLXN BGDNECONPRVTXN BGDNECONGOVTXN BGDNEGDIFGOVXN BGDNEGDIFPRVXN BGDNEEXPGNFSXN BGDNEIMPGNFSXN BGDPANUSATLS BGDFMLBLPOLYFR


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
'The following variables were in exogenous mode but were ucnhanged
{%model}.exclude(m) BGDBXGSRMRCHCD BGDBMGSRMRCHCD BGDBXFSTREMTCD BGDBXFSTOTHRCD BGDBMFSTREMTCD BGDBMFSTOTHRCD BGDNYGDPMKTPCD BGDBFCAFFFDICD BGDBFCAFFPFTCD BGDBFCAFOOTHCD BGDBFCAFCAPTCD BGDBFCAFNEOMCD BGDBFCAFRACGCD


'********************************************************************************************************
'***************** Writing excludes for sheet Labor *****************************************
'********************************************************************************************************
{%model}.exclude(r) BGDLMPRTTOTL__A
{%model}.exclude(r) BGDLMEMPTOTL_A
{%model}.exclude(r) BGDNYWRTTOTLXN_A
'The following variables were in exogenous mode but were ucnhanged
{%model}.exclude(m) BGDSPPOPTOTL BGDSPPOP1564TO BGDLMPRTTOTL_ BGDLMEMPTOTL BGDLMUNRSTRL_  BGDNYWRTTOTLXN BGDNYYWBTOTLCN


'********************************************************************************************************
'***************** Writing excludes for sheet Fiscal-Summary *****************************************
'********************************************************************************************************
'The following variables were in exogenous mode but were ucnhanged
{%model}.exclude(m) BGDGGFINEXTLCN BGDGGFINEAMTCN BGDGGFINEDSBCN BGDGGFINDOMTCN BGDGGFINEXTLSHARE_ BGDGGDBTVALECN BGDGGDBTVALDCN


'********************************************************************************************************
'***************** Writing excludes for sheet Fiscal-Revenues *****************************************
'********************************************************************************************************
{%model}.exclude(r) BGDGGREVDRCTCN
{%model}.exclude(r) BGDGGREVTVATCN_A
{%model}.exclude(r) BGDGGREVIMPDCN_A
{%model}.exclude(r) BGDGGREVEXPDCN_A
{%model}.exclude(r) BGDGGREVEXCDCN_A
{%model}.exclude(r) BGDGGREVSUPDCN_A
{%model}.exclude(r) BGDGGREVOTHDCN_A
{%model}.exclude(r) BGDGGREVNNBRCN
{%model}.exclude(r) BGDGGREVTOTHCN
{%model}.exclude(r) BGDGGREVNONTCN_A
{%model}.exclude(r) BGDGGREVGRNTCN_A
'The following variables were in exogenous mode but were ucnhanged
{%model}.exclude(m) BGDGGREVDRCTCN_A BGDGGREVTVATCN BGDGGREVIMPDCN BGDGGREVEXPDCN BGDGGREVEXCDCN BGDGGREVSUPDCN BGDGGREVOTHDCN BGDGGREVNNBRCN_A BGDGGREVTOTHCN_A BGDGGREVOTHRCN BGDGGREVNONTCN BGDGGREVGRNTCN


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
{%model}.exclude(m) BGDGGEXPGNFSCN BGDGGEXPWAGECN BGDGGEXPTRNSCN BGDINTRDDIFFFR BGDINTREDIFFFR BGDGGEXPCAPTCN BGDGGEXPOTHRCN


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
%Fname="C:\WBG\LocalITUtilities\BGD\Data\BGD2024-12-02~04-48-01soln.wf1"
wfsave(2) %Fname
close BGD2024-12-02~04-48-01soln
wfselect BGDsoln
