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
'Neither Exog All nor Endog all selected
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
{%model}.exclude(r) BGDPANUSATLS_A
{%model}.exclude(r) BGDFMLBLPOLYFR
'The following variables were in exogenous mode but were ucnhanged
{%model}.exclude(m) BGDFPCPITOTLXN_A BGDNECONPRVTXN_A BGDNECONGOVTXN_A BGDNEGDIFGOVXN_A BGDNEGDIFPRVXN_A BGDNEEXPGNFSXN_A BGDNEIMPGNFSXN_A BGDPANUSATLS BGDFMLBLPOLYFR_A BGDINFLEXPT


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
{%model}.exclude(r) BGDGGREVIMPDCN
{%model}.exclude(r) BGDGGREVEXPDCN
{%model}.exclude(r) BGDGGREVEXCDCN
{%model}.exclude(r) BGDGGREVSUPDCN
{%model}.exclude(r) BGDGGREVOTHDCN
{%model}.exclude(r) BGDGGREVNNBRCN
{%model}.exclude(r) BGDGGREVNONTCN
{%model}.exclude(r) BGDGGREVGRNTCN
'The following variables were in exogenous mode but were ucnhanged
{%model}.exclude(m) BGDGGREVDRCTCN_A BGDGGREVTVATCN_A BGDGGREVIMPDCN_A BGDGGREVEXPDCN_A BGDGGREVEXCDCN_A BGDGGREVSUPDCN_A BGDGGREVOTHDCN_A BGDGGREVNNBRCN_A BGDGGREVOTHRCN BGDGGREVNONTCN_A BGDGGREVGRNTCN_A


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



'Exclusion for row #5, Var:CANNEIMPGNFSKD
'Placing raw data from excel in hold variable for later treatment, and create the shock variable (_2)

hold.fill(o=2024)   0.776135489212892, 3.63986008595671, 3.84304696293205, 3.84304696293205, 3.84304696293205, 3.84304696293207, 3.84304696293207
smpl @all
series CANNEIMPGNFSKD_2 = CANNEIMPGNFSKD
smpl %fcst_start %fcst_end

{%model}.exclude(r) CANNEIMPGNFSKD_A

'Mode set to growth: setting shock value (_2) of series BGDCANNEIMPGNFSKD equal to level consistent with growth rates recorded in excel sheet (hold) 
series CANNEIMPGNFSKD_2 = CANNEIMPGNFSKD_2(-1) * (1 + hold / 100)
{%model}.override(m) CANNEIMPGNFSKD
{%model}.exclude(m) CANNEIMPGNFSKD



'Exclusion for row #6, Var:CHNNEIMPGNFSKD
'Placing raw data from excel in hold variable for later treatment, and create the shock variable (_2)

hold.fill(o=2024)   2.80002204889429, 2.7417724847193, 2.74177248471936, 2.74177248471934, 2.74177248471934, 2.74177248471934, 2.74177248471936
smpl @all
series CHNNEIMPGNFSKD_2 = CHNNEIMPGNFSKD
smpl %fcst_start %fcst_end

{%model}.exclude(r) CHNNEIMPGNFSKD_A

'Mode set to growth: setting shock value (_2) of series BGDCHNNEIMPGNFSKD equal to level consistent with growth rates recorded in excel sheet (hold) 
series CHNNEIMPGNFSKD_2 = CHNNEIMPGNFSKD_2(-1) * (1 + hold / 100)
{%model}.override(m) CHNNEIMPGNFSKD
{%model}.exclude(m) CHNNEIMPGNFSKD



'Exclusion for row #7, Var:DEUNEIMPGNFSKD
'Placing raw data from excel in hold variable for later treatment, and create the shock variable (_2)

hold.fill(o=2024)   2.99526840882558, 3.1040648931123, 3.4349432583638, 3.4349432583638, 3.4349432583638, 3.43494325836378, 3.43494325836378
smpl @all
series DEUNEIMPGNFSKD_2 = DEUNEIMPGNFSKD
smpl %fcst_start %fcst_end

