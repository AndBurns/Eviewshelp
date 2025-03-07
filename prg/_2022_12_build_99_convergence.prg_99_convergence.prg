smpl %forecast_start-4 %forecast_end

string convergence ="nygdpmktp nygdpfcst neconprvt necongovt negdiftot negdifprv negdifgov neexpgnfs neimpgnfs"
string convergenceRealOnly = ""
string convergenceNominalOnly = ""
string convergencePriceOnly = "nekrttotl"
string convergenceSingleOnly = "nygdppotlkd"

'**************************************************************************
' CONSTRUCTION PLOT VARIABLES
'**************************************************************************
convergence = @wcross(%cty, @upper(convergence))

%temp_real = @wcross(convergence, "KN")
%temp_price = @wcross(convergence, "XN")
%temp_nominal = @wcross(convergence, "CN")
convergenceSingleOnly = @wcross(%cty, @upper(convergenceSingleOnly))

%temp_real = %temp_real + " " + @wcross(@wcross(%cty, @upper(convergenceRealOnly)), "KN")
%temp_nominal = %temp_nominal + " " + @wcross(@wcross(%cty, @upper(convergenceNominalOnly)), "CN")
%temp_price = %temp_price + " " + @wcross(@wcross(%cty, @upper(convergencePriceOnly)), "XN")

delete(noerr) report
delete(noerr) _convergence_*

spool report
!i = 0

'**************************************************************************
' PLOT REAL VARIABLES
'**************************************************************************
%ttpot=%cty+"NYGDPPOTLKN"

for %tt {%temp_real}
	!i = !i + 1
	call plot_convergence(%tt,%ttpot,%tt,!i,"g","g")
next

'**************************************************************************
' PLOT NOMINAL VARIABLES
'**************************************************************************
for %tt {%temp_nominal}
	!i = !i + 1
	call plot_convergence(%tt,"NA",%tt,!i,"g","g")
next

'**************************************************************************
' PLOT SINGLE VARIABLES
'**************************************************************************
for %tt {convergenceSingleOnly}
	!i = !i + 1
	call plot_convergence(%tt,"NA",%tt,!i,"g","g")
next

'**************************************************************************
' PLOT PRICE VARIABLES
'**************************************************************************
%ttinfl=%cty+"INFLEXPT"

for %tt {%temp_price}
	!i = !i + 1
	call plot_convergence(%tt,%ttinfl,%tt,!i,"g","l")
next

'**************************************************************************
' PLOT OUTPUT GAP
'**************************************************************************
!i = !i + 1
%tt=%cty+"NYGDPGAP_"

call plot_convergence(%tt,"NA",%tt,!i,"l","l")

'**************************************************************************
' PLOT FX
'**************************************************************************
!i = !i + 1
%tt=%cty+"PANUSATLS"

call plot_convergence(%tt,"NA",%tt,!i,"g","g")

'**************************************************************************
' PLOT POTENTIAL
'**************************************************************************
!i = !i + 1
%tt=%cty+"NYGDPPOTLKN"
%tt2=%cty+"NYGDPMKTPKN"

call plot_convergence(%tt,%tt2,%tt,!i,"g","g")


'**************************************************************************
' PLOT UNEMPLOYMENT
'**************************************************************************
!i = !i + 1
%tt=%cty+"LMUNRTOTL_"
%tt2=%cty+"LMUNRSTRL_"

call plot_convergence(%tt,%tt2,%tt,!i,"l","l")

'**************************************************************************
' PLOT DEBT
'**************************************************************************
!i = !i + 1
%tt="(BGDGGDBTTOTLCN/BGDNYGDPMKTPCN)*100"
%tt2="(BGDBNCABFUNDCD/BGDNYGDPMKTPCD)*100"

call plot_convergence(%tt,%tt2,"DY",!i,"l","l")

'**************************************************************************
' PLOT FISCAL
'**************************************************************************
!i = !i + 1
%tt="(BGDGGREVTOTLCN/BGDNYGDPMKTPCN)*100"
%tt2="(BGDGGEXPTOTLCN/BGDNYGDPMKTPCN)*100"

call plot_convergence(%tt,%tt2,"Fiscal",!i,"l","l")

'**************************************************************************
' PLOT SECTORS - contribution to GVA
'**************************************************************************
	!i = !i + 1
	group VA_BLOCK 100*(({%cty}NVAGRTOTLKN_0)/{%cty}NYGDPFCSTKN_0) 100*(({%cty}NVINDOTHRKN_0)/{%cty}NYGDPFCSTKN_0) 100*(({%cty}NVENGTOTLKN_0)/{%cty}NYGDPFCSTKN_0) 100*(({%cty}NVSRVTOTLKN_0)/{%cty}NYGDPFCSTKN_0)

	freeze(graph3e) VA_BLOCK.bar(s)
	graph3e.options fillcolor(WHITE) backcolor(WHITE) -INBOX  BACKFADE(NONE) 'linepat
	graph3e.options stackposneg
	'graph3e.setelem(1) linecolor(0,0,0) lwidth(2) lpat(2) 'symbol(15)
	graph3e.setelem(1) fillcolor(0,171,255)
	graph3e.setelem(2) fillcolor(0,64,128) 'fillhatch(DIAGCROSS)
	graph3e.setelem(3) fillcolor(128,0,64)
	graph3e.setelem(4) fillcolor(255,255,0)
	'graph3e.NAME(1) GVA
	graph3e.NAME(1) AGR
	graph3e.NAME(2) IND (OTHR)
	graph3e.NAME(3) IND (ENE)
	graph3e.NAME(4) SRV
	graph3e.addtext(2,-0.4,font(16)) Value added composition
	graph3e.addtext(l) % Share of GVA 
	graph3e.legend font("Times", 16) 
	graph3e.legend position(3,0) -inbox
	graph3e.axis(l) range(0,100)
	
	report.append graph3e

	if {!i}<10 then 
		report.name untitled0{!i} VA Shares
	endif
	
