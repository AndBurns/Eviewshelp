'*******************************************************
' Potential GDP
'*******************************************************
	smpl @all
	'Structural employment
	BGD.append @identity BGDLMEMPSTRL = (1-BGDLMUNRSTRL_/100)*(BGDLMPRTSTRL_/100)*BGDSPPOP1564TO ' Structural employment
	'Capital stock
	BGD.append @IDENTITY BGDNEGDIKSTKKN = BGDNEGDIKSTKKN(-1) * (1 - BGDDEPR / 100) + BGDNEGDIFTOTKN
	'Cost of capital
	BGD.append @IDENTITY BGDNEKRTTOTLXN = BGDNEGDIFTOTXN/100 * (BGDFMLBLPOLYFR + BGDNEKRTPREMFR + BGDDEPR - BGDINFLEXPT)
	' Nominal marginal cost
	BGD.append @IDENTITY BGDPSTAR  = (BGDNYWRTTOTLXN^BGDNYYWBTOTLCN_  * BGDNEKRTTOTLXN^(1  - BGDNYYWBTOTLCN_))  / (BGDNYGDPTFP  * BGDNYYWBTOTLCN_^BGDNYYWBTOTLCN_  * (1  - BGDNYYWBTOTLCN_)^(1  - BGDNYYWBTOTLCN_)) 
	'GDP potential LCU
	BGD.append @IDENTITY BGDNYGDPPOTLKN = (BGDNYGDPTFP  * BGDLMEMPSTRL^BGDNYYWBTOTLCN_  * BGDNEGDIKSTKKN(-1)^(1-BGDNYYWBTOTLCN_))
	'GDP potential USD 
	BGD.append @IDENTITY BGDNYGDPPOTLKD = (BGDNYGDPPOTLKN * (@elem(BGDNYGDPMKTPCN , 2016) / (@elem(BGDNYGDPMKTPKN , 2016)))) / @elem(BGDPANUSATLS , 2016)
	'GDP gap
	BGD.append @IDENTITY BGDNYGDPGAP_ = ((BGDNYGDPMKTPKN / BGDNYGDPPOTLKN - 1) * 100)
	
'*******************************************************
' Per capita GDP
'*******************************************************	
	smpl @all
	'LCU
	BGD.append @IDENTITY BGDGDPPCKN = (BGDNYGDPMKTPKN / BGDSPPOPTOTL)
	'USD
	BGD.append @IDENTITY BGDGDPPCKD = (BGDNYGDPMKTPKD / BGDSPPOPTOTL)
		
'*******************************************************
' NIA-Expenditures  -VOLUMES
'*******************************************************
	smpl @all
	'GDP Indentity
	BGD.append @IDENTITY BGDNYGDPMKTPKN = BGDNECONPRVTKN + BGDNECONGOVTKN + BGDNEGDIFTOTKN + BGDNEGDISTKBKN + BGDNEEXPGNFSKN - BGDNEIMPGNFSKN + BGDNYGDPDISCKN
	'GDE identity
	BGD.append @IDENTITY BGDNEGDETTOTKN = (BGDNECONPRVTKN + BGDNECONGOVTKN + BGDNEGDIFTOTKN + BGDNEGDISTKBKN + BGDNYGDPDISCKN)  
	'Total investment
	BGD.append @IDENTITY BGDNEGDIFTOTKN = BGDNEGDIFGOVKN + BGDNEGDIFPRVKN
	'Public investment	
	BGD.append @IDENTITY BGDNEGDIFGOVKN = BGDNEGDIFGOVCN / BGDNEGDIFGOVXN
	'Government consumption
	BGD.append @IDENTITY BGDNECONGOVTKN = BGDNECONGOVTCN / BGDNECONGOVTXN
	'Private consumption (behavioral equation)
	smpl 1986 %end_estimate
	c = 0
	equation _BGDNECONPRVTKN.LS DLOG(BGDNECONPRVTKN) = C(1) +  C(2) * (LOG(BGDNECONPRVTKN(-1)) - LOG((BGDNYYWBTOTLCN(-1)*(1-BGDGGREVDRCTER(-1)/100)+BGDBXFSTREMTCD(-1)*BGDPANUSATLS(-1)+BGDGGEXPTRNSCN(-1))/BGDNECONPRVTXN(-1))) + C(3) * DLOG((BGDNYYWBTOTLCN*(1-BGDGGREVDRCTER/100)+BGDBXFSTREMTCD*BGDPANUSATLS+BGDGGEXPTRNSCN)/BGDNECONPRVTXN)
	'Private investment (behavioral equation)
	smpl 1993 %end_estimate
	c = 0
equation _BGDNEGDIFPRVKN.LS DLOG(BGDNEGDIFPRVKN) =  -0.2* (LOG(BGDNEGDIFPRVKN(-1)) - LOG(1-BGDNYYWBTOTLCN_(-1)) - LOG(BGDNYGDPPOTLKN(-1)) + LOG(BGDNEKRTTOTLXN(-1)/BGDNYGDPCPSHXN(-1))- C(1)) +c(10)* DLOG(BGDNYGDPMKTPKN) - 0.3* DLOG(BGDNEKRTTOTLXN/BGDNEGDIFPRVXN)  
	'Exports (behavioral equation)
	smpl 1990 %end_estimate
	C(1)=60
	equation _bgdneexpgnfskn.LS DLOG(BGDNEEXPGNFSKN) =  -c(2)* (LOG(BGDNEEXPGNFSKN(-1)) - LOG(BGDXMKT(-1)) - C(4)*@DURING("1990 2011" )  - c(5) *LOG(BGDNEEXPGNFSXN(-1)/BGDNYGDPCPSHXN(-1))-log(@abs(c(1)))) + c(10) * DLOG(BGDNEEXPGNFSXN/(BGDNYGDPCPSHXN)) + c(11) * DLOG(BGDXMKT)

	'Imports (behavioural equation)
	smpl 1980 %end_estimate
	C(1)=.2
	equation _BGDNEIMPGNFSKN.ls dlog(bgdneimpgnfskn) = -c(2)*(log(bgdneimpgnfskn(-1))-log(bgdnegdettotkn(-1))+c(3)*log(bgdneimpgnfsxn(-1)/BGDNYGDPCPSHXN(-1))-c(4)*@during("1980 1994")-c(5)*@during("1995 2009")-log(abs(c(1))))-c(10)*dlog(bgdneimpgnfsxn/bgdneconprvtkn)+1.7*dlog(bgdnegdettotkn)

			
