' ============================
' DAMAGES AND ADAPTATION
' ============================

' ============================
' [1] Data consruction
' ============================

	smpl @all
' Damage variables
	series {%cty}avdamage = 0 ' The expected damange (in % GDP)
	series {%cty}NEFLOAVERKN_ = {%cty}avdamage
	series {%cty}COVERAGE = 0 ' How much of damages are being covered by investment into adaptation
	series {%cty}adap = 0 ' How much of damages are being covered by investment into adaptation
	series {%cty}insu = 0 ' How much of damages are being covered by investment into private insurance
	series {%cty}cofu = 0  ' How much of damages are being covered by investment into contingency funds
	series {%cty}debt = 0 ' How much of damages are being covered by investment into reducing debts

'====================================
' MARKUP CALCULATION FOR INSURANCE
	series {%cty}scale =  2644.44 
	series {%cty}shape =  0.122 
	scalar {%cty}resc = 2 

	series {%cty}means = ({%cty}NEFLOAVERKN_)*{%cty}shape*{%cty}scale/3.07  ' 3.07 is a scalar to ensure that E(D)=AAL  (((({%cty}NEHURAVERKN_+0.00000001)/100)*@elem({%cty}nygdpmktpkd,"2017"))/shape)*3.07
	series {%cty}markup = (((({%cty}NEFLOAVERKN_*{%cty}shape*({%cty}scale^2))/{%cty}resc)^(1/2))*0.1)/(0.00000001+{%cty}NEFLOAVERKN_*{%cty}shape*{%cty}scale/{%cty}resc)  ' 0.11 is the standard parameter charged on variances
'====================================


	series {%cty}DISPREPCN = {%cty}adap*{%cty}COVERAGE*({%cty}avdamage/100)*{%cty}NYGDPMKTPCN 'investment in disaster preparation
	series {%cty}DISPREPCNI = {%cty}INSU*(1+{%cty}markup)*({%cty}avdamage/100)*{%cty}NYGDPMKTPCN ' investment in disaster preparation (private insurance)
	series {%cty}DISPREPCNC = {%cty}COFU*({%cty}avdamage/100)*{%cty}NYGDPMKTPCN 'investment in disaster preparation (contingency fund)
	series {%cty}DISPREPCND = {%cty}DEBT*({%cty}avdamage/100)*{%cty}NYGDPMKTPCN 'investment in disaster preparation (reducing public debt to make space for shocks)

	series {%cty}DISPREPKN = {%cty}DISPREPCN/{%cty}NYGDPMKTPXN 'Disaster preparation, constant price terms
	series {%cty}DISPREPKNI = {%cty}DISPREPCNI/{%cty}NYGDPMKTPXN
	series {%cty}DISPREPKNC = {%cty}DISPREPCNC/{%cty}NYGDPMKTPXN
	series {%cty}DISPREPKND = {%cty}DISPREPCND/{%cty}NYGDPMKTPXN

	smpl @first @first
	series {%cty}NEADPKSTGKN = 0.00001 ' Adaptation capital
	smpl @first+1 %dat_end
	{%cty}NEADPKSTGKN = (({%cty}NEADPKSTGKN(-1))  * (1  - {%cty}DEPR/100)) + {%cty}DISPREPKN+0.00001 'Formation of adaptation capital (to avoid division by 0 add a tiny amount+0.0001)
	smpl @all

	series  {%cty}NEADPKMAXKN = ((1+0.01)/(0.01+{%cty}DEPR/100))*(({%cty}avdamage+0.00001)/100)*{%cty}NYGDPMKTPKN 'Maximum adaptation level

	series {%cty}NEFLOPTVTKN = @recode(1.0*({%cty}NEADPKSTGKN/{%cty}NEADPKMAXKN)^0.3<0,0.001,1.0*({%cty}NEADPKSTGKN/{%cty}NEADPKMAXKN)^0.3) 'Calculation of protection level. The minimum protection level is set to a very small positive value to avoid problems in solving the model.

	series {%cty}FLODSTKN = 0
	series {%cty}FLODAMKN = 0
	series {%cty}FLODAMCN = 0
	series {%cty}PAYOUTCN = 0
	series {%cty}CFVOLUMECN = 0
	series {%cty}CFVOLUMEKN = 0
	series {%cty}GGEXPRECVCN = 0
	series {%cty}interestcf = 0.03
	series {%cty}RECOVINVESTKN  = 0

	series myear=@year
	!stDate1=@ifirst({%cty}NEGDIKSTKKN)
	%stDate=@str(myear(!stDate1))

	smpl %stDate %stDate
	series {%cty}NEGDIKSTKKN2 = {%cty}NEGDIKSTKKN
	smpl %stDate+1 %dat_end
	{%cty}NEGDIKSTKKN2 = {%cty}NEGDIKSTKKN2(-1) * (1 - {%cty}DEPR) + {%cty}NEGDIFTOTKN-{%cty}RECOVINVESTKN