{%model}.exclude(r) DEUNEIMPGNFSKD_A

'Mode set to growth: setting shock value (_2) of series BGDDEUNEIMPGNFSKD equal to level consistent with growth rates recorded in excel sheet (hold) 
series DEUNEIMPGNFSKD_2 = DEUNEIMPGNFSKD_2(-1) * (1 + hold / 100)
{%model}.override(m) DEUNEIMPGNFSKD
{%model}.exclude(m) DEUNEIMPGNFSKD



'Exclusion for row #8, Var:ESPNEIMPGNFSKD
'Placing raw data from excel in hold variable for later treatment, and create the shock variable (_2)

hold.fill(o=2024)   2.37169689261221, 3.16071113204446, 2.79323953037329, 2.79323953037331, 2.79323953037329, 2.79323953037329, 2.79323953037331
smpl @all
series ESPNEIMPGNFSKD_2 = ESPNEIMPGNFSKD
smpl %fcst_start %fcst_end

{%model}.exclude(r) ESPNEIMPGNFSKD_A

'Mode set to growth: setting shock value (_2) of series BGDESPNEIMPGNFSKD equal to level consistent with growth rates recorded in excel sheet (hold) 
series ESPNEIMPGNFSKD_2 = ESPNEIMPGNFSKD_2(-1) * (1 + hold / 100)
{%model}.override(m) ESPNEIMPGNFSKD
{%model}.exclude(m) ESPNEIMPGNFSKD



'Exclusion for row #9, Var:FRANEIMPGNFSKD
'Placing raw data from excel in hold variable for later treatment, and create the shock variable (_2)

hold.fill(o=2024)   3.58609179729024, 2.40200519892844, 3.87328650653513, 3.87328650653513, 3.87328650653511, 3.87328650653511, 3.87328650653511
smpl @all
series FRANEIMPGNFSKD_2 = FRANEIMPGNFSKD
smpl %fcst_start %fcst_end

{%model}.exclude(r) FRANEIMPGNFSKD_A

'Mode set to growth: setting shock value (_2) of series BGDFRANEIMPGNFSKD equal to level consistent with growth rates recorded in excel sheet (hold) 
series FRANEIMPGNFSKD_2 = FRANEIMPGNFSKD_2(-1) * (1 + hold / 100)
{%model}.override(m) FRANEIMPGNFSKD
{%model}.exclude(m) FRANEIMPGNFSKD



'Exclusion for row #10, Var:GBRNEIMPGNFSKD
'Placing raw data from excel in hold variable for later treatment, and create the shock variable (_2)

hold.fill(o=2024)   1.06757369263768, 0.610869823286686, 1.5382878267781, 1.53828782677812, 1.5382878267781, 1.53828782677812, 1.53828782677812
smpl @all
series GBRNEIMPGNFSKD_2 = GBRNEIMPGNFSKD
smpl %fcst_start %fcst_end

{%model}.exclude(r) GBRNEIMPGNFSKD_A

'Mode set to growth: setting shock value (_2) of series BGDGBRNEIMPGNFSKD equal to level consistent with growth rates recorded in excel sheet (hold) 
series GBRNEIMPGNFSKD_2 = GBRNEIMPGNFSKD_2(-1) * (1 + hold / 100)
{%model}.override(m) GBRNEIMPGNFSKD
{%model}.exclude(m) GBRNEIMPGNFSKD



'Exclusion for row #11, Var:INDNEIMPGNFSKD
'Placing raw data from excel in hold variable for later treatment, and create the shock variable (_2)

hold.fill(o=2024)   7.20000000000001, 8.60000000000001, 8.49999999999973, 8.49999999999973, 8.49999999999973, 8.49999999999975, 8.49999999999973
smpl @all
series INDNEIMPGNFSKD_2 = INDNEIMPGNFSKD
smpl %fcst_start %fcst_end