'**************************************************************************
' PLOT ELECTRICITY - Shares
'**************************************************************************
	!i = !i + 1
	group ENE_BLOCK2022 ({%cty}nvcoleleqn_0/({%cty}nvcoleleqn_0+{%cty}nvoileleqn_0+{%cty}nvgaseleqn_0+{%cty}nvreneleqn_0))*100 ({%cty}nvoileleqn_0/({%cty}nvcoleleqn_0+{%cty}nvoileleqn_0+{%cty}nvgaseleqn_0+{%cty}nvreneleqn_0))*100 ({%cty}nvgaseleqn_0/({%cty}nvcoleleqn_0+{%cty}nvoileleqn_0+{%cty}nvgaseleqn_0+{%cty}nvreneleqn_0))*100 ({%cty}nvreneleqn_0/({%cty}nvcoleleqn_0+{%cty}nvoileleqn_0+{%cty}nvgaseleqn_0+{%cty}nvreneleqn_0))*100

	freeze(graph3h) ENE_BLOCK2022.bar(s)
	graph3h.options fillcolor(WHITE) backcolor(WHITE) -INBOX  BACKFADE(NONE) 'bar
	graph3h.setelem(1) fillcolor(0,171,255)
	graph3h.setelem(2) fillcolor(0,64,128) 'fillhatch(DIAGCROSS)
	graph3h.setelem(3) fillcolor(128,0,64)
	graph3h.setelem(4) fillcolor(255,255,0)
	graph3h.NAME(1) Coal
	graph3h.NAME(2) Oil
	graph3h.NAME(3) Gas
	graph3h.NAME(4) Ren
	graph3h.addtext(2,-0.4,font(16)) Electricity composition
	graph3h.addtext(l) % total electricity
	graph3h.legend font("Times", 16) 
	graph3h.legend position(3,0) -inbox
	graph3h.axis(l) range(0,100)
	
	report.append graph3h

	if {!i}<10 then 
		report.name untitled0{!i} VA Shares
	endif
	
	show report

'**************************************************************************
'**************************************************************************
subroutine plot_convergence(string %var1,string %var2,string %title,scalar !i, string %display, string %display2)
	if (%display = "g") then
		if (%var2 = "NA") then
			graph _convergence_{!i} ({%var1}/{%var1}(-1)-1)*100 0
		else
			if (%display2 = "g") then
				graph _convergence_{!i} ({%var1}/{%var1}(-1)-1)*100 ({%var2}/{%var2}(-1)-1)*100 0
			else
				if (%display2 = "l") then
					graph _convergence_{!i} ({%var1}/{%var1}(-1)-1)*100 {%var2} 0
				endif
			endif
		endif
	else
		if (%display = "l") then
			if (%var2 = "NA") then
				graph _convergence_{!i} {%var1} 0
			else
				if (%display2 = "g") then
					graph _convergence_{!i} {%var1} ({%var2}/{%var2}(-1)-1)*100 0
				else
					if (%display2 = "l") then
						graph _convergence_{!i} {%var1} {%var2} 0
					endif
				endif
			endif
		endif
	endif
	
	_convergence_{!i}.options linepat fillcolor(WHITE) backcolor(WHITE) -INBOX  BACKFADE(NONE)
	_convergence_{!i}.addtext(t, font(+b,16)) {%title}
	

	
	if (%display = "g") then
		_convergence_{!i}.name(1) {%var1} (growth)
		
		if (%var2 <> "NA") then
			if (%display2 = "g") then
				_convergence_{!i}.name(2) {%var2} (growth)
			else
				if (%display2 = "l") then
					_convergence_{!i}.name(2) {%var2} (level)
				endif
			endif
		endif
	else
		if (%display = "l") then
			_convergence_{!i}.name(1) {%var1} (level)
			
			if (%var2 <> "NA") then
				if (%display2 = "g") then
					_convergence_{!i}.name(2) {%var2} (growth)
				else
					if (%display2 = "l") then
						_convergence_{!i}.name(2) {%var2} (level)
					endif
				endif
			endif
		endif
	endif
	
	_convergence_{!i}.draw(shade, bottom, rgb(234,234,234)) {%begin_date} {%forecast_start}

	report.append _convergence_{!i}

	if {!i}<10 then 
		report.name untitled0{!i} {%title}
	else
		report.name untitled{!i} {%title}
	endif
endsub


