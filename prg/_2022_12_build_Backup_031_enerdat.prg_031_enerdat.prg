' ======================================
' READS IN EMISSIONS AND ENERGY DATA
	' [1] READ ENERGY DATA
	' [2] READ IO DATA
	' [3] MATCH [1] AND [2]
' ======================================
' Emissions data from several sources
	' OurWorldInData: https://ourworldindata.org/co2/country/south-africa (downloaded spreadsheet is for all countries)
	' By sector: https://ourworldindata.org/grapher/co-emissions-by-sector?country=~BGD
	' WB: https://data.worldbank.org/indicator/EN.ATM.CO2E.KT?locations=ZA
	' Transport emissions (% total fuel): https://data.worldbank.org/indicator/EN.CO2.TRAN.ZS
' Electricity data 
	' Production (twh): https://ourworldindata.org/grapher/electricity-production-by-source (1twh = (85984.5/1000)ktoe)
	' LCOE for renewables (USD/kwh): https://ourworldindata.org/grapher/levelized-cost-of-energy?country=~OWID_WRL
	' Average electricity price (USD cents/kwh): https://govdata360.worldbank.org/indicators/h6779690b?country=ZAF&indicator=42573&countries=BRA&viz=line_chart&years=2014,2019
' Production and consumption of energy by source (ktoe): IEA World Energy Statistics and Balances (OECD)
' Vehicle pump prices:
	' Diesel (USD/L): https://data.worldbank.org/indicator/EP.PMP.DESL.CD
	' Gasoline (USD/L): https://data.worldbank.org/indicator/EP.PMP.SGAS.CD
' Value added data (ZAF only)
	' Electricity+water [nominal] : (6635J) 
	' Electricity+water [real - 2010 price] : (6635K)
	' HH. consumption of electricity (6368J and 6368Y)
' Pollution data	
	' Mean exposure levels: https://data.worldbank.org/indicator/EN.ATM.PM25.MC.M3

' ===================================================
' CREATE IO SCALARS AND MAPPING

	importtbl(name=io) "C:\WBG\LocalITUtilities\BGD\Climate\build\data\SAM.xlsx" range=EviewsIO na="#N/A"

	'%cty = "BGD"
	%tempN = "AGR ENE IND SRV"
	%temp = "AGR ELE NELE IND SRV"
	%temp0 = "AGR IND SRV"
	%temp1 = "ELE NELE"
	%tempFD = "GC_C HH_C inv_C exp_C"
	%tempFD1 = "Taxes_R imp_R"


' Intermediate demand shares excluding energy (beta)
	scalar {%cty}intdNE_AGR = (@val(io(2,2))+@val(io(5,2))+@val(io(6,2)))/@val(io(7,2))
	'scalar {%cty}intdNE_ELE = (@val(io(2,3))+@val(io(5,3))+@val(io(6,3)))/@val(io(7,3))
	'scalar {%cty}intdNE_NELE = (@val(io(2,4))+@val(io(5,4))+@val(io(6,4)))/@val(io(7,4))
	scalar {%cty}intdNE_ENE = (@val(io(2,3))+@val(io(5,3))+@val(io(6,3))+@val(io(2,4))+@val(io(5,4))+@val(io(6,4)))/(@val(io(7,3))+@val(io(7,4)))
	scalar {%cty}intdNE_IND = (@val(io(2,5))+@val(io(5,5))+@val(io(6,5)))/@val(io(7,5))
	scalar {%cty}intdNE_SRV = (@val(io(2,6))+@val(io(5,6))+@val(io(6,6)))/@val(io(7,6))

' Intermediate demand shares energy (gamma)
	scalar {%cty}intdE_AGR = (@val(io(3,2))+@val(io(4,2)))/@val(io(7,2))
	'scalar {%cty}intdE_ELE = (@val(io(3,3))+@val(io(4,3)))/@val(io(7,3))
	'scalar {%cty}intdE_NELE = (@val(io(3,4))+@val(io(4,4)))/@val(io(7,4))
	scalar {%cty}intdE_ENE = (@val(io(3,3))+@val(io(4,3))+@val(io(3,4))+@val(io(4,4)))/(@val(io(7,3))+@val(io(7,4)))
	scalar {%cty}intdE_IND = (@val(io(3,5))+@val(io(4,5)))/@val(io(7,5))
	scalar {%cty}intdE_SRV = (@val(io(3,6))+@val(io(4,6)))/@val(io(7,6))

' Intermediate supply shares (zeta)
	scalar {%cty}ints_agr = (@val(io(2,2))+@val(io(2,3))+@val(io(2,4))+@val(io(2,5))+@val(io(2,6)))/(@val(io(2,7))+@val(io(2,8))+@val(io(2,9))+@val(io(2,10)))
	'scalar {%cty}ints_ele = (@val(io(3,2))+@val(io(3,3))+@val(io(3,4))+@val(io(3,5))+@val(io(3,6)))/(@val(io(3,7))+@val(io(3,8))+@val(io(3,9))+@val(io(3,10)))
	'scalar {%cty}ints_nele = (@val(io(4,2))+@val(io(4,3))+@val(io(4,4))+@val(io(4,5))+@val(io(4,6)))/(@val(io(4,7))+@val(io(4,8))+@val(io(4,9))+@val(io(4,10)))
	scalar {%cty}ints_ene = (@val(io(3,2))+@val(io(3,3))+@val(io(3,4))+@val(io(3,5))+@val(io(3,6))+@val(io(4,2))+@val(io(4,3))+@val(io(4,4))+@val(io(4,5))+@val(io(4,6)))/(@val(io(3,7))+@val(io(3,8))+@val(io(3,9))+@val(io(3,10))+@val(io(4,7))+@val(io(4,8))+@val(io(4,9))+@val(io(4,10)))
	scalar {%cty}ints_ind = (@val(io(5,2))+@val(io(5,3))+@val(io(5,4))+@val(io(5,5))+@val(io(5,6)))/(@val(io(5,7))+@val(io(5,8))+@val(io(5,9))+@val(io(5,10)))
	scalar {%cty}ints_srv = (@val(io(6,2))+@val(io(6,3))+@val(io(6,4))+@val(io(6,5))+@val(io(6,6)))/(@val(io(6,7))+@val(io(6,8))+@val(io(6,9))+@val(io(6,10)))


' Shares of sectors to final demand (alpha)
	!z = 0
	for %k {%tempFD}
		!z = !z+1
		scalar {%k}_sum = @val(io(2,!z+6))+@val(io(3,!z+6))+@val(io(4,!z+6))+@val(io(5,!z+6))+@val(io(6,!z+6))
	next

	!y = 0
	for %k {%tempFD1}
		!y = !y+1
		scalar {%k}_sum = @val(io(!y+9,2))+@val(io(!y+9,3))+@val(io(!y+9,4))+@val(io(!y+9,5))+@val(io(!y+9,6))
	next

	!z = 0
	for %k {%temp}
		!z = !z+1
		scalar {%cty}{%k}_alfaG = @val(io(!z+1,7))/GC_C_sum
		scalar {%cty}{%k}_alfaC = @val(io(!z+1,8))/HH_C_sum
		scalar {%cty}{%k}_alfaI = @val(io(!z+1,9))/inv_C_sum
		scalar {%cty}{%k}_alfaE = @val(io(!z+1,10))/exp_C_sum
	next

	!y = 0
	for %k {%temp}
		!y = !y+1
		scalar {%cty}{%k}_alfaT = @val(io(10,!y+1))/Taxes_R_sum
		scalar {%cty}{%k}_alfaM = @val(io(11,!y+1))/imp_R_sum
	next

	scalar {%cty}ENE_alfaG = {%cty}ELE_alfaG+{%cty}NELE_alfaG
	scalar {%cty}ENE_alfaC = {%cty}ELE_alfaC+{%cty}NELE_alfaC
	scalar {%cty}ENE_alfaI = {%cty}ELE_alfaI+{%cty}NELE_alfaI
	scalar {%cty}ENE_alfaE = {%cty}ELE_alfaE+{%cty}NELE_alfaE
	scalar {%cty}ENE_alfaT = {%cty}ELE_alfaT+{%cty}NELE_alfaT
	scalar {%cty}ENE_alfaM = {%cty}ELE_alfaM+{%cty}NELE_alfaM

' ===================================================
' READ ENERGY SECTOR DATA

	import %pathxlsdata range=fossil colhead=2 namepos=last na="#N/A" @freq A @id @date(series01) @destid @date @smpl @all

' ***  ***  ***  ***  ***  ***  ***  ***  ***  ***  ***  *** ***  ***  ***  ***  ***  ***
' [0] From Quantities to National Account Values
	' Start with quantities

	scalar EMISCOAL=3.960713 'CO2 emissions in tons for coal consumption in toe
	scalar EMISOIL=3.068924 'CO2 emissions in tons for oil consumption in toe
	scalar EMISGAS=2.348795 'CO2 emissions in tons for gas consumption in toe

	scalar CONVMTTOE=1.42857143 'Conversion mt to toe
	scalar CONVBBLTOE=7.4 'Conversion BBL to toe
	scalar CONVMMBTUTOE=39.6832072 'Conversion mmbtu to toe
	scalar CONVKWHTOE=11630 'Conversion kWh to toe
	scalar GASADJ = 1
	
	smpl @all

' Value added calculations
	series {%cty}NVCOLPRODCN2= {%cty}NVCOLPRODQN*((CONVMTTOE*1000)*WLDFCOAL_AUS*{%cty}PANUSATLS/1000000+{%cty}GGREVCO2CER*(EMISCOAL*1000)*({%cty}PANUSATLS/1000000)) 'Value of coal produced, in current LCU
	series {%cty}NVOILPRODCN2= {%cty}NVOILPRODQN*((CONVBBLTOE*1000)*WLDFCRUDE_PETRO*{%cty}PANUSATLS/1000000+{%cty}GGREVCO2OER*(EMISOIL*1000)*({%cty}PANUSATLS/1000000)) 'Value of oil produced, in current LCU
	series {%cty}NVGASPRODCN2= {%cty}NVGASPRODQN*((WLDFNGAS_EUR*1000)*CONVMMBTUTOE*GASADJ*{%cty}PANUSATLS/1000000+{%cty}GGREVCO2GER*(EMISGAS*1000)*({%cty}PANUSATLS/1000000)) 'Value of gas produced, in current LCU
	series {%cty}NVRENPRODCN2= {%cty}NVRENPRODQN*(WLDHYDROPOWER*1000)*CONVKWHTOE*{%cty}PANUSATLS/1000000 'Value of renewables produced, in current LCU