{%model}.exclude(r) INDNEIMPGNFSKD_A

'Mode set to growth: setting shock value (_2) of series BGDINDNEIMPGNFSKD equal to level consistent with growth rates recorded in excel sheet (hold) 
series INDNEIMPGNFSKD_2 = INDNEIMPGNFSKD_2(-1) * (1 + hold / 100)
{%model}.override(m) INDNEIMPGNFSKD
{%model}.exclude(m) INDNEIMPGNFSKD



'Exclusion for row #12, Var:ITANEIMPGNFSKD
'Placing raw data from excel in hold variable for later treatment, and create the shock variable (_2)

hold.fill(o=2024)   2.94017899790915, 3.03973313129438, 2.83093344541754, 2.83093344541754, 2.83093344541754, 2.83093344541754, 2.83093344541754
smpl @all
series ITANEIMPGNFSKD_2 = ITANEIMPGNFSKD
smpl %fcst_start %fcst_end

{%model}.exclude(r) ITANEIMPGNFSKD_A

'Mode set to growth: setting shock value (_2) of series BGDITANEIMPGNFSKD equal to level consistent with growth rates recorded in excel sheet (hold) 
series ITANEIMPGNFSKD_2 = ITANEIMPGNFSKD_2(-1) * (1 + hold / 100)
{%model}.override(m) ITANEIMPGNFSKD
{%model}.exclude(m) ITANEIMPGNFSKD



'Exclusion for row #13, Var:NLDNEIMPGNFSKD
'Placing raw data from excel in hold variable for later treatment, and create the shock variable (_2)

hold.fill(o=2024)   2.77787094474653, 3.47546102906802, 3.65206128903235, 3.65206128903237, 3.65206128903237, 3.65206128903237, 3.65206128903237
smpl @all
series NLDNEIMPGNFSKD_2 = NLDNEIMPGNFSKD
smpl %fcst_start %fcst_end

{%model}.exclude(r) NLDNEIMPGNFSKD_A

'Mode set to growth: setting shock value (_2) of series BGDNLDNEIMPGNFSKD equal to level consistent with growth rates recorded in excel sheet (hold) 
series NLDNEIMPGNFSKD_2 = NLDNEIMPGNFSKD_2(-1) * (1 + hold / 100)
{%model}.override(m) NLDNEIMPGNFSKD
{%model}.exclude(m) NLDNEIMPGNFSKD



'Exclusion for row #14, Var:BELNEIMPGNFSKD
'Placing raw data from excel in hold variable for later treatment, and create the shock variable (_2)

hold.fill(o=2024)   1.88249759809309, 4.04045865243743, 3.95701858746458, 3.95701858746458, 3.95701858746458, 3.95701858746458, 3.95701858746458
smpl @all
series BELNEIMPGNFSKD_2 = BELNEIMPGNFSKD
smpl %fcst_start %fcst_end

{%model}.exclude(r) BELNEIMPGNFSKD_A

'Mode set to growth: setting shock value (_2) of series BGDBELNEIMPGNFSKD equal to level consistent with growth rates recorded in excel sheet (hold) 
series BELNEIMPGNFSKD_2 = BELNEIMPGNFSKD_2(-1) * (1 + hold / 100)
{%model}.override(m) BELNEIMPGNFSKD
{%model}.exclude(m) BELNEIMPGNFSKD



'Exclusion for row #15, Var:ROWNEIMPGNFSKD
'Placing raw data from excel in hold variable for later treatment, and create the shock variable (_2)

hold.fill(o=2024)   4.66461657194597, 4.47683898938525, 4.09321484335943, 4.06511363586894, 4.03672241516266, 4.00798851961421, 3.97885741834534
smpl @all
series ROWNEIMPGNFSKD_2 = ROWNEIMPGNFSKD
smpl %fcst_start %fcst_end

{%model}.exclude(r) ROWNEIMPGNFSKD_A