' ============================
' [2] Equation and identities
' ============================

	' {%cty}FLODSTKN = stock of capital destroyed. First need to invest here before capital becomes productive again (i.e. goes into the production function) ; 0 for now historically
	' {%cty}FLODAMKN = damages from climate shock
	' {%cty}RECOVINVESTKN = Is the reconstruction investment (0 for now historically)

	{%cty}.append @IDENTITY {%cty}NEFLOAVERKN_ = {%cty}avdamage

	{%cty}.append @IDENTITY {%cty}FLODSTKN = @recode({%cty}FLODSTKN(-1) + {%cty}FLODAMKN - {%cty}RECOVINVESTKN>0.9*{%cty}NEGDIKSTKKN2,0.9*{%cty}NEGDIKSTKKN2,{%cty}FLODSTKN(-1) + {%cty}FLODAMKN - {%cty}RECOVINVESTKN) 

	{%cty}.append @identity {%cty}RECOVINVESTKN = @recode({%cty}FLODSTKN(-1)>0.5*{%cty}NEGDIFGOVKN,0.5*{%cty}NEGDIFGOVKN,{%cty}FLODSTKN(-1)) 'Amount of money invested into damage repair. Assumption: The government can invest at most half of all government investment into recovery.

	{%cty}.append @IDENTITY {%cty}NEGDIKSTKKN2 = {%cty}NEGDIKSTKKN2(-1) * (1 - {%cty}DEPR) + {%cty}NEGDIFTOTKN-{%cty}RECOVINVESTKN

	'{%cty}.DROP {%cty}NEGDIKSTKKN

	{%cty}.append @IDENTITY {%cty}NEGDIKSTKKN = (1-({%cty}FLODSTKN/{%cty}NEGDIKSTKKN2))^(1/(1-(1-{%cty}NYYWBTOTLCN_)))*{%cty}NEGDIKSTKKN2 'Capital stock following Hallegatte & Vogt-Schilb (2016) 


'***************************************** 
'Adaptation to flooding damage 
'***************************************** 

	{%cty}.append @identity {%cty}DISPREPCN = {%cty}adap*{%cty}COVERAGE*({%cty}avdamage/100)*{%cty}NYGDPMKTPCN 'investment in disaster preparation

	{%cty}.append @identity {%cty}NEADPKSTGKN = (({%cty}NEADPKSTGKN(-1))  * (1  - {%cty}DEPR/100)) + {%cty}DISPREPKN+0.00001 'Formation of adaptation capital

	{%cty}.append @identity {%cty}NEADPKMAXKN = ((1+0.01)/(0.01+{%cty}DEPR/100))*(({%cty}avdamage+0.00001)/100)*{%cty}NYGDPMKTPKN 'Maximum adaptation level

	{%cty}.append @identity {%cty}NEFLOPTVTKN = @recode(1.0*({%cty}NEADPKSTGKN/{%cty}NEADPKMAXKN)^0.3<0,0.001,1.0*({%cty}NEADPKSTGKN/{%cty}NEADPKMAXKN)^0.3) 'Calculation of protection level. The minimum protection level is set to a very small positive value to avoid problems in solving the model.

	{%cty}.append @identity {%cty}FLODAMKN =  ({%cty}NEFLOAVERKN_/100)*{%cty}NYGDPMKTPKN(-1)*(1-{%cty}NEFLOPTVTKN)  'Calculation of residual flooding damage: Flooding damage (first part) and damage reductions from adaptation (second part).
	{%cty}.append @identity {%cty}FLODAMCN = {%cty}FLODAMKN*{%cty}NYGDPMKTPXN 'Conversion of flooding damage to current prices

