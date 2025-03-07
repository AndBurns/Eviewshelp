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
'Endog all selected
{%model}.exclude 'Exclude nothing except what is excluded below
series hold 'used to transform excel entered data (%GDP g etc.) into levels 
series MShold 'used to transform excel entered data for MS 
smpl 2024 2030


'********************************************************************************************************
'***************** Writing excludes for sheet NIA-Vols *****************************************
'********************************************************************************************************
{%model}.exclude(r) BGDNECONPRVTKN
{%model}.exclude(r) BGDNEGDIFPRVKN
{%model}.exclude(r) BGDNEEXPGNFSKN
{%model}.exclude(r) BGDNEIMPGNFSKN
'The following variables were in exogenous mode but were ucnhanged
{%model}.exclude(m) BGDNYGDPTFP BGDNECONPRVTKN_A BGDNEGDIFPRVKN_A BGDNEGDISTKBKN BGDNEEXPGNFSKN_A BGDNEIMPGNFSKN_A BGDNYGDPDISCKN


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
{%model}.exclude(r) BGDFMLBLPOLYFR
'The following variables were in exogenous mode but were ucnhanged
{%model}.exclude(m) BGDFPCPITOTLXN_A BGDNECONPRVTXN_A BGDNECONGOVTXN_A BGDNEGDIFGOVXN_A BGDNEGDIFPRVXN_A BGDNEEXPGNFSXN_A BGDNEIMPGNFSXN_A BGDPANUSATLS_A BGDFMLBLPOLYFR_A BGDINFLEXPT


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
{%model}.exclude(r) BGDFIRESTOTLCD
'The following variables were in exogenous mode but were ucnhanged
{%model}.exclude(m) BGDBXGSRMRCHCD_A BGDBMGSRMRCHCD_A BGDBXFSTREMTCD_A BGDBXFSTOTHRCD_A BGDBMFSTREMTCD_A BGDBMFSTOTHRCD_A BGDNYGDPMKTPCD BGDBFCAFFFDICD_A BGDBFCAFFPFTCD_A BGDBFCAFOOTHCD_A BGDBFCAFCAPTCD BGDBFCAFNEOMCD BGDBFCAFRACGCD_A BGDFIRESTOTLCD_A


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



'Exclusion for row #14, Var:GGREVTVATCN_A
'Placing raw data from excel in hold variable for later treatment, and create the shock variable (_2)

hold.fill(o=2024)   0, 0, 0, 0, 0, 0, 0

MShold.fill(o=2024)   2.93980503785827, 3.35286534813546, 2.72938851353859, 2.74861386291361, 2.76832726540598, 2.7852662224173, 2.7962080648383
series yg=mshold+hold
smpl @all
series BGDGGREVTVATCN_A_2 = BGDGGREVTVATCN_A
smpl %fcst_start %fcst_end

_BGDGGREVTVATCN.fit fit

'Prepare series necessary to calculate the add factor for this equation
'Create:
'        * _2 AF variable 
'        * store original AF For use later
'        * create y variable As RHS Of dependent variable Of equation
'        * Create equation fitted value
smpl @all
series BGDGGREVTVATCN_A_2 = BGDGGREVTVATCN_A
series orig_AF = BGDGGREVTVATCN_A
series y = BGDGGREVTVATCN_0
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
series orig_AF = BGDGGREVTVATCN_A 
series  orig_ser = BGDGGREVTVATCN_0

'Create temporary model comprised of the equation being AF'd
delete(noerr) test
model test
test.merge _BGDGGREVTVATCN

'Calculate the additive AF for the dependent variable
test.scenario "baseline"
test.addassign(v, c) @stochastic
smpl %solve_start %fcst_end
test.addinit(v = n) @stochastic
test.solve(s = d, d = s)