'*******************************************************
' NIA-Expenditures  -PRICES
'*******************************************************
	'Consumer price deflator  (behavioural equation)
	smpl 1997 %end_estimate
	c = 0
	equation _BGDNECONPRVTXN.LS DLOG(BGDNECONPRVTXN) = C(1) - C(2) * (LOG(BGDNECONPRVTXN(-1)) - 0.7 * LOG(BGDNYGDPCPSHXN(-1)) - (1-0.7) * LOG(BGDNEIMPGNFSXN(-1)) - LOG((1+BGDGGREVTVATER(-1)/100)*(1+BGDGGREVEXCDER(-1)/100))) + 0.7* DLOG(BGDNYGDPCPSHXN) + (1-0.7) * DLOG(BGDNEIMPGNFSXN) + DLOG((1+BGDGGREVTVATER/100)*(1+BGDGGREVEXCDER/100)) + C(10) * @DURING("1980 2002") + 0.15 * BGDNYGDPGAP_/100

	'Government price deflator (behavioural equation)
	smpl %begin_date %end_estimate
	c = 0
	equation _BGDNECONGOVTXN.LS DLOG(BGDNECONGOVTXN) = C(1) -0.1 * (LOG(BGDNECONGOVTXN(-1)) - LOG(BGDNECONPRVTXN(-1))) + C(10)* DLOG(BGDNECONPRVTXN)+C(11)*@DURING("1981 1982")
	'Public investment deflator (behavioural equation)
	smpl %begin_date %end_estimate
	c = 0
	equation _BGDNEGDIFGOVXN.LS(OPTMETHOD=LEGACY) DLOG(BGDNEGDIFGOVXN) = C(1) - 0.1 * (LOG(BGDNEGDIFGOVXN(-1)) - LOG(BGDNECONPRVTXN(-1))) + C(10)* DLOG(BGDNECONPRVTXN)+C(11)*@DURING("1987")+C(12)*@DURING("1997")+C(13)*@DURING("2000")
	'Private investment deflator (behavioural equation)
	smpl 2000 %end_estimate
	c = 0
equation _BGDNEGDIFPRVXN.LS DLOG(BGDNEGDIFPRVXN) = C(1) -C(2)* (LOG(BGDNEGDIFPRVXN(-1)) - LOG(BGDNECONPRVTXN(-1))) + C(10) * DLOG(BGDNECONPRVTXN)  + C(11) * @DURING("2008")
	'Export deflator (behavioural equation)
	smpl %begin_date %end_estimate
	c = 0
	equation _BGDNEEXPGNFSXN.LS DLOG(BGDNEEXPGNFSXN) = C(1) -0.1* (LOG(BGDNEEXPGNFSXN(-1)) - 0.84 * LOG((1+BGDGGREVEXPDER(-1)/100)*BGDNYGDPCPSHXN(-1)) - (1-0.84) * LOG((1+BGDGGREVEXPDER(-1)/100)*BGDPXKEY(-1)*BGDPANUSATLS(-1))) + 0.83 * DLOG((1+BGDGGREVEXPDER/100)*BGDNYGDPCPSHXN) + (1-0.83) * DLOG((1+BGDGGREVEXPDER(-1)/100)*BGDPXKEY*BGDPANUSATLS)+ C(10) * @DURING("2004")+C(11)*@DURING("2005 2018")
	'Import deflator (behavioural equation)	
	smpl %begin_date %end_estimate
	c = 0
	equation _BGDNEIMPGNFSXN.LS DLOG(BGDNEIMPGNFSXN) = C(1) -0.1* (LOG(BGDNEIMPGNFSXN(-1)) - 0.5* LOG(BGDNECONPRVTXN(-1)/(1+BGDGGREVTVATER(-1)/100)) - (1-0.5) * LOG((1+BGDGGREVIMPDER(-1)/100)*BGDPMKEY(-1)*BGDPANUSATLS(-1))) + 0.5 * DLOG(BGDNECONPRVTXN/(1+BGDGGREVTVATER/100)) + (1-0.5) * DLOG((1+BGDGGREVIMPDER/100)*BGDPMKEY*BGDPANUSATLS)   + C(10) * @DURING("2009") + C(11) * @DURING("2015")
	'CPI  (behavioural equation)	
	smpl 2008 2019
	C = 0
	equation _BGDFPCPITOTLXN.LS DLOG(BGDFPCPITOTLXN)= -0.2*(LOG(BGDFPCPITOTLXN(-1)) - LOG(BGDNECONPRVTXN(-1)) +C(1)) + C(10)*DLOG(BGDNECONPRVTXN) '+ C(11)*BGDNYGDPGAP_
	'Total investment deflator 
	BGD.append @IDENTITY BGDNEGDIFTOTXN = BGDNEGDIFTOTCN / BGDNEGDIFTOTKN
	'Total GDP deflator
	BGD.append @IDENTITY BGDNYGDPMKTPXN = BGDNYGDPMKTPCN / BGDNYGDPMKTPKN

'*******************************************************
' NIA-Expenditures  -VALUES
'*******************************************************
	'GDP market price
	BGD.append @IDENTITY BGDNYGDPMKTPCN = BGDNECONPRVTCN + BGDNECONGOVTCN + BGDNEGDIFTOTCN + BGDNEGDISTKBCN + BGDNEEXPGNFSCN - BGDNEIMPGNFSCN + BGDNYGDPDISCCN
	'GDE	
	BGD.append @IDENTITY BGDNEGDETTOTCN = (BGDNECONPRVTCN + BGDNECONGOVTCN + BGDNEGDIFTOTCN + BGDNEGDISTKBCN + BGDNYGDPDISCCN)
	'Private consumption
	BGD.append @IDENTITY BGDNECONPRVTCN = BGDNECONPRVTKN * BGDNECONPRVTXN
	'Total investment		
	BGD.append @IDENTITY BGDNEGDIFTOTCN = BGDNEGDIFGOVCN + BGDNEGDIFPRVCN
	'Private investment
	BGD.append @IDENTITY BGDNEGDIFPRVCN = BGDNEGDIFPRVKN * BGDNEGDIFPRVXN
	'Exports
	BGD.append @IDENTITY BGDNEEXPGNFSCN = BGDNEEXPGNFSKN * BGDNEEXPGNFSXN
	'Imports
	BGD.append @IDENTITY BGDNEIMPGNFSCN = BGDNEIMPGNFSKN * BGDNEIMPGNFSXN
	'Government consumption (quasi_identity) 
	smpl %begin_date %end_estimate
	c = 0
	equation _BGDNECONGOVTCN.LS @PC(BGDNECONGOVTCN) = @PC(BGDGGEXPGNFSCN+BGDGGEXPWAGECN) + C(1)*DUMH
	'Public investment (quasi_identity)
	smpl %begin_date %end_estimate
	c = 0
	equation _BGDNEGDIFGOVCN.LS @PC(BGDNEGDIFGOVCN) = @PC(BGDGGEXPCAPTCN) + C(1)*DUMH