'***************************************** 
' Investment options
'*****************************************
	{%cty}.append @identity {%cty}markup = (((({%cty}NEFLOAVERKN_*{%cty}shape*({%cty}scale^2))/{%cty}resc)^(1/2))*0.1)/(0.00000001+{%cty}NEFLOAVERKN_*{%cty}shape*{%cty}scale/{%cty}resc)  ' 0.11 is the standard parameter charged on variances
	{%cty}.append @identity {%cty}DISPREPCNI = {%cty}INSU*(1+{%cty}markup)*({%cty}avdamage/100)*{%cty}NYGDPMKTPCN ' investment in disaster preparation (private insurance)
	{%cty}.append @identity {%cty}DISPREPCNC = {%cty}COFU*({%cty}avdamage/100)*{%cty}NYGDPMKTPCN 'investment in disaster preparation (contingency fund)
	{%cty}.append @identity {%cty}DISPREPCND = {%cty}DEBT*({%cty}avdamage/100)*{%cty}NYGDPMKTPCN 'investment in disaster preparation (reducing public debt to make space for shocks)

	{%cty}.append @identity {%cty}DISPREPKN = {%cty}DISPREPCN/{%cty}NYGDPMKTPXN 'Disaster preparation, constant price terms
	{%cty}.append @identity {%cty}DISPREPKNI = {%cty}DISPREPCNI/{%cty}NYGDPMKTPXN
	{%cty}.append @identity {%cty}DISPREPKNC = {%cty}DISPREPCNC/{%cty}NYGDPMKTPXN
	{%cty}.append @identity {%cty}DISPREPKND = {%cty}DISPREPCND/{%cty}NYGDPMKTPXN

'***************************************** 
' Insurance components
'*****************************************

	{%cty}.append @identity {%cty}PAYOUTCN = ({%cty}insu+{%cty}debt)*{%cty}FLODAMCN+{%cty}cofu*@recode({%cty}CFVOLUMECN>{%cty}FLODAMCN,{%cty}FLODAMCN,{%cty}CFVOLUMECN) 'Insurance payout depending on coverage and depending on the insurance type. In the case of the contingency fund, the payout is limited by the volume of the fund.

	{%cty}.append @identity {%cty}GGEXPRECVCN  = 0.5 * {%cty}PAYOUTCN + 0.5 * {%cty}PAYOUTCN (-1) ' Public recovery Spending from payout

	{%cty}.append @identity {%cty}CFVOLUMECN={%cty}CFVOLUMECN(-1)*(1+{%cty}interestcf)+{%cty}DISPREPCNC-{%cty}cofu*{%cty}PAYOUTCN(-1) 'Evolution of the fund size

	{%cty}.append @identity {%cty}CFVOLUMEKN={%cty}CFVOLUMECN/{%cty}NYGDPMKTPXN

'***************************************** 
' Change existing identities
'*****************************************
	'{%cty}.drop {%cty}NYGDPMKTPKN
	'{%cty}.drop {%cty}NYGDPMKTPCN
	{%cty}.drop {%cty}GGEXPTOTLCN
	{%cty}.drop {%cty}GGREVTOTLCN

	{%cty}.append @IDENTITY {%cty}NYGDPMKTPKN={%cty}NYGDPDISCKN+{%cty}NECONPRVTKN+{%cty}NECONGOVTKN+{%cty}NEGDIFTOTKN+{%cty}NEEXPGNFSKN-{%cty}NEIMPGNFSKN+{%cty}NEGDISTKBKN+{%cty}DISPREPKN
	{%cty}.append @IDENTITY {%cty}NYGDPMKTPCN={%cty}NECONPRVTCN+{%cty}NECONGOVTCN+{%cty}NEGDIFTOTCN+{%cty}NEEXPGNFSCN-{%cty}NEIMPGNFSCN+{%cty}NEGDISTKBCN+{%cty}NYGDPDISCCN+{%cty}DISPREPCN