'Mode set to growth: setting shock value (_2) of series BGDROWNEIMPGNFSKD equal to level consistent with growth rates recorded in excel sheet (hold) 
series ROWNEIMPGNFSKD_2 = ROWNEIMPGNFSKD_2(-1) * (1 + hold / 100)
{%model}.override(m) ROWNEIMPGNFSKD
{%model}.exclude(m) ROWNEIMPGNFSKD



'Exclusion for row #16, Var:USANEIMPGNFSKD
'Placing raw data from excel in hold variable for later treatment, and create the shock variable (_2)

hold.fill(o=2024)   -0.0193568578648384, 1.50187287994186, 2.38807121134528, 2.38807121134526, 2.38807121134526, 2.38807121134526, 2.38807121134526
smpl @all
series USANEIMPGNFSKD_2 = USANEIMPGNFSKD
smpl %fcst_start %fcst_end

{%model}.exclude(r) USANEIMPGNFSKD_A

'Mode set to growth: setting shock value (_2) of series BGDUSANEIMPGNFSKD equal to level consistent with growth rates recorded in excel sheet (hold) 
series USANEIMPGNFSKD_2 = USANEIMPGNFSKD_2(-1) * (1 + hold / 100)
{%model}.override(m) USANEIMPGNFSKD
{%model}.exclude(m) USANEIMPGNFSKD



'Exclusion for row #17, Var:TURNEIMPGNFSKD
'Placing raw data from excel in hold variable for later treatment, and create the shock variable (_2)

hold.fill(o=2024)   3.50000000000006, 4.00000000000007, 5.59999999999992, 5.59999999999994, 5.59999999999994, 5.59999999999996, 5.59999999999996
smpl @all
series TURNEIMPGNFSKD_2 = TURNEIMPGNFSKD
smpl %fcst_start %fcst_end

{%model}.exclude(r) TURNEIMPGNFSKD_A

'Mode set to growth: setting shock value (_2) of series BGDTURNEIMPGNFSKD equal to level consistent with growth rates recorded in excel sheet (hold) 
series TURNEIMPGNFSKD_2 = TURNEIMPGNFSKD_2(-1) * (1 + hold / 100)
{%model}.override(m) TURNEIMPGNFSKD
{%model}.exclude(m) TURNEIMPGNFSKD



'Exclusion for row #20, Var:SAUNYGDPMKTPCD
'Placing raw data from excel in hold variable for later treatment, and create the shock variable (_2)

hold.fill(o=2024)   2.43014063034539, 2.56204594810416, 4.22180031675656, 4.22180031675656, 4.22180031675656, 4.22180031675656, 4.22180031675656
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

hold.fill(o=2024)   6.47458191638317, 2.12502091286897, 2.12504277546712, 2.12504277546712, 2.12504277546712, 2.12504277546712, 2.12504277546712
smpl @all
series ARENYGDPMKTPCD_2 = ARENYGDPMKTPCD
smpl %fcst_start %fcst_end

{%model}.exclude(r) ARENYGDPMKTPCD_A

'Mode set to growth: setting shock value (_2) of series BGDARENYGDPMKTPCD equal to level consistent with growth rates recorded in excel sheet (hold) 
series ARENYGDPMKTPCD_2 = ARENYGDPMKTPCD_2(-1) * (1 + hold / 100)
{%model}.override(m) ARENYGDPMKTPCD
{%model}.exclude(m) ARENYGDPMKTPCD



'Exclusion for row #22, Var:GBRNYGDPMKTPCD
'Placing raw data from excel in hold variable for later treatment, and create the shock variable (_2)

hold.fill(o=2024)   7.6736535993126, 6.75340263422453, 6.61096776699683, 6.61096776699683, 6.61096776699683, 6.61096776699683, 6.61096776699681
smpl @all
series GBRNYGDPMKTPCD_2 = GBRNYGDPMKTPCD
smpl %fcst_start %fcst_end

{%model}.exclude(r) GBRNYGDPMKTPCD_A

