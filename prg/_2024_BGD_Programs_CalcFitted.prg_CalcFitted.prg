String myljunk = _BGDNEIMPGNFSKN.@varlist
myljunk =@replace(myljunk,"*100"," ")
myljunk =@replace(myljunk,"/100"," ")
myljunk =@replace(myljunk,"/"," ")
myljunk =@replace(myljunk,"(-1)","")
myljunk =@replace(myljunk,"(-2)","")
myljunk =@replace(myljunk,"(-3)","")
myljunk =@replace(myljunk,"(-4)","")
myljunk =@replace(myljunk,"(-5)","")
myljunk =@replace(myljunk,"(-6)","")
myljunk =@replace(myljunk,"(-7)","")
myljunk =@replace(myljunk,"(-8)","")
myljunk =@replace(myljunk,"(-9)","")
myljunk =@replace(myljunk,"(-10)","")
myljunk =@replace(myljunk,"*12","")
myljunk =@replace(myljunk,"12*","")
myljunk =@replace(myljunk,"@PC(","")
myljunk =@replace(myljunk,"DLOG(","")
myljunk =@replace(myljunk,"D(","")
myljunk =@replace(myljunk,"/(","")
myljunk =@replace(myljunk,")/","")
myljunk =@replace(myljunk,"@PCY(","")
myljunk =@replace(myljunk,"LOG(","")
myljunk =@replace(myljunk,")","")
myljunk =@replace(myljunk,"@DURING("," ")
myljunk =@replace(myljunk,"("," ")
myljunk =@replace(myljunk,"*"," ")
myljunk =@replace(myljunk,"-"," ")
myljunk =@replace(myljunk,"+"," ")
myljunk =@replace(myljunk,"))","")
myljunk =@replace(myljunk,"((","")
myljunk =@replace(myljunk,")","")
myljunk =@replace(myljunk,"(","")
myljunk =@replace(myljunk,"@RECODE(","")
myljunk =@wunique(myljunk)
'Now for each of these variables create a temp of the original data, then copy the _2 datainto the original and generate fit before restoring originals
myljunk=@wdrop(myljunk,"C 1 2 3 4 5 6 7 8 9 0")
for %var {myljunk}
   series {%var}_temp={%var}
   series {%var}={%var}_2
next
_BGDNEIMPGNFSKN.fit shockfit
copy *_temp *
