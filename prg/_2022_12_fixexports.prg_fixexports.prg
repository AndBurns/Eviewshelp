close @all
wfopen m:\wbg_mfmod\data\bgdsoln.wf1
smpl @all
series bgdxmkt=@elem(bgdneexpgnfskn,"2016")/@elem(bgdxmkt,"2016")*bgdxmkt

'show bgdxmkt bgdxmkt1 bgdneexpgnfskn


smpl 1991 2019
equation _bgdneexpgnfskn.ls DLOG(BGDNEEXPGNFSKN) =  -0.3* (LOG(BGDNEEXPGNFSKN(-1)) - LOG(BGDXMKT(-1)) -C(1)*@during("2010 2019") + c(4)*@during("1990 2009" ) - 0.6 *LOG(BGDNEEXPGNFSXN(-1)/(BGDNYGDPFCSTXN(-1)))) + 0.6 * DLOG(BGDNEEXPGNFSXN/(BGDNYGDPFCSTXN)) +1 * DLOG(BGDXMKT)
bgd.update
wfsave(2) m:\wbg_mfmod\data\bgdfixedsoln.wf1