' Create total energy VA (electricity + other non electricity). If you have this in NIA then add it, otherwise continue here
	%temps = %cty+"NVENGTOTLCN"
	if @isobject(%temps) then 
		else
			series {%cty}NVENGTOTLCN = ({%cty}NVCOLPRODCN2+{%cty}NVOILPRODCN2+{%cty}NVGASPRODCN2+{%cty}NVRENPRODCN2)
	endif

	series {%cty}NVINDOTHRCN = {%cty}NVINDTOTLCN-{%cty}NVENGTOTLCN ' OTHER NON-ENERGY INDUSTRY

	' {{{Need to rescale both the CN and KN such that the sum of the energy components add up to ENERGY VALUE ADDED which is a national accounts variable}}}
	series SCALINGF={%cty}NVENGTOTLCN/({%cty}NVCOLPRODCN2+{%cty}NVOILPRODCN2+{%cty}NVGASPRODCN2+{%cty}NVRENPRODCN2) 'Scaling factor to match the value added from the fossil fuel sector (based on IO table data) to value of the individual energy sources sold (based on IEA data)

	series {%cty}NVCOLPRODCN=SCALINGF*{%cty}NVCOLPRODCN2  'Value of coal produced, in current LCU, adjusted by scaling factor
	series {%cty}NVOILPRODCN=SCALINGF*{%cty}NVOILPRODCN2 'Value of oil produced, in current LCU, adjusted by scaling factor
	series {%cty}NVGASPRODCN=SCALINGF*{%cty}NVGASPRODCN2 'Value of gas produced, in current LCU, adjusted by scaling factor
	series {%cty}NVRENPRODCN=SCALINGF*{%cty}NVRENPRODCN2 'Value of newables produced, in current LCU, adjusted by scaling factor

	series {%cty}NVCOLPRODXN=((WLDFCOAL_AUS*CONVMTTOE*{%cty}PANUSATLS)+{%cty}GGREVCO2CER*(EMISCOAL)*({%cty}PANUSATLS))/((@elem(WLDFCOAL_AUS,{%base_year})*CONVMTTOE*@elem({%cty}PANUSATLS,{%base_year}))+@elem({%cty}GGREVCO2CER,{%base_year})*(EMISCOAL)*(@elem({%cty}PANUSATLS,{%base_year}))) 'Gross price index for coal (price index and carbon taxes)
	series {%cty}NVOILPRODXN=((WLDFCRUDE_PETRO*CONVBBLTOE*{%cty}PANUSATLS)+{%cty}GGREVCO2OER*(EMISOIL)*({%cty}PANUSATLS))/((@elem(WLDFCRUDE_PETRO,{%base_year})*CONVBBLTOE*@elem({%cty}PANUSATLS,{%base_year}))+@elem({%cty}GGREVCO2OER,{%base_year})*(EMISOIL)*(@elem({%cty}PANUSATLS,{%base_year}))) 'Gross price index for oil (price index and carbon taxes)
	series {%cty}NVGASPRODXN=((WLDFNGAS_EUR*CONVMMBTUTOE*GASADJ*{%cty}PANUSATLS)+{%cty}GGREVCO2GER*(EMISGAS)*({%cty}PANUSATLS))/((@elem(WLDFNGAS_EUR,{%base_year})*CONVMMBTUTOE*GASADJ*@elem({%cty}PANUSATLS,{%base_year}))+@elem({%cty}GGREVCO2GER,{%base_year})*(EMISGAS)*(@elem({%cty}PANUSATLS,{%base_year}))) ' Gross price index for gas
	series {%cty}NVRENPRODXN=(WLDHYDROPOWER*{%cty}PANUSATLS)/(@elem(WLDHYDROPOWER,{%base_year})*@elem({%cty}PANUSATLS,{%base_year})) 'Price index for renewables

	series {%cty}NVCOLPRODKN2={%cty}NVCOLPRODCN2/{%cty}NVCOLPRODXN 'Value of coal produced, in constant LCU
	series {%cty}NVOILPRODKN2={%cty}NVOILPRODCN2/{%cty}NVOILPRODXN 'Value of oil produced, in constant LCU
	series {%cty}NVGASPRODKN2={%cty}NVGASPRODCN2/{%cty}NVGASPRODXN 'Value of gas produced, in constant LCU
	series {%cty}NVRENPRODKN2={%cty}NVRENPRODCN2/{%cty}NVRENPRODXN 'Value of gas produced, in constant LCU

' Create total energy VA (electricity + other non electricity). If you have this in NIA then add it, otherwise continue here
	%temps1 = %cty+"NVENGTOTLKN"
	if @isobject(%temps1) then
		else 
			series {%cty}NVENGTOTLKN = ({%cty}NVCOLPRODKN2+{%cty}NVOILPRODKN2+{%cty}NVGASPRODKN2+{%cty}NVRENPRODKN2)
	endif

	series {%cty}NVENGTOTLXN = {%cty}NVENGTOTLCN/{%cty}NVENGTOTLKN
	series {%cty}NVINDOTHRKN = {%cty}NVINDTOTLKN-{%cty}NVENGTOTLKN
	series {%cty}NVINDOTHRXN = {%cty}NVINDOTHRCN/{%cty}NVINDOTHRKN

	series SCALINGFR={%cty}NVENGTOTLKN/({%cty}NVCOLPRODKN2+{%cty}NVOILPRODKN2+{%cty}NVGASPRODKN2+{%cty}NVRENPRODKN2)

' Now scaling the KNs
	series {%cty}NVCOLPRODKN=SCALINGFR*{%cty}NVCOLPRODKN2  
	series {%cty}NVOILPRODKN=SCALINGFR*{%cty}NVOILPRODKN2 
	series {%cty}NVGASPRODKN=SCALINGFR*{%cty}NVGASPRODKN2 
	series {%cty}NVRENPRODKN=SCALINGFR*{%cty}NVRENPRODKN2 

' Now recalculating the XNs

	series {%cty}NVCOLPRODXN = @recode({%cty}NVCOLPRODCN=0,1,{%cty}NVCOLPRODCN/{%cty}NVCOLPRODKN)
	series {%cty}NVOILPRODXN = @recode({%cty}NVOILPRODCN=0,1,{%cty}NVOILPRODCN/{%cty}NVOILPRODKN)
	series {%cty}NVGASPRODXN = @recode({%cty}NVGASPRODCN=0,1,{%cty}NVGASPRODCN/{%cty}NVGASPRODKN)
	series {%cty}NVRENPRODXN = @recode({%cty}NVRENPRODCN=0,1,{%cty}NVRENPRODCN/{%cty}NVRENPRODKN)

	logmsg rescaling of KN and CN complete with XN recalcuated

' Now calculate the share of fossils in electricity while assuming that all of renewables go into electricity
	series {%cty}NVELCRNRTCN = {%cty}NVRENPRODCN/{%cty}NVINDELECCN ' Share of renewables in electricity value added (current prices)
	series {%cty}NVELCRNRTKN = {%cty}NVRENPRODKN/{%cty}NVINDELECKN ' Share of renewables in electricity value added (constant prices)

	series {%cty}NVELCFSRTCN = ({%cty}NVINDELECCN-{%cty}NVRENPRODCN)/({%cty}NVCOLPRODCN+{%cty}NVOILPRODCN+{%cty}NVGASPRODCN)' Share of fossil in electricity value added (current prices)
	series {%cty}NVELCFSRTKN = ({%cty}NVINDELECKN-{%cty}NVRENPRODKN)/({%cty}NVCOLPRODKN+{%cty}NVOILPRODKN+{%cty}NVGASPRODKN)' Share of fossil in electricity value added (constant prices)

	series {%cty}NVINDFSRTCN = 1-{%cty}NVELCFSRTCN' Share of fossil in manufacturing value added (current prices)
	series {%cty}NVINDFSRTKN = 1-{%cty}NVELCFSRTKN' Share of fossil in manufacturing value added (current prices)

	series {%cty}NVMNFFSRTCN = 1-{%cty}NVELCFSRTCN ' Share of fossil in manufacturing value added (current prices)
	series {%cty}NVMNFFSRTKN = 1-{%cty}NVELCFSRTKN ' Share of fossil in manufacturing value added (current prices)

	series {%cty}NVINDENGYSKN={%cty}NVMNFFSRTKN*({%cty}NVCOLPRODKN+{%cty}NVOILPRODKN+{%cty}NVGASPRODKN) ' MNF (FOSSIL) VA (CONSTANT PRICES)
	series {%cty}NVINDENGYSCN={%cty}NVMNFFSRTCN*({%cty}NVCOLPRODCN+{%cty}NVOILPRODCN+{%cty}NVGASPRODCN) ' MNF (FOSSIL) VA (CURRENT PRICES)

' GROSS PRICES
	series {%cty}NVCOLPRODGN=((WLDFCOAL_AUS*CONVMTTOE*{%cty}PANUSATLS)+{%cty}GGREVCO2CER*(EMISCOAL)*({%cty}PANUSATLS))/((@elem(WLDFCOAL_AUS,{%base_year})*CONVMTTOE*@elem({%cty}PANUSATLS,{%base_year}))+@elem({%cty}GGREVCO2CER,{%base_year})*(EMISCOAL)*(@elem({%cty}PANUSATLS,{%base_year}))) 'Gross price index for coal (price index and carbon taxes)
	series {%cty}NVOILPRODGN=((WLDFCRUDE_PETRO*CONVBBLTOE*{%cty}PANUSATLS)+{%cty}GGREVCO2OER*(EMISOIL)*({%cty}PANUSATLS))/((@elem(WLDFCRUDE_PETRO,{%base_year})*CONVBBLTOE*@elem({%cty}PANUSATLS,{%base_year}))+@elem({%cty}GGREVCO2OER,{%base_year})*(EMISOIL)*(@elem({%cty}PANUSATLS,{%base_year}))) 'Gross price index for coal (price index and carbon taxes)
	series {%cty}NVGASPRODGN=((WLDFNGAS_EUR*CONVMMBTUTOE*GASADJ*{%cty}PANUSATLS)+{%cty}GGREVCO2GER*(EMISGAS)*({%cty}PANUSATLS))/((@elem(WLDFNGAS_EUR,{%base_year})*CONVMMBTUTOE*GASADJ*@elem({%cty}PANUSATLS,{%base_year}))+@elem({%cty}GGREVCO2GER,{%base_year})*(EMISGAS)*(@elem({%cty}PANUSATLS,{%base_year}))) 'Gross price index for coal (price index and carbon taxes)

' IMPORTS
	series {%cty}NVCOLNIMPCN={%cty}NVCOLNIMPQN*((WLDFCOAL_AUS*1000)*CONVMTTOE*{%cty}PANUSATLS/1000000+{%cty}GGREVCO2CER*(EMISCOAL*1000)*({%cty}PANUSATLS/1000000)) 'Value of coal imported, in current LCU
	series {%cty}NVOILNIMPCN={%cty}NVOILNIMPQN*((WLDFCRUDE_PETRO*1000)*CONVBBLTOE*{%cty}PANUSATLS/1000000+{%cty}GGREVCO2OER*(EMISOIL*1000)*({%cty}PANUSATLS/1000000)) 'Value of oil imported, in current LCU
	series {%cty}NVGASNIMPCN={%cty}NVGASNIMPQN*((WLDFNGAS_EUR*1000)*CONVMMBTUTOE*{%cty}PANUSATLS/1000000+{%cty}GGREVCO2GER*(EMISGAS*1000)*({%cty}PANUSATLS/1000000)) 'Value of gas imported, in current LCU
	series {%cty}NVRENNIMPCN={%cty}NVRENNIMPQN*(WLDHYDROPOWER*1000)*CONVKWHTOE*{%cty}PANUSATLS/1000000 'Value of renewables imported, in current LCU
	series {%cty}NVENGNIMPCN = {%cty}NVCOLNIMPCN+{%cty}NVOILNIMPCN+{%cty}NVGASNIMPCN+{%cty}NVRENNIMPCN ' Energy imports

	series {%cty}NVCOLNIMPKN={%cty}NVCOLNIMPCN/{%cty}NVCOLPRODXN 'Value of coal imported, in constant LCU
	series {%cty}NVOILNIMPKN={%cty}NVOILNIMPCN/{%cty}NVOILPRODXN 'Value of oil imported, in constant LCU
	series {%cty}NVGASNIMPKN={%cty}NVGASNIMPCN/{%cty}NVGASPRODXN 'Value of gas imported, in constant LCU
	series {%cty}NVRENNIMPKN={%cty}NVRENNIMPCN/{%cty}NVRENPRODXN 'Value of renewables imported, in constant LCU
	series {%cty}NVENGNIMPKN = {%cty}NVCOLNIMPKN+{%cty}NVOILNIMPKN+{%cty}NVGASNIMPKN+{%cty}NVRENNIMPKN ' Energy imports

	series {%cty}NVENGNIMPXN = {%cty}NVENGNIMPCN/{%cty}NVENGNIMPKN ' Energy import deflator

	series {%cty}NEIMPGSNECN={%cty}NEIMPGNFSCN-{%cty}NVCOLNIMPCN-{%cty}NVOILNIMPCN-{%cty}NVGASNIMPCN-{%cty}NVRENNIMPCN 'Non-energy imports, in current LCU
	series {%cty}NEIMPGSNEKN={%cty}NEIMPGNFSKN-{%cty}NVCOLNIMPKN-{%cty}NVOILNIMPKN-{%cty}NVGASNIMPKN-{%cty}NVRENNIMPKN 'Non-energy imports, in constant LCU
	series {%cty}NEIMPGSNEXN={%cty}NEIMPGSNECN/{%cty}NEIMPGSNEKN 'Non-energy imports, price index