'Mode set to growth: setting shock value (_2) of series BGDGBRNYGDPMKTPCD equal to level consistent with growth rates recorded in excel sheet (hold) 
series GBRNYGDPMKTPCD_2 = GBRNYGDPMKTPCD_2(-1) * (1 + hold / 100)
{%model}.override(m) GBRNYGDPMKTPCD
{%model}.exclude(m) GBRNYGDPMKTPCD



'Exclusion for row #23, Var:KWTNYGDPMKTPCD
'Placing raw data from excel in hold variable for later treatment, and create the shock variable (_2)

hold.fill(o=2024)   1.34180904914278, -2.33950992630203, -2.33950945947403, -2.33950945947403, -2.33950945947403, -2.33950945947402, -2.33950945947401
smpl @all
series KWTNYGDPMKTPCD_2 = KWTNYGDPMKTPCD
smpl %fcst_start %fcst_end

{%model}.exclude(r) KWTNYGDPMKTPCD_A

'Mode set to growth: setting shock value (_2) of series BGDKWTNYGDPMKTPCD equal to level consistent with growth rates recorded in excel sheet (hold) 
series KWTNYGDPMKTPCD_2 = KWTNYGDPMKTPCD_2(-1) * (1 + hold / 100)
{%model}.override(m) KWTNYGDPMKTPCD
{%model}.exclude(m) KWTNYGDPMKTPCD



'Exclusion for row #24, Var:USANYGDPMKTPCD
'Placing raw data from excel in hold variable for later treatment, and create the shock variable (_2)

hold.fill(o=2024)   3.77336996880142, 3.87011822647163, 4.04486586989181, 4.04486586989181, 4.04486586989181, 4.04486586989181, 4.04486586989179
smpl @all
series USANYGDPMKTPCD_2 = USANYGDPMKTPCD
smpl %fcst_start %fcst_end

{%model}.exclude(r) USANYGDPMKTPCD_A

'Mode set to growth: setting shock value (_2) of series BGDUSANYGDPMKTPCD equal to level consistent with growth rates recorded in excel sheet (hold) 
series USANYGDPMKTPCD_2 = USANYGDPMKTPCD_2(-1) * (1 + hold / 100)
{%model}.override(m) USANYGDPMKTPCD
{%model}.exclude(m) USANYGDPMKTPCD



'Exclusion for row #25, Var:QATNYGDPMKTPCD
'Placing raw data from excel in hold variable for later treatment, and create the shock variable (_2)

hold.fill(o=2024)   -8.64129910025191, 8.27573442641762, 8.27573442641745, 8.27573442641747, 8.27573442641747, 8.27573442641747, 8.27573442641745
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

hold.fill(o=2024)   2.64423076923055, 2.34192037470706, 2.93501144164809, 2.93501144164807, 2.93501144164807, 2.93501144164807, 2.93501144164809
smpl @all
series OMNNYGDPMKTPCD_2 = OMNNYGDPMKTPCD
smpl %fcst_start %fcst_end

{%model}.exclude(r) OMNNYGDPMKTPCD_A

'Mode set to growth: setting shock value (_2) of series BGDOMNNYGDPMKTPCD equal to level consistent with growth rates recorded in excel sheet (hold) 
series OMNNYGDPMKTPCD_2 = OMNNYGDPMKTPCD_2(-1) * (1 + hold / 100)
{%model}.override(m) OMNNYGDPMKTPCD
{%model}.exclude(m) OMNNYGDPMKTPCD



'Exclusion for row #27, Var:SGPNYGDPMKTPCD
'Placing raw data from excel in hold variable for later treatment, and create the shock variable (_2)

hold.fill(o=2024)   4.75039830741868, 5.05703480748567, 4.71872574800538, 4.71872574800538, 4.71872574800538, 4.71872574800536, 4.71872574800538
smpl @all
series SGPNYGDPMKTPCD_2 = SGPNYGDPMKTPCD
smpl %fcst_start %fcst_end

