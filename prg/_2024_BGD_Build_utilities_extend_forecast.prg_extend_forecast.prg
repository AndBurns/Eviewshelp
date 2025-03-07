'#################################################################
' SUBROUTINE extend_forecast
'	string i_cty : name of the country
'	string i_fcst_start : forecast period start
'	string i_fcst_end : forecast period end
'	string l_constant : list of constant variables
'	string l_value : list of variables in value
'	string l_value : list of variables in value (external where there are addtional forecast)
'	string l_volume : list of variables in volume 
'	string l_price : list of price variables
'	string l_wage : list of wage variables
'	string l_population : list of population variables
'	string l_dummy : list of DUMH variables
'	scalar i_inflexpt : long-term growth rate of prices
'	scalar i_popgrowth : long-term growth rate of population
'	scalar i_tfpgrowth : long-term growth rate of TFP
'	scalar i_labshare : share of labor in production
'
' Description : extend data in the forecast period according to their type
' Return : a string _extended_forecast is returned for all the variables that have been extended
'#################################################################
subroutine extend_forecast(string i_cty,string i_fcst_start, string i_fcst_end, string l_constant, string l_value, string l_volume,string l_price, string l_wage, string l_population, string l_dummy, scalar i_inflexpt, scalar i_tfpgrowth, scalar i_labshare) ', scalar i_popgrowth
	string _extended_forecast = ""
	
	%buff_start = i_fcst_start
	%buff_end = i_fcst_end
	
	%buff_cty = i_cty
	
	'Constant
		%buff = l_constant
		if @wcount(%buff)>0 then
			for %var {%buff}
				smpl %buff_start %buff_end
				{%var} = {%var}(-1)
			next
		endif
		_extended_forecast = _extended_forecast + " " + l_constant

	'Volume
		%buff = l_volume
		if @wcount(%buff)>0 then
			for %var {%buff}
				smpl %buff_start %buff_end
				{%var} = {%var}(-1)*(1+i_tfpgrowth/100)^(1/i_labshare)*(1+@pc({%cty}SPPOPTOTL)/100)
			next
		endif
		_extended_forecast = _extended_forecast + " " + l_volume


	'Price
		%buff = l_price
		if @wcount(%buff)>0 then
			for %var {%buff}
				smpl %buff_start %buff_end
				{%var} = {%var}(-1)*(1+i_inflexpt/100)
			next
		endif
		_extended_forecast = _extended_forecast + " " + l_price

	'Value
		%buff = l_value
		if @wcount(%buff)>0 then
			for %var {%buff}
				smpl %buff_start %buff_end
				{%var} = {%var}(-1)*(1+i_tfpgrowth/100)^(1/i_labshare)*(1+@pc({%cty}SPPOPTOTL)/100)*(1+i_inflexpt/100)
			next
		endif
		_extended_forecast = _extended_forecast + " " + l_value

	'Wage
		%buff = l_wage
		if @wcount(%buff)>0 then
			for %var {%buff}
				smpl %buff_start %buff_end
				{%var} = {%var}(-1)*(1+i_tfpgrowth/100)^(1/i_labshare)*(1+i_inflexpt/100)
			next
		endif
		_extended_forecast = _extended_forecast + " " + l_wage

'	'Population - now use entered in spreadsheet
'		%buff = l_population
'		if @wcount(%buff)>0 then
'			for %var {%buff}
'				smpl %buff_start %buff_end
'				{%var} = {%var}(-1)*(1+i_popgrowth/100)
'			next
'		endif
		_extended_forecast = _extended_forecast + " " + l_population
		
	'Dummies
		%buff = l_dummy
		if @wcount(%buff)>0 then
			for %var {%buff}
				smpl %buff_start %buff_end
				{%var} = 0
			next
		endif
		_extended_forecast = _extended_forecast + " " + l_dummy
	
	'TFP
		if @isobject(%buff_cty + "NYGDPTFP")=1 then
			smpl %buff_start %buff_end
			{%buff_cty}NYGDPTFP = {%buff_cty}NYGDPTFP(-1)*(1+i_tfpgrowth/100)
		endif
		_extended_forecast = _extended_forecast + " " + %buff_cty + "NYGDPTFP"
endsub