' ***  ***  ***  ***  ***  ***  ***  ***  ***  ***  ***  *** ***  ***  ***  ***  ***  ***
' [1] Re-write VA mapping and split IND into ENE (ELEC and NON-ELEC) and NON- ENE

	smpl @all

	series {%cty}NVAGRSMKN=(({%cty}AGR_alfaC*{%cty}NECONPRVTKN+{%cty}AGR_alfaG*{%cty}NECONGOVTKN+{%cty}AGR_alfaI*({%cty}NEGDIFTOTKN)+{%cty}AGR_alfaE*{%cty}NEEXPGNFSKN)*(1+{%cty}ints_agr)-{%cty}AGR_alfaM*{%cty}NEIMPGNFSKN-{%cty}AGR_alfaT*{%cty}NYTAXNINDKN)/(1+{%cty}intdNE_AGR+{%cty}intdE_AGR)+{%cty}NVAGRTOTLKN(-1)/ {%cty}NYGDPFCSTKN(-1) * ({%cty}NYGDPDISCKN+{%cty}NEGDISTKBKN)

	series {%cty}NVINDSMKN=(({%cty}IND_alfaC*{%cty}NECONPRVTKN+{%cty}IND_alfaG*{%cty}NECONGOVTKN+{%cty}IND_alfaI*({%cty}NEGDIFTOTKN)+{%cty}IND_alfaE*{%cty}NEEXPGNFSKN)*(1+{%cty}ints_IND)-{%cty}IND_alfaM*{%cty}NEIMPGNFSKN-{%cty}IND_alfaT*{%cty}NYTAXNINDKN)/(1+{%cty}intdNE_IND+{%cty}intdE_IND)+{%cty}NVINDTOTLKN(-1)/ {%cty}NYGDPFCSTKN(-1) * ({%cty}NYGDPDISCKN+{%cty}NEGDISTKBKN)

	series {%cty}NVENESMKN=(({%cty}ENE_alfaC*{%cty}NECONPRVTKN+{%cty}ENE_alfaG*{%cty}NECONGOVTKN+{%cty}ENE_alfaI*({%cty}NEGDIFTOTKN)+{%cty}ENE_alfaE*{%cty}NEEXPGNFSKN)*(1+{%cty}ints_ENE)-{%cty}ENE_alfaM*{%cty}NEIMPGNFSKN-{%cty}ENE_alfaT*{%cty}NYTAXNINDKN)/(1+{%cty}intdNE_ENE+{%cty}intdE_AGR)+{%cty}NVENGTOTLKN(-1)/ {%cty}NYGDPFCSTKN(-1) * ({%cty}NYGDPDISCKN+{%cty}NEGDISTKBKN)

	series {%cty}NVSRVSMKN=(({%cty}SRV_alfaC*{%cty}NECONPRVTKN+{%cty}SRV_alfaG*{%cty}NECONGOVTKN+{%cty}SRV_alfaI*({%cty}NEGDIFTOTKN)+{%cty}SRV_alfaE*{%cty}NEEXPGNFSKN)*(1+{%cty}ints_SRV)-{%cty}SRV_alfaM*{%cty}NEIMPGNFSKN-{%cty}SRV_alfaT*{%cty}NYTAXNINDKN)/(1+{%cty}intdNE_SRV+{%cty}intdE_SRV)+{%cty}NVSRVTOTLKN(-1)/ {%cty}NYGDPFCSTKN(-1) * ({%cty}NYGDPDISCKN+{%cty}NEGDISTKBKN)

' Insert simulated sectors into model object

	{%cty}.APPEND @IDENTITY {%cty}NVAGRSMKN=(({%cty}AGR_alfaC*{%cty}NECONPRVTKN+{%cty}AGR_alfaG*{%cty}NECONGOVTKN+{%cty}AGR_alfaI*({%cty}NEGDIFTOTKN)+{%cty}AGR_alfaE*{%cty}NEEXPGNFSKN)*(1+{%cty}ints_agr)-{%cty}AGR_alfaM*{%cty}NEIMPGNFSKN-{%cty}AGR_alfaT*{%cty}NYTAXNINDKN)/(1+{%cty}intdNE_AGR+{%cty}intdE_AGR)+{%cty}NVAGRTOTLKN(-1)/ {%cty}NYGDPFCSTKN(-1) * ({%cty}NYGDPDISCKN+{%cty}NEGDISTKBKN)

	{%cty}.APPEND @IDENTITY {%cty}NVINDSMKN=(({%cty}IND_alfaC*{%cty}NECONPRVTKN+{%cty}IND_alfaG*{%cty}NECONGOVTKN+{%cty}IND_alfaI*({%cty}NEGDIFTOTKN)+{%cty}IND_alfaE*{%cty}NEEXPGNFSKN)*(1+{%cty}ints_IND)-{%cty}IND_alfaM*{%cty}NEIMPGNFSKN-{%cty}IND_alfaT*{%cty}NYTAXNINDKN)/(1+{%cty}intdNE_IND+{%cty}intdE_IND)+{%cty}NVINDTOTLKN(-1)/ {%cty}NYGDPFCSTKN(-1) * ({%cty}NYGDPDISCKN+{%cty}NEGDISTKBKN)

	{%cty}.APPEND @IDENTITY {%cty}NVENESMKN=(({%cty}ENE_alfaC*{%cty}NECONPRVTKN+{%cty}ENE_alfaG*{%cty}NECONGOVTKN+{%cty}ENE_alfaI*({%cty}NEGDIFTOTKN)+{%cty}ENE_alfaE*{%cty}NEEXPGNFSKN)*(1+{%cty}ints_ENE)-{%cty}ENE_alfaM*{%cty}NEIMPGNFSKN-{%cty}ENE_alfaT*{%cty}NYTAXNINDKN)/(1+{%cty}intdNE_ENE+{%cty}intdE_AGR)+{%cty}NVENGTOTLKN(-1)/ {%cty}NYGDPFCSTKN(-1) * ({%cty}NYGDPDISCKN+{%cty}NEGDISTKBKN)

	{%cty}.APPEND @IDENTITY {%cty}NVSRVSMKN=(({%cty}SRV_alfaC*{%cty}NECONPRVTKN+{%cty}SRV_alfaG*{%cty}NECONGOVTKN+{%cty}SRV_alfaI*({%cty}NEGDIFTOTKN)+{%cty}SRV_alfaE*{%cty}NEEXPGNFSKN)*(1+{%cty}ints_SRV)-{%cty}SRV_alfaM*{%cty}NEIMPGNFSKN-{%cty}SRV_alfaT*{%cty}NYTAXNINDKN)/(1+{%cty}intdNE_SRV+{%cty}intdE_SRV)+{%cty}NVSRVTOTLKN(-1)/ {%cty}NYGDPFCSTKN(-1) * ({%cty}NYGDPDISCKN+{%cty}NEGDISTKBKN)

' ***  ***  ***  ***  ***  ***  ***  ***  ***  ***  ***  *** ***  ***  ***  ***  ***  ***
' [1.1] Cost shares - note that income (or demand) is derived in [1]
	' Calculate cost share - see system.prg

	series {%cty}nvagrtot = ({%cty}NVAGRTOTLKN/{%cty}NYGDPFCSTKN)
	series {%cty}nvenetot = ({%cty}NVENGTOTLKN/{%cty}NYGDPFCSTKN)
	series {%cty}NVOTHRETOT = ({%cty}NVINDOTHRKN/{%cty}NYGDPFCSTKN)
	series {%cty}nvsrvtot = ({%cty}NVSRVTOTLKN/{%cty}NYGDPFCSTKN)

	smpl 1990 %end_estimate
	'equation _{%cty}NVAGRTOT.ls {%cty}NVAGRTOT =C(1)+C(2)*LOG({%cty}NVAGRTOTLXN/{%cty}NVSRVTOTLXN)+C(3)*LOG({%cty}NVINDOTHRXN/{%cty}NVSRVTOTLXN)+C(4)*LOG({%cty}NVENGTOTLXN/{%cty}NVSRVTOTLXN)+C(5)*LOG({%cty}NVAGRSMKN)
	equation _{%cty}NVAGRTOT.ls BGDNVAGRTOT =C(1)+C(2)*LOG(BGDNVAGRTOTLXN/BGDNVSRVTOTLXN)+C(3)*LOG(BGDNVINDOTHRXN/BGDNVSRVTOTLXN)+C(4)*LOG(BGDNVENGTOTLXN/BGDNVSRVTOTLXN)+C(5)*LOG(BGDNVAGRSMKN/BGDNYGDPFCSTXN)+C(10)*T_LR*@DURING("1995 2000")+C(11)*T_LR*@DURING("2001 2009")

	'equation _{%cty}NVAGRTOT.ls {%cty}NVAGRTOT =C(1)

	if !SR1 = 1 then
		smpl 1990 %end_estimate
		equation _{%cty}NVENGTOTLKN.ls DLOG({%cty}NVENGTOTLKN)=C(1)-0.3*(LOG({%cty}NVENGTOTLKN(-1))-LOG({%cty}NVENESMKN(-1))+0.3*LOG({%cty}NVENGTOTLXN(-1)/{%cty}NYGDPFCSTXN(-1)))+C(3)*LOG({%cty}NVENGTOTLXN/{%cty}NYGDPFCSTXN)+1*DLOG({%cty}NVENESMKN)+C(10)*@DURING("2006")+C(11)*@DURING("2008")+C(12)*@DURING("2015")
	else
		smpl 1990 %end_estimate
		equation _{%cty}NVENETOT.ls {%cty}NVENETOT=C(1)+C(2)*LOG({%cty}NVAGRTOTLXN/{%cty}NVSRVTOTLXN)+C(3)*LOG({%cty}NVINDOTHRXN/{%cty}NVSRVTOTLXN)+C(4)*LOG({%cty}NVENGTOTLXN/{%cty}NVSRVTOTLXN)+C(5)*LOG({%cty}NVENESMKN)+C(10)*@DURING("2009")+C(11)*@DURING("2011")+C(12)*@DURING("2016")
		'equation _{%cty}NVENETOT.ls {%cty}NVENETOT=C(1)
	endif

	smpl 1990 %end_estimate
	'equation _{%cty}NVOTHRETOT.ls {%cty}NVOTHRETOT=C(1)+C(2)*LOG({%cty}NVAGRTOTLXN/{%cty}NVSRVTOTLXN)+C(3)*LOG({%cty}NVINDOTHRXN/{%cty}NVSRVTOTLXN)+C(4)*LOG({%cty}NVENGTOTLXN/{%cty}NVSRVTOTLXN)+C(5)*LOG({%cty}NVINDSMKN)
	
	equation _{%cty}NVOTHRETOT.ls BGDNVOTHRETOT=0.14+C(2)*LOG(BGDNVAGRTOTLXN/BGDNVSRVTOTLXN)+C(3)*LOG(BGDNVINDOTHRXN/BGDNVSRVTOTLXN)+C(4)*LOG(BGDNVENGTOTLXN/BGDNVSRVTOTLXN)+C(5)*LOG(BGDNVINDSMKN/BGDNYGDPFCSTXN)+C(10)*@DURING("1996 2004")+C(11)*@DURING("2018")+C(12)*@DURING("2010 2011")
	'equation _{%cty}NVOTHRETOT.ls {%cty}NVOTHRETOT=C(1)

	{%cty}.APPEND @IDENTITY {%cty}nvsrvtot = (1-{%cty}nvagrtot-{%cty}nvenetot-{%cty}NVOTHRETOT) ' SERVICES SHARE

' Add identities to the model
	'delete _{%cty}nvagrtotlkn _{%cty}nvindtotlkn _{%cty}NVINDTOTLXN

	{%cty}.APPEND @IDENTITY {%cty}nvagrtotlkn = {%cty}nvagrtot*{%cty}nygdpfcstkn ' AGR output
	if !SR1 = 1 then
		{%cty}.APPEND @IDENTITY {%cty}nvenetot = {%cty}NVENGTOTLKN/{%cty}nygdpfcstkn ' ENE output
	else
		{%cty}.APPEND @IDENTITY {%cty}NVENGTOTLKN = {%cty}nvenetot*{%cty}nygdpfcstkn ' ENE output
	endif
	{%cty}.APPEND @IDENTITY {%cty}NVINDOTHRKN = {%cty}NVOTHRETOT*{%cty}nygdpfcstkn ' OTH Industry output
	{%cty}.APPEND @IDENTITY {%cty}nvindtotlkn = {%cty}NVINDOTHRKN+{%cty}NVENGTOTLKN ' IND TOTAL output
	{%cty}.APPEND @IDENTITY {%cty}nvsrvtotlkn = {%cty}nvsrvtot*{%cty}nygdpfcstkn ' SRV output

' ***  ***  ***  ***  ***  ***  ***  ***  ***  ***  ***  *** ***  ***  ***  ***  ***  ***
' [2] Calculate CES outputs and aggregates

