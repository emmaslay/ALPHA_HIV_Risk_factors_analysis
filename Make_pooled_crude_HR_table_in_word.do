

*********************************************************************************
*	
*	PUTS THE POOLED CRUDE HR & CI IN A WORD TABLE.								*
*	NB the pooled results are the site-adjusted ones							*
*********************************************************************************

use ${alphapath}/ALPHA/projects/gates_incidence_risks_2019/results/pooled/site_specific_hr_summary_long,clear

*reshape long hr p stars lb ub fup_mod fails_mod people_mod flag no_pyrs merge_with_N baseline,i(sex youth varname val parm) j(s)
keep if s==9

*drop the non-interaction estimates for calendar year
drop if varname=="fouryear" & sex==2 & youth==2 & interaction==0
*drop the interaction terms for reshape. NB if end up with more interactions need a better way
drop interaction interaction_var intstr



gen forcol=0 if sex==1 & youth==1
replace forcol=1 if sex==1 & youth==2
replace forcol=2 if sex==2 & youth==1
replace forcol=3 if sex==2 & youth==2

drop sex youth parm int_baseline
reshape wide hr p stars lb ub fup_mod fails_mod people_mod flag no_pyrs merge_with_N baseline,i(  varname val ) j(forcol)

** get relevant records
sort   framework varname val 
gen obs=_n

cap putdocx clear
putdocx begin, pagesize(A4) font("Arial Narrow",10,black) margin(all, 1.27cm) 
putdocx paragraph,style("Heading1")
putdocx text ("Table : Site adjusted HR and 95% CI for HIV seroconversion in pooled data, by age and sex")

unique varname
*three lines of heading and a line for each variable 
local nrec=r(N)+r(unique)+3
di `nrec'

putdocx table pooled_res=(`nrec',5), cellmargin(left, 0.1cm) cellmargin(right,0.1cm) headerrow(2)


*specify THE COLUMN WIDTHS
putdocx table pooled_res(.,1),width(6.4cm)
putdocx table pooled_res(.,2),width(2.8cm)
putdocx table pooled_res(.,3),width(2.8cm)
putdocx table pooled_res(.,4),width(2.8cm)
putdocx table pooled_res(.,5),width(2.8cm)


*put in a title
putdocx table pooled_res(1,2) = ("Crude HR and CI "), bold font("",12,black) halign(center)  valign(center) colspan(4)

*sort out borders
putdocx table pooled_res(.,.),border(all,nil)

putdocx table pooled_res(1,.),border(top,thick)
putdocx table pooled_res(2,.),border(bottom,thick)

putdocx table pooled_res(`nrec',.),border(bottom,thick)



*PUT IN THE COLUMN HEADINGS

putdocx table pooled_res(2,1) = ("Risk Factor"), bold  font("",12,black) halign(left) valign(center)

putdocx table pooled_res(2,2) = ("Young Men"), bold font("",10,black) halign(center)   valign(center)
putdocx table pooled_res(2,3) = ("Older Men"), bold font("",10,black) halign(center)   valign(center)
putdocx table pooled_res(2,4) = ("Young Women"), bold font("",10,black) halign(center)   valign(center)
putdocx table pooled_res(2,5) = ("Older Women"), bold font("",10,black) halign(center)   valign(center)


*ASSIGN STARTING ROW FOR DATA
local rowcount=4

*LOOP DOWN RECORDS AND OUTPUT RESULTS

levels framework,local(flist)
foreach f in `flist' {
local fname: label (framework) `f'

** write framework heading
putdocx table pooled_res(`rowcount',1)=("`fname'"),bold  font("Arial","10") colspan(10)
local rowcount=`rowcount'+1

levels varname if framework==`f',local(vlist)

/*there should be only one variable under each framework heading so this doesn't really mean anything but 
it is a convenient way to get variable name. hangover from when several variables were under one heading */
foreach v in `vlist' { 

*See if this is categorical or continuous, get list of values for categorical variables
unique val if varname=="`v'"
if r(unique)>1 {
levels val if varname=="`v'",local(vallist)
}
else {
	local vallist="."
}

*Loop through each value of categorical variables, will just go through once for continuous
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
putdocx table pooled_res(`rowcount',1)=(`"`valname'"'),  halign(left) valign(center) 

*set the counter which controls which set of variables are looked at
local counter=0
*loop across the table columns
foreach l in 2 3 4 5 {
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
putdocx table pooled_res(`rowcount',`l')=("`hrres'"), halign(center) valign(center) font("","9") linebreak bold
putdocx table pooled_res(`rowcount',`l')=("`ci'"), halign(center) valign(center) font("","9") append bold
putdocx table pooled_res(`rowcount',`l'), shading(${waterloo}) 
}
*above 1
if `lb'>1  & `ub'>1 & `ub'<.  {
putdocx table pooled_res(`rowcount',`l')=("`hrres'"),   halign(center) valign(center)  font("","9") linebreak bold
putdocx table pooled_res(`rowcount',`l')=("`ci'"),   halign(center) valign(center)  font("","9") append bold
putdocx table pooled_res(`rowcount',`l'), shading(${hammersmith}) 
}

*includes 1
if `lb'<1  & `ub'>1 & `ub'<.  {
putdocx table pooled_res(`rowcount',`l')=("`hrres'"),  halign(center) valign(center)   font("","9") linebreak
putdocx table pooled_res(`rowcount',`l')=("`ci'"),  halign(center) valign(center)   font("","9") append

}

*includes 1 but p<0.1 and HR<1
if `lb'<1  & `ub'>1 & `ub'<. & `pres'<0.1 & `hr'<1  {
putdocx table pooled_res(`rowcount',`l')=("`hrres'"),  halign(center) valign(center)  font("","9") linebreak
putdocx table pooled_res(`rowcount',`l')=("`ci'"),  halign(center) valign(center)  font("","9")  append
putdocx table pooled_res(`rowcount',`l'), shading("237 247 244")  
}

*includes 1 but p<0.1 and HR>1
if `lb'<1  & `ub'>1 & `ub'<. & `pres'<0.1 & `hr'>1 & `hr'<.  {
putdocx table pooled_res(`rowcount',`l')=("`hrres'"),  halign(center) valign(center)   font("","9") linebreak
putdocx table pooled_res(`rowcount',`l')=("`ci'"),  halign(center) valign(center)   font("","9") append
putdocx table pooled_res(`rowcount',`l'), shading("252 232 238") 

}

*if it is baseline category

if `baseline'==1  & int(`hrres')==1  {
putdocx table pooled_res(`rowcount',`l')=("1"),  halign(center) valign(center)  font("","9","31 62 97")
putdocx table pooled_res(`rowcount',`l'), shading("236 242 249") 
}


***** PUT IN A - IF THERE WAS NO DATA AND ** IF THERE WERE NO FAILURES
local flag=flag`counter'[`x']
if `flag'==1 {
putdocx table pooled_res(`rowcount',`l')=("**"),  font("","9") halign(center) valign(center) linebreak
}

local notime=no_pyrs`counter'[`x']
if `notime'==1 {
putdocx table pooled_res(`rowcount',`l')=("-"),  font("","9") halign(center) valign(center) linebreak
}


local counter=`counter'+1
} /* close letter loop */



*go to next row
local rowcount=`rowcount'+1


} /* close values loop */
} /*close variable loop (varname) */
} /* close framework loop */


*----------------------------------------------------------------------------



putdocx save "${alphapath}/ALPHA/projects/gates_incidence_risks_2019/results/for_paper/Table_of_pooled_siteadj_crude_HR.docx",replace