{%model}.exclude(r) SGPNYGDPMKTPCD_A

'Mode set to growth: setting shock value (_2) of series BGDSGPNYGDPMKTPCD equal to level consistent with growth rates recorded in excel sheet (hold) 
series SGPNYGDPMKTPCD_2 = SGPNYGDPMKTPCD_2(-1) * (1 + hold / 100)
{%model}.override(m) SGPNYGDPMKTPCD
{%model}.exclude(m) SGPNYGDPMKTPCD



'Exclusion for row #28, Var:DEUNYGDPMKTPCD
'Placing raw data from excel in hold variable for later treatment, and create the shock variable (_2)

hold.fill(o=2024)   6.11843261409508, 5.51853692225479, 4.46538488082135, 4.46538488082135, 4.46538488082135, 4.46538488082135, 4.46538488082135
smpl @all
series DEUNYGDPMKTPCD_2 = DEUNYGDPMKTPCD
smpl %fcst_start %fcst_end

{%model}.exclude(r) DEUNYGDPMKTPCD_A

'Mode set to growth: setting shock value (_2) of series BGDDEUNYGDPMKTPCD equal to level consistent with growth rates recorded in excel sheet (hold) 
series DEUNYGDPMKTPCD_2 = DEUNYGDPMKTPCD_2(-1) * (1 + hold / 100)
{%model}.override(m) DEUNYGDPMKTPCD
{%model}.exclude(m) DEUNYGDPMKTPCD



'Exclusion for row #29, Var:BHRNYGDPMKTPCD
'Placing raw data from excel in hold variable for later treatment, and create the shock variable (_2)

hold.fill(o=2024)   4.34042446895748, 4.57472690526275, 4.57472690526295, 4.57472690526293, 4.57472690526295, 4.57472690526295, 4.57472690526295
smpl @all
series BHRNYGDPMKTPCD_2 = BHRNYGDPMKTPCD
smpl %fcst_start %fcst_end

{%model}.exclude(r) BHRNYGDPMKTPCD_A

'Mode set to growth: setting shock value (_2) of series BGDBHRNYGDPMKTPCD equal to level consistent with growth rates recorded in excel sheet (hold) 
series BHRNYGDPMKTPCD_2 = BHRNYGDPMKTPCD_2(-1) * (1 + hold / 100)
{%model}.override(m) BHRNYGDPMKTPCD
{%model}.exclude(m) BHRNYGDPMKTPCD



'Exclusion for row #30, Var:JPNNYGDPMKTPCD
'Placing raw data from excel in hold variable for later treatment, and create the shock variable (_2)

hold.fill(o=2024)   1.30765190002489, 5.56303300843257, 4.10006440265225, 4.10006440265225, 4.10006440265223, 4.10006440265223, 4.10006440265223
smpl @all
series JPNNYGDPMKTPCD_2 = JPNNYGDPMKTPCD
smpl %fcst_start %fcst_end

{%model}.exclude(r) JPNNYGDPMKTPCD_A

'Mode set to growth: setting shock value (_2) of series BGDJPNNYGDPMKTPCD equal to level consistent with growth rates recorded in excel sheet (hold) 
series JPNNYGDPMKTPCD_2 = JPNNYGDPMKTPCD_2(-1) * (1 + hold / 100)
{%model}.override(m) JPNNYGDPMKTPCD
{%model}.exclude(m) JPNNYGDPMKTPCD



'Exclusion for row #31, Var:MYSNYGDPMKTPCD
'Placing raw data from excel in hold variable for later treatment, and create the shock variable (_2)

hold.fill(o=2024)   4.90999289538565, 4.78653904902757, 4.78653904902744, 4.78653904902744, 4.78653904902744, 4.78653904902744, 4.78653904902744
smpl @all
series MYSNYGDPMKTPCD_2 = MYSNYGDPMKTPCD
smpl %fcst_start %fcst_end

{%model}.exclude(r) MYSNYGDPMKTPCD_A