'	Elasticities of substition for energy E(coal, oil, gas, renewables) 
	scalar {%cty}CESENGYPROD = 5 ' 0.1, 2PRODUCTION 
	scalar {%cty}CESENGYIMP = 2 ' IMPORTS  (BETWEEN DIFFERENT ENERGY TYPES)
	scalar {%cty}CESENGYCON = 2 ' 2CONSUMPTION (BETWEEN ENERGY AND OTHER)
	scalar {%cty}CESECOMYCON =2 ' 2 'Consumption between eergy commodities
	scalar {%cty}CESENGYIMPT = 1.05 ' IMPORTS (BETWEEN ENERGY AND OTHER)

	string fuelsprod = "COL OIL GAS REN"

	for %ab {fuelsprod}
		series {%cty}NV{%ab}PRODSH =  ((({%cty}NV{%ab}PRODKN+0.000)/(({%cty}NVENGTOTLKN+0.000)*({%cty}NVENGTOTLXN/{%cty}NV{%ab}PRODXN)^({%cty}CESENGYPROD))))^(1/{%cty}CESENGYPROD)   ' Production weights

		if @isobject(%cty+"NV"+%ab+"NIMPKN") then
			series {%cty}NV{%ab}NIMPSH =  ((({%cty}NV{%ab}NIMPKN+0.000)/(({%cty}NVENGNIMPKN+0.000)*({%cty}NVENGNIMPXN/{%cty}NV{%ab}PRODXN)^({%cty}CESENGYIMP))))^(1/{%cty}CESENGYIMP) ' Import weights
		else
			series {%cty}NV{%ab}NIMPSH = 0
		endif
	next

	'show {%cty}NVENGTOTLXN (({%cty}NVCOLPRODSH^{%cty}CESENGYPROD)*{%cty}NVCOLPRODXN^(1-{%cty}CESENGYPROD)+({%cty}NVOILPRODSH^{%cty}CESENGYPROD)*{%cty}NVOILPRODXN^(1-{%cty}CESENGYPROD)+({%cty}NVGASPRODSH^{%cty}CESENGYPROD)*{%cty}NVGASPRODXN^(1-{%cty}CESENGYPROD)+({%cty}NVRENPRODSH^{%cty}CESENGYPROD)*{%cty}NVRENPRODXN^(1-{%cty}CESENGYPROD))^(1/(1-{%cty}CESENGYPROD))

	'show {%cty}NVENGNIMPXN (({%cty}NVCOLNIMPSH^{%cty}CESENGYPROD)*{%cty}NVCOLPRODXN^(1-{%cty}CESENGYPROD)+({%cty}NVOILNIMPSH^{%cty}CESENGYPROD)*{%cty}NVOILPRODXN^(1-{%cty}CESENGYPROD)+({%cty}NVGASNIMPSH^{%cty}CESENGYPROD)*{%cty}NVGASPRODXN^(1-{%cty}CESENGYPROD)+({%cty}NVRENNIMPSH^{%cty}CESENGYPROD)*{%cty}NVRENPRODXN^(1-{%cty}CESENGYPROD))^(1/(1-{%cty}CESENGYPROD))

'CALCULATE WEIGHTS BETWEEN ENERGY AND NON-ENERGY IMPORTS
	series {%cty}NEIMPENGYSH =  (({%cty}NVENGNIMPKN/({%cty}NEIMPGNFSKN*({%cty}NEIMPGNFSXN/{%cty}NVENGNIMPXN)^({%cty}CESENGYIMPT))))^(1/{%cty}CESENGYIMPT)   ' Import weights (energy)
	series {%cty}NEIMPOTHRSH =  (({%cty}NEIMPGSNEKN/({%cty}NEIMPGNFSKN*({%cty}NEIMPGNFSXN/{%cty}NEIMPGSNEXN)^({%cty}CESENGYIMPT))))^(1/{%cty}CESENGYIMPT)    ' Import weights (other)


' CALCULATE OTHER CONSUMPTION (VA+M+TAX=ENERGY CONS - where we assume that no energy gets exported)
	series {%cty}NECONENGYKN = {%cty}NVENGTOTLKN+{%cty}NVENGNIMPKN ' +(-0.51*{%cty}NYTAXNINDKN) ' +(-0.51*{%cty}NYTAXNINDKN) = the weight of tax on energy vs other sectors - check with Gregor that this amount scales with the effective rate he calculatured
	series {%cty}NECONENGYCN = {%cty}NVENGTOTLCN+{%cty}NVENGNIMPCN ' +(-0.51*{%cty}NYTAXNINDCN)
	series {%cty}NECONENGYXN = {%cty}NECONENGYCN/{%cty}NECONENGYKN ' Consumption energy price index

	series {%cty}NECONOTHRKN = {%cty}NECONPRVTKN-{%cty}NECONENGYKN ' Other consumption (constant prices)
	series {%cty}NECONOTHRCN = {%cty}NECONPRVTCN-{%cty}NECONENGYCN ' Other consumption (current prices)
	series {%cty}NECONOTHRXN = {%cty}NECONOTHRCN/{%cty}NECONOTHRKN ' Other consumption (deflator = 1 in 2011)

	series {%cty}NECONENGYSH =  (({%cty}NECONENGYKN/({%cty}NECONPRVTKN*({%cty}NECONPRVTXN/{%cty}NECONENGYXN)^({%cty}CESENGYCON))))^(1/{%cty}CESENGYCON)   ' Consumption  weights (energy)
	series {%cty}NECONOTHRSH =  (({%cty}NECONOTHRKN/({%cty}NECONPRVTKN*({%cty}NECONPRVTXN/{%cty}NECONOTHRXN)^({%cty}CESENGYCON))))^(1/{%cty}CESENGYCON)   ' Consumption  weights (other)


	smpl 2001 @last ' Only because the code barfs due to NA's in history
	series {%cty}NECONENGYGN = ({%cty}NVCOLPRODSH^({%cty}CESENGYPROD)*({%cty}NVCOLPRODGN)^(1-{%cty}CESENGYPROD)+{%cty}NVGASPRODSH^({%cty}CESENGYPROD)*({%cty}NVGASPRODGN)^(1-{%cty}CESENGYPROD)+{%cty}NVOILPRODSH^({%cty}CESENGYPROD)*({%cty}NVOILPRODGN)^(1-{%cty}CESENGYPROD)+{%cty}NVRENPRODSH^({%cty}CESENGYPROD)*({%cty}NVRENPRODXN)^(1-{%cty}CESENGYPROD))^(1/(1-{%cty}CESENGYPROD)) ' Gross Price for consumers

' SPLIT OUT THE REMAINING CONSUMPTION BY FUEL TYPE - IT IS THE DIFFERENC THE SUM OF PRODUCTION AND IMPORTS

' Electricity - consumption commodities 
	series {%cty}NECOLCONELCN = SCALINGF*{%cty}NVCOLELEQN*((WLDFCOAL_AUS*1000)*CONVMTTOE*{%cty}PANUSATLS/1000000+{%cty}GGREVCO2CER*(EMISCOAL*1000)*({%cty}PANUSATLS/1000000)) ' Electricity consumption of commodity k (nominal)
	series {%cty}NEOILCONELCN = SCALINGF*{%cty}NVOILELEQN*((WLDFCRUDE_PETRO*1000)*CONVBBLTOE*{%cty}PANUSATLS/1000000+{%cty}GGREVCO2OER*(EMISOIL*1000)*({%cty}PANUSATLS/1000000)) ' Electricity consumption of commodity k (nominal)
	series {%cty}NEGASCONELCN = SCALINGF*{%cty}NVGASELEQN*((WLDFNGAS_EUR*1000)*CONVMMBTUTOE*1*{%cty}PANUSATLS/1000000+{%cty}GGREVCO2GER*(EMISGAS*1000)*({%cty}PANUSATLS/1000000)) ' Electricity consumption of commodity k (nominal) 
	series {%cty}NERENCONELCN = SCALINGF*{%cty}NVRENELEQN*(WLDHYDROPOWER*1000)*CONVKWHTOE*{%cty}PANUSATLS/1000000 ' Electricity consumption of commodity k (nominal)

	series {%cty}NECOLCONELKN = {%cty}NECOLCONELCN/{%cty}NVCOLPRODXN ' Electricity consumption of commodity k (real)
	series {%cty}NEOILCONELKN = {%cty}NEOILCONELCN/{%cty}NVOILPRODXN ' Electricity consumption of commodity k (real)
	series {%cty}NEGASCONELKN = {%cty}NEGASCONELCN/{%cty}NVGASPRODXN ' Electricity consumption of commodity k (real)
	series {%cty}NERENCONELKN = {%cty}NERENCONELCN/{%cty}NVRENPRODXN ' Electricity consumption of commodity k (real)


	string fuelsprod = "COL OIL GAS REN"
	smpl @all
	for %ah {fuelsprod} ' C(k) = Y(k)+M(k) - T(k)
		series {%cty}NE{%ah}CONKN =  ({%cty}NV{%ah}PRODKN+{%cty}NV{%ah}NIMPKN) ' -({%cty}NV{%ah}PRODKN+{%cty}NV{%ah}NIMPKN)/({%cty}NVENGNIMPKN+{%cty}NVENGTOTLKN)*0.51*{%cty}NYTAXNINDKN ' real consumption of commodity k
		series {%cty}NE{%ah}CONCN =  ({%cty}NV{%ah}PRODCN+{%cty}NV{%ah}NIMPCN) ' -({%cty}NV{%ah}PRODCN+{%cty}NV{%ah}NIMPCN)/({%cty}NVENGNIMPCN+{%cty}NVENGTOTLCN)*0.51*{%cty}NYTAXNINDCN ' nominal consumption of commodity k
		series {%cty}NE{%ah}CONXN = {%cty}NE{%ah}CONCN/{%cty}NE{%ah}CONKN  ' Deflator for consumption of commodity k

		series {%cty}NE{%ah}CONELXN = {%cty}NE{%ah}CONELCN/{%cty}NE{%ah}CONELKN ' Consumption deflator for electricty by type k 

			' Non electricity: C^NE(k) = C(k) - C^E(k)
		series {%cty}NE{%ah}CONNECN = {%cty}NE{%ah}CONCN - {%cty}NE{%ah}CONELCN ' Non-Electricity consumption of commodity k (nominal)
		series {%cty}NE{%ah}CONNEKN = {%cty}NE{%ah}CONNECN/{%cty}NV{%ah}PRODXN ' Non-Electricity consumption of commodity k (real)
		series {%cty}NE{%ah}CONNEXN = {%cty}NE{%ah}CONNECN/{%cty}NE{%ah}CONNEKN  ' Non-Electricity consumption of commodity k (real)

		'series {%cty}NE{%ah}CONSH =  (({%cty}NE{%ah}CONKN/({%cty}NECONENGYKN*({%cty}NECONENGYXN/{%cty}NE{%ah}CONXN)^({%cty}CESENGYIMP))))^(1/{%cty}CESENGYIMP) ' consumption weights
	next

	smpl @all

	series {%cty}NECONELECN =  {%cty}NECOLCONELCN+{%cty}NEOILCONELCN+{%cty}NEGASCONELCN+{%cty}NERENCONELCN'+({%cty}GGREVELECER*{%cty}PANUSATLS/1000)  ' Electricity consumption (nominal) - pre-electricity subsidy
	series {%cty}NECONELEKN =  {%cty}NECOLCONELKN+{%cty}NEOILCONELKN+{%cty}NEGASCONELKN+{%cty}NERENCONELKN'+@elem(({%cty}GGREVELECER*{%cty}PANUSATLS/1000),"2011")  ' Electricity consumption (real) - pre-electricity subsidy
	series {%cty}NECONELEXN = {%cty}NECONELECN/{%cty}NECONELEKN ' Electricity consumption deflator - pre-electricity subsidy

	series {%cty}GGREVELECER_ =  0 ' E
	smpl 2001 @last
	{%cty}GGREVELECER_ = 100*({%cty}GGREVELECER*{%cty}PANUSATLS/1000)/{%cty}NECONELECN ' Electricity tax/subsidy

	smpl @all

	series {%cty}NECONNELCN =  {%cty}NECOLCONNECN+{%cty}NEOILCONNECN+{%cty}NEGASCONNECN+{%cty}NERENCONNECN ' Non-Electricity consumption (nominal)
	series {%cty}NECONNELKN =  {%cty}NECOLCONNEKN+{%cty}NEOILCONNEKN+{%cty}NEGASCONNEKN+{%cty}NERENCONNEKN ' Non-Electricity consumption (real)
	series {%cty}NECONNELXN = {%cty}NECONNELCN/{%cty}NECONNELKN ' Non-Electricity consumption deflator

 ' CES FOR ENERGY
	series {%cty}NECONELESH =  (({%cty}NECONELEKN/({%cty}NECONENGYKN*({%cty}NECONENGYXN/({%cty}NECONELEXN))^({%cty}CESENGYCON))))^(1/{%cty}CESENGYCON) ' electricity weight
	series {%cty}NECONNELSH =  (({%cty}NECONNELKN/({%cty}NECONENGYKN*({%cty}NECONENGYXN/{%cty}NECONNELXN)^({%cty}CESENGYCON))))^(1/{%cty}CESENGYCON) ' non-electricity weight

	for %ah {fuelsprod}
		series {%cty}NE{%ah}CONELSH = (({%cty}NE{%ah}CONELKN/({%cty}NECONELEKN*({%cty}NECONELEXN/{%cty}NE{%ah}CONELXN)^({%cty}CESECOMYCON))))^(1/{%cty}CESECOMYCON) ' electricity weight of comdty (k)
		series {%cty}NE{%ah}CONNESH = (({%cty}NE{%ah}CONNEKN/({%cty}NECONNELKN*({%cty}NECONNELXN/{%cty}NE{%ah}CONNEXN)^({%cty}CESECOMYCON))))^(1/{%cty}CESECOMYCON) ' electricity weight of comdty (k)
	next

	' Check that these identities absolutely hold and that the shares are in the assumptions.prg and held fixed
	'show {%cty}NECONELEXN (({%cty}NECOLCONELSH^{%cty}CESENGYCON)*{%cty}NECOLCONELXN^(1-{%cty}CESENGYCON)+({%cty}NEOILCONELSH^{%cty}CESENGYCON)*{%cty}NEOILCONELXN^(1-{%cty}CESENGYCON)+({%cty}NEGASCONELSH^{%cty}CESENGYCON)*{%cty}NEGASCONELXN^(1-{%cty}CESENGYCON)+({%cty}NERENCONELSH^{%cty}CESENGYCON)*{%cty}NERENCONELXN^(1-{%cty}CESENGYCON))^(1/(1-{%cty}CESENGYCON))  ' test Electricity CES (k)
	'show {%cty}NECONNELXN (({%cty}NECOLCONNESH^{%cty}CESENGYCON)*{%cty}NECOLCONNEXN^(1-{%cty}CESENGYCON)+({%cty}NEOILCONNESH^{%cty}CESENGYCON)*{%cty}NEOILCONNEXN^(1-{%cty}CESENGYCON)+({%cty}NEGASCONNESH^{%cty}CESENGYCON)*{%cty}NEGASCONNEXN^(1-{%cty}CESENGYCON)+({%cty}NERENCONNESH^{%cty}CESENGYCON)*{%cty}NERENCONNEXN^(1-{%cty}CESENGYCON))^(1/(1-{%cty}CESENGYCON))  ' test Non-Electricity CES (k)
	'show {%cty}NECONENGYXN (({%cty}NECONELESH^{%cty}CESENGYCON)*(1+{%cty}GGREVELECER_/100)*{%cty}NECONELEXN^(1-{%cty}CESENGYCON)+({%cty}NECONNELSH^{%cty}CESENGYCON)*{%cty}NECONNELXN^(1-{%cty}CESENGYCON))^(1/(1-{%cty}CESENGYCON)) ' test Energy CES (Electricity ; Non-electricity)
	'show {%cty}NECONPRVTXN (({%cty}NECONENGYSH^{%cty}CESENGYCON)*{%cty}NECONENGYXN^(1-{%cty}CESENGYCON)+({%cty}NECONOTHRSH^{%cty}CESENGYCON)*{%cty}NECONOTHRXN^(1-{%cty}CESENGYCON))^(1/(1-{%cty}CESENGYCON)) ' test total Cons CES (Energy; Other)


