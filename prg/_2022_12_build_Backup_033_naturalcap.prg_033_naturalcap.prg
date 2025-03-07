' ========================================================================================
'				NATURAL CAPITAL ACCOUNTING
' ========================================================================================

' https://development-data-hub-s3-public.s3.amazonaws.com/ddhfiles/143151/ans-methodology-january-30-2018_2_0_0.pdf

' Gross National Savings
	' Depletion of renewables and non-renewables
	' Human capital spending
	' Pollution damage (CO2 and PM2.5)
' ========================================================================================

' **********************************************
' ** Read data for accounting variables **


' **********************************************
' ** Caclulation Gross National Savings **
	' : Gross National Income - Total Consumption + Net Transfers
		' : Gross National Income = GDP + net factor income - NIT
		' : Total Consumption = Government + HH. Consumption

	series {%cty}GNICD = {%cty}NYGDPMKTPCD+ {%cty}BNFSTCABTCD - ({%cty}NYTAXNINDCN/{%cty}PANUSATLS)
	series {%cty}GNSCD = {%cty}GNICD - ({%cty}NECONPRVTCN+{%cty}NECONGOVTCN)/{%cty}PANUSATLS  
	{%cty}.APPEND @IDENTITY {%cty}GNICD = {%cty}NYGDPMKTPCD+ {%cty}BNFSTCABTCD - ({%cty}NYTAXNINDCN/{%cty}PANUSATLS)
	{%cty}.APPEND @IDENTITY {%cty}GNSCD = {%cty}GNICD - ({%cty}NECONPRVTCN+{%cty}NECONGOVTCN)/{%cty}PANUSATLS  

' **********************************************
' ** Depletion of non-renewables **
	' : Valuation V = sum_(i=t)^(t+T-1) pi(i) * q(i) * (1+r)^-(i-t)

		' pi = rent = revenues - production costs (see documentation - source is Rystad Energy (https://www.rystadenergy.com/energy-themes/oil--gas/upstream/u-cube/)
		' q = quanitity produced (sourced from EIA - however nothing on coal and oil for {%cty})
		' r = discount rate = 0.04
		' T = time to depletetion = Reserves / production (reserves also from EIA)
	' : Annual depletion: D = V/T

' Mineral and energy depleteion is exogenous for now ({%cty}NYADJDNGYCD {%cty}NYADJDMINCD)

' **********************************************
' ** Depletion of renewables **
	' : Net depletion D = (Q-N)*pi

		' : Q = Volume of roundwood harvested (Source: FAOSTAT -> = production of industrial roundwood + woodfuel)
		' : N = Volume of natural growth in production oriented forest (Source:  FAO’s Global Forest Resources Assessment)
			' : N = A*I ( (total forest area * 0.8) * net annual increment) ; or Forest Area (AG.LND.FRST.K2 sq km)
		' : pi = unit rent per cubic meter: Anual export unit value of roundwood (E) * rental adjustment factor (a) (or natural resource rent: NY.GDP.TOTL.RT.ZS)
			' E = CN/KN (Source: FAO) - countries that fall outside third quartile and first quartile are forced to global median
				' Or Oil (NY.GDP.PETR.RT.ZS) ; Gas (NY.GDP.NGAS.RT.ZS) ; Coal (NY.GDP.COAL.RT.ZS) ; Minerals (NY.GDP.MINR.RT.ZS)

'series ({%cty}NVAGRRNDWQ-{%cty}NVAGRFAREQ*0.8*{%cty}NVAGRRNDAQ)*{%cty}NVAGRRNDEQ*0.4
	' 1 M^3 = 0.0001 ha meter ; 1 Ha = 10,000 m^2
		' {%cty}NVAGRRNDWQ (m^3) ; {%cty}NVAGRFAREQ (km^2) ; {%cty}NVAGRRNDAQ (1000 ha)