smpl @all
'Save the AF consistent with the additive model and create a new one _S for the simul
series orig_add_AF = BGDGGREVTVATCN_A 
series BGDGGREVTVATCN_A_S = BGDGGREVTVATCN_A
'Now caculate the additive add factor _A_S consistent with the desired growth path
smpl %fcst_start %solve_end
series BGDGGREVTVATCN_A_S = BGDGGREVTVATCN_A+Y(-1)*(delta_AF_add/100)
series BGDGGREVTVATCN_A_add = BGDGGREVTVATCN_A
'Solve the additive model using the AF shock -- in order to find the pathway for LHS variable
setmaxerrs 2
test.scenario(d) "Find New Y"
seterrcount 0
setmaxerrs 1
test.scenario(n, a = s, i = "baseline", c) "Find New Y"
test.scenario "Find New Y"
test.override(m) BGDGGREVTVATCN_A
test.exclude(m)  BGDGGREVTVATCN_A

smpl %solve_start %fcst_end
test.solve(s = d, d = D, o=g, i = a, c = 0.000001, f = t, v = t, g = n)

'Have calculated the new path for the LHS variable
smpl %solve_start %solve_end
series BGDGGREVTVATCN = BGDGGREVTVATCN_s
series BGDGGREVTVATCN_A = orig_AF


'Calculate new intercept-type add factor
smpl %solve_start %solve_end
{%model}.addinit(v=n,s=a) BGDGGREVTVATCN

'Set shock veriosn of AF (_2) equal to the level of the AF consistent with new growth path and then restore old values of _A and root series
series BGDGGREVTVATCN_A_2 = BGDGGREVTVATCN_A
series BGDGGREVTVATCN_A = orig_AF
series BGDGGREVTVATCN= orig_ser
{%model}.override(m) BGDGGREVTVATCN_A
{%model}.exclude(m) BGDGGREVTVATCN_A
{%model}.exclude(r) BGDGGREVIMPDCN



'Exclusion for row #19, Var:GGREVIMPDCN_A
'Placing raw data from excel in hold variable for later treatment, and create the shock variable (_2)

hold.fill(o=2024)   0, 0, 0, 0, 0, 0, 0

MShold.fill(o=2024)   0.842234413905089, 0.602638764166762, 0.673183246156055, 0.678170161766182, 0.668928947107987, 0.64704357901867, 0.612657744927708
series yg=mshold+hold
smpl @all
series BGDGGREVIMPDCN_A_2 = BGDGGREVIMPDCN_A
smpl %fcst_start %fcst_end

_BGDGGREVIMPDCN.fit fit

'Prepare series necessary to calculate the add factor for this equation
'Create:
'        * _2 AF variable 
'        * store original AF For use later
'        * create y variable As RHS Of dependent variable Of equation
'        * Create equation fitted value
smpl @all
series BGDGGREVIMPDCN_A_2 = BGDGGREVIMPDCN_A
series orig_AF = BGDGGREVIMPDCN_A
series y = BGDGGREVIMPDCN_0
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
series orig_AF = BGDGGREVIMPDCN_A 
series  orig_ser = BGDGGREVIMPDCN_0

'Create temporary model comprised of the equation being AF'd
delete(noerr) test
model test
test.merge _BGDGGREVIMPDCN

'Calculate the additive AF for the dependent variable
test.scenario "baseline"
test.addassign(v, c) @stochastic
smpl %solve_start %fcst_end
test.addinit(v = n) @stochastic
test.solve(s = d, d = s)

smpl @all
'Save the AF consistent with the additive model and create a new one _S for the simul
series orig_add_AF = BGDGGREVIMPDCN_A 
series BGDGGREVIMPDCN_A_S = BGDGGREVIMPDCN_A
'Now caculate the additive add factor _A_S consistent with the desired growth path
smpl %fcst_start %solve_end
series BGDGGREVIMPDCN_A_S = BGDGGREVIMPDCN_A+Y(-1)*(delta_AF_add/100)
series BGDGGREVIMPDCN_A_add = BGDGGREVIMPDCN_A
'Solve the additive model using the AF shock -- in order to find the pathway for LHS variable
setmaxerrs 2
test.scenario(d) "Find New Y"
seterrcount 0
setmaxerrs 1
test.scenario(n, a = s, i = "baseline", c) "Find New Y"
test.scenario "Find New Y"
test.override(m) BGDGGREVIMPDCN_A
test.exclude(m)  BGDGGREVIMPDCN_A