' ADD EMISSIONS
	series {%cty}CCEMISCO2CKN = (1000*EMISCOAL)*({%cty}NVCOLPRODQN+{%cty}NVCOLNIMPQN) ' Coal emissions
	series {%cty}CCEMISCO2OKN = (1000*EMISOIL)*({%cty}NVOILPRODQN+{%cty}NVOILNIMPQN) ' Oil emissions
	series {%cty}CCEMISCO2GKN = (1000*EMISGAS)*({%cty}NVGASPRODQN+{%cty}NVGASNIMPQN) ' Gas emissions

	series {%cty}CCEMISCO2TKN = {%cty}CCEMISCO2CKN+{%cty}CCEMISCO2OKN+{%cty}CCEMISCO2GKN ' Total emissions

' ADD REVENUES FORGONE
	series {%cty}GGREVEMISCN = {%cty}PANUSATLS/1000000*(({%cty}GGREVCO2CER*(EMISCOAL*1000)*({%cty}NVCOLPRODQN+{%cty}NVCOLNIMPQN)) +({%cty}GGREVCO2OER*(EMISOIL*1000)*({%cty}NVOILPRODQN+{%cty}NVOILNIMPQN)) +({%cty}GGREVCO2GER* (EMISGAS*1000)*({%cty}NVGASPRODQN+{%cty}NVGASNIMPQN)))

	series {%cty}GGREVELECN = ({%cty}GGREVELECER_/100)*{%cty}NECONELECN

' Recalculate other revenue
	series {%cty}GGREVOTHRCN = {%cty}GGREVTOTLCN - ({%cty}GGREVTAXTCN+{%cty}GGREVNONTCN+{%cty}GGREVGRNTCN+{%cty}GGREVEMISCN+{%cty}GGREVELECN)

' Energy OUTPUT (i.e. intermediate energy use for each industry) :  VA_Energy + sum_(j) [beta_energy_(j)*VA_(j)*(1+{beta_(j)/(1-beta_(j))})]

	series {%cty}BETAENGYAGR = 0.21
	series {%cty}BETAENGYIND = 0.35
	series {%cty}BETAENGYENG = 0.53
	series {%cty}BETAENGYSRV = 0.10

	for %nonen AGRTOTL INDOTHR ENGTOTL SRVTOTL
		if  %nonen=="INDOTHRT" then 
			%temp = @mid(%nonen,4,5)
		else
			%temp = @mid(%nonen,1,3)
		endif
		
		series {%cty}{%temp}INTKN = {%cty}BETAENGY{%temp}*{%cty}NV{%nonen}KN ' Energy intermediate inputs for each industry (constant prices)
		series {%cty}{%temp}INTCN =  {%cty}BETAENGY{%temp}*{%cty}NV{%nonen}CN ' Energy intermediate inputs for each industry (current prices)
	next
	series {%cty}NVENGOUTPKN = {%cty}NVENGTOTLKN+{%cty}AGRINTKN+{%cty}INDINTKN+{%cty}ENGINTKN+{%cty}SRVINTKN

	series {%cty}NVENGOUTPCN = {%cty}NVENGTOTLCN+{%cty}AGRINTCN+{%cty}INDINTCN+{%cty}ENGINTCN+{%cty}SRVINTCN


'*************************************************************
' Local air pollution
'*************************************************************
' https://data.worldbank.org/indicator/EN.ATM.PM25.MC.M3?locations=ZA 
'series {%cty}PM25= {%cty}PM25(-1)+(0+D(({%cty}NVCOLPRODQN+{%cty}NVCOLNIMPQN)*0.0000535+({%cty}NVOILPRODQN+{%cty}NVOILNIMPQN)*0.000353+({%cty}NVGASPRODQN+{%cty}NVGASNIMPQN)*0.0000296)) 'Total PM 2.5 concentration
	smpl 1990 %end_estimate
	equation _{%cty}PM25.LS {%cty}PM25= C(1)*DUMH+{%cty}PM25(-1)+(0+D(({%cty}NVCOLPRODQN+{%cty}NVCOLNIMPQN)*0.0000535+({%cty}NVOILPRODQN+{%cty}NVOILNIMPQN)*0.000353+({%cty}NVGASPRODQN+{%cty}NVGASNIMPQN)*0.0000296))
	smpl @all
	series {%cty}WDL={%cty}SPPOP1564TO*3.7*(1-exp(-0.0046*{%cty}PM25)) 'Million working days lost
	series {%cty}APDEATHS = 0
	'smpl 2000 2018
	'{%cty}APDEATHS = 1600/1
	'smpl 2019 @last
	'series {%cty}APDEATHS={%cty}APDEATHS(-1)+D(0.000025*({%cty}SPPOPTOTL*1000000)*({%cty}PM25-4.15)) 'Air pollution deaths 22917
	'series {%cty}APDEATHS=(0.000025*({%cty}SPPOPTOTL*1000000)*({%cty}PM25-4.15)) 'Air pollution deaths
	smpl @all
	series {%cty}HEAPCN=0.01*{%cty}NYGDPMKTPCN*({%cty}NYGDPMKTPCN/@ELEM({%cty}NYGDPMKTPCN,2016))*(({%cty}PM25-4.15)/(@elem({%cty}PM25,2016)-4.15)) 'Health expenditure attributable to pollution - check with WHO  4% of GDP

	series {%cty}LMEFFLFCN=(({%cty}LMPRTTOTL_/100)*{%cty}SPPOP1564TO)-({%cty}WDL/240) 'Effective labor force: Nominal labor force less "working years lost"
	'series {%cty}GGEXPGNFSCN2={%cty}GGEXPGNFSCN-{%cty}HEAPKN+{%cty}HEAPKN(-1) 'New measure for government consumption (accounting for HEAP)
	'series {%cty}GGEXPCAPTCN2={%cty}GGEXPCAPTCN+{%cty}HEAPKN-{%cty}HEAPKN(-1) 'New measure for government investment (accounting for HEAP)

	series {%cty}LMWAPOPKN = ({%cty}LMPRTSTRL_/100)*{%cty}SPPOP1564TO

'*************************************************************
' ADD REMAINING EQUATIONS TO THE MODEL
'*************************************************************
' INDUSTRY PRICES

	smpl @all
	'{%cty}.DROP {%cty}NVSRVTOTLXN {%cty}NVINDTOTLCN {%cty}NVAGRTOTLCN {%cty}NVSRVTOTLCN {%cty}NEIMPGNFSCN  ' {%cty}NVINDTOTLCN {%cty}NVAGRTOTLXN {%cty}NVINDTOTLXN 
	string VAS = "AGR SRV" 'INDOTHR  Energy prices is a CES
	
	smpl 1990 %end_estimate
	for %vv {VAS}
		equation _{%cty}NV{%vv}TOTLXN.LS(OPTMETHOD=LEGACY) DLOG({%cty}NV{%vv}TOTLXN)=-0.2*(LOG({%cty}NV{%vv}TOTLXN(-1))-LOG({%cty}NECONPRVTXN(-1)))+@LOGIT(C(1))*DLOG({%cty}NECONPRVTXN)+(1-@LOGIT(C(1)))*DLOG({%cty}NV{%vv}TOTLXN(-1)) + C(10)
	next
	
	equation _BGDNVINDOTHRXN.LS(OPTMETHOD=LEGACY) DLOG(BGDNVINDOTHRXN)=C(1)*(LOG(BGDNVINDOTHRXN(-1))-LOG(BGDNECONPRVTXN(-1)))+C(2)*DLOG(BGDNECONPRVTXN)+(1-C(2))*DLOG(BGDNVINDOTHRXN(-1)) + C(10)+C(11)*@DURING("2008")
	
	equation _{%cty}NVINDOTHRXN.LS(OPTMETHOD=LEGACY) DLOG({%cty}NVINDOTHRXN)=-0.2*(LOG({%cty}NVINDOTHRXN(-1))-LOG({%cty}NECONPRVTXN(-1)))+@LOGIT(C(1))*DLOG({%cty}NECONPRVTXN)+(1-@LOGIT(C(1)))*DLOG({%cty}NVINDOTHRXN(-1)) + C(10)

	{%cty}.APPEND @IDENTITY {%cty}NVAGRTOTLCN = {%cty}NVAGRTOTLXN*{%cty}NVAGRTOTLKN 
	{%cty}.APPEND @IDENTITY {%cty}NVENGTOTLCN = {%cty}NVENGTOTLXN*{%cty}NVENGTOTLKN 
	{%cty}.APPEND @IDENTITY {%cty}NVINDOTHRCN = {%cty}NVINDOTHRXN*{%cty}NVINDOTHRKN 
	{%cty}.APPEND @IDENTITY {%cty}NVINDTOTLCN = {%cty}NVENGTOTLCN+{%cty}NVINDOTHRCN
	{%cty}.APPEND @IDENTITY {%cty}NVINDTOTLXN = {%cty}NVINDTOTLCN/{%cty}NVINDTOTLKN
	'{%cty}.APPEND @IDENTITY {%cty}NVSRVTOTLCN
	{%cty}.APPEND @IDENTITY {%cty}NVSRVTOTLCN  = {%cty}NYGDPFCSTCN  - {%cty}NVAGRTOTLCN  - {%cty}NVINDTOTLCN
	delete _{%cty}NVSRVTOTLXN
	{%cty}.APPEND @IDENTITY {%cty}NVSRVTOTLXN= {%cty}NVSRVTOTLCN/{%cty}NVSRVTOTLKN