'Mode set to growth: setting shock value (_2) of series BGDMYSNYGDPMKTPCD equal to level consistent with growth rates recorded in excel sheet (hold) 
series MYSNYGDPMKTPCD_2 = MYSNYGDPMKTPCD_2(-1) * (1 + hold / 100)
{%model}.override(m) MYSNYGDPMKTPCD
{%model}.exclude(m) MYSNYGDPMKTPCD



'Exclusion for row #34, Var:USAINTRFR
'Placing raw data from excel in hold variable for later treatment, and create the shock variable (_2)

hold.fill(o=2024)   2.96920015456584, 2.77943587659525, 2.60603202017868, 2.60603202017868, 2.60603202017868, 2.60603202017868, 2.60603202017868
smpl @all
series USAINTRFR_2 = USAINTRFR
smpl %fcst_start %fcst_end

{%model}.exclude(r) USAINTRFR_A


'Mode set to level, setting shock value (_2) of series BGDUSAINTRFR equal to values in excel sheet (hold) 
series USAINTRFR_2 = hold 'USAINTRFR
{%model}.override(m) USAINTRFR
{%model}.exclude(m) USAINTRFR
'The following variables were in exogenous mode but were ucnhanged
{%model}.exclude(m) 


'********************************************************************************************************
'***************** Writing excludes for sheet Commodities *****************************************
'********************************************************************************************************



'Exclusion for row #5, Var:WLDFCRUDE_Petro
'Placing raw data from excel in hold variable for later treatment, and create the shock variable (_2)

hold.fill(o=2024)   81, 78, 76.9718899162707, 80.8204844120842, 84.8615086326885, 89.1045840643229, 93.559813267539
smpl @all
series WLDFCRUDE_Petro_2 = WLDFCRUDE_Petro
smpl %fcst_start %fcst_end

{%model}.exclude(r) WLDFCRUDE_Petro_A


'Mode set to level, setting shock value (_2) of series BGDWLDFCRUDE_Petro equal to values in excel sheet (hold) 
series WLDFCRUDE_Petro_2 = hold 'WLDFCRUDE_Petro
{%model}.override(m) WLDFCRUDE_Petro
{%model}.exclude(m) WLDFCRUDE_Petro



'Exclusion for row #6, Var:WLDFNGAS_EUR
'Placing raw data from excel in hold variable for later treatment, and create the shock variable (_2)

hold.fill(o=2024)   12, 11.5, 11.3109620498341, 11.8765101523258, 12.4703356599421, 13.0938524429392, 13.7485450650862
smpl @all
series WLDFNGAS_EUR_2 = WLDFNGAS_EUR
smpl %fcst_start %fcst_end

{%model}.exclude(r) WLDFNGAS_EUR_A


'Mode set to level, setting shock value (_2) of series BGDWLDFNGAS_EUR equal to values in excel sheet (hold) 
series WLDFNGAS_EUR_2 = hold 'WLDFNGAS_EUR
{%model}.override(m) WLDFNGAS_EUR
{%model}.exclude(m) WLDFNGAS_EUR



'Exclusion for row #7, Var:WLDFCOAL_AUS
'Placing raw data from excel in hold variable for later treatment, and create the shock variable (_2)

hold.fill(o=2024)   130, 110, 107.407398713037, 112.777768648689, 118.416657081123, 124.337489935179, 130.554364431938
smpl @all
series WLDFCOAL_AUS_2 = WLDFCOAL_AUS
smpl %fcst_start %fcst_end



'Mode set to level, setting shock value (_2) of series BGDWLDFCOAL_AUS equal to values in excel sheet (hold) 
series WLDFCOAL_AUS_2 = hold 'WLDFCOAL_AUS
{%model}.override(m) WLDFCOAL_AUS
{%model}.exclude(m) WLDFCOAL_AUS



'Exclusion for row #10, Var:WLDFALUMINUM
'Placing raw data from excel in hold variable for later treatment, and create the shock variable (_2)

