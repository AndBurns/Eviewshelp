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
		report.name untitled0{!i} {%var1}
	else
		report.name untitled{!i} {%var1}
	endif
endsub