' ============================
' Simple shocks
' ============================
close @all
logmode l
%path = @runpath
cd %path

%file = %path + "data\BGDSOLN.wf1"
wfopen %file

%cty = "BGD"
%solve_start = "2016"
%solve_end = "2030"

' ================================

                                smpl @all
                                delete *_A
                                {%cty}.update

                                {%cty}.exclude
                                smpl %solve_start %solve_end
                                {%cty}.addassign(i,c) @stochastic
                                {%cty}.addinit(v=n) @stochastic

                                {%cty}.scenario "baseline"
                                {%cty}.solve(s=d,d=d,o={%s}, i=a, g=n)
                                logmsg "resolved baseline"

' ================================
' GOVERNMENT INVESTMENT

{%cty}.scenario(n,a=3,i="Baseline",c) "simple"
{%cty}.scenario "simple"

%exos = "BGDGGEXPGNFSCN BGDGGEXPWAGECN BGDGGEXPTRNSCN  BGDGGEXPOTHRCN BGDGGEXPTSOCCN BGDGGEXPTOTHCN BGDBXFSTREMTCD" 'BGDBXFSTREMTCD

smpl @all
series BGDGGEXPCAPTCN_3 = BGDGGEXPCAPTCN_0

smpl 2025 2025
series BGDGGEXPCAPTCN_3 = BGDGGEXPCAPTCN+0.01*BGDNYGDPMKTPCN

{%cty}.exclude BGDGGEXPCAPTCN {%exos}
{%cty}.override BGDGGEXPCAPTCN

smpl 2016 @last
{%cty}.solve(s=d,d=d,o=g, i=a, g=n)

smpl 2020 %solve_end
group oil @PC({%cty}NYGDPMKTPKN_3) @PC({%cty}NYGDPMKTPKN_0)

                freeze(graph3a) OIL.line
                graph3a.options fillcolor(WHITE) backcolor(WHITE) -INBOX  BACKFADE(NONE) frameaxes(all)
                graph3a.setelem(1) linecolor(148,190,255) lwidth(2) lpat(1) 'symbol(15)
                graph3a.setelem(2) linecolor(255,0,0) lwidth(2) lpat(1) 'symbol(15)
                graph3a.NAME(1) Scenario
                graph3a.NAME(2) Baseline

                graph3a.addtext(4.61,-0.75) 1% of GDP increase in pub. inv. in 2025
                graph3a.addtext(l) % pa growth
                graph3a.legend font("Times", 16)
                graph3a.legend position(3.42,2.04) -inbox
                graph3a.addtext(2,-0.4,font(16)) GDP responses
show graph3a

group OIL5  (({%cty}NYGDPMKTPKN_3/{%cty}NYGDPMKTPKN_0)-1)*100
                freeze(graph3aa) OIL5.line
                graph3aa.options fillcolor(WHITE) backcolor(WHITE) -INBOX  BACKFADE(NONE) frameaxes(all)
                graph3aa.setelem(1) linecolor(148,190,255) lwidth(2) lpat(1) 'symbol(15)
                graph3aa.NAME(1) Scenario


                graph3aa.addtext(4.61,-0.75) 1% of GDP increase in pub. inv. in 2025
                graph3aa.addtext(l) % differences from baseline
                graph3aa.legend font("Times", 16)
                graph3aa.legend position(3.42,2.04) -inbox
                graph3aa.addtext(2,-0.4,font(16)) GDP responses
show graph3aa

smpl 2020 %solve_end
group oil6 {%cty}NYGDPMKTPKN_3 {%cty}NYGDPMKTPKN_0

                freeze(graph3ab) OIL6.line
                graph3ab.options fillcolor(WHITE) backcolor(WHITE) -INBOX  BACKFADE(NONE) frameaxes(all)
                graph3ab.setelem(1) linecolor(148,190,255) lwidth(2) lpat(1) 'symbol(15)
                graph3ab.setelem(2) linecolor(255,0,0) lwidth(2) lpat(1) 'symbol(15)
                graph3ab.NAME(1) Scenario
                graph3ab.NAME(2) Baseline

                graph3ab.addtext(4.61,-0.75) 1% of GDP increase in pub. inv. in 2025
                graph3ab.addtext(l) m LCU real
                graph3ab.legend font("Times", 16)
                graph3ab.legend position(3.42,2.04) -inbox
                graph3ab.addtext(2,-0.4,font(16)) GDP responses