hold.fill(o=2024)   2200, 2400, 2419.28733740157, 2540.25170427165, 2667.26428948523, 2800.62750395949, 2940.65887915747
smpl @all
series WLDFALUMINUM_2 = WLDFALUMINUM
smpl %fcst_start %fcst_end

{%model}.exclude(r) WLDFALUMINUM_A


'Mode set to level, setting shock value (_2) of series BGDWLDFALUMINUM equal to values in excel sheet (hold) 
series WLDFALUMINUM_2 = hold 'WLDFALUMINUM
{%model}.override(m) WLDFALUMINUM
{%model}.exclude(m) WLDFALUMINUM



'Exclusion for row #11, Var:WLDFCOPPER
'Placing raw data from excel in hold variable for later treatment, and create the shock variable (_2)

hold.fill(o=2024)   8100, 8500, 8448.62495843006, 8871.05620635156, 9314.60901666914, 9780.3394675026, 10269.3564408777
smpl @all
series WLDFCOPPER_2 = WLDFCOPPER
smpl %fcst_start %fcst_end

{%model}.exclude(r) WLDFCOPPER_A


'Mode set to level, setting shock value (_2) of series BGDWLDFCOPPER equal to values in excel sheet (hold) 
series WLDFCOPPER_2 = hold 'WLDFCOPPER
{%model}.override(m) WLDFCOPPER
{%model}.exclude(m) WLDFCOPPER



'Exclusion for row #12, Var:WLDFIRON_ORE
'Placing raw data from excel in hold variable for later treatment, and create the shock variable (_2)

hold.fill(o=2024)   105, 100, 98.9519258206214, 103.899522111652, 109.094498217235, 114.549223128097, 120.276684284502
smpl @all
series WLDFIRON_ORE_2 = WLDFIRON_ORE
smpl %fcst_start %fcst_end

{%model}.exclude(r) WLDFIRON_ORE_A


'Mode set to level, setting shock value (_2) of series BGDWLDFIRON_ORE equal to values in excel sheet (hold) 
series WLDFIRON_ORE_2 = hold 'WLDFIRON_ORE
{%model}.override(m) WLDFIRON_ORE
{%model}.exclude(m) WLDFIRON_ORE



'Exclusion for row #13, Var:WLDFLEAD
'Placing raw data from excel in hold variable for later treatment, and create the shock variable (_2)

hold.fill(o=2024)   2050, 2100, 2100, 2205, 2315.25, 2431.0125, 2552.563125
smpl @all
series WLDFLEAD_2 = WLDFLEAD
smpl %fcst_start %fcst_end

{%model}.exclude(r) WLDFLEAD_A


'Mode set to level, setting shock value (_2) of series BGDWLDFLEAD equal to values in excel sheet (hold) 
series WLDFLEAD_2 = hold 'WLDFLEAD
{%model}.override(m) WLDFLEAD
{%model}.exclude(m) WLDFLEAD
'The following variables were in exogenous mode but were ucnhanged
{%model}.exclude(m) WLDFNICKEL WLDFGOLD WLDFSILVER WLDFCOTTON_A_INDX WLDFISTL_JP_INDX WLDFPLYWOOD WLDFWOODPULP WLDFTOBAC_US MUV WLDFMAIZE WLDFRICE_05 WLDFWHEAT_US_HRW WLDFBANANA_US WLDFBEEF WLDFCOCOA WLDFCOFFEE_COMPO WLDFGRNUT_OIL WLDFORANGE WLDFPALM_OIL WLDFSORGHUM WLDFSOYBEAN_MEAL WLDFSOYBEAN_OIL WLDFSOYBEANS WLDFSUGAR_WLD WLDFTEA_AVG
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
%Fname="C:\WBG\LocalITUtilities\BGD\Data\BGD2024-21-02~09-20-00soln.wf1"
wfsave(2) %Fname
close BGD2024-21-02~09-20-00soln
wfselect BGDsoln