'series {%cty}NYADJDFORCD2 =  (({%cty}NVAGRRNDWQ*0.001)-({%cty}NVAGRFAREQ/1000)*0.8*({%cty}NVAGRRNDAQ/1000))*({%cty}NVAGRMRNTCN_/100)*{%cty}NYGDPMKTPCD
	series {%cty}NVAGRMRNTCN_ = 0.14 ' Historical data jumps too much
	series {%cty}NYADJDFORCD2 =  (({%cty}NVAGRRNDWQ*0.001)-({%cty}NVAGRFAREQ/1000)*0.8*({%cty}NVAGRRNDAQ/1000))*({%cty}NVAGRMRNTCN_/100)*{%cty}NYGDPMKTPCD

	equation _{%cty}NVAGRRNDWQ.LS DLOG({%cty}NVAGRRNDWQ)=C(1)+C(2)*DLOG({%cty}NVAGRTOTLKN)+C(3)*DLOG({%cty}NERENCONELXN/{%cty}NEGASCONELXN) ' equation for harvesting roundwood = f(income, relative price)

	{%cty}.APPEND @IDENTITY {%cty}NYADJDFORCD2 =  (({%cty}NVAGRRNDWQ*0.001)-({%cty}NVAGRFAREQ/1000)*0.8*({%cty}NVAGRRNDAQ/1000))*({%cty}NVAGRMRNTCN_/100)*{%cty}NYGDPMKTPCD 

	smpl 1980 %end_estimate
	equation _{%cty}NYADJDFORCD.ls @PC({%cty}NYADJDFORCD) = @PC({%cty}NYADJDFORCD2)+C(1)*DUMH ' Quasi identity for forest adjustment

	' EMISSIONS FROM LAND USE (CONVERTING FOREST LAND INTO AGRICULTURAL LAND)
	equation _{%cty}CCEMISGHGFKN.ls @PC({%cty}CCEMISGHGFKN) = C(2)*@PC((({%cty}NVAGRRNDWQ*0.001)-({%cty}NVAGRFAREQ/1000)*0.8*({%cty}NVAGRRNDAQ/1000)))+C(1)*DUMH

' **********************************************
' ** CO2 Damage **
	' : Emissions (t CO2) * USD 30 (derived mainly from fossil-fuels)

	equation _{%cty}CCEMISGHGOKN.LS DLOG({%cty}CCEMISGHGOKN) = DLOG({%cty}CCEMISCO2TKN)+C(1)*DUMH ' Equation that maps modeled carbon emissions from fossil to those in WDI

	smpl @all
	series {%cty}COSTCO2 = 30 ' Social cost of carbon (30USD per ton of carbon emitted)

	series {%cty}CO2DAM = {%cty}CCEMISGHGOKN*{%cty}COSTCO2 ' Damages (in USD) from fossil fuel carbon emissions

	{%cty}.APPEND @IDENTITY {%cty}CO2DAM = {%cty}CCEMISGHGOKN*30

	smpl 1980 %end_estimate
	equation _{%cty}NYADJDCO2CD.LS DLOG({%cty}NYADJDCO2CD) = DLOG({%cty}CO2DAM) + C(1)*DUMH

' **********************************************
' ** Local Air Pollution Damage **

	' : Financial costs due to premature deaths = Deaths *  [sum_(i)^(T) * (Y*alfa/L) * ((1+g)^i)/(1+r)^i)
		' : Deaths (as in model or alternatively standardized - SH.STA.AIRP.P5)
		' : (Y*alfa/L) = W -> Average income per worker (wage rate)
		' : g = annual growth of income (2.5%)
		' : r = discount rate (4%)
		' : T = expected number of working years per individual in different age categories (T = s*LFPR) - s = survival rate (SP.DYN.TO65.MA.ZS) and LFPR is labor force participation)
			' 0.55*0.71 = s*LFPR = 39 years sum(i)^39 [(1.025/1.04)^(i)] = 29.56

	smpl @all
	'series {%cty}FINDEATH = {%cty}APDEATHS*(({%cty}NYWRTTOTLCN/{%cty}PANUSATLS)*29.56)
	'{%cty}.APPEND @IDENTITY {%cty}FINDEATH = {%cty}APDEATHS*(({%cty}NYWRTTOTLCN/{%cty}PANUSATLS)*29.56)

	series {%cty}FINDEATH = {%cty}APDEATHS*(({%cty}NYWRTTOTLCN/{%cty}PANUSATLS)*1)
	{%cty}.APPEND @IDENTITY {%cty}FINDEATH = {%cty}APDEATHS*(({%cty}NYWRTTOTLCN/{%cty}PANUSATLS)*1)

	smpl 2010 2018
	equation _{%cty}NYADJDPEMCD.LS @PC({%cty}NYADJDPEMCD) = @PC({%cty}FINDEATH)+C(1)*DUMH ' Mapping financial deaths to WDI data