'***************************************************************************
'***    COMMODITY CONS, PRD AND IMP ***
'***************************************************************************
	smpl 2006 %end_estimate ' 1990 %end_estimate
	for %ab COL OIL GAS  '  = "COL OIL GAS REN"
		if !SR = 1 then
			if %ab = "COL" or %ab = "GAS" then ' Insert commodities if you also want them to responsd slowly
				equation _{%cty}NV{%ab}PRODKN.LS DLOG({%cty}NV{%ab}PRODKN) = C(1)-0.1*(LOG({%cty}NV{%ab}PRODKN(-1))-LOG({%cty}NVENGTOTLKN(-1))-0.7*LOG(({%cty}NVENGTOTLXN(-1)/{%cty}NV{%ab}PRODXN(-1))))+0.3*DLOG({%cty}NVENGTOTLKN)+0.3*DLOG({%cty}NVENGTOTLXN/{%cty}NV{%ab}PRODXN)  ' Production CES {%cty}CESENGYPROD

				equation _{%cty}NE{%ab}CONELKN.LS DLOG({%cty}NE{%ab}CONELKN) = C(1)-0.1*(LOG({%cty}NE{%ab}CONELKN(-1))-LOG({%cty}NECONELEKN(-1))-0.7*LOG(({%cty}NECONELEXN(-1)/{%cty}NE{%ab}CONELXN(-1))))+0.3*DLOG({%cty}NECONELEKN)+0.3*DLOG({%cty}NECONELEXN/{%cty}NE{%ab}CONELXN) 
				equation _{%cty}NE{%ab}CONNEKN.LS DLOG({%cty}NE{%ab}CONNEKN) = C(1)-0.1*(LOG({%cty}NE{%ab}CONNEKN(-1))-LOG({%cty}NECONNELKN(-1))-0.7*LOG(({%cty}NECONNELXN(-1)/{%cty}NE{%ab}CONNEXN(-1))))+0.3*DLOG({%cty}NECONNELKN)+0.3*DLOG({%cty}NECONNELXN/{%cty}NE{%ab}CONNEXN) 
			else
				{%cty}.append @identity {%cty}NV{%ab}PRODKN = {%cty}NV{%ab}PRODSH^({%cty}CESENGYPROD)*({%cty}NVENGTOTLKN*({%cty}NVENGTOTLXN/{%cty}NV{%ab}PRODXN)^({%cty}CESENGYPROD))   ' Production CES

				{%cty}.append @identity {%cty}NE{%ab}CONELKN= {%cty}NE{%ab}CONELSH^({%cty}CESECOMYCON)*({%cty}NECONELEKN*({%cty}NECONELEXN/{%cty}NE{%ab}CONELXN)^({%cty}CESECOMYCON)) ' electricity Consumption CES of Commodity k
				{%cty}.append @identity {%cty}NE{%ab}CONNEKN = {%cty}NE{%ab}CONNESH^({%cty}CESECOMYCON)*({%cty}NECONNELKN*({%cty}NECONNELXN/{%cty}NE{%ab}CONNEXN)^({%cty}CESECOMYCON))   ' non electricity Consumption CES of Commodity k
			endif
		else
			{%cty}.append @identity {%cty}NV{%ab}PRODKN = {%cty}NV{%ab}PRODSH^({%cty}CESENGYPROD)*({%cty}NVENGTOTLKN*({%cty}NVENGTOTLXN/{%cty}NV{%ab}PRODXN)^({%cty}CESENGYPROD))   ' Production CES

			{%cty}.append @identity {%cty}NE{%ab}CONELKN= {%cty}NE{%ab}CONELSH^({%cty}CESECOMYCON)*({%cty}NECONELEKN*({%cty}NECONELEXN/{%cty}NE{%ab}CONELXN)^({%cty}CESECOMYCON)) ' electricity Consumption CES of Commodity k
			{%cty}.append @identity {%cty}NE{%ab}CONNEKN = {%cty}NE{%ab}CONNESH^({%cty}CESECOMYCON)*({%cty}NECONNELKN*({%cty}NECONNELXN/{%cty}NE{%ab}CONNEXN)^({%cty}CESECOMYCON))   ' non electricity Consumption CES of Commodity k
		endif


		{%cty}.append @identity {%cty}NE{%ab}CONELCN = {%cty}NE{%ab}CONELKN*{%cty}NE{%ab}CONELXN ' Nomimal electricity consumption of Commodity k
		{%cty}.append @identity {%cty}NE{%ab}CONNECN = {%cty}NE{%ab}CONNEKN*{%cty}NE{%ab}CONNEXN ' Nomimal non-electricity consumption of Commodity k
		{%cty}.append @identity {%cty}NE{%ab}CONKN = {%cty}NE{%ab}CONELKN+{%cty}NE{%ab}CONNEKN ' Consumption of Commodity k = elec cons(k) + non-elec cons (k)
		{%cty}.append @identity {%cty}NE{%ab}CONCN = {%cty}NE{%ab}CONELCN+{%cty}NE{%ab}CONNECN ' Consumption of Commodity k = elec cons(k) + non-elec cons (k)
		{%cty}.append @identity {%cty}NE{%ab}CONXN = {%cty}NE{%ab}CONCN/{%cty}NE{%ab}CONKN 

		{%cty}.append @identity {%cty}NV{%ab}NIMPKN = {%cty}NE{%ab}CONKN - {%cty}NV{%ab}PRODKN
		{%cty}.append @identity {%cty}NV{%ab}NIMPCN = {%cty}NE{%ab}CONCN - {%cty}NV{%ab}PRODCN
	next

	{%cty}.append @identity {%cty}NVRENPRODKN = {%cty}NVENGTOTLKN-{%cty}NVCOLPRODKN-{%cty}NVOILPRODKN-{%cty}NVGASPRODKN
	{%cty}.append @identity {%cty}NERENCONELKN = {%cty}NECONELEKN - {%cty}NECOLCONELKN-{%cty}NEOILCONELKN-{%cty}NEGASCONELKN
	{%cty}.append @identity {%cty}NERENCONNEKN = {%cty}NECONNELKN - {%cty}NECOLCONNEKN - {%cty}NEOILCONNEKN-{%cty}NEGASCONNEKN

	{%cty}.append @identity {%cty}NERENCONELCN = {%cty}NERENCONELKN*{%cty}NERENCONELXN ' Nomimal electricity consumption of Commodity k
	{%cty}.append @identity {%cty}NERENCONNECN = {%cty}NERENCONNEKN*{%cty}NERENCONNEXN ' Nomimal non-electricity consumption of Commodity k
	{%cty}.append @identity {%cty}NERENCONKN = {%cty}NERENCONELKN+{%cty}NERENCONNEKN ' Consumption of Commodity k = elec cons(k) + non-elec cons (k)
	{%cty}.append @identity {%cty}NERENCONCN = {%cty}NERENCONELCN+{%cty}NERENCONNECN ' Consumption of Commodity k = elec cons(k) + non-elec cons (k)
	{%cty}.append @identity {%cty}NERENCONXN = {%cty}NERENCONCN/{%cty}NERENCONKN 

	{%cty}.append @identity {%cty}NVRENNIMPKN = {%cty}NERENCONKN - {%cty}NVRENPRODKN
	{%cty}.append @identity {%cty}NVRENNIMPCN = {%cty}NERENCONCN - {%cty}NVRENPRODCN

' VOLUMES AND EMISSIONS
' CONSUMPTION CES (ENERGY; OTHER)

	{%cty}.append @identity {%cty}NECONENGYKN = {%cty}NECONENGYSH^({%cty}CESENGYCON)*({%cty}NECONPRVTKN*({%cty}NECONPRVTXN/{%cty}NECONENGYXN)^({%cty}CESENGYCON))  ' Consumption Energy CES
	'{%cty}.append @identity {%cty}NECONOTHRKN = {%cty}NECONOTHRSH^({%cty}CESENGYCON)*({%cty}NECONPRVTKN*({%cty}NECONPRVTXN/{%cty}NECONOTHRXN)^({%cty}CESENGYCON))   ' Consumption Other CES
	{%cty}.append @identity {%cty}NECONOTHRKN = {%cty}NECONPRVTKN-{%cty}NECONENGYKN 

	{%cty}.append @identity {%cty}NECONENGYCN ={%cty}NECONENGYXN*{%cty}NECONENGYKN ' Consumption energy (current prices)
	{%cty}.append @identity {%cty}NECONOTHRCN = {%cty}NECONOTHRKN*{%cty}NECONOTHRXN ' Other consumption (current prices)

	{%cty}.append @identity {%cty}NECONENGYXN = (({%cty}NECONELESH^{%cty}CESENGYCON)*{%cty}NECONELEXN^(1-{%cty}CESENGYCON)+({%cty}NECONNELSH^{%cty}CESENGYCON)*{%cty}NECONNELXN^(1-{%cty}CESENGYCON))^(1/(1-{%cty}CESENGYCON)) ' test Energy CES (Electricity ; Non-electricity)

' ENERGY CONS CES (ELECTRICITY; NON-ELECTRICITY)
	{%cty}.append @identity {%cty}NECONELEKN = {%cty}NECONELESH^({%cty}CESENGYCON)*({%cty}NECONENGYKN*({%cty}NECONENGYXN/{%cty}NECONELEXN)^({%cty}CESENGYCON)) ' electricity consumption CES
	'{%cty}.append @identity {%cty}NECONNELKN = {%cty}NECONNELSH^({%cty}CESENGYCON)*({%cty}NECONENGYKN*({%cty}NECONENGYXN/{%cty}NECONNELXN)^({%cty}CESENGYCON))  ' non-electricity consumption CES
	{%cty}.append @identity {%cty}NECONNELKN = {%cty}NECONENGYKN - {%cty}NECONELEKN


	{%cty}.append @identity {%cty}NECONELEXN = (({%cty}NECOLCONELSH^{%cty}CESECOMYCON)*{%cty}NECOLCONELXN^(1-{%cty}CESECOMYCON)+({%cty}NEOILCONELSH^{%cty}CESECOMYCON)*{%cty}NEOILCONELXN^(1-{%cty}CESECOMYCON)+({%cty}NEGASCONELSH^{%cty}CESECOMYCON)*{%cty}NEGASCONELXN^(1-{%cty}CESECOMYCON)+({%cty}NERENCONELSH^{%cty}CESECOMYCON)*{%cty}NERENCONELXN^(1-{%cty}CESECOMYCON))^(1/(1-{%cty}CESECOMYCON))  ' test Electricity CES (k)

	{%cty}.append @identity {%cty}NECONNELXN = (({%cty}NECOLCONNESH^{%cty}CESECOMYCON)*{%cty}NECOLCONNEXN^(1-{%cty}CESECOMYCON)+({%cty}NEOILCONNESH^{%cty}CESECOMYCON)*{%cty}NEOILCONNEXN^(1-{%cty}CESECOMYCON)+({%cty}NEGASCONNESH^{%cty}CESECOMYCON)*{%cty}NEGASCONNEXN^(1-{%cty}CESECOMYCON)+({%cty}NERENCONNESH^{%cty}CESECOMYCON)*{%cty}NERENCONNEXN^(1-{%cty}CESECOMYCON))^(1/(1-{%cty}CESECOMYCON))  ' test Non-Electricity CES (k)

	{%cty}.append @identity {%cty}NECONNELCN = {%cty}NECONNELKN*{%cty}NECONNELXN ' Electricity consumption (nominal)
	{%cty}.append @identity {%cty}NECONELECN = {%cty}NECONELEKN*{%cty}NECONELEXN '  Non-Electricity consumption (nominal)

' PRICES FOR ELECTRICITY AND NON-ELECTRICITY ENERGY CONSUMPTION

' Consumption electricity prices of commodity k
	smpl 1990 %end_estimate
	equation _{%cty}NECOLCONELXN.LS dlog({%cty}NECOLCONELXN) = dlog({%cty}NVCOLPRODGN)+C(1)*DUMH ' Coal consumption price
	equation _{%cty}NEOILCONELXN.LS dlog({%cty}NEOILCONELXN) = dlog({%cty}NVOILPRODGN)+C(1)*DUMH ' Oil consumption price
	equation _{%cty}NEGASCONELXN.LS dlog({%cty}NEGASCONELXN) = dlog({%cty}NVGASPRODGN)+C(1)*DUMH ' Gas consumption price
	equation _{%cty}NERENCONELXN.LS dlog({%cty}NERENCONELXN) = dlog({%cty}NVRENPRODXN)+C(1)*DUMH ' Hydro consumption price