show graph3ab



group oil1 (BGDNYGDPGAP__3-BGDNYGDPGAP__0) ((BGDbncabfundcd_3/BGDNYGDPMKTPCD_3)-(BGDbncabfundcd_0/BGDNYGDPMKTPCD_0))*100

                freeze(graph3b) OIL1.line
                graph3b.options fillcolor(WHITE) backcolor(WHITE) -INBOX  BACKFADE(NONE) frameaxes(all)
                graph3b.setelem(1) linecolor(148,190,255) lwidth(2) lpat(1) 'symbol(15)
                graph3b.setelem(2) linecolor(255,0,0) lwidth(2) lpat(1) 'symbol(15)
                graph3b.NAME(1) Output gap
                graph3b.NAME(2) Current account balance (%GDP)

                graph3b.addtext(4.61,-0.75) 1% of GDP increase in pub. inv. in 2025
                graph3b.addtext(l) %
                graph3b.legend font("Times", 16)
                graph3b.legend position(3.42,2.04) -inbox
                'graph3b.addtext(2,-0.4,font(16)) GDP responses
show graph3b

' ================================
' OIL PRICE

{%cty}.scenario(n,a=4,i="Baseline",c) "simpled"
{%cty}.scenario "simpled"

%exos = ""

smpl @all
series WLDFCRUDE_PETRO_4 = WLDFCRUDE_PETRO

smpl 2025 @last
series WLDFCRUDE_PETRO_4 = WLDFCRUDE_PETRO+10

{%cty}.exclude {%exos}
{%cty}.override WLDFCRUDE_PETRO

smpl 2016 @last
{%cty}.solve(s=d,d=d,o=g, i=a, g=n)
smpl 2020 %solve_end
group oil2 @PC({%cty}NYGDPMKTPKN_4)-@PC({%cty}NYGDPMKTPKN_0) @PC({%cty}NECONPRVTKN_4)-@PC({%cty}NECONPRVTKN_0) @PC({%cty}NEIMPGNFSKN_4)-@PC({%cty}NEIMPGNFSKN_0)

                freeze(graph3c) OIL2.line
                graph3c.options fillcolor(WHITE) backcolor(WHITE) -INBOX  BACKFADE(NONE) frameaxes(all)
                graph3c.setelem(1) linecolor(148,190,255) lwidth(2) lpat(1) 'symbol(15)
                graph3c.setelem(2) linecolor(255,0,0) lwidth(2) lpat(1) 'symbol(15)
                graph3c.setelem(3) linecolor(0,255,0) lwidth(2) lpat(1) 'symbol(15)
                graph3c.NAME(1) GDP
                graph3c.NAME(2) Consumption
                graph3c.NAME(3) Imports
                graph3c.addtext(4.61,-0.75) USD 10 increase in oil prices               
                graph3c.addtext(l) % change
                graph3c.legend font("Times", 16)             
                graph3c.legend position(3.42,2.04) -inbox
                graph3c.addtext(2,-0.4,font(16)) GDP responses


group oil4 @PC({%cty}NYGDPFCSTXN_4)-@PC({%cty}NYGDPFCSTXN_0) @PC({%cty}NECONPRVTXN_4)-@PC({%cty}NECONPRVTXN_0) @PC({%cty}NEIMPGNFSXN_4)-@PC({%cty}NEIMPGNFSXN_0)

                freeze(graph3d) OIL4.line
                graph3d.options fillcolor(WHITE) backcolor(WHITE) -INBOX  BACKFADE(NONE) frameaxes(all)
                graph3d.setelem(1) linecolor(148,190,255) lwidth(2) lpat(1) 'symbol(15)
                graph3d.setelem(2) linecolor(255,0,0) lwidth(2) lpat(1) 'symbol(15)
                graph3d.setelem(3) linecolor(0,255,0) lwidth(2) lpat(1) 'symbol(15)
                graph3d.NAME(1) GDP
                graph3d.NAME(2) Consumption
                graph3d.NAME(3) Imports
                graph3d.addtext(4.61,-0.75) USD 10 increase in oil prices               
                graph3d.addtext(l) % change
                graph3d.legend font("Times", 16)
                graph3d.legend position(3.42,2.04) -inbox
                graph3d.addtext(2,-0.4,font(16)) Inflation responses
show graph3c
show graph3d