smpl %solve_start %fcst_end
test.solve(s = d, d = D, o=g, i = a, c = 0.000001, f = t, v = t, g = n)

'Have calculated the new path for the LHS variable
smpl %solve_start %solve_end
series BGDGGREVIMPDCN = BGDGGREVIMPDCN_s
series BGDGGREVIMPDCN_A = orig_AF


'Calculate new intercept-type add factor
smpl %solve_start %solve_end
{%model}.addinit(v=n,s=a) BGDGGREVIMPDCN

'Set shock veriosn of AF (_2) equal to the level of the AF consistent with new growth path and then restore old values of _A and root series
series BGDGGREVIMPDCN_A_2 = BGDGGREVIMPDCN_A
series BGDGGREVIMPDCN_A = orig_AF
series BGDGGREVIMPDCN= orig_ser
{%model}.override(m) BGDGGREVIMPDCN_A
{%model}.exclude(m) BGDGGREVIMPDCN_A
{%model}.exclude(r) BGDGGREVEXPDCN



'Exclusion for row #24, Var:GGREVEXPDCN_A
'Placing raw data from excel in hold variable for later treatment, and create the shock variable (_2)

hold.fill(o=2024)   0, 0, 0, 0, 0, 0, 0

MShold.fill(o=2024)   2.54928650842061E-05, 2.50841673920197E-05, 3.34859724395242E-05, 3.34136554917202E-05, 3.24668653296671E-05, 3.13008787602971E-05, 3.00727639488951E-05
series yg=mshold+hold
smpl @all
series BGDGGREVEXPDCN_A_2 = BGDGGREVEXPDCN_A
smpl %fcst_start %fcst_end

_BGDGGREVEXPDCN.fit fit

'Prepare series necessary to calculate the add factor for this equation
'Create:
'        * _2 AF variable 
'        * store original AF For use later
'        * create y variable As RHS Of dependent variable Of equation
'        * Create equation fitted value
smpl @all
series BGDGGREVEXPDCN_A_2 = BGDGGREVEXPDCN_A
series orig_AF = BGDGGREVEXPDCN_A
series y = BGDGGREVEXPDCN_0
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
series orig_AF = BGDGGREVEXPDCN_A 
series  orig_ser = BGDGGREVEXPDCN_0

'Create temporary model comprised of the equation being AF'd
delete(noerr) test
model test
test.merge _BGDGGREVEXPDCN

'Calculate the additive AF for the dependent variable
test.scenario "baseline"
test.addassign(v, c) @stochastic
smpl %solve_start %fcst_end
test.addinit(v = n) @stochastic
test.solve(s = d, d = s)

smpl @all
'Save the AF consistent with the additive model and create a new one _S for the simul
series orig_add_AF = BGDGGREVEXPDCN_A 
series BGDGGREVEXPDCN_A_S = BGDGGREVEXPDCN_A
'Now caculate the additive add factor _A_S consistent with the desired growth path
smpl %fcst_start %solve_end
series BGDGGREVEXPDCN_A_S = BGDGGREVEXPDCN_A+Y(-1)*(delta_AF_add/100)
series BGDGGREVEXPDCN_A_add = BGDGGREVEXPDCN_A
'Solve the additive model using the AF shock -- in order to find the pathway for LHS variable
setmaxerrs 2
test.scenario(d) "Find New Y"
seterrcount 0
setmaxerrs 1
test.scenario(n, a = s, i = "baseline", c) "Find New Y"
test.scenario "Find New Y"
test.override(m) BGDGGREVEXPDCN_A
test.exclude(m)  BGDGGREVEXPDCN_A

smpl %solve_start %fcst_end
test.solve(s = d, d = D, o=g, i = a, c = 0.000001, f = t, v = t, g = n)