'*******************************************************
' NIA-Expenditures  -USD CONVERSION
'*******************************************************
	BGD.append @IDENTITY BGDNEEXPGNFSCD = BGDNEEXPGNFSCN / BGDPANUSATLS
	BGD.append @IDENTITY BGDNEIMPGNFSCD = BGDNEIMPGNFSCN / BGDPANUSATLS

	BGD.append @IDENTITY BGDNEEXPGNFSKD = (BGDNEEXPGNFSKN * (@ELEM(BGDNEEXPGNFSCN , 2016) / (@ELEM(BGDNEEXPGNFSKN , 2016)))) / @ELEM(BGDPANUSATLS , 2016)
	BGD.append @IDENTITY BGDNEIMPGNFSKD = (BGDNEIMPGNFSKN * (@ELEM(BGDNEIMPGNFSCN , 2016) / (@ELEM(BGDNEIMPGNFSKN , 2016)))) / @ELEM(BGDPANUSATLS , 2016)

	BGD.append @IDENTITY BGDNEEXPGNFSXD = (BGDNEEXPGNFSCD / BGDNEEXPGNFSKD)
	BGD.append @IDENTITY BGDNEIMPGNFSXD = (BGDNEIMPGNFSCD / BGDNEIMPGNFSKD)

	BGD.append @IDENTITY BGDNYGDPMKTPCD = BGDNYGDPMKTPCN / BGDPANUSATLS
	BGD.append @IDENTITY BGDNYGDPMKTPKD = (BGDNYGDPMKTPKN * (@ELEM(BGDNYGDPMKTPCN , 2016) / (@ELEM(BGDNYGDPMKTPKN , 2016)))) / @ELEM(BGDPANUSATLS , 2016)
	BGD.append @IDENTITY BGDNYGDPMKTPXD = (BGDNYGDPMKTPCD / BGDNYGDPMKTPKD)


'*******************************************************
' LABOR MARKET
'*******************************************************
	'Wage rate
	c=0
	smpl %begin_date %end_estimate
	equation _BGDNYWRTTOTLXN.LS DLOG(BGDNYWRTTOTLXN) = (C(1)*BGDINFLEXPT/100+(1-C(1))*DLOG(BGDNYGDPCPSHXN(-1))+DLOG(BGDNYGDPPOTLKN/BGDLMEMPSTRL)) - 0.1*(BGDLMUNRTOTL_-BGDLMUNRSTRL_)/100
	' Employment
	 c=0
	smpl %begin_date %end_estimate
	equation _BGDLMEMPTOTL.LS DLOG(BGDLMEMPTOTL) =-0.2*(LOG(BGDLMEMPTOTL(-1))-LOG(BGDLMEMPSTRL(-1))) + DLOG(BGDLMEMPSTRL) - 0.1*(DLOG(BGDNYWRTTOTLXN/BGDNYGDPCPSHXN)-DLOG(BGDNYGDPPOTLKN/BGDLMEMPSTRL)) +0.2*(DLOG(BGDNEGDETTOTKN)-DLOG(BGDNYGDPPOTLKN))+C(4)
	' Participation rate
	c=0
	smpl %begin_date %end_estimate
	equation _BGDLMPRTTOTL_.LS BGDLMPRTTOTL_ = 0.5*(BGDLMPRTSTRL_) + (1-0.5)*(BGDLMPRTTOTL_(-1))+C(2)*@DURING("2017")
	'Unemployment rate
	BGD.append @identity BGDLMUNRTOTL_ = (1-BGDLMEMPTOTL/(BGDLMPRTTOTL_/100*BGDSPPOP1564TO))*100
	'Total wage bill
	BGD.append @IDENTITY BGDNYYWBTOTLCN = BGDNYWRTTOTLXN*BGDLMEMPTOTL


'*******************************************************
' NIA-Production - VOLUMES
'*******************************************************
	'Agriculture GVA
	smpl %begin_date %end_estimate
	c = 0
	equation _BGDNVAGRTOTLKN.LS DLOG(BGDNVAGRTOTLKN) = C(1) - 0.1* (LOG(BGDNVAGRTOTLKN(-1))-LOG(BGDNECONPRVTKN(-1)+BGDNECONGOVTKN(-1)+BGDNEGDIFTOTKN(-1))) + C(3) * DLOG(BGDNECONPRVTKN+BGDNECONGOVTKN+BGDNEGDIFTOTKN) + (1-C(3)) * DLOG(BGDNVAGRTOTLKN(-1)) + C(10) * T_LR
	'Industry GVA	
	smpl %begin_date %end_estimate
	c = 0
	equation _BGDNVINDTOTLKN.LS(OPTMETHOD=LEGACY) DLOG(BGDNVINDTOTLKN) = C(1) - 0.1 * (LOG(BGDNVINDTOTLKN(-1))-LOG(BGDNECONPRVTKN(-1)+BGDNECONGOVTKN(-1)+BGDNEGDIFTOTKN(-1)+BGDNEEXPGNFSKN(-1))) + C(3) * DLOG(BGDNECONPRVTKN+BGDNECONGOVTKN+BGDNEGDIFTOTKN+BGDNEEXPGNFSKN) + (1-C(3)) * DLOG(BGDNVINDTOTLKN(-1)) + C(10) * T_LR
	'Services are residuals
	BGD.append @IDENTITY BGDNVSRVTOTLKN = BGDNYGDPFCSTKN - BGDNVAGRTOTLKN - BGDNVINDTOTLKN	
	
'*******************************************************
' PRODUCER COSTS -PRICES
'*******************************************************
	'Factor cost price  (behavioural equation)	 *key price in the model*
	smpl 1986 %end_estimate
	c = 0
'equation _BGDNYGDPFCSTXN.LS DLOG(BGDNYGDPFCSTXN) = -0.3*(LOG(BGDNYGDPFCSTXN(-1))-LOG(BGDPSTAR(-1)))+C(2)+0.3*DLOG(BGDNYGDPFCSTXN(-1))+(1-0.3)*(0.7*(BGDINFLEXPT/100)+(1-0.7)*DLOG(BGDPSTAR(-1))) +0.35*BGDNYGDPGAP_/100

equation _BGDNYGDPCPSHXN.ls(optmethod=legacy) DLOG(BGDNYGDPCPSHXN) = -0.3*(LOG(BGDNYGDPCPSHXN(-1))-LOG(BGDPSTAR(-1)))+C(2)+0.3*DLOG(BGDNYGDPCPSHXN(-1))+(1-0.3)*(0.7*(BGDINFLEXPT/100)+(1-0.7)*DLOG(BGDPSTAR(-1))) +0.35*BGDNYGDPGAP_/100


'*******************************************************
' NIA-Production - PRICES
'*******************************************************			
	'Agriculture deflator (behavioural equation)	 
	smpl %begin_date %end_estimate
	c = 0
	equation _BGDNVAGRTOTLXN.LS(OPTMETHOD=LEGACY) DLOG(BGDNVAGRTOTLXN) = C(1) - 0.1* (LOG(BGDNVAGRTOTLXN(-1))-LOG(BGDNECONPRVTXN(-1))) + C(3) * DLOG(BGDNECONPRVTXN) + (1-C(3)) * DLOG(BGDNVAGRTOTLXN(-1))
	'Industry (behavioural equation)	 
	smpl %begin_date %end_estimate
	c = 0
	equation _BGDNVINDTOTLXN.LS(OPTMETHOD=LEGACY) DLOG(BGDNVINDTOTLXN) = C(1) - 0.1* (LOG(BGDNVINDTOTLXN(-1))-LOG(BGDNECONPRVTXN(-1))) + C(3) * DLOG(BGDNECONPRVTXN) + (1-C(3)) * DLOG(BGDNVINDTOTLXN(-1))
	'Services
	BGD.append @IDENTITY BGDNVSRVTOTLXN = BGDNVSRVTOTLCN / BGDNVSRVTOTLKN