' Consumption non-electricity prices of commodity k
	equation _{%cty}NECOLCONNEXN.LS dlog({%cty}NECOLCONNEXN) = dlog({%cty}NVCOLPRODGN)+C(1)*DUMH ' Coal consumption price
	equation _{%cty}NEOILCONNEXN.LS dlog({%cty}NEOILCONNEXN) = dlog({%cty}NVOILPRODGN)+C(1)*DUMH ' Oil consumption price
	equation _{%cty}NEGASCONNEXN.LS dlog({%cty}NEGASCONNEXN) = dlog({%cty}NVGASPRODGN)+C(1)*DUMH ' Gas consumption price
	equation _{%cty}NERENCONNEXN.LS dlog({%cty}NERENCONNEXN) = dlog({%cty}NVRENPRODXN)+C(1)*DUMH ' Hydro consumption price


	{%cty}.append @identity {%cty}NECONENGYGN = ({%cty}NVCOLPRODSH^({%cty}CESENGYPROD)*({%cty}NVCOLPRODGN)^(1-{%cty}CESENGYPROD)+{%cty}NVGASPRODSH^({%cty}CESENGYPROD)*({%cty}NVGASPRODGN)^(1-{%cty}CESENGYPROD)+{%cty}NVOILPRODSH^({%cty}CESENGYPROD)*({%cty}NVOILPRODGN)^(1-{%cty}CESENGYPROD)+{%cty}NVRENPRODSH^({%cty}CESENGYPROD)*({%cty}NVRENPRODXN)^(1-{%cty}CESENGYPROD))^(1/(1-{%cty}CESENGYPROD)) ' Gross Price for consumers

	{%cty}.append @identity {%cty}NVCOLPRODGN=((WLDFCOAL_AUS*CONVMTTOE*{%cty}PANUSATLS)+{%cty}GGREVCO2CER*(EMISCOAL)*({%cty}PANUSATLS))/((@elem(WLDFCOAL_AUS,{%base_year})*CONVMTTOE*@elem({%cty}PANUSATLS,{%base_year}))+@elem({%cty}GGREVCO2CER,{%base_year})*(EMISCOAL)*(@elem({%cty}PANUSATLS,{%base_year}))) 'Gross price index for coal (price index and carbon taxes)

	{%cty}.append @identity {%cty}NVOILPRODGN=((WLDFCRUDE_PETRO*CONVBBLTOE*{%cty}PANUSATLS)+{%cty}GGREVCO2OER*(EMISOIL)*({%cty}PANUSATLS))/((@elem(WLDFCRUDE_PETRO,{%base_year})*CONVBBLTOE*@elem({%cty}PANUSATLS,{%base_year}))+@elem({%cty}GGREVCO2OER,{%base_year})*(EMISOIL)*(@elem({%cty}PANUSATLS,{%base_year}))) 'Gross price index for coal (price index and carbon taxes)

	{%cty}.append @identity {%cty}NVGASPRODGN=((WLDFNGAS_EUR*CONVMMBTUTOE*GASADJ*{%cty}PANUSATLS)+{%cty}GGREVCO2GER*(EMISGAS)*({%cty}PANUSATLS))/((@elem(WLDFNGAS_EUR,{%base_year})*CONVMMBTUTOE*GASADJ*@elem({%cty}PANUSATLS,{%base_year}))+@elem({%cty}GGREVCO2GER,{%base_year})*(EMISGAS)*(@elem({%cty}PANUSATLS,{%base_year}))) 'Gross price index for coal (price index and carbon taxes)

	equation _{%cty}NECONOTHRXN.LS DLOG(BGDNECONOTHRXN) = -0.3*(LOG(BGDNECONOTHRXN(-1))-0.5*LOG(BGDNYGDPFCSTXN(-1))-LOG(1+BGDGGREVTVATER(-1)/100)-(1-0.5)*LOG(BGDNEIMPGNFSXN(-1)))+C(3)+0.3*DLOG(BGDNEIMPGNFSXN)+(1-0.3)*DLOG(BGDNYGDPFCSTXN)+DLOG(1+BGDGGREVTVATER/100) +C(10)*@DURING("2009 2010") ' Other consumption

	{%cty}.append @identity {%cty}NECONPRVTXN = (({%cty}NECONENGYSH^{%cty}CESENGYCON)*{%cty}NECONENGYXN^(1-{%cty}CESENGYCON)+({%cty}NECONOTHRSH^{%cty}CESENGYCON)*{%cty}NECONOTHRXN^(1-{%cty}CESENGYCON))^(1/(1-{%cty}CESENGYCON)) ' TOTAL 

' IMPORTS
'Values and volumes

	{%cty}.append @identity {%cty}NVENGNIMPCN = {%cty}NVCOLNIMPCN+{%cty}NVOILNIMPCN+{%cty}NVGASNIMPCN+{%cty}NVRENNIMPCN ' Energy imports (current prices)
	{%cty}.append @identity {%cty}NVENGNIMPKN = {%cty}NVCOLNIMPKN+{%cty}NVOILNIMPKN+{%cty}NVGASNIMPKN+{%cty}NVRENNIMPKN ' Energy imports (constant prices)
	{%cty}.append @identity {%cty}NVENGNIMPXN = {%cty}NVENGNIMPCN/{%cty}NVENGNIMPKN ' Energy import price deflator

	{%cty}.append @identity {%cty}NEIMPGSNECN= {%cty}NEIMPGSNEKN*{%cty}NEIMPGSNEXN ' Non-energy imports, in current LCU
	{%cty}.append @identity {%cty}NEIMPGNFSCN = {%cty}NEIMPGSNECN+{%cty}NVENGNIMPCN  'TOTAL IMPORTS (current prices)
	{%cty}.append @identity {%cty}NEIMPGNFSKN = {%cty}NEIMPGSNEKN+{%cty}NVENGNIMPKN ' TOTAL IMPORTS (constant prices)

	equation _{%cty}NVCOLPRODXN.LS dlog({%cty}NVCOLPRODXN)=dlog({%cty}NVCOLPRODGN)+c(1)*DUMH 'Price index for coal
	equation _{%cty}NVOILPRODXN.LS dlog({%cty}NVOILPRODXN)=dlog({%cty}NVOILPRODGN)+c(1)*DUMH 'Price index for oil
	equation _{%cty}NVGASPRODXN.LS dlog({%cty}NVGASPRODXN)=dlog({%cty}NVGASPRODGN)+c(1)*DUMH 'Price index for oil
	equation _{%cty}NVRENPRODXN.LS dlog({%cty}NVRENPRODXN)=dlog((WLDHYDROPOWER*{%cty}PANUSATLS)/(@elem(WLDHYDROPOWER,2011)*@elem({%cty}PANUSATLS,2011)))+c(1)*DUMH 'Price index for renewables
	
	smpl 1990 %end_estimate
	equation _{%cty}NEIMPGSNEKN.LS DLOG({%cty}NEIMPGSNEKN) =-0.3*(LOG({%cty}NEIMPGSNEKN(-1))-LOG({%cty}NEGDETTOTKN(-1))+0.6*LOG({%cty}NEIMPGSNEXN(-1)/({%cty}NYGDPFCSTXN(-1))))-0.4*DLOG({%cty}NEIMPGSNEXN/{%cty}NYGDPFCSTXN)+C(5)+0.8*DLOG({%cty}NYGDPPOTLKN)+C(10)*@DURING("2009") ' non energy imports

	'equation _{%cty}NEIMPGSNEXN.LS DLOG({%cty}NEIMPGSNEXN) = -0.3*(LOG({%cty}NEIMPGSNEXN(-1))-0.6*LOG({%cty}NECONPRVTXN(-1))-(1-0.6)*LOG({%cty}PMKEY(-1)*{%cty}PANUSATLS(-1)))+0.4*DLOG({%cty}NECONPRVTXN)+(1-0.4)*DLOG({%cty}PMKEY*{%cty}PANUSATLS)+C(4)+C(10)*@DURING("2007") ' Non energy deflator
	
	smpl 1990 %end_estimate
	equation _{%cty}NEIMPGSNEXN.LS DLOG(BGDNEIMPGSNEXN) = -0.4*(LOG(BGDNEIMPGSNEXN(-1))-0.5*LOG(BGDNYGDPFCSTXN(-1))-(1-0.5)*LOG(BGDPMKEY(-1)*BGDPANUSATLS(-1)))+0.7*DLOG(BGDNYGDPFCSTXN)+(1-0.7)*DLOG(BGDPMKEY*BGDPANUSATLS)+C(4)+C(10)*@DURING("2005 2007")

' ENERGY PRICE INDEX (PRODUCTION)

	{%cty}.append @identity {%cty}NVENGTOTLXN = (({%cty}NVCOLPRODSH^{%cty}CESENGYPROD)*{%cty}NVCOLPRODXN^(1-{%cty}CESENGYPROD)+({%cty}NVOILPRODSH^{%cty}CESENGYPROD)*{%cty}NVOILPRODXN^(1-{%cty}CESENGYPROD)+({%cty}NVGASPRODSH^{%cty}CESENGYPROD)*{%cty}NVGASPRODXN^(1-{%cty}CESENGYPROD)+({%cty}NVRENPRODSH^{%cty}CESENGYPROD)*{%cty}NVRENPRODXN^(1-{%cty}CESENGYPROD))^(1/(1-{%cty}CESENGYPROD))

	'delete _{%cty}NEIMPGNFSXN _{%cty}NEIMPGNFSKN _{%cty}NECONPRVTXN

	{%cty}.append @identity {%cty}NEIMPGNFSXN = {%cty}NEIMPGNFSCN/{%cty}NEIMPGNFSKN

' ELECTRICITY AND FOSSIL FUEL MANUFACTURING

	{%cty}.append @identity {%cty}NVINDENGYSKN={%cty}NVMNFFSRTKN*({%cty}NVCOLPRODKN+{%cty}NVOILPRODKN+{%cty}NVGASPRODKN) ' MNF (FOSSIL) VA (CONSTANT PRICES)
	{%cty}.append @identity {%cty}NVINDENGYSCN={%cty}NVMNFFSRTCN*({%cty}NVCOLPRODCN+{%cty}NVOILPRODCN+{%cty}NVGASPRODCN) ' MNF (FOSSIL) VA (CURRENT PRICES)

	{%cty}.append @identity {%cty}NVINDELECKN = {%cty}NVRENPRODKN+{%cty}NVELCFSRTKN*({%cty}NVCOLPRODKN+{%cty}NVOILPRODKN+{%cty}NVGASPRODKN)  ' Electricity VA (Constant Prices)
	{%cty}.append @identity {%cty}NVINDELECCN = {%cty}NVRENPRODCN+{%cty}NVELCFSRTCN*({%cty}NVCOLPRODCN+{%cty}NVOILPRODCN+{%cty}NVGASPRODCN) ' Electricity VA (Current Prices) 

' BACKING OUT THE QUANTITIES
	' FIRST RESCALE

' PRODUCTION
	{%cty}.append @identity {%cty}NVCOLPRODCN = {%cty}NVCOLPRODXN*{%cty}NVCOLPRODKN
	{%cty}.append @identity {%cty}NVOILPRODCN = {%cty}NVOILPRODXN*{%cty}NVOILPRODKN
	{%cty}.append @identity {%cty}NVGASPRODCN = {%cty}NVGASPRODXN*{%cty}NVGASPRODKN
	{%cty}.append @identity {%cty}NVRENPRODCN = {%cty}NVRENPRODXN*{%cty}NVRENPRODKN

	{%cty}.append @identity {%cty}NVCOLPRODCN2 = {%cty}NVCOLPRODCN/SCALINGF  'Value of coal produced, in current LCU, adjusted by scaling factor ' SCALINGF is EXOGENOUS AND SHOULD BE A CONSTANT
	{%cty}.append @identity {%cty}NVOILPRODCN2 = {%cty}NVOILPRODCN/SCALINGF 'Value of oil produced, in current LCU, adjusted by scaling factor
	{%cty}.append @identity {%cty}NVGASPRODCN2 = {%cty}NVGASPRODCN/SCALINGF 'Value of gas produced, in current LCU, adjusted by scaling factor
	{%cty}.append @identity {%cty}NVRENPRODCN2 = {%cty}NVRENPRODCN/SCALINGF 'Value of newables produced, in current LCU, adjusted by scaling factor

	{%cty}.append @identity {%cty}NVCOLPRODQN = {%cty}NVCOLPRODCN2/((CONVMTTOE*1000)*WLDFCOAL_AUS*{%cty}PANUSATLS/1000000+{%cty}GGREVCO2CER*(EMISCOAL*1000)*({%cty}PANUSATLS/1000000)) ' Volumes of coal
	{%cty}.append @identity {%cty}NVOILPRODQN = {%cty}NVOILPRODCN2/((CONVBBLTOE*1000)*WLDFCRUDE_PETRO*{%cty}PANUSATLS/1000000+{%cty}GGREVCO2OER*(EMISOIL*1000)*({%cty}PANUSATLS/1000000)) ' Volumes of oil
	{%cty}.append @identity {%cty}NVGASPRODQN = {%cty}NVGASPRODCN2/((WLDFNGAS_EUR*1000)*CONVMMBTUTOE*GASADJ*{%cty}PANUSATLS/1000000+{%cty}GGREVCO2GER*(EMISGAS*1000)*({%cty}PANUSATLS/1000000)) ' Volumes of gas
	{%cty}.append @identity {%cty}NVRENPRODQN = {%cty}NVRENPRODCN2/((WLDHYDROPOWER*1000)*CONVKWHTOE*{%cty}PANUSATLS/1000000)  ' Volumes of hydro