'Have calculated the new path for the LHS variable
smpl %solve_start %solve_end
series BGDGGREVEXPDCN = BGDGGREVEXPDCN_s
series BGDGGREVEXPDCN_A = orig_AF


'Calculate new intercept-type add factor
smpl %solve_start %solve_end
{%model}.addinit(v=n,s=a) BGDGGREVEXPDCN

'Set shock veriosn of AF (_2) equal to the level of the AF consistent with new growth path and then restore old values of _A and root series
series BGDGGREVEXPDCN_A_2 = BGDGGREVEXPDCN_A
series BGDGGREVEXPDCN_A = orig_AF
series BGDGGREVEXPDCN= orig_ser
{%model}.override(m) BGDGGREVEXPDCN_A
{%model}.exclude(m) BGDGGREVEXPDCN_A
{%model}.exclude(r) BGDGGREVEXCDCN



'Exclusion for row #29, Var:GGREVEXCDCN_A
'Placing raw data from excel in hold variable for later treatment, and create the shock variable (_2)

hold.fill(o=2024)   0, 0, 0, 0, 0, 0, 0

MShold.fill(o=2024)   0.0750147197614094, 0.0702633435526024, 0.0696513007457883, 0.0701973017012984, 0.0707557978196991, 0.071249730949363, 0.0716033494153622
series yg=mshold+hold
smpl @all
series BGDGGREVEXCDCN_A_2 = BGDGGREVEXCDCN_A
smpl %fcst_start %fcst_end

_BGDGGREVEXCDCN.fit fit

'Prepare series necessary to calculate the add factor for this equation
'Create:
'        * _2 AF variable 
'        * store original AF For use later
'        * create y variable As RHS Of dependent variable Of equation
'        * Create equation fitted value
smpl @all
series BGDGGREVEXCDCN_A_2 = BGDGGREVEXCDCN_A
series orig_AF = BGDGGREVEXCDCN_A
series y = BGDGGREVEXCDCN_0
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
series orig_AF = BGDGGREVEXCDCN_A 
series  orig_ser = BGDGGREVEXCDCN_0

'Create temporary model comprised of the equation being AF'd
delete(noerr) test
model test
test.merge _BGDGGREVEXCDCN

'Calculate the additive AF for the dependent variable
test.scenario "baseline"
test.addassign(v, c) @stochastic
smpl %solve_start %fcst_end
test.addinit(v = n) @stochastic
test.solve(s = d, d = s)

smpl @all
'Save the AF consistent with the additive model and create a new one _S for the simul
series orig_add_AF = BGDGGREVEXCDCN_A 
series BGDGGREVEXCDCN_A_S = BGDGGREVEXCDCN_A
'Now caculate the additive add factor _A_S consistent with the desired growth path
smpl %fcst_start %solve_end
series BGDGGREVEXCDCN_A_S = BGDGGREVEXCDCN_A+Y(-1)*(delta_AF_add/100)
series BGDGGREVEXCDCN_A_add = BGDGGREVEXCDCN_A
'Solve the additive model using the AF shock -- in order to find the pathway for LHS variable
setmaxerrs 2
test.scenario(d) "Find New Y"
seterrcount 0
setmaxerrs 1
test.scenario(n, a = s, i = "baseline", c) "Find New Y"
test.scenario "Find New Y"
test.override(m) BGDGGREVEXCDCN_A
test.exclude(m)  BGDGGREVEXCDCN_A

smpl %solve_start %fcst_end
test.solve(s = d, d = D, o=g, i = a, c = 0.000001, f = t, v = t, g = n)

'Have calculated the new path for the LHS variable
smpl %solve_start %solve_end
series BGDGGREVEXCDCN = BGDGGREVEXCDCN_s
series BGDGGREVEXCDCN_A = orig_AF


'Calculate new intercept-type add factor
smpl %solve_start %solve_end
{%model}.addinit(v=n,s=a) BGDGGREVEXCDCN