'*******************************************************
' NIA-Production - VALUES 
'*******************************************************	
	BGD.append @IDENTITY BGDNVAGRTOTLCN = BGDNVAGRTOTLKN * BGDNVAGRTOTLXN
	BGD.append @IDENTITY BGDNVINDTOTLCN = BGDNVINDTOTLKN * BGDNVINDTOTLXN
	BGD.append @IDENTITY BGDNVSRVTOTLCN = BGDNYGDPFCSTCN - BGDNVAGRTOTLCN - BGDNVINDTOTLCN
		
'*******************************************************
' NIA-Production - TAXES 
'*******************************************************			
	smpl %begin_date  %end_estimate
	 c = 0
'	equation _BGDNYTAXNINDCN.ls BGDNYTAXNINDCN/BGDNYGDPMKTPCN =  C(1)
	equation _BGDNYTAXNINDCN.ls @pc(BGDNYTAXNINDCN)= @pc(BGDNYGDPMKTPCN) + C(1)*@DURING("2015")

	smpl %begin_date  %end_estimate
	c = 0
'	equation _BGDNYTAXNINDKN.ls BGDNYTAXNINDKN/BGDNYGDPMKTPKN =  C(1)
	equation _BGDNYTAXNINDKN.ls @pc(BGDNYTAXNINDKN)= @pc(BGDNYGDPMKTPKN) + C(1)*@DURING("2015")
			
'*******************************************************
' NIA-Production - AGGREGATES GDP FACTOR COST 
'*******************************************************	
	BGD.append @IDENTITY BGDNYGDPFCSTCN  = BGDNYGDPMKTPCN  - BGDNYTAXNINDCN
	BGD.append @IDENTITY BGDNYGDPFCSTKN  = BGDNYGDPMKTPKN  - BGDNYTAXNINDKN	
	BGD.append @IDENTITY BGDNYGDPFCSTXN  = BGDNYGDPFCSTCN  / BGDNYGDPFCSTKN

'*******************************************************
' FISCAL - REVENUES
'*******************************************************
		'TOTAL REVENES	
		BGD.append @IDENTITY BGDGGREVTOTLCN = BGDGGREVTAXTCN + BGDGGREVNONTCN + BGDGGREVGRNTCN + BGDGGREVOTHRCN
	
		'TAX REVENUES
			BGD.append @IDENTITY BGDGGREVTAXTCN = BGDGGREVIMPDCN + BGDGGREVEXPDCN + BGDGGREVTVATCN + BGDGGREVDRCTCN + BGDGGREVEXCDCN + BGDGGREVSUPDCN + BGDGGREVOTHDCN + BGDGGREVNNBRCN + BGDGGREVTOTHCN

			' Import duty
			BGD.append @IDENTITY BGDGGREVIMPDER = (BGDGGREVIMPDCN/BGDNEIMPGNFSCN)*100 
			equation _BGDGGREVIMPDCN.ls(optmethod=legacy)  BGDGGREVIMPDCN = c(1)*DUMH + (BGDGGREVIMPDER(-1)/100)*BGDNEIMPGNFSCN
			' Export duty
			BGD.append @IDENTITY BGDGGREVEXPDER = (BGDGGREVEXPDCN/BGDNEEXPGNFSCN)*100 
			equation _BGDGGREVEXPDCN.ls(optmethod=legacy)  BGDGGREVEXPDCN = c(1)*DUMH + (BGDGGREVEXPDER(-1)/100)*BGDNEEXPGNFSCN
			' VAT
			BGD.append @IDENTITY BGDGGREVTVATER = (BGDGGREVTVATCN/(BGDNECONPRVTCN + BGDNECONGOVTCN) )*100
			equation _BGDGGREVTVATCN.ls(optmethod=legacy)  BGDGGREVTVATCN = c(1)*DUMH + (BGDGGREVTVATER(-1)/100)*(BGDNECONPRVTCN + BGDNECONGOVTCN) 
			' Excise duties
			BGD.append @IDENTITY BGDGGREVEXCDER = (BGDGGREVEXCDCN/(BGDNECONPRVTCN + BGDNECONGOVTCN))*100
			equation _BGDGGREVEXCDCN.ls(optmethod=legacy)  BGDGGREVEXCDCN = c(1)*DUMH + (BGDGGREVEXCDER(-1)/100)*(BGDNECONPRVTCN + BGDNECONGOVTCN) 
			' Direct Tax
			BGD.append @IDENTITY BGDGGREVDRCTER = (BGDGGREVDRCTCN/BGDNYGDPMKTPCN)*100
			equation _BGDGGREVDRCTCN.ls(optmethod=legacy)  BGDGGREVDRCTCN = c(1)*DUMH + (BGDGGREVDRCTER(-1)/100)*BGDNYGDPMKTPCN
			' Supplementary duties
			BGD.append @IDENTITY BGDGGREVSUPDER = (BGDGGREVSUPDCN/(BGDNECONPRVTCN + BGDNECONGOVTCN) )*100
			equation _BGDGGREVSUPDCN.ls(optmethod=legacy)  BGDGGREVSUPDCN = c(1)*DUMH + (BGDGGREVSUPDER(-1)/100)*(BGDNECONPRVTCN + BGDNECONGOVTCN) 
			' Other taxes and duties
			BGD.append @IDENTITY BGDGGREVOTHDER = (BGDGGREVOTHDCN/BGDNYGDPMKTPCN)*100
			equation _BGDGGREVOTHDCN.ls(optmethod=legacy)  BGDGGREVOTHDCN = c(1)*DUMH + (BGDGGREVOTHDER(-1)/100)*BGDNYGDPMKTPCN	
			' Non-NBR taxes
			BGD.append @IDENTITY BGDGGREVNNBRER = (BGDGGREVNNBRCN/BGDNYGDPMKTPCN)*100
			equation _BGDGGREVNNBRCN.ls(optmethod=legacy)  BGDGGREVNNBRCN = c(1)*DUMH + (BGDGGREVNNBRER(-1)/100)*BGDNYGDPMKTPCN
			' All Other Taxes
			BGD.append @IDENTITY BGDGGREVTOTHER = (BGDGGREVTOTHCN/BGDNYGDPMKTPCN)*100
			equation _BGDGGREVTOTHCN.ls(optmethod=legacy)  BGDGGREVTOTHCN = c(1)*DUMH + (BGDGGREVTOTHER(-1)/100)*BGDNYGDPMKTPCN
	
		'NON TAX REVENUES
			smpl %begin_date %end_estimate
			c = 0
			equation _BGDGGREVNONTCN.LS (BGDGGREVNONTCN/BGDNYGDPMKTPCN) = C(1)
		
		'GRANTS
			smpl %begin_date %end_estimate
			c = 0
			equation _BGDGGREVGRNTCN.LS (BGDGGREVGRNTCN/BGDNYGDPMKTPCN) = C(1)
			
		'OTHER REVENUES
			'Exogenous variables : BGDGGREVOTHRCN