' Change fiscal estimates
	smpl @all
	series {%cty}fininv = 0.5
	smpl @first %est_end
	!now = 0.15
	equation _{%cty}GGEXPGNFSCN.LS(OPTMETHOD=LEGACY) {%cty}GGEXPGNFSCN  = !now*{%cty}GGEXPGNFSCN(-1)+(1-!now)*(0.18 *({%cty}GGREVTOTLCN-{%cty}GGEXPINTPCN(-0))) - (1-{%cty}fininv)*({%cty}DISPREPCN) +C(10) *@DURING("2012")
	equation _{%cty}GGEXPCAPTCN.LS(OPTMETHOD=LEGACY)  {%cty}GGEXPCAPTCN = !now*{%cty}GGEXPCAPTCN(-1)+(1-!now)*(0.13*({%cty}GGREVTOTLCN-{%cty}GGEXPINTPCN(-0)))- {%cty}fininv*({%cty}DISPREPCN)+C(10)*@DURING("2013") 'Capital expenditure (fiscal rule)
	equation _{%cty}GGEXPWAGECN.LS(OPTMETHOD=LEGACY)  {%cty}GGEXPWAGECN = !now*{%cty}GGEXPWAGECN(-1)+(1-!now)*(0.43*({%cty}GGREVTOTLCN-{%cty}GGEXPINTPCN(-0)))- {%cty}fininv*({%cty}DISPREPCN)+C(10)*@DURING("2013") 'Capital expenditure (fiscal rule)

	smpl @all
	series {%cty}GGEXPOTHRCN = {%cty}GGEXPTOTLCN - ({%cty}GGEXPWAGECN + {%cty}GGEXPINTPCN + {%cty}GGEXPGNFSCN  + {%cty}GGEXPCAPTCN + {%cty}GGEXPTRNSCN + {%cty}DISPREPCN+{%cty}DISPREPCNI+{%cty}DISPREPCNC+{%cty}HEAPCN)
	equation _{%cty}GGEXPOTHRCN.LS {%cty}GGEXPOTHRCN/({%cty}GGREVTOTLCN-{%cty}GGEXPINTPCN) = C(1)

	{%cty}.append @IDENTITY {%cty}GGEXPTOTLCN = {%cty}GGEXPWAGECN + {%cty}GGEXPINTPCN + {%cty}GGEXPGNFSCN  + {%cty}GGEXPCAPTCN + {%cty}GGEXPOTHRCN + {%cty}GGEXPTRNSCN +{%cty}DISPREPCN+{%cty}DISPREPCNI+{%cty}DISPREPCNC+{%cty}HEAPCN
	{%cty}.append @IDENTITY {%cty}GGREVTOTLCN = {%cty}GGREVTAXTCN + {%cty}GGREVNONTCN + {%cty}GGREVGRNTCN + {%cty}GGREVOTHRCN + {%cty}GGREVEMISCN + {%cty}GGREVELECN+({%cty}insu+{%cty}cofu)*{%cty}PAYOUTCN

'*************************************************************
' Change Potential GDP
'*************************************************************
	'{%cty}.DROP {%cty}NYGDPPOTLKN
	'{%cty}.DROP {%cty}NYGDPPOTLKD 
	'{%cty}.DROP {%cty}NYGDPGAP_

	series {%cty}AGDAMAGE = 0 ' Agricultural damages
	series {%cty}HEATLOSS = 0 ' Heat damages

	{%cty}.append @identity {%cty}NYGDPPOTLKN  = (1  + {%cty}AGDAMAGE  * @ELEM({%cty}NVAGRTOTLKN , "2018")  / @ELEM({%cty}NYGDPMKTPKN  , "2018"))*{%cty}NYGDPTFP*((1  - ({%cty}HEATLOSS  / 100))  * {%cty}LMEMPSTRL^{%cty}NYYWBTOTLCN_)  * ({%cty}NEGDIKSTKKN(-1)^(1-{%cty}NYYWBTOTLCN_))  

	{%cty}.append @identity {%cty}NYGDPPOTLKD  = ({%cty}NYGDPPOTLKN  * (@elem({%cty}NYGDPMKTPCN  , 2015)  / (@elem({%cty}NYGDPMKTPKN  , 2015))))  / @elem({%cty}panusatls  , 2015)
	{%cty}.append @identity {%cty}NYGDPGAP_  = ({%cty}NYGDPMKTPKN  / {%cty}NYGDPPOTLKN  - 1)  * 100