' IMPORTS
	{%cty}.append @identity {%cty}NVCOLNIMPQN = {%cty}NVCOLNIMPCN/((WLDFCOAL_AUS*1000)*CONVMTTOE*{%cty}PANUSATLS/1000000+{%cty}GGREVCO2CER*(EMISCOAL*1000)*({%cty}PANUSATLS/1000000))  'Value of coal imported, in current LCU
	{%cty}.append @identity {%cty}NVOILNIMPQN = {%cty}NVOILNIMPCN/((WLDFCRUDE_PETRO*1000)*CONVBBLTOE*{%cty}PANUSATLS/1000000+{%cty}GGREVCO2OER*(EMISOIL*1000)*({%cty}PANUSATLS/1000000)) 'Value of oil imported, in current LCU
	{%cty}.append @identity {%cty}NVGASNIMPQN = {%cty}NVGASNIMPCN/((WLDFNGAS_EUR*1000)*CONVMMBTUTOE*{%cty}PANUSATLS/1000000+{%cty}GGREVCO2GER*(EMISGAS*1000)*({%cty}PANUSATLS/1000000)) 'Value of gas imported, in current LCU
	{%cty}.append @identity {%cty}NVRENNIMPQN = {%cty}NVRENNIMPCN/((WLDHYDROPOWER*1000)*CONVKWHTOE*{%cty}PANUSATLS/1000000) 'Value of renewables imported, in current LCU

' ADD EMISSIONS
	{%cty}.append @identity {%cty}CCEMISCO2CKN = (1000*EMISCOAL)*({%cty}NVCOLPRODQN+{%cty}NVCOLNIMPQN) ' Coal emissions
	{%cty}.append @identity {%cty}CCEMISCO2OKN = (1000*EMISOIL)*({%cty}NVOILPRODQN+{%cty}NVOILNIMPQN) ' Oil emissions
	{%cty}.append @identity {%cty}CCEMISCO2GKN = (1000*EMISGAS)*({%cty}NVGASPRODQN+{%cty}NVGASNIMPQN) ' Gas emissions

	smpl 1990 %end_estimate
	equation _{%cty}EMCOLFULT.LS @pc({%cty}EMCOLFULT) = @PC({%cty}CCEMISCO2CKN)+C(1)*DUMH ' Maps it to actual CO in million Tons
	equation _{%cty}EMOILFULT.LS @pc({%cty}EMOILFULT) = @PC({%cty}CCEMISCO2OKN)+C(1)*DUMH ' Maps it to actual CO in million Tons
	equation _{%cty}EMGASFULT.LS @pc({%cty}EMGASFULT) = @PC({%cty}CCEMISCO2GKN)+C(1)*DUMH ' Maps it to actual CO in million Tons

	series {%cty}CCEMISCO2Q = {%cty}EMCOLFULT+{%cty}EMOILFULT+{%cty}EMGASFULT ' Emissions (million tons)
	{%cty}.append @identity {%cty}CCEMISCO2Q = {%cty}EMCOLFULT+{%cty}EMOILFULT+{%cty}EMGASFULT ' Emissions (million tons)

	{%cty}.append @identity {%cty}CCEMISCO2TKN = {%cty}CCEMISCO2CKN+{%cty}CCEMISCO2OKN+{%cty}CCEMISCO2GKN ' Total emissions


' ADD FISCAL REVENUES
' REVENUES LOST DUE TO CARBON SUBSIDY
	{%cty}.append @identity {%cty}GGREVEMISCN = {%cty}PANUSATLS/1000000 *(({%cty}GGREVCO2CER*(EMISCOAL*1000)*({%cty}NVCOLPRODQN+{%cty}NVCOLNIMPQN)) +({%cty}GGREVCO2OER*(EMISOIL*1000)*({%cty}NVOILPRODQN+{%cty}NVOILNIMPQN)) +({%cty}GGREVCO2GER* (EMISGAS*1000)*({%cty}NVGASPRODQN+{%cty}NVGASNIMPQN)))

	{%cty}.append @identity {%cty}GGREVELECN = ({%cty}GGREVELECER_/100)*{%cty}NECONELECN

	'{%cty}.APPEND @IDENTITY {%cty}GGREVTOTLCN = {%cty}GGREVOTHRCN + ({%cty}GGREVTAXTCN+{%cty}GGREVNONTCN+{%cty}GGREVGRNTCN+{%cty}GGREVEMISCN+{%cty}GGREVELECN)
	BGD.append @IDENTITY BGDGGREVTOTLCN = BGDGGREVTAXTCN + BGDGGREVNONTCN + BGDGGREVGRNTCN + BGDGGREVOTHRCN + {%cty}GGREVEMISCN + {%cty}GGREVELECN

'***************************************************************************
'***    INTERMEDIATE ENERGY DEMAND ***
'***************************************************************************

	for %nonen AGRTOTL INDOTHR ENGTOTL SRVTOTL
		if  %nonen=="INDOTHRT" then 
			%temp = @mid(%nonen,4,5)
		else
			%temp = @mid(%nonen,1,3)
		endif
		
		{%cty}.APPEND @IDENTITY {%cty}{%temp}INTKN = {%cty}BETAENGY{%temp}*{%cty}NV{%nonen}KN ' Energy intermediate inputs for each industry (constant prices)
		{%cty}.APPEND @IDENTITY {%cty}{%temp}INTCN =  {%cty}BETAENGY{%temp}*{%cty}NV{%nonen}CN ' Energy intermediate inputs for each industry (current prices)
	next

	{%cty}.APPEND @IDENTITY {%cty}NVENGOUTPKN = {%cty}NVENGTOTLKN+{%cty}AGRINTKN+{%cty}INDINTKN+{%cty}ENGINTKN+{%cty}SRVINTKN

	{%cty}.APPEND @IDENTITY {%cty}NVENGOUTPCN = {%cty}NVENGTOTLCN+{%cty}AGRINTCN+{%cty}INDINTCN+{%cty}ENGINTCN+{%cty}SRVINTCN

'***************************************************************************
'***    AIR POLLUTION MODULE ***
'***************************************************************************

	'{%cty}.append @identity {%cty}PM25= {%cty}PM25(-1)+D(({%cty}NVCOLPRODQN+{%cty}NVCOLNIMPQN)*0.0000535+({%cty}NVOILPRODQN+ {%cty}NVOILNIMPQN)*0.000353+({%cty}NVGASPRODQN+{%cty}NVGASNIMPQN)*0.0000296) 'Total PM 2.5 concentration
	{%cty}.append @identity {%cty}WDL={%cty}SPPOP1564TO*3.7*(1-exp(-0.0046*{%cty}PM25)) 'Million working days lost
	'{%cty}.append @identity {%cty}APDEATHS=0.000025*({%cty}SPPOPTOTL*1000000)*({%cty}PM25-4.15) 'Air pollution deaths
	
	smpl 1990 %end_estimate
	equation _{%cty}HEAPCN.LS DLOG({%cty}HEAPCN)=C(1)-0.3*(LOG({%cty}HEAPCN(-1))-LOG({%cty}PM25(-1)))+1*DLOG({%cty}PM25)

	smpl @all
		series {%cty}GGEXPOTHRCN = {%cty}ggexptotlcn - ({%cty}ggexpwagecn  + {%cty}GGEXPGNFSCN  + {%cty}GGEXPINTPCN  + {%cty}GGEXPTRNSCN  + {%cty}GGEXPCAPTCN+{%cty}HEAPCN)
	'{%cty}.append @identity  {%cty}ggexptotlcn = {%cty}GGEXPOTHRCN + ({%cty}ggexpwagecn  + {%cty}GGEXPGNFSCN  + {%cty}GGEXPINTPCN  + {%cty}GGEXPTRNSCN  + {%cty}GGEXPCAPTCN+{%cty}HEAPCN)
	BGD.append @IDENTITY BGDGGEXPTOTLCN = BGDGGEXPCRNTCN + BGDGGEXPCAPTCN + BGDGGEXPOTHRCN + {%cty}HEAPCN 
	
	smpl 1990 %end_estimate
	equation _{%cty}LMWAPOPKN.LS dlog({%cty}LMWAPOPKN) = C(1)-0.3*(log({%cty}LMWAPOPKN(-1))-log({%cty}SPPOP1564TO(-1)-{%cty}WDL(-1)/240))+dlog({%cty}SPPOP1564TO-{%cty}WDL/240)

	'{%cty}.append @identity {%cty}LMUNRTOTL_ = (1-{%cty}LMEMPTOTL/{%cty}LMWAPOPKN)*100
	{%cty}.append @identity {%cty}LMUNRTOTL_ = (1-{%cty}LMEMPTOTL/({%cty}LMPRTTOTL_/100*{%cty}SPPOP1564TO))*100
	{%cty}.append @identity {%cty}LMEMPSTRL = (1-{%cty}LMUNRSTRL_/100)*({%cty}LMWAPOPKN)
	{%cty}.append @identity {%cty}LMPRTSTRL_ = ({%cty}LMWAPOPKN/{%cty}SPPOP1564TO)*100

' Electricity quantities
	{%cty}.append @identity {%cty}nvoileleqn = {%cty}neoilconelcn/(scalingf*((wldfcrude_petro*1000)*convbbltoe*{%cty}panusatls/1000000+{%cty}ggrevco2oer*(emisoil*1000)*({%cty}panusatls/1000000))) 
	{%cty}.append @identity {%cty}nvcoleleqn = {%cty}necolconelcn/(scalingf*((wldfcoal_aus*1000)*convmttoe*{%cty}panusatls/1000000+{%cty}ggrevco2cer*(emiscoal*1000)*({%cty}panusatls/1000000)))
	{%cty}.append @identity {%cty}nvgaseleqn = {%cty}negasconelcn/(scalingf*((wldfngas_eur*1000)*convmmbtutoe*1*{%cty}panusatls/1000000+{%cty}ggrevco2ger*(emisgas*1000)*({%cty}panusatls/1000000)))
	{%cty}.append @identity {%cty}nvreneleqn = {%cty}nerenconelcn/(scalingf*(wldhydropower*1000)*convkwhtoe*{%cty}panusatls/1000000)

' Consumption quantities
	smpl @all
	series {%cty}nvcolconsqn = {%cty}nvcolprodqn+{%cty}nvcolnimpqn
	series {%cty}nvoilconsqn = {%cty}nvoilprodqn+{%cty}nvoilnimpqn
	series {%cty}nvgasconsqn = {%cty}nvgasprodqn+{%cty}nvgasnimpqn
	series {%cty}nvrenconsqn = {%cty}nvrenprodqn+{%cty}nvrennimpqn

	{%cty}.append @identity {%cty}nvcolconsqn = {%cty}nvcolprodqn+{%cty}nvcolnimpqn
	{%cty}.append @identity {%cty}nvoilconsqn = {%cty}nvoilprodqn+{%cty}nvoilnimpqn
	{%cty}.append @identity {%cty}nvgasconsqn = {%cty}nvgasprodqn+{%cty}nvgasnimpqn
	{%cty}.append @identity {%cty}nvrenconsqn = {%cty}nvrenprodqn+{%cty}nvrennimpqn


' TASKS: MAKE SURE THAT HEAPCN enters HH consumption
	smpl 1990 %end_estimate
	equation _{%cty}NECONGOVTCN.LS @PC({%cty}NECONGOVTCN) = @PC({%cty}GGEXPGNFSCN+{%cty}GGEXPWAGECN+{%cty}HEAPCN) + C(1)*DUMH
	smpl @all