'*******************************************************
' FISCAL - EXPENDITURES
'*******************************************************			
		'TOTAL EXPENDITURES
		BGD.append @IDENTITY BGDGGEXPTOTLCN = BGDGGEXPCRNTCN + BGDGGEXPCAPTCN + BGDGGEXPOTHRCN
		
		'CURRENT EXPENDITURES
		BGD.append @IDENTITY BGDGGEXPCRNTCN = BGDGGEXPWAGECN + BGDGGEXPINTPCN + BGDGGEXPGNFSCN + BGDGGEXPTRNSCN
	
		'If using fiscal rule - expenditure proportional to revenues 
		if !fiscRule = 1 then
			'WAGE
			smpl %begin_date %end_estimate
			c = 0
			equation _BGDGGEXPWAGECN.LS (BGDGGEXPWAGECN/(BGDGGREVTOTLCN-BGDGGEXPINTPCN(-1))) = C(1)
			'GOODS and SERVICES
			smpl %begin_date %end_estimate
			c = 0		
			equation _BGDGGEXPGNFSCN.LS (BGDGGEXPGNFSCN/(BGDGGREVTOTLCN-BGDGGEXPINTPCN(-1))) = C(1)
			'TRANSFERS
			smpl %begin_date %end_estimate
			c = 0		
			equation _BGDGGEXPTRNSCN.LS (BGDGGEXPTRNSCN/(BGDGGREVTOTLCN-BGDGGEXPINTPCN(-1))) = C(1)	
			'OTHER EXPENDITURES
			'Exogenous variables : BGDGGEXPOTHRCN
			'CAPITAL EXPENDITURES
			' smpl %begin_date %end_estimate
			smpl 1992 %end_estimate
			c = 0
			equation _BGDGGEXPCAPTCN.LS (BGDGGEXPCAPTCN/(BGDGGREVTOTLCN-BGDGGEXPINTPCN(-1))) = C(1)
		
		else
			'WAGE
			smpl %begin_date %end_estimate
			c = 0
			equation _BGDGGEXPWAGECN.LS DLOG(BGDGGEXPWAGECN) = C(1) - C(2) * (LOG(BGDGGEXPWAGECN(-1)) - LOG(BGDNYGDPMKTPCN(-1))) +0.1*DLOG(BGDNYGDPMKTPCN) '			
			'GOODS and SERVICES
			smpl 2000 %end_estimate
			c = 0		
			equation _BGDGGEXPGNFSCN.LS DLOG(BGDGGEXPGNFSCN) =   C(1) -0.2* (LOG(BGDGGEXPGNFSCN(-1)) - LOG(BGDNYGDPMKTPCN(-1))) + C(10)*DLOG(BGDNYGDPMKTPCN)
			'TRANSFERS
			smpl 2010 %end_estimate
			c = 0		
			equation _BGDGGEXPTRNSCN.LS DLOG(BGDGGEXPTRNSCN) = C(1) - 0.5* (LOG(BGDGGEXPTRNSCN(-1)) - LOG(BGDNYGDPMKTPCN(-1))) + C(10)*DLOG(BGDNYGDPMKTPCN) 
			'OTHER EXPENDITURES
			'Exogenous variables : BGDGGEXPOTHRCN	
			'CAPITAL EXPENDITURES
			smpl 1992 %end_estimate
			c = 0
			equation _BGDGGEXPCAPTCN.LS DLOG(BGDGGEXPCAPTCN) = C(1) - C(2) * (LOG(BGDGGEXPCAPTCN(-1)) - LOG(BGDNYGDPMKTPCN(-1))) + 0.1*DLOG(BGDNYGDPMKTPCN)
		endif
		
		'INTEREST PAYMENTS	
			'Total = domestic + external
			BGD.append @IDENTITY BGDGGEXPINTPCN = BGDGGEXPINTDCN + BGDGGEXPINTECN
			'Domestic
			BGD.append @IDENTITY BGDGGEXPINTDCN = BGDINTRDFR / 100 * BGDGGDBTDOMTCN(-1)
			'External
			BGD.append @IDENTITY BGDGGEXPINTECN = BGDINTREFR / 100 * BGDGGDBTEXTLCN(-1)
			'Interest rate on domestic debt
			BGD.append @IDENTITY BGDINTRDFR = BGDINTRDDIFFFR + BGDFMLBLPOLYFR 
			'Interest on external debt
			BGD.append @IDENTITY BGDINTREFR = BGDINTREDIFFFR + USAINTRFR
			'Interest rate marks up - move with debt 
'			'Domestiic
'			smpl 2006 %end_estimate
			c = 0
			equation _BGDINTRDDIFFFR.LS  BGDINTRDDIFFFR = C(1)+0.0002*((BGDGGDBTTOTLCN(-1)/BGDNYGDPMKTPCN(-1))*100-60)
			'External
			smpl 2004 %end_estimate
			c = 0
			equation _BGDINTREDIFFFR.LS  BGDINTREDIFFFR = C(1)+0.0002*((BGDGGDBTTOTLCN(-1)/BGDNYGDPMKTPCN(-1))*100-60)

			
'*******************************************************
' FISCAL - BALANCES
'*******************************************************		
		'Overall balance
		BGD.append @IDENTITY BGDGGBALOVRLCN = BGDGGREVTOTLCN - BGDGGEXPTOTLCN
		'Primary balance
		BGD.append @IDENTITY BGDGGBALPRIMCN = BGDGGBALOVRLCN + BGDGGEXPINTPCN
		'Overall balance in USD
		BGD.append @IDENTITY BGDGGBALOVRLCD = BGDGGBALOVRLCN / BGDPANUSATLS 
	
'*******************************************************
' FISCAL - DEBT
'*******************************************************		
		'Total debt = external + domestic
		BGD.append @IDENTITY BGDGGDBTTOTLCN = BGDGGDBTEXTLCN + BGDGGDBTDOMTCN
		'Total debt in USD
		BGD.append @IDENTITY BGDGGDBTTOTLCD = BGDGGDBTTOTLCN / BGDPANUSATLS
		'External debt
		BGD.append @IDENTITY BGDGGDBTEXTLCN = BGDGGDBTEXTLCN(-1) + BGDGGDBTVALECN + BGDGGFINEXTLCN 
		'Domestic debt
		BGD.append @IDENTITY BGDGGDBTDOMTCN = BGDGGDBTDOMTCN(-1) + BGDGGDBTVALDCN + BGDGGFINDOMTCN 
		'Exogenous variables : BGDGGDBTVALECN BGDGGDBTVALDCN