'Set shock veriosn of AF (_2) equal to the level of the AF consistent with new growth path and then restore old values of _A and root series
series BGDGGREVEXCDCN_A_2 = BGDGGREVEXCDCN_A
series BGDGGREVEXCDCN_A = orig_AF
series BGDGGREVEXCDCN= orig_ser
{%model}.override(m) BGDGGREVEXCDCN_A
{%model}.exclude(m) BGDGGREVEXCDCN_A
{%model}.exclude(r) BGDGGREVSUPDCN



'Exclusion for row #34, Var:GGREVSUPDCN_A
'Placing raw data from excel in hold variable for later treatment, and create the shock variable (_2)

hold.fill(o=2024)   0, 0, 0, 0, 0, 0, 0

MShold.fill(o=2024)   0.994409804536002, 0.931435010397181, 0.923349813746554, 0.930609954470066, 0.937949856552656, 0.944195316092629, 0.948141801608877
series yg=mshold+hold
smpl @all
series BGDGGREVSUPDCN_A_2 = BGDGGREVSUPDCN_A
smpl %fcst_start %fcst_end

_BGDGGREVSUPDCN.fit fit

'Prepare series necessary to calculate the add factor for this equation
'Create:
'        * _2 AF variable 
'        * store original AF For use later
'        * create y variable As RHS Of dependent variable Of equation
'        * Create equation fitted value
smpl @all
series BGDGGREVSUPDCN_A_2 = BGDGGREVSUPDCN_A
series orig_AF = BGDGGREVSUPDCN_A
series y = BGDGGREVSUPDCN_0
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
series orig_AF = BGDGGREVSUPDCN_A 
series  orig_ser = BGDGGREVSUPDCN_0

'Create temporary model comprised of the equation being AF'd
delete(noerr) test
model test
test.merge _BGDGGREVSUPDCN

'Calculate the additive AF for the dependent variable
test.scenario "baseline"
test.addassign(v, c) @stochastic
smpl %solve_start %fcst_end
test.addinit(v = n) @stochastic
test.solve(s = d, d = s)

smpl @all
'Save the AF consistent with the additive model and create a new one _S for the simul
series orig_add_AF = BGDGGREVSUPDCN_A 
series BGDGGREVSUPDCN_A_S = BGDGGREVSUPDCN_A
'Now caculate the additive add factor _A_S consistent with the desired growth path
smpl %fcst_start %solve_end
series BGDGGREVSUPDCN_A_S = BGDGGREVSUPDCN_A+Y(-1)*(delta_AF_add/100)
series BGDGGREVSUPDCN_A_add = BGDGGREVSUPDCN_A
'Solve the additive model using the AF shock -- in order to find the pathway for LHS variable
setmaxerrs 2
test.scenario(d) "Find New Y"
seterrcount 0
setmaxerrs 1
test.scenario(n, a = s, i = "baseline", c) "Find New Y"
test.scenario "Find New Y"
test.override(m) BGDGGREVSUPDCN_A
test.exclude(m)  BGDGGREVSUPDCN_A

smpl %solve_start %fcst_end
test.solve(s = d, d = D, o=g, i = a, c = 0.000001, f = t, v = t, g = n)

'Have calculated the new path for the LHS variable
smpl %solve_start %solve_end
series BGDGGREVSUPDCN = BGDGGREVSUPDCN_s
series BGDGGREVSUPDCN_A = orig_AF


'Calculate new intercept-type add factor
smpl %solve_start %solve_end
{%model}.addinit(v=n,s=a) BGDGGREVSUPDCN

'Set shock veriosn of AF (_2) equal to the level of the AF consistent with new growth path and then restore old values of _A and root series
series BGDGGREVSUPDCN_A_2 = BGDGGREVSUPDCN_A
series BGDGGREVSUPDCN_A = orig_AF
series BGDGGREVSUPDCN= orig_ser
{%model}.override(m) BGDGGREVSUPDCN_A
{%model}.exclude(m) BGDGGREVSUPDCN_A
{%model}.exclude(r) BGDGGREVOTHDCN



