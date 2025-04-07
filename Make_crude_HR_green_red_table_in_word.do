

*********************************************************************************
*	
*	PUTS THE CRUDE HR & CI IN THE RED/GREEN WORD TABLE.								*
*	NB the pooled results are the site-adjusted ones							*
*********************************************************************************


*=============================
* YOUNG WOMEN
*=============================


use ${alphapath}/ALPHA/projects/gates_incidence_risks_2019/results/pooled/site_specific_hr_summary_for_green_red_table,clear

** get relevant records
keep if sex==2 & youth==1
sort sex youth framework varname val 
gen obs=_n

cap putdocx clear
putdocx begin, pagesize(A4) font("Arial Narrow",10,black) margin(all, 1.27cm) 
putdocx paragraph,style("Heading1")
putdocx text ("Table 3: Younger women")

unique varname
*three lines of heading and a line for each variable 
local nrec=r(N)+r(unique)+3
di `nrec'

putdocx table yw=(`nrec',10), cellmargin(left, 0.1cm) cellmargin(right,0.1cm) headerrow(2)


*specify THE COLUMN WIDTHS
putdocx table yw(.,1),width(2.5cm)
putdocx table yw(.,2),width(1.9cm)
putdocx table yw(.,3),width(1.9cm)
putdocx table yw(.,4),width(1.9cm)
putdocx table yw(.,5),width(1.9cm)
putdocx table yw(.,6),width(1.9cm)
putdocx table yw(.,7),width(1.9cm)
putdocx table yw(.,8),width(1.9cm)
putdocx table yw(.,9),width(1.9cm)
putdocx table yw(.,10),width(1.9cm)

*put in a title
putdocx table yw(1,2) = ("Crude HR and CI for women 15-24 by study for 2005-16 inclusive"), bold font("",12,black) halign(center)  valign(center) colspan(9)

*sort out borders
putdocx table yw(.,.),border(all,nil)

putdocx table yw(1,.),border(top,thick)
putdocx table yw(2,.),border(bottom,thick)