'*******************************************************
' FISCAL - FINANCING
'*******************************************************		
		'Financing requirement
		BGD.append @IDENTITY BGDGGFINREQMCN = - BGDGGBALOVRLCN
		'Financing gap
		BGD.append @IDENTITY BGDGGFINFGAPCN = BGDGGFINREQMCN - BGDGGFINTOTLCN 
		'Total finance = external + domestic
		BGD.append @IDENTITY BGDGGFINTOTLCN = BGDGGFINEXTLCN + BGDGGFINDOMTCN
		
		' External fiancing (behavioral equation)
		equation _BGDGGFINEXTLCN.LS BGDGGFINEXTLCN = BGDGGFINEXTLSHARE_/100 * BGDGGFINREQMCN + C(1) * @DURING("2015")
		'Other external financing
		BGD.append @IDENTITY BGDGGFINEOTHCN = BGDGGFINEXTLCN + BGDGGFINEAMTCN - BGDGGFINEDSBCN
		' Domestic (behavioural equation)
		equation _BGDGGFINDOMTCN.LS BGDGGFINDOMTCN = (1-BGDGGFINEXTLSHARE_/100) * BGDGGFINREQMCN + C(1) * @DURING("2015")
		
'*******************************************************
' MONETARY
'*******************************************************
	'Interest rate
	smpl %begin_date %end_estimate
	c = 0
	equation _BGDFMLBLPOLYFR.LS(OPTMETHOD=LEGACY) BGDFMLBLPOLYFR/100 = C(1) * BGDFMLBLPOLYFR(-1)/100 + (1-C(1)) * (C(2) + 1.5*(@PC(BGDNECONPRVTXN) - BGDINFLEXPT)/100 + 0.3 * BGDNYGDPGAP_/100)'+C(10)*@DURING("2010") BGDFPCPITOTLXN

'*******************************************************
' BOP 
'*******************************************************
	'CURRENT ACCOUNT
		'TRADE			
			'TOTAL EXPORTS (quasi-identity)
			smpl %begin_date %end_estimate
			c = 0
			equation _BGDBXGSRGNFSCD.LS(OPTMETHOD=LEGACY) DLOG(BGDBXGSRGNFSCD) = DLOG((BGDNEEXPGNFSKN*BGDNEEXPGNFSXN)/BGDPANUSATLS) + C(1)*DUMH
				'Merchandise exports	
				smpl %begin_date %end_estimate
				c = 0
				equation _BGDBXGSRMRCHCD.LS (BGDBXGSRMRCHCD/BGDBXGSRGNFSCD) = C(1)
				'Services export	
				BGD.append @IDENTITY BGDBXGSRNFSVCD = BGDBXGSRGNFSCD - BGDBXGSRMRCHCD
	
			'TOTAL IMPORTS (quasi-identity)
				smpl %begin_date %end_estimate
				c = 0
				equation _BGDBMGSRGNFSCD.LS(OPTMETHOD=LEGACY) DLOG(BGDBMGSRGNFSCD) = DLOG((BGDNEIMPGNFSKN*BGDNEIMPGNFSXN)/BGDPANUSATLS)  +C(1)*DUMH
				'Merchandised imports				
				smpl %begin_date %end_estimate
				c = 0
				equation _BGDBMGSRMRCHCD.LS DLOG(BGDBMGSRMRCHCD/BGDBMGSRGNFSCD) = C(1) 
				'Services imports
				BGD.append @IDENTITY BGDBMGSRNFSVCD = BGDBMGSRGNFSCD - BGDBMGSRMRCHCD
				
		'PRIMARY AND SECONDARY INCOME
				'EXPORTS Factor Services and Transfers
				BGD.append @identity BGDBXFSTCABTCD = BGDBXFSTREMTCD + BGDBXFSTOTHRCD
					'Inward remittances (behavioural equation)
					smpl 2000 %end_estimate
					c = 0
					equation _BGDBXFSTREMTCD.LS DLOG(BGDBXFSTREMTCD) = C(1) - C(2) * (LOG(BGDBXFSTREMTCD(-1))-LOG(BGDREMT_IN(-1))) + 1*DLOG(BGDREMT_IN) + C(10) * @DURING("2007 2008")			
					'Other factor services and transfer exports 
					smpl %begin_date %end_estimate
					c = 0
					equation _BGDBXFSTOTHRCD.LS (BGDBXFSTOTHRCD/BGDNYGDPMKTPCD) =  C(1) 
				'IMPORTS Factor Services and Transfers
				BGD.append @identity BGDBMFSTCABTCD = BGDBMFSTREMTCD + BGDBMFSTINTECD + BGDBMFSTOTHRCD
					'Outward remittances (behavioural equation)
					smpl 1995 %end_estimate
					c = 0
					equation _BGDBMFSTREMTCD.LS DLOG(BGDBMFSTREMTCD) = C(1) - C(2) * (LOG(BGDBMFSTREMTCD(-1))-LOG(BGDNYGDPMKTPCD(-1))) + 1* DLOG(BGDNYGDPMKTPCD) + C(10) * @DURING("2013")
					'Other factor services and transfer imports
					smpl %begin_date %end_estimate
					c = 0
					equation _BGDBMFSTOTHRCD.LS (BGDBMFSTOTHRCD/BGDNYGDPMKTPCD) = C(1) 
					'Interest payments aboard
					BGD.append @identity BGDBMFSTINTECD = BGDGGEXPINTECN / BGDPANUSATLS


'*******************************************************
' BOP - BALANCE
'*******************************************************	
			'Factor tServices and transfer (BALANCE)
			BGD.append @identity BGDBNFSTCABTCD = BGDBXFSTCABTCD - BGDBMFSTCABTCD
			'Current account balance 			
			BGD.append @identity BGDBNCABFUNDCD = BGDBNGSRGNFSCD + BGDBNFSTCABTCD
			'Net trade
			BGD.append @identity BGDBNGSRGNFSCD = BGDBXGSRGNFSCD - BGDBMGSRGNFSCD