'Exclusion for row #39, Var:GGREVOTHDCN_A
'Placing raw data from excel in hold variable for later treatment, and create the shock variable (_2)

hold.fill(o=2024)   0, 0, 0, 0, 0, 0, 0

MShold.fill(o=2024)   0.0271475264435377, 0.0269079718182197, 0.0276183075491435, 0.0277342185128358, 0.0277319698952274, 0.0277036530864211, 0.0276687618803224
series yg=mshold+hold
smpl @all
series BGDGGREVOTHDCN_A_2 = BGDGGREVOTHDCN_A
smpl %fcst_start %fcst_end

_BGDGGREVOTHDCN.fit fit

'Prepare series necessary to calculate the add factor for this equation
'Create:
'        * _2 AF variable 
'        * store original AF For use later
'        * create y variable As RHS Of dependent variable Of equation
'        * Create equation fitted value
smpl @all
series BGDGGREVOTHDCN_A_2 = BGDGGREVOTHDCN_A
series orig_AF = BGDGGREVOTHDCN_A
series y = BGDGGREVOTHDCN_0
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
series orig_AF = BGDGGREVOTHDCN_A 
series  orig_ser = BGDGGREVOTHDCN_0

'Create temporary model comprised of the equation being AF'd
delete(noerr) test
model test
test.merge _BGDGGREVOTHDCN

'Calculate the additive AF for the dependent variable
test.scenario "baseline"
test.addassign(v, c) @stochastic
smpl %solve_start %fcst_end
test.addinit(v = n) @stochastic
test.solve(s = d, d = s)

smpl @all
'Save the AF consistent with the additive model and create a new one _S for the simul
series orig_add_AF = BGDGGREVOTHDCN_A 
series BGDGGREVOTHDCN_A_S = BGDGGREVOTHDCN_A
'Now caculate the additive add factor _A_S consistent with the desired growth path
smpl %fcst_start %solve_end
series BGDGGREVOTHDCN_A_S = BGDGGREVOTHDCN_A+Y(-1)*(delta_AF_add/100)
series BGDGGREVOTHDCN_A_add = BGDGGREVOTHDCN_A
'Solve the additive model using the AF shock -- in order to find the pathway for LHS variable
setmaxerrs 2
test.scenario(d) "Find New Y"
seterrcount 0
setmaxerrs 1
test.scenario(n, a = s, i = "baseline", c) "Find New Y"
test.scenario "Find New Y"
test.override(m) BGDGGREVOTHDCN_A
test.exclude(m)  BGDGGREVOTHDCN_A

smpl %solve_start %fcst_end
test.solve(s = d, d = D, o=g, i = a, c = 0.000001, f = t, v = t, g = n)

'Have calculated the new path for the LHS variable
smpl %solve_start %solve_end
series BGDGGREVOTHDCN = BGDGGREVOTHDCN_s
series BGDGGREVOTHDCN_A = orig_AF


'Calculate new intercept-type add factor
smpl %solve_start %solve_end
{%model}.addinit(v=n,s=a) BGDGGREVOTHDCN

'Set shock veriosn of AF (_2) equal to the level of the AF consistent with new growth path and then restore old values of _A and root series
series BGDGGREVOTHDCN_A_2 = BGDGGREVOTHDCN_A
series BGDGGREVOTHDCN_A = orig_AF
series BGDGGREVOTHDCN= orig_ser
{%model}.override(m) BGDGGREVOTHDCN_A
{%model}.exclude(m) BGDGGREVOTHDCN_A
{%model}.exclude(r) BGDGGREVNNBRCN



'Exclusion for row #44, Var:GGREVNNBRCN_A
'Placing raw data from excel in hold variable for later treatment, and create the shock variable (_2)

hold.fill(o=2024)   0, 0, 0, 0, 0, 0, 0

MShold.fill(o=2024)   0.165001828900704, 0.163547278866018, 0.167867729592681, 0.168574301722288, 0.168554668822905, 0.168351703700541, 0.168051610995705
series yg=mshold+hold
smpl @all
series BGDGGREVNNBRCN_A_2 = BGDGGREVNNBRCN_A
smpl %fcst_start %fcst_end