putdocx table yw(`nrec',.),border(bottom,thick)



*PUT IN THE COLUMN HEADINGS

putdocx table yw(2,1) = ("Risk Factor"), bold  font("",12,black) halign(left) valign(center)

putdocx table yw(2,2) = ("Ifakara"), bold font("",10,black) halign(center)   valign(center)
putdocx table yw(2,3) = ("Karonga"), bold font("",10,black) halign(center)   valign(center)
putdocx table yw(2,4) = ("Kisesa"), bold font("",10,black) halign(center)   valign(center)
putdocx table yw(2,5) = ("Kisumu"), bold font("",10,black) halign(center)   valign(center)
putdocx table yw(2,6) = ("Manicaland"), bold font("",10,black) halign(center)   valign(center)
putdocx table yw(2,7) = ("Masaka"), bold font("",10,black) halign(center)   valign(center)
putdocx table yw(2,8) = ("Rakai"), bold font("",10,black) halign(center)   valign(center)
putdocx table yw(2,9) = ("uMkhanyakude"), bold font("",10,black) halign(center)   valign(center)
putdocx table yw(2,10) = ("Pooled"), bold font("",10,black) halign(center)   valign(center)


*ASSIGN STARTING ROW FOR DATA
local rowcount=4

*LOOP DOWN RECORDS AND OUTPUT RESULTS

levels framework,local(flist)
foreach f in `flist' {
local fname: label (framework) `f'

** write framework heading
putdocx table yw(`rowcount',1)=("`fname'"),bold  font("Arial","10") colspan(10)
local rowcount=`rowcount'+1

levels varname if framework==`f',local(vlist)


foreach v in `vlist' {
unique val if varname=="`v'"
if r(unique)>1 {
levels val if varname=="`v'",local(vallist)
}
else {
	local vallist=.
}
foreach val in `vallist' {

qui summ obs if varname=="`v'" & val==`val'

local x=int(r(mean))  /*find the observation number of this record in order to extract data. nb if there are duplicates (shouldn't be) this will take only the first record so there will be no error */
local valname=vallab[`x']
local vname=varlab[`x']
/*remove brackets as they seem to offend putexcel
local valname=subinstr("`valname'","(","-",.)
local valname=subinstr("`valname'",")"," ",.)
local vname=subinstr("`vname'","(","-",.)
local vname=subinstr("`vname'",")"," ",.)
*/
putdocx table yw(`rowcount',1)=(`"`valname'"'),  halign(left) valign(center) 


local counter=1
foreach l in 2 3 4 5 6 7 8 9 10 {
local baseline=baseline`counter'[`x']
local pres=p`counter'[`x']
local hr=hr`counter'[`x']
local lb=lb`counter'[`x']
local ub=ub`counter'[`x']
local lbres:di %5.2f lb`counter'[`x']
local ubres:di %5.2f ub`counter'[`x']
local ci=subinstr("(`lbres'-`ubres')"," ", "",.)
local hrres:di %5.2f hr`counter'[`x']
local hrres=subinstr("`hrres'"," ", "",.)
*below 1
if `lb'<1 & `ub'<1   {
putdocx table yw(`rowcount',`l')=("`hrres'"), halign(center) valign(center) font("","9") linebreak
putdocx table yw(`rowcount',`l')=("`ci'"), halign(center) valign(center) font("","9") append
putdocx table yw(`rowcount',`l'), shading(${waterloo}) 
}
*above 1
if `lb'>1  & `ub'>1 & `ub'<.  {
putdocx table yw(`rowcount',`l')=("`hrres'"),   halign(center) valign(center)  font("","9") linebreak
putdocx table yw(`rowcount',`l')=("`ci'"),   halign(center) valign(center)  font("","9") append
putdocx table yw(`rowcount',`l'), shading(${hammersmith}) 
}

*includes 1
if `lb'<1  & `ub'>1 & `ub'<.  {
putdocx table yw(`rowcount',`l')=("`hrres'"),  halign(center) valign(center)   font("","9") linebreak
putdocx table yw(`rowcount',`l')=("`ci'"),  halign(center) valign(center)   font("","9") append

}

*includes 1 but p<0.1 and HR<1
if `lb'<1  & `ub'>1 & `ub'<. & `pres'<0.1 & `hr'<1  {
putdocx table yw(`rowcount',`l')=("`hrres'"),  halign(center) valign(center)  font("","9") linebreak
putdocx table yw(`rowcount',`l')=("`ci'"),  halign(center) valign(center)  font("","9")  append
putdocx table yw(`rowcount',`l'), shading("237 247 244")  
}

*includes 1 but p<0.1 and HR>1
if `lb'<1  & `ub'>1 & `ub'<. & `pres'<0.1 & `hr'>1 & `hr'<.  {
putdocx table yw(`rowcount',`l')=("`hrres'"),  halign(center) valign(center)   font("","9") linebreak
putdocx table yw(`rowcount',`l')=("`ci'"),  halign(center) valign(center)   font("","9") append
putdocx table yw(`rowcount',`l'), shading("252 232 238") 

}

*if it is baseline category

if `baseline'==1  & int(`hrres')==1  {
putdocx table yw(`rowcount',`l')=("1"),  halign(center) valign(center)  font("","9","31 62 97")
putdocx table yw(`rowcount',`l'), shading("236 242 249") 
}


***** PUT IN A - IF THERE WAS NO DATA AND * IF NO MODEL WAS FITTED AND ** IF THERE WERE NO FAILURES or n/a if no comparison is possible
local flag=flag`counter'[`x']
if `flag'==1 {
putdocx table yw(`rowcount',`l')=("**"),  font("","9") halign(center) valign(center) linebreak
}
local nomod=no_model_flag`counter'[`x']
if `nomod'==1 {
putdocx table yw(`rowcount',`l')=("*"),  font("","9") halign(center) valign(center) linebreak
}

local notime=no_pyrs`counter'[`x']
if `notime'==1 {
putdocx table yw(`rowcount',`l')=("-"),  font("","9") halign(center) valign(center) linebreak
}

local compar=compar`counter'[`x']
if `compar'==0 {
putdocx table yw(`rowcount',`l')=("n/a"),  font("","9") halign(center) valign(center) linebreak
}


local counter=`counter'+1
} /* close letter loop */



*go to next row
local rowcount=`rowcount'+1
} /* close values loop */
} /*close variable loop (varname) */
} /* close framework loop */


di in white "YOUNG WOMEN DONE"
*----------------------------------------------------------------------------



*=============================
* OLDER WOMEN
*=============================


use ${alphapath}/ALPHA/projects/gates_incidence_risks_2019/results/pooled/site_specific_hr_summary_for_green_red_table,clear

** get relevant records
keep if sex==2 & youth==2



sort sex youth framework varname val 
gen obs=_n

putdocx paragraph,style("Heading1")
putdocx text ("Table 4: Older women")
putdocx paragraph

unique varname
*three lines of heading and a line for each variable 
local nrec=r(N)+r(unique)+3
di `nrec'

putdocx table ow=(`nrec',10), cellmargin(left, 0.1cm) cellmargin(right,0.1cm)   headerrow(2)


*specify THE COLUMN WIDTHS
putdocx table ow(.,1),width(2.5cm)
putdocx table ow(.,2),width(1.9cm)
putdocx table ow(.,3),width(1.9cm)
putdocx table ow(.,4),width(1.9cm)
putdocx table ow(.,5),width(1.9cm)
putdocx table ow(.,6),width(1.9cm)
putdocx table ow(.,7),width(1.9cm)
putdocx table ow(.,8),width(1.9cm)
putdocx table ow(.,9),width(1.9cm)
putdocx table ow(.,10),width(1.9cm)

*put in a title
putdocx table ow(1,2) = ("Crude HR and CI for women 25-49 by study for 2005-16 inclusive"), bold font("",12,black) halign(center)  valign(center) colspan(9)

*sort out borders
putdocx table ow(.,.),border(all,nil)

putdocx table ow(1,.),border(top,thick)
putdocx table ow(2,.),border(bottom,thick)

putdocx table ow(`nrec',.),border(bottom,thick)



*PUT IN THE COLUMN HEADINGS

putdocx table ow(2,1) = ("Risk Factor"), bold  font("",12,black) halign(left) valign(center)

putdocx table ow(2,2) = ("Ifakara"), bold font("",10,black) halign(center)   valign(center)
putdocx table ow(2,3) = ("Karonga"), bold font("",10,black) halign(center)   valign(center)
putdocx table ow(2,4) = ("Kisesa"), bold font("",10,black) halign(center)   valign(center)
putdocx table ow(2,5) = ("Kisumu"), bold font("",10,black) halign(center)   valign(center)
putdocx table ow(2,6) = ("Manicaland"), bold font("",10,black) halign(center)   valign(center)
putdocx table ow(2,7) = ("Masaka"), bold font("",10,black) halign(center)   valign(center)
putdocx table ow(2,8) = ("Rakai"), bold font("",10,black) halign(center)   valign(center)
putdocx table ow(2,9) = ("uMkhanyakude"), bold font("",10,black) halign(center)   valign(center)
putdocx table ow(2,10) = ("Pooled"), bold font("",10,black) halign(center)   valign(center)


*ASSIGN STARTING ROW FOR DATA
local rowcount=4

** LOOP DOWN RECORDS AND OUTPUT RESULTS

levels framework,local(flist)
foreach f in `flist' {
local fname: label (framework) `f'

** write framework heading
putdocx table ow(`rowcount',1)=("`fname'"),bold  font("Arial","10") colspan(10)
local rowcount=`rowcount'+1

levels varname if framework==`f',local(vlist)


foreach v in `vlist' {
unique val if varname=="`v'"
if r(unique)>1 {
levels val if varname=="`v'",local(vallist)
}
else {
	local vallist=.
}
foreach val in `vallist' {

qui summ obs if varname=="`v'" & val==`val'

local x=int(r(mean))  /*find the observation number of this record in order to extract data. nb if there are duplicates (shouldn't be) this will take only the first record so there will be no error */
local valname=vallab[`x']
local vname=varlab[`x']
*remove brackets as they seem to offend putexcel
local valname=subinstr("`valname'","(","-",.)
local valname=subinstr("`valname'",")"," ",.)
local vname=subinstr("`vname'","(","-",.)
local vname=subinstr("`vname'",")"," ",.)

putdocx table ow(`rowcount',1)=(`"`valname'"'),  halign(left) valign(center) 


local counter=1
foreach l in 2 3 4 5 6 7 8 9 10 {
local baseline=baseline`counter'[`x']
local pres=p`counter'[`x']
local hr=hr`counter'[`x']
local lb=lb`counter'[`x']
local ub=ub`counter'[`x']
local lbres:di %5.2f lb`counter'[`x']
local ubres:di %5.2f ub`counter'[`x']
local ci=subinstr("(`lbres'-`ubres')"," ", "",.)
local hrres:di %5.2f hr`counter'[`x']
local hrres=subinstr("`hrres'"," ", "",.)
*below 1
if `lb'<1 & `ub'<1   {
putdocx table ow(`rowcount',`l')=("`hrres'"), halign(center) valign(center) font("","9") linebreak
putdocx table ow(`rowcount',`l')=("`ci'"), halign(center) valign(center) font("","9") append
putdocx table ow(`rowcount',`l'), shading(${waterloo}) 
}
*above 1
if `lb'>1  & `ub'>1 & `ub'<.  {
putdocx table ow(`rowcount',`l')=("`hrres'"),   halign(center) valign(center)  font("","9") linebreak
putdocx table ow(`rowcount',`l')=("`ci'"),   halign(center) valign(center)  font("","9") append
putdocx table ow(`rowcount',`l'), shading(${hammersmith}) 
}

*includes 1
if `lb'<1  & `ub'>1 & `ub'<.  {
putdocx table ow(`rowcount',`l')=("`hrres'"),  halign(center) valign(center)   font("","9") linebreak
putdocx table ow(`rowcount',`l')=("`ci'"),  halign(center) valign(center)   font("","9") append

}

*includes 1 but p<0.1 and HR<1
if `lb'<1  & `ub'>1 & `ub'<. & `pres'<0.1 & `hr'<1  {
putdocx table ow(`rowcount',`l')=("`hrres'"),  halign(center) valign(center)  font("","9") linebreak
putdocx table ow(`rowcount',`l')=("`ci'"),  halign(center) valign(center)  font("","9")  append
putdocx table ow(`rowcount',`l'), shading("237 247 244")  
}

*includes 1 but p<0.1 and HR>1
if `lb'<1  & `ub'>1 & `ub'<. & `pres'<0.1 & `hr'>1 & `hr'<.  {
putdocx table ow(`rowcount',`l')=("`hrres'"),  halign(center) valign(center)   font("","9") linebreak
putdocx table ow(`rowcount',`l')=("`ci'"),  halign(center) valign(center)   font("","9") append
putdocx table ow(`rowcount',`l'), shading("252 232 238") 

}

*if it is baseline category

if `baseline'==1  & int(`hrres')==1  {
putdocx table ow(`rowcount',`l')=("1"),  halign(center) valign(center)  font("","9","31 62 97")
putdocx table ow(`rowcount',`l'), shading("236 242 249") 
}


***** PUT IN A - IF THERE WAS NO DATA AND ** IF THERE WERE NO FAILURES
local flag=flag`counter'[`x']
if `flag'==1 {
putdocx table ow(`rowcount',`l')=("**"),  font("","9") halign(center) valign(center) linebreak
}
local nomod=no_model_flag`counter'[`x']
if `nomod'==1 {
putdocx table ow(`rowcount',`l')=("*"),  font("","9") halign(center) valign(center) linebreak
}
local notime=no_pyrs`counter'[`x']
if `notime'==1 {
putdocx table ow(`rowcount',`l')=("-"),  font("","9") halign(center) valign(center) linebreak
}

local compar=compar`counter'[`x']
if `compar'==0 {
putdocx table ow(`rowcount',`l')=("n/a"),  font("","9") halign(center) valign(center) linebreak
}

local counter=`counter'+1
} /* close letter loop */



*go to next row
local rowcount=`rowcount'+1
} /* close values loop */
} /*close variable loop (varname) */
} /* close framework loop */

*restore

di in white "Older women done"
*----------------------------------------------------------------------------------------------------------------------



*=============================
* YOUNG MEN
*=============================


use ${alphapath}/ALPHA/projects/gates_incidence_risks_2019/results/pooled/site_specific_hr_summary_for_green_red_table,clear

** get relevant records
keep if sex==1 & youth==1
sort sex youth framework varname val 
gen obs=_n

putdocx pagebreak
putdocx paragraph,style("Heading1")
putdocx text ("Table 5: Younger men")
putdocx paragraph

unique varname
*three lines of heading and a line for each variable 
local nrec=r(N)+r(unique)+3
di `nrec'

putdocx table ym=(`nrec',10), cellmargin(left, 0.1cm) cellmargin(right,0.1cm)  headerrow(2)


*specify THE COLUMN WIDTHS
putdocx table ym(.,1),width(2.5cm)
putdocx table ym(.,2),width(1.9cm)
putdocx table ym(.,3),width(1.9cm)
putdocx table ym(.,4),width(1.9cm)
putdocx table ym(.,5),width(1.9cm)
putdocx table ym(.,6),width(1.9cm)
putdocx table ym(.,7),width(1.9cm)
putdocx table ym(.,8),width(1.9cm)
putdocx table ym(.,9),width(1.9cm)
putdocx table ym(.,10),width(1.9cm)

*put in a title
putdocx table ym(1,2) = ("Crude HR and CI for men 15-24 by study for 2005-16 inclusive"), bold font("",12,black) halign(center)  valign(center) colspan(9)

*sort out borders
putdocx table ym(.,.),border(all,nil)

putdocx table ym(1,.),border(top,thick)
putdocx table ym(2,.),border(bottom,thick)

putdocx table ym(`nrec',.),border(bottom,thick)



*PUT IN THE COLUMN HEADINGS

putdocx table ym(2,1) = ("Risk Factor"), bold  font("",12,black) halign(left) valign(center)

putdocx table ym(2,2) = ("Ifakara"), bold font("",10,black) halign(center)   valign(center)
putdocx table ym(2,3) = ("Karonga"), bold font("",10,black) halign(center)   valign(center)
putdocx table ym(2,4) = ("Kisesa"), bold font("",10,black) halign(center)   valign(center)
putdocx table ym(2,5) = ("Kisumu"), bold font("",10,black) halign(center)   valign(center)
putdocx table ym(2,6) = ("Manicaland"), bold font("",10,black) halign(center)   valign(center)
putdocx table ym(2,7) = ("Masaka"), bold font("",10,black) halign(center)   valign(center)
putdocx table ym(2,8) = ("Rakai"), bold font("",10,black) halign(center)   valign(center)
putdocx table ym(2,9) = ("uMkhanyakude"), bold font("",10,black) halign(center)   valign(center)
putdocx table ym(2,10) = ("Pooled"), bold font("",10,black) halign(center)   valign(center)


*ASSIGN STARTING ROW FOR DATA
local rowcount=4

*LOOP DOWN RECORDS AND OUTPUT RESULTS

levels framework,local(flist)
foreach f in `flist' {
local fname: label (framework) `f'

** write framework heading
putdocx table ym(`rowcount',1)=("`fname'"),bold  font("Arial","10") colspan(10)
local rowcount=`rowcount'+1

levels varname if framework==`f',local(vlist)


foreach v in `vlist' {
unique val if varname=="`v'"
if r(unique)>1 {
levels val if varname=="`v'",local(vallist)
}
else {
	local vallist=.
}
foreach val in `vallist' {

qui summ obs if varname=="`v'" & val==`val'

local x=int(r(mean))  /*find the observation number of this record in order to extract data. nb if there are duplicates (shouldn't be) this will take only the first record so there will be no error */
local valname=vallab[`x']
local vname=varlab[`x']
*remove brackets as they seem to offend putexcel
local valname=subinstr("`valname'","(","-",.)
local valname=subinstr("`valname'",")"," ",.)
local vname=subinstr("`vname'","(","-",.)
local vname=subinstr("`vname'",")"," ",.)

putdocx table ym(`rowcount',1)=(`"`valname'"'),  halign(left) valign(center) 


local counter=1
foreach l in 2 3 4 5 6 7 8 9 10 {
local baseline=baseline`counter'[`x']
local pres=p`counter'[`x']
local hr=hr`counter'[`x']
local lb=lb`counter'[`x']
local ub=ub`counter'[`x']
local lbres:di %5.2f lb`counter'[`x']
local ubres:di %5.2f ub`counter'[`x']
local ci=subinstr("(`lbres'-`ubres')"," ", "",.)
local hrres:di %5.2f hr`counter'[`x']
local hrres=subinstr("`hrres'"," ", "",.)
*below 1
if `lb'<1 & `ub'<1   {
putdocx table ym(`rowcount',`l')=("`hrres'"), halign(center) valign(center) font("","9") linebreak
putdocx table ym(`rowcount',`l')=("`ci'"), halign(center) valign(center) font("","9") append
putdocx table ym(`rowcount',`l'), shading(${waterloo}) 
}
*above 1
if `lb'>1  & `ub'>1 & `ub'<.  {
putdocx table ym(`rowcount',`l')=("`hrres'"),   halign(center) valign(center)  font("","9") linebreak
putdocx table ym(`rowcount',`l')=("`ci'"),   halign(center) valign(center)  font("","9") append
putdocx table ym(`rowcount',`l'), shading(${hammersmith}) 
}

*includes 1
if `lb'<1  & `ub'>1 & `ub'<.  {
putdocx table ym(`rowcount',`l')=("`hrres'"),  halign(center) valign(center)   font("","9") linebreak
putdocx table ym(`rowcount',`l')=("`ci'"),  halign(center) valign(center)   font("","9") append

}

*includes 1 but p<0.1 and HR<1
if `lb'<1  & `ub'>1 & `ub'<. & `pres'<0.1 & `hr'<1  {
putdocx table ym(`rowcount',`l')=("`hrres'"),  halign(center) valign(center)  font("","9") linebreak
putdocx table ym(`rowcount',`l')=("`ci'"),  halign(center) valign(center)  font("","9")  append
putdocx table ym(`rowcount',`l'), shading("237 247 244")  
}

*includes 1 but p<0.1 and HR>1
if `lb'<1  & `ub'>1 & `ub'<. & `pres'<0.1 & `hr'>1 & `hr'<.  {
putdocx table ym(`rowcount',`l')=("`hrres'"),  halign(center) valign(center)   font("","9") linebreak
putdocx table ym(`rowcount',`l')=("`ci'"),  halign(center) valign(center)   font("","9") append
putdocx table ym(`rowcount',`l'), shading("252 232 238") 

}

*if it is baseline category

if `baseline'==1  & int(`hrres')==1  {
putdocx table ym(`rowcount',`l')=("1"),  halign(center) valign(center)  font("","9","31 62 97")
putdocx table ym(`rowcount',`l'), shading("236 242 249") 
}


***** PUT IN A - IF THERE WAS NO DATA AND ** IF THERE WERE NO FAILURES
local flag=flag`counter'[`x']
if `flag'==1 {
putdocx table ym(`rowcount',`l')=("**"),  font("","9") halign(center) valign(center) linebreak
}
local nomod=no_model_flag`counter'[`x']
if `nomod'==1 {
putdocx table ym(`rowcount',`l')=("*"),  font("","9") halign(center) valign(center) linebreak
}
local notime=no_pyrs`counter'[`x']
if `notime'==1 {
putdocx table ym(`rowcount',`l')=("-"),  font("","9") halign(center) valign(center) linebreak
}

local compar=compar`counter'[`x']
if `compar'==0 {
putdocx table ym(`rowcount',`l')=("n/a"),  font("","9") halign(center) valign(center) linebreak
}



local counter=`counter'+1
} /* close letter loop */



*go to next row
local rowcount=`rowcount'+1
} /* close values loop */
} /*close variable loop (varname) */
} /* close framework loop */

*restore

di in white "Young men done"
*---------------------------------------------------------------------------------------------------------------


*=============================
* OLDER MEN
*=============================


use ${alphapath}/ALPHA/projects/gates_incidence_risks_2019/results/pooled/site_specific_hr_summary_for_green_red_table,clear

** get relevant records
keep if sex==1 & youth==2
sort sex youth framework varname val 
gen obs=_n

putdocx pagebreak
putdocx paragraph,style("Heading1")
putdocx text ("Table 6: Older men")
putdocx paragraph
unique varname
*three lines of heading and a line for each variable 
local nrec=r(N)+r(unique)+3
di `nrec'

putdocx table om=(`nrec',10), cellmargin(left, 0.1cm) cellmargin(right,0.1cm)   headerrow(2)


*specify THE COLUMN WIDTHS
putdocx table om(.,1),width(2.5cm)
putdocx table om(.,2),width(1.9cm)
putdocx table om(.,3),width(1.9cm)
putdocx table om(.,4),width(1.9cm)
putdocx table om(.,5),width(1.9cm)
putdocx table om(.,6),width(1.9cm)
putdocx table om(.,7),width(1.9cm)
putdocx table om(.,8),width(1.9cm)
putdocx table om(.,9),width(1.9cm)
putdocx table om(.,10),width(1.9cm)

*put in a title
putdocx table om(1,2) = ("Crude HR and CI for men 25-49 by study for 2005-16 inclusive"), bold font("",12,black) halign(center)  valign(center) colspan(9)

*sort out borders
putdocx table om(.,.),border(all,nil)

putdocx table om(1,.),border(top,thick)
putdocx table om(2,.),border(bottom,thick)

putdocx table om(`nrec',.),border(bottom,thick)



*PUT IN THE COLUMN HEADINGS

putdocx table om(2,1) = ("Risk Factor"), bold  font("",12,black) halign(left) valign(center)

putdocx table om(2,2) = ("Ifakara"), bold font("",10,black) halign(center)   valign(center)
putdocx table om(2,3) = ("Karonga"), bold font("",10,black) halign(center)   valign(center)
putdocx table om(2,4) = ("Kisesa"), bold font("",10,black) halign(center)   valign(center)
putdocx table om(2,5) = ("Kisumu"), bold font("",10,black) halign(center)   valign(center)
putdocx table om(2,6) = ("Manicaland"), bold font("",10,black) halign(center)   valign(center)
putdocx table om(2,7) = ("Masaka"), bold font("",10,black) halign(center)   valign(center)
putdocx table om(2,8) = ("Rakai"), bold font("",10,black) halign(center)   valign(center)
putdocx table om(2,9) = ("uMkhanyakude"), bold font("",10,black) halign(center)   valign(center)
putdocx table om(2,10) = ("Pooled"), bold font("",10,black) halign(center)   valign(center)


*ASSIGN STARTING ROW FOR DATA
local rowcount=4

*LOOP DOWN RECORDS AND OUTPUT RESULTS

levels framework,local(flist)
foreach f in `flist' {
local fname: label (framework) `f'

** write framework heading
putdocx table om(`rowcount',1)=("`fname'"),bold  font("Arial","10") colspan(10)
local rowcount=`rowcount'+1

levels varname if framework==`f',local(vlist)


foreach v in `vlist' {
unique val if varname=="`v'"
if r(unique)>1 {
levels val if varname=="`v'",local(vallist)
}
else {
	local vallist=.
}
foreach val in `vallist' {

qui summ obs if varname=="`v'" & val==`val'

local x=int(r(mean))  /*find the observation number of this record in order to extract data. nb if there are duplicates (shouldn't be) this will take only the first record so there will be no error */
local valname=vallab[`x']
local vname=varlab[`x']
*remove brackets as they seem to offend putexcel
local valname=subinstr("`valname'","(","-",.)
local valname=subinstr("`valname'",")"," ",.)
local vname=subinstr("`vname'","(","-",.)
local vname=subinstr("`vname'",")"," ",.)

putdocx table om(`rowcount',1)=(`"`valname'"'),  halign(left) valign(center) 


local counter=1
foreach l in 2 3 4 5 6 7 8 9 10 {
local baseline=baseline`counter'[`x']
local pres=p`counter'[`x']
local hr=hr`counter'[`x']
local lb=lb`counter'[`x']
local ub=ub`counter'[`x']
local lbres:di %5.2f lb`counter'[`x']
local ubres:di %5.2f ub`counter'[`x']
local ci=subinstr("(`lbres'-`ubres')"," ", "",.)
local hrres:di %5.2f hr`counter'[`x']
local hrres=subinstr("`hrres'"," ", "",.)
*below 1
if `lb'<1 & `ub'<1   {
putdocx table om(`rowcount',`l')=("`hrres'"), halign(center) valign(center) font("","9") linebreak
putdocx table om(`rowcount',`l')=("`ci'"), halign(center) valign(center) font("","9") append
putdocx table om(`rowcount',`l'), shading(${waterloo}) 
}
*above 1
if `lb'>1  & `ub'>1 & `ub'<.  {
putdocx table om(`rowcount',`l')=("`hrres'"),   halign(center) valign(center)  font("","9") linebreak
putdocx table om(`rowcount',`l')=("`ci'"),   halign(center) valign(center)  font("","9") append
putdocx table om(`rowcount',`l'), shading(${hammersmith}) 
}

*includes 1
if `lb'<1  & `ub'>1 & `ub'<.  {
putdocx table om(`rowcount',`l')=("`hrres'"),  halign(center) valign(center)   font("","9") linebreak
putdocx table om(`rowcount',`l')=("`ci'"),  halign(center) valign(center)   font("","9") append

}

*includes 1 but p<0.1 and HR<1
if `lb'<1  & `ub'>1 & `ub'<. & `pres'<0.1 & `hr'<1  {
putdocx table om(`rowcount',`l')=("`hrres'"),  halign(center) valign(center)  font("","9") linebreak
putdocx table om(`rowcount',`l')=("`ci'"),  halign(center) valign(center)  font("","9")  append
putdocx table om(`rowcount',`l'), shading("237 247 244")  
}

*includes 1 but p<0.1 and HR>1
if `lb'<1  & `ub'>1 & `ub'<. & `pres'<0.1 & `hr'>1 & `hr'<.  {
putdocx table om(`rowcount',`l')=("`hrres'"),  halign(center) valign(center)   font("","9") linebreak
putdocx table om(`rowcount',`l')=("`ci'"),  halign(center) valign(center)   font("","9") append
putdocx table om(`rowcount',`l'), shading("252 232 238") 

}

*if it is baseline category

if `baseline'==1  & int(`hrres')==1  {
putdocx table om(`rowcount',`l')=("1"),  halign(center) valign(center)  font("","9","31 62 97")
putdocx table om(`rowcount',`l'), shading("236 242 249") 
}


***** PUT IN A - IF THERE WAS NO DATA AND ** IF THERE WERE NO FAILURES
local flag=flag`counter'[`x']
if `flag'==1 {
putdocx table om(`rowcount',`l')=("**"),  font("","9") halign(center) valign(center) linebreak
}
local nomod=no_model_flag`counter'[`x']
if `nomod'==1 {
putdocx table om(`rowcount',`l')=("*"),  font("","9") halign(center) valign(center) linebreak
}
local notime=no_pyrs`counter'[`x']
if `notime'==1 {
putdocx table om(`rowcount',`l')=("-"),  font("","9") halign(center) valign(center) linebreak
}

local compar=compar`counter'[`x']
if `compar'==0 {
putdocx table om(`rowcount',`l')=("n/a"),  font("","9") halign(center) valign(center) linebreak
}


local counter=`counter'+1
} /* close letter loop */



*go to next row
local rowcount=`rowcount'+1
} /* close values loop */
} /*close variable loop (varname) */
} /* close framework loop */

*restore

di in white "Older men done"
*---------------------------------------------------------------------------


putdocx save "${alphapath}/ALPHA/projects/gates_incidence_risks_2019/results/for_paper/Crude_HR_green_red_everyone.docx",replace