'*******************************************************
'FINANCIAL ACCOUNT
'*******************************************************		
			'Financial flows = Capital flows + portfolio flows + Other flows
			BGD.append @identity BGDBFCAFFINXCD = BGDBFCAFFFDICD + BGDBFCAFFPFTCD + BGDBFCAFOTHRCD
				'Capital flows (behavioural equation)
				smpl 2000 %end_estimate
				c = 0
				equation _BGDBFCAFFFDICD.LS @PC(BGDBFCAFFFDICD) = @PC(BGDNYGDPMKTPCD) + C(1) * @DURING("2015")
				'Portfolio flows (behavioural equation)
				smpl 2014 %end_estimate
				c = 0
				equation _BGDBFCAFFPFTCD.LS @PC(BGDBFCAFFPFTCD) = @PC(BGDNYGDPMKTPCD) + C(1) * @DURING("2015")
				'Other Flows = government loans + other capital flows
				BGD.append @IDENTITY BGDBFCAFOTHRCD = BGDBFCAFOOTHCD + BGDBFFINTGOVCD				
					'Government loans
					BGD.append @identity BGDBFFINTGOVCD = BGDBFFINAGOVCD + BGDBFFINDGOVCD + BGDBFFINOGOVCD
						'Government loans - amotrization
						BGD.append @identity BGDBFFINAGOVCD = BGDGGFINEAMTCN / BGDPANUSATLS
						'Government loans - disbursement
						BGD.append @identity BGDBFFINDGOVCD = BGDGGFINEDSBCN / BGDPANUSATLS
						'Government loans - financialization			
						BGD.append @identity BGDBFFINOGOVCD = BGDGGFINEOTHCN / BGDPANUSATLS
					'Other capital flows (behavioral equation)
					smpl 2018 %end_estimate
					c = 0
					equation _BGDBFCAFOOTHCD.LS @PC(BGDBFCAFOOTHCD) = @PC(BGDNYGDPMKTPCD) + C(1) * @DURING("2018")
			

'*******************************************************
'BALANCE OF PAYMENTS AND RESERVES
'*******************************************************	
			'BOP BALANCE = capital account + financial flows +current account balance + net errors and omissions
			BGD.append @IDENTITY BGDBFBOPTOTLCD = BGDBFCAFCAPTCD + BGDBFCAFFINXCD + BGDBNCABFUNDCD + BGDBFCAFNEOMCD
			'External financing gap
			BGD.append @IDENTITY BGDBFFINFGAPCD = BGDBFBOPTOTLCD + BGDBFCAFRACGCD
			'Changes in reserves
			smpl %begin_date %end_estimate
			c = 0
			equation _BGDBFCAFRACGCD.LS BGDBFCAFRACGCD = - BGDBFBOPTOTLCD + C(1) * DUMH
			'??			
			smpl %begin_date %end_estimate
			c = 0
			equation _BGDFIRESTOTLCD.LS D(BGDFIRESTOTLCD) = - BGDBFCAFRACGCD + C(1) * DUMH
			'Exogenous variables : BGDBFCAFCAPTCD BGDBFCAFNEOMCD  (capital account and net errors and omissions)
			
'*******************************************************
' EXTERNAL - EXCHANGE RATE
'*******************************************************
	'Exchange rates USD (behavioral equation)
	smpl %begin_date %end_estimate
	c = 0		
	equation _BGDPANUSATLS.ls DLOG(BGDPANUSATLS) = C(1) -0.2*(LOG(BGDPANUSATLS(-1))-LOG((1+USAINTRFR(-1)/100)/(1+BGDFMLBLPOLYFR(-1)/100)))+0.15*DLOG(BGDPANUSATLS(-1))+1*DLOG((1+USAINTRFR/100)/(1+BGDFMLBLPOLYFR/100))+C(10)*@DURING("2012")
	'Trading partners information 	
	for %c BGD USA DEU GBR FRA CHN ESP CAN ITA TUR NLD BEL IND
		BGD.append @IDENTITY {%c}EXR05 = {%c}PANUSATLS / @elem({%c}PANUSATLS , 2016)
		BGD.append @IDENTITY {%c}PCEXN05 = {%c}NECONPRVTXN / @elem({%c}NECONPRVTXN , 2016)
	next
	'Effective exchange rate real (main trading partner)
	BGD.append @IDENTITY BGDreer  = 100  * (0.1976357385 * 1 / ((BGDEXR05 / BGDPCEXN05) / (USAEXR05 / USAPCEXN05))  + 0.1462581536 * 1 / ((BGDEXR05 / BGDPCEXN05) / (DEUEXR05 / DEUPCEXN05))  + 0.08439290517 * 1 / ((BGDEXR05 / BGDPCEXN05) / (GBREXR05 / GBRPCEXN05))  + 0.06887154717 * 1 / ((BGDEXR05 / BGDPCEXN05) / (FRAEXR05 / FRAPCEXN05))  + 0.04927114879 * 1 / ((BGDEXR05 / BGDPCEXN05) / (CHNEXR05 / CHNPCEXN05))  + 0.04496640064 * 1 / ((BGDEXR05 / BGDPCEXN05) / (ESPEXR05 / ESPPCEXN05))  + 0.03717605296 * 1 / ((BGDEXR05 / BGDPCEXN05) / (CANEXR05 / CANPCEXN05))  + 0.03359022571 * 1 / ((BGDEXR05 / BGDPCEXN05) / (ITAEXR05 / ITAPCEXN05))  + 0.03241757735 * 1 / ((BGDEXR05 / BGDPCEXN05) / (TUREXR05 / TURPCEXN05))  + 0.02752241922 * 1 / ((BGDEXR05 / BGDPCEXN05) / (NLDEXR05 / NLDPCEXN05))  + 0.0260141169 * 1 / ((BGDEXR05 / BGDPCEXN05) / (BELEXR05 / BELPCEXN05))  + 0.02484860441 * 1 / ((BGDEXR05 / BGDPCEXN05) / (INDEXR05 / INDPCEXN05))) / (1-0.22703511)
	'Effective exchange rate nominal (main trading partner)
	BGD.append @IDENTITY BGDneer  = 100  * (0.1976357385 * 1 / (BGDEXR05 / USAEXR05)  + 0.1462581536 * 1 / (BGDEXR05 / DEUEXR05)  + 0.08439290517 * 1 / (BGDEXR05 / GBREXR05)  + 0.06887154717 * 1 / (BGDEXR05 / FRAEXR05)  + 0.04927114879 * 1 / (BGDEXR05 / CHNEXR05)  + 0.04496640064 * 1 / (BGDEXR05 / ESPEXR05)  + 0.03717605296 * 1 / (BGDEXR05 / CANEXR05)  + 0.03359022571 * 1 / (BGDEXR05 / ITAEXR05)  + 0.03241757735 * 1 / (BGDEXR05 / TUREXR05)  + 0.02752241922 * 1 / (BGDEXR05 / NLDEXR05)  + 0.0260141169 * 1 / (BGDEXR05 / BELEXR05)  + 0.02484860441 * 1 / (BGDEXR05 / INDEXR05)) / (1-0.22703511)