_BGDGGREVNNBRCN.fit fit

'Prepare series necessary to calculate the add factor for this equation
'Create:
'        * _2 AF variable 
'        * store original AF For use later
'        * create y variable As RHS Of dependent variable Of equation
'        * Create equation fitted value
smpl @all
series BGDGGREVNNBRCN_A_2 = BGDGGREVNNBRCN_A
series orig_AF = BGDGGREVNNBRCN_A
series y = BGDGGREVNNBRCN_0
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
series orig_AF = BGDGGREVNNBRCN_A 
series  orig_ser = BGDGGREVNNBRCN_0

'Create temporary model comprised of the equation being AF'd
delete(noerr) test
model test
test.merge _BGDGGREVNNBRCN

'Calculate the additive AF for the dependent variable
test.scenario "baseline"
test.addassign(v, c) @stochastic
smpl %solve_start %fcst_end
test.addinit(v = n) @stochastic
test.solve(s = d, d = s)

smpl @all
'Save the AF consistent with the additive model and create a new one _S for the simul
series orig_add_AF = BGDGGREVNNBRCN_A 
series BGDGGREVNNBRCN_A_S = BGDGGREVNNBRCN_A
'Now caculate the additive add factor _A_S consistent with the desired growth path
smpl %fcst_start %solve_end
series BGDGGREVNNBRCN_A_S = BGDGGREVNNBRCN_A+Y(-1)*(delta_AF_add/100)
series BGDGGREVNNBRCN_A_add = BGDGGREVNNBRCN_A
'Solve the additive model using the AF shock -- in order to find the pathway for LHS variable
setmaxerrs 2
test.scenario(d) "Find New Y"
seterrcount 0
setmaxerrs 1
test.scenario(n, a = s, i = "baseline", c) "Find New Y"
test.scenario "Find New Y"
test.override(m) BGDGGREVNNBRCN_A
test.exclude(m)  BGDGGREVNNBRCN_A

smpl %solve_start %fcst_end
test.solve(s = d, d = D, o=g, i = a, c = 0.000001, f = t, v = t, g = n)

'Have calculated the new path for the LHS variable
smpl %solve_start %solve_end
series BGDGGREVNNBRCN = BGDGGREVNNBRCN_s
series BGDGGREVNNBRCN_A = orig_AF


'Calculate new intercept-type add factor
smpl %solve_start %solve_end
{%model}.addinit(v=n,s=a) BGDGGREVNNBRCN

'Set shock veriosn of AF (_2) equal to the level of the AF consistent with new growth path and then restore old values of _A and root series
series BGDGGREVNNBRCN_A_2 = BGDGGREVNNBRCN_A
series BGDGGREVNNBRCN_A = orig_AF
series BGDGGREVNNBRCN= orig_ser
{%model}.override(m) BGDGGREVNNBRCN_A
{%model}.exclude(m) BGDGGREVNNBRCN_A
{%model}.exclude(r) BGDGGREVNONTCN
{%model}.exclude(r) BGDGGREVGRNTCN
'The following variables were in exogenous mode but were ucnhanged
{%model}.exclude(m) BGDGGREVDRCTCN_A BGDGGREVOTHRCN BGDGGREVNONTCN_A BGDGGREVGRNTCN_A


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
{%model}.exclude(m) BGDGGEXPGNFSCN_A BGDGGEXPWAGECN_A BGDGGEXPTRNSCN_A BGDINTRDDIFFFR_A BGDINTREDIFFFR_A BGDUSAINTRFR BGDGGEXPCAPTCN_A BGDGGEXPOTHRCN


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
%Fname="C:\WBG\LocalITUtilities\BGD\Data\BGD2024-14-02~08-22-37soln.wf1"
wfsave(2) %Fname
close BGD2024-14-02~08-22-37soln
wfselect BGDsoln