' **********************************************
' ** Education Expenditures **

	smpl @all
' : Education expenditures (USD) NY.ADJ.AEDU.CD
	series {%cty}GGEXPEDUSCN_ = (({%cty}NYADJAEDUCD/1)*{%cty}PANUSATLS)/({%cty}GGEXPWAGECN+{%cty}GGEXPGNFSCN) ' Education expenditure as a share of current expenditures
	{%cty}.APPEND @IDENTITY {%cty}NYADJAEDUCD = ({%cty}GGEXPEDUSCN_*({%cty}GGEXPWAGECN+{%cty}GGEXPGNFSCN)/{%cty}PANUSATLS)*1

' **********************************************
' ** Natural Income and Savings **

' ANS = GNS - CFC + EDU - NRD - GHG - POL

	equation _{%cty}NYADJDKAPCD.LS @PC({%cty}NYADJDKAPCD) = @PC({%cty}DEPR*({%cty}NEGDIKSTKKN(-1)/{%cty}PANUSATLS))+C(1)*DUMH

	series {%cty}DNNSCD = {%cty}GNSCD -  ({%cty}NYADJDKAPCD - {%cty}NYADJAEDUCD + ({%cty}NYADJDNGYCD+{%cty}NYADJDMINCD+{%cty}NYADJDFORCD) + {%cty}NYADJDCO2CD + {%cty}NYADJDPEMCD)/1

	series {%cty}CCEMISTOTLKN =  {%cty}CCEMISGHGOKN+{%cty}CCEMISGHGFKN+{%cty}CCEMISGHGAKN ' Total GHG Emis = GHG (Fossils) + GHG (Land Use) + GHG (Agriculture)

	{%cty}.APPEND @IDENTITY {%cty}DNNSCD = {%cty}GNSCD -  ({%cty}NYADJDKAPCD - {%cty}NYADJAEDUCD + ({%cty}NYADJDNGYCD+{%cty}NYADJDMINCD+{%cty}NYADJDFORCD) + {%cty}NYADJDCO2CD + {%cty}NYADJDPEMCD)/1
	{%cty}.APPEND @IDENTITY {%cty}CCEMISTOTLKN =  {%cty}CCEMISGHGOKN+{%cty}CCEMISGHGFKN+{%cty}CCEMISGHGAKN ' Total GHG Emis = GHG (Fossils) + GHG (Land Use) + GHG (Agriculture)

	equation _{%cty}NECONOTHRXN.LS DLOG({%cty}NECONOTHRXN) = C(1) - 0.5 * (LOG({%cty}NECONOTHRXN(-1)) - 0.4* LOG({%cty}NYGDPFCSTXN(-1))-0.4*LOG({%cty}NVAGRTOTLXN(-1)) - (1-0.4-0.4) * LOG({%cty}NEIMPGNFSXN(-1)) - LOG((1+{%cty}GGREVGNFSER(-1)/100))) + 0.4 * DLOG({%cty}NYGDPFCSTXN) +0.4*DLOG({%cty}NVAGRTOTLXN)+ (1-0.4-0.4) * DLOG({%cty}NEIMPGNFSXN) + DLOG(1+{%cty}GGREVGNFSER/100)