'*******************************************************
' EXTERNAL - KEYFITZ
'*******************************************************		
	'KEYFITZ - export  (manufacturing price index)
	BGD.append @IDENTITY BGDPXKEY = MUV / @ELEM(MUV , 2016)

	'KEYFITZ - imports (weighted by imports weight)
	BGD.append @IDENTITY BGDPMKEY  = ( 0.002452542217  * WLDFALUMINUM  / @ELEM(WLDFALUMINUM  , 2016)  + 0.000027200099  * WLDFBANANA_US  / @ELEM(WLDFBANANA_US  , 2016)  + 0.003404545665  * WLDFBEEF  / @ELEM(WLDFBEEF  , 2016)  + 0.247806497590  * WLDFCOAL_AUS  / @ELEM(WLDFCOAL_AUS  , 2016)  + 0.000497856374  * WLDFCOCOA  / @ELEM(WLDFCOCOA  , 2016)  + 0.000380801379  * WLDFCOFFEE_COMPO  / @ELEM(WLDFCOFFEE_COMPO  , 2016)  + 0.000013600049  * WLDFCOPPER  / @ELEM(WLDFCOPPER  , 2016)  + 3.512983391193  * WLDFCOTTON_A_INDX  / @ELEM(WLDFCOTTON_A_INDX  , 2016)  + 4.5  * WLDFCRUDE_PETRO  / @ELEM(WLDFCRUDE_PETRO  , 2016)  + 0.000026202967  * WLDFGRNUT_OIL  / @ELEM(WLDFGRNUT_OIL  , 2016)  + 0.000412534828  * WLDFGRNUT_OIL  / @ELEM(WLDFGRNUT_OIL  , 2016)  + 0.001156004187  * WLDFGOLD  / @ELEM(WLDFGOLD  , 2016)  + 0.000072533596  * WLDFGRNUT  / @ELEM(WLDFGRNUT  , 2016)  + 0.000009066700  * WLDFIRON_ORE  / @ELEM(WLDFIRON_ORE  , 2016)  + 0.010453207011  * WLDFLEAD  / @ELEM(WLDFLEAD  , 2016)  + 0.708186298485  * WLDFMAIZE  / @ELEM(WLDFMAIZE  , 2016)  + 75.46499434 * MUV  / @ELEM(MUV  , 2016)  + 0.000213458882  * WLDFNICKEL  / @ELEM(WLDFNICKEL  , 2016)  + 0.205605544733  * WLDFORANGE  / @ELEM(WLDFORANGE  , 2016)  + 0.097435286258  * WLDFNGAS_EUR  / @ELEM(WLDFNGAS_EUR  , 2016)  + 0.064586633942  * WLDFPALM_OIL  / @ELEM(WLDFPALM_OIL  , 2016)  + 1.455917006872  * WLDFRICE_05  / @ELEM(WLDFRICE_05  , 2016)  + 0.025930760592  * WLDFRUBBER1_MYSG  / @ELEM(WLDFRUBBER1_MYSG  , 2016)  + 0.000285601034  * WLDFSILVER  / @ELEM(WLDFSILVER  , 2016)  + 1.293541485392  * WLDFSOYBEAN_MEAL  / @ELEM(WLDFSOYBEAN_MEAL  , 2016)  + 0.822399512182  * WLDFSOYBEAN_OIL  / @ELEM(WLDFSOYBEAN_OIL  , 2016)  + 0.207065283353  * WLDFSOYBEANS  / @ELEM(WLDFSOYBEANS  , 2016)  + 0.000235734187  * WLDFSORGHUM  / @ELEM(WLDFSORGHUM  , 2016)  + 5.530605099306  * WLDFISTL_JP_INDX  / @ELEM(WLDFISTL_JP_INDX  , 2016)  + 2.081016071070  * WLDFSUGAR_WLD  / @ELEM(WLDFSUGAR_WLD  , 2016)  + 0.019806205074  * WLDFTEA_AVG  / @ELEM(WLDFTEA_AVG  , 2016)  + 0.043860158868  * WLDFTOBAC_US  / @ELEM(WLDFTOBAC_US  , 2016)  + 0.000022666749  * WLDFLOGS_MYS  / @ELEM(WLDFLOGS_MYS  , 2016)  + 0.044154826602  * WLDFPLYWOOD  / @ELEM(WLDFPLYWOOD  , 2016)  + 0.001310148353  * WLDFWOODPULP  / @ELEM(WLDFWOODPULP  , 2016)  + 0.250716908132  * WLDFSAWNWD_MYS  / @ELEM(WLDFSAWNWD_MYS  , 2016)  + 3.402414990698  * WLDFWHEAT_US_HRW  / @ELEM(WLDFWHEAT_US_HRW  , 2016) )  / 100
		
	'Terms of trade
	BGD.append @IDENTITY BGDTOT = (BGDNEEXPGNFSXN / BGDNEIMPGNFSXN)
		
'*******************************************************
' EXTERNAL - EXPORT MARKET
'*******************************************************	
	'Export market growth (weight by trading partners)
	BGD.append @IDENTITY BGDXMKT_GR = 0.1976357385 * @pc(USANEIMPGNFSKD) + 0.1462581536 * @pc(DEUNEIMPGNFSKD) + 0.08439290517 * @pc(GBRNEIMPGNFSKD) + 0.06887154717 * @pc(FRANEIMPGNFSKD) + 0.04927114879 * @pc(CHNNEIMPGNFSKD) + 0.04496640064 * @pc(ESPNEIMPGNFSKD) + 0.03717605296 * @pc(CANNEIMPGNFSKD) + 0.03359022571 * @pc(ITANEIMPGNFSKD) + 0.03241757735 * @pc(TURNEIMPGNFSKD) + 0.02752241922 * @pc(NLDNEIMPGNFSKD) + 0.0260141169 * @pc(BELNEIMPGNFSKD) + 0.02484860441 * @pc(INDNEIMPGNFSKD) + 0.22703511 * @pc(ROWNEIMPGNFSKD)
	'Export market level
	BGD.append @IDENTITY BGDXMKT = BGDXMKT(-1) * (1 + BGDXMKT_GR / 100)
		
'*******************************************************
' EXTERNAL - REMITTANCE SOURCES
'*******************************************************		
	'Sources in growth rate
	BGD.append @IDENTITY BGDREMT_IN_GR  = (0.22 * @pc(SAUNYGDPMKTPCD) + 0.10 * @pc(ARENYGDPMKTPCD) + 0.10 * @pc(GBRNYGDPMKTPCD) + 0.07 * @pc(KWTNYGDPMKTPCD) + 0.16 * @pc(USANYGDPMKTPCD) + 0.06 * @pc(QATNYGDPMKTPCD) + 0.04 * @pc(OMNNYGDPMKTPCD) + 0.02 * @pc(SGPNYGDPMKTPCD) + 0.004 * @pc(DEUNYGDPMKTPCD) + 0.03 * @pc(BHRNYGDPMKTPCD)+ 0.003 * @pc(JPNNYGDPMKTPCD)+ 0.05* @pc(MYSNYGDPMKTPCD)) / 0.857

	'Sources in level		
	BGD.append @identity BGDREMT_IN = BGDREMT_IN(-1) * (1+BGDREMT_IN_GR/100)	

'***************************************************
'***************************************************
'MERGE ALL AVAILABLE EQUATIONS TO THE MODEL OBJECT
%eqlist=@wlookup("*","equation")  

for !i=1 to @wcount(%eqlist)  
  %eq = @word(%eqlist,!i) 
 	{%model}.merge {%eq}
next
'***************************************************
'***************************************************


