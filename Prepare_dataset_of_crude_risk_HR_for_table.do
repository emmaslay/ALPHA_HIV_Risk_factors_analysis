
*********************************************************************************
*	THIS:
*	COMBINES ALL THE INDIVIDUAL (SITE, RISK, SEX, AGE ESTIMATES) 					
*	it makes-
*	${alphapath}/ALPHA/projects/gates_incidence_risks_2019/results/pooled/site_specific_hr_summary
*	${alphapath}/ALPHA/projects/gates_incidence_risks_2019/results/pooled/site_specific_hr_summary_for_green_red_table																		*
*	includes all pooled results then retains only the site adjusted ones
*********************************************************************************


cd "${alphapath}/ALPHA/projects/gates_incidence_risks_2019/results/pooled"

 /* removed the all age result as not using them
clear
 local applist :dir . files "aw_*"
 append using `applist'
 
 save crude_risks_women_all,replace
*/
  clear
 local applist :dir . files "yw_*"
 append using `applist'
 
 save crude_risks_women_young,replace
 
  clear
 local applist :dir . files "ow_*"
 append using `applist'
 
 save crude_risks_women_older,replace
 
/*
 clear
 local applist :dir . files "am_*"
 append using `applist'
 
 save crude_risks_men_all,replace
*/
 
  clear
 local applist :dir . files "ym_*"
 append using `applist'
 
 save crude_risks_men_young,replace
 
  clear
 local applist :dir . files "om_*"
 append using `applist'
 
 save crude_risks_men_older,replace
 

*** COMBINE INTO ONE DATASET
use "${alphapath}/ALPHA/projects/gates_incidence_risks_2019/results/pooled/crude_risks_women_young",clear
gen sex=2 
gen youth=1 

append using "${alphapath}/ALPHA/projects/gates_incidence_risks_2019/results/pooled/crude_risks_women_older"
replace sex=2 if sex==.
replace youth=2 if youth==.

append using "${alphapath}/ALPHA/projects/gates_incidence_risks_2019/results/pooled/crude_risks_men_young"
replace sex=1 if sex==.
replace youth=1 if youth==.

append using "${alphapath}/ALPHA/projects/gates_incidence_risks_2019/results/pooled/crude_risks_men_older"
replace sex=1 if sex==.
replace youth=2 if youth==.


keep idnum idstr stderr estimate p stars min95 max95 sex youth parm es*
rename estimate hr
rename idnum study_name
label define study_name 0 "Pooled" 1 "Karonga" 2 "Kisesa" 3 "Manicaland" 4 "Masaka" 5 "Rakai" 6 "uMkhanyakude" 8 "Kisumu" 9 "Ifakara",modify
label values study_name study_name
replace study_name=0 if study_name>4 & study_name<5
replace study_name=0 if study_name==.
label define youth 0 "15-49" 1 "15-24" 2 "25-49",modify
label values youth youth

drop stderr
rename min95 lb 
rename max95 ub
drop if parm=="_cons"

*identify records that are for omitted categories
gen omitted=1 if substr(parm,2,2)=="o." |  substr(parm,3,2)=="o."
recode omitted .=0
*identify records that are for baseline categories
gen baseline=1 if substr(parm,2,2)=="b." |  substr(parm,3,2)=="b."
recode baseline .=0
*identify records where there is an interaction
gen interaction=strmatch(parm,"*#*")
**Sort out study interaction baselines
gen int_baseline=strmatch(parm,"*#?b*")


*Get nice value text and a neat value code
replace parm=subinstr(parm,"."," ",.)
replace parm=subinstr(parm,"#"," # ",.)
gen valstr=word(parm,1)
replace valstr=subinstr(valstr,"b","",.)
replace valstr=subinstr(valstr,"o","",.)
gen val=real(valstr)
drop valstr
replace idstr=subinstr(idstr,"."," ",.)
replace idstr=subinstr(idstr,"#"," # ",.)


**get variable with varname text
gen varname=word(idstr,2) 

*Identify interactions
gen intstr=word(parm,4)
gen interaction_var=word(idstr,5) + " " + intstr
replace interaction_var="" if interaction==0
** add some nice text here, manually for now
replace interaction_var=" uMkhanyakude" if interaction_var=="s_6 1"

*find the siteadj estimates for pooled and retain those and not the other pooled ones
gen siteadj=1 if   substr(idstr,1,7)=="siteadj"
recode siteadj .=0
replace siteadj=0 if study_name==0 & siteadj==1 & strmatch(parm,"*study_name")
*drop the non-site adjusted estimates and the study estimates that come with each variable estimate
drop if study_name==0 & siteadj==0


*fill in the continuous vars
replace varname=word(idstr,1) if val==.
gen refcatstr=substr(parm,2,1)
gen refcat=0
replace refcat=1 if (refcatstr=="b" & val<.) | (refcatstr=="o" & val<.)
drop refcatstr

/*
*sort out the fixed effect for study in the estimates from the pooled dataset- get rid of them
replace varname=word(idstr,2) if study_name==0 & varname==""
gen varname2=word(parm,2)
replace varname2=word(parm,1) if val==.
drop if study_name==0 & varname~=varname2


*** NEED TO DROP ANY RECORDS WHERE A CATEGORY WAS OMITTED- NOT INFORMATIVE AND INTRODUCES DUPLICATE RECORDS LATER
drop if omitted==1
*/

drop siteadj


*** ALSO NEED TO DROP NONSENSE COEFFICIENTS FOR ANY CATEGORIES WHERE THERE WEREN'T ENOUGH EVENTS TO MAKE A PROPER ESTIMATE

preserve
use "${alphapath}/ALPHA\Projects\Gates_incidence_risks_2019\results\Pooled\Risk_dist/everything_pooled_prev_by_study_name_sex_youth",clear
recode youth 0=2
gen varname_for_merge=varname
gen interaction=0
gen interaction_var=""
keep sex study_name val youth fup_mod fails_mod people_mod varname_for_merge varname interaction interaction_var
save "${alphapath}/ALPHA\Projects\Gates_incidence_risks_2019\results\Pooled\Risk_dist/fup_and_fails_by_study_name_sex_youth",replace
restore

*gen varname_for_merge=subinstr(varname,"tv_","",.)
merge 1:1 study_name sex youth varname val interaction interaction_var using "${alphapath}/ALPHA\Projects\Gates_incidence_risks_2019\results\Pooled\Risk_dist/fup_and_fails_by_study_name_sex_youth"
*looks like those who don't merge are the ones where categories have dropped out of models. carry on and see if looks ok




drop varname_for_merge 
rename _m merge_with_N
drop if merge_with_N==2

gen flag=0
replace flag=1 if baseline==0 & ub==.
replace flag=1 if baseline==0 & ub>10000
label var flag "Estimate not good- check N - due to mean across imp of <2 failures in grp"


**suppress HR where there were no failures in category or the small nos mean the ub was huge
*NB not just supressing all where N fails was small because some estimates are good at a mean of 2 fails across imputations while others fail with 5
replace hr=. if flag==1
replace ub=. if flag==1
replace lb=. if flag==1

*make an indicator for categories where there was no data- no pyrs
gen no_pyrs=0 if fup_mod<.
replace no_pyrs=1 if fup_mod<1
replace no_pyrs=0 if baseline==1 



save ${alphapath}/ALPHA/projects/gates_incidence_risks_2019/results/pooled/site_specific_hr_summary,replace




*================================================================
*** MAKE A SUMMARY DATASET FOR HR TO USE WHEN EXPORTING TO EXCEL
*================================================================
*need to get labels
 use "K:\ALPHA\Incidence_ready_data\pooled\mi_data\incidence_ready_risk_factors_MI_pooled_1.dta", clear
label define yesnodk 0 "No" 1 "Yes" 9 "No data",modify
label values mobile tv_morethan1 tv_casual tv_regular tv_new_partner tv_anylost yesnodk
label save _all using all_the_labels.do,replace


use ${alphapath}/ALPHA/projects/gates_incidence_risks_2019/results/pooled/site_specific_hr_summary,clear


do all_the_labels.do
*this matches up the ones where the variable name is the same as the label name
gen vallab=""
levels varname,local(vlist)
foreach v in `vlist' {
	levels val if varname=="`v'",local(vallist)
	foreach val in `vallist' {
local valname: label `v' `val'
replace vallab="`valname'" if varname=="`v'" & val==`val'
} /* close values loop */
} /*close var loop */


*now for the others- yes no ones
foreach v in mobile tv_morethan1 tv_casual tv_regular tv_new_partner tv_anylost {
	levels val if varname=="`v'",local(vallist)
	foreach val in `vallist' {
local valname: label yesnodk `val'
replace vallab="`valname'" if varname=="`v'" & val==`val'
} /* close values loop */
} /*close var loop */

*partners' age
	levels val if varname=="tv_pagegrp",local(vallist)
	foreach val in `vallist' {
local valname: label pagegrp `val'
replace vallab="`valname'" if varname=="tv_pagegrp" & val==`val'
} /* close values loop */

**condom use

	levels val if varname=="tv_clastyr",local(vallist)
	foreach val in `vallist' {
local valname: label clastyr_summary `val'
replace vallab="`valname'" if varname=="tv_clastyr" & val==`val'
} /* close values loop */


** tidy up labels for study interactions so that the baseline group for the interaction variable lines up with everyone else

*change the values for the interactions so they have their own group
levels varname,local(vlist)
foreach v in `vlist' {
*Need to work out how many values there already are
unique val if varname=="`v'"
local toadd=r(unique)
replace val=val + `toadd' if interaction==1 & int_b==0 & varname=="`v'"
}


*add the interaction var to the vallab for the interaction ones
replace vallab=vallab + interaction_var if interaction==1 & int_b==0



**fix the varname for the continuous pooled siteadj estimates
replace varname=substr(varname,9,.) if substr(varname,1,8)=="siteadj_"






gen framework=.
replace framework=	0	if varname=="study_name"
replace framework=	1	if varname=="youth"
replace framework=	2	if varname=="sex"
replace framework=	3	if varname=="tv_educ"
replace framework=	6	if varname=="residence"
replace framework=	7	if varname=="mobile"
replace framework=	11	if varname=="fouryear"
replace framework=	12	if varname=="same_sex_par"
replace framework=	13	if varname=="same_sex_plr"
replace framework=	14	if varname=="opp_sex_par"
replace framework=	15	if varname=="opp_sex_plr"
replace framework=	17	if varname=="tv_mstat_br"
replace framework=	18	if varname=="tv_ptnrs"
replace framework=	19	if varname=="tv_morethan1"
replace framework=	20	if varname=="tv_casual"
replace framework=	21	if varname=="tv_regular"
replace framework=	22	if varname=="tv_pagegrp"
replace framework=	23	if varname=="untreated_opp_sex_prevalence"
replace framework=	29	if varname=="tv_new_partner"
replace framework=	31	if varname=="tv_cf_all"
replace framework=	32	if varname=="tv_circumcised"
replace framework=	33	if varname=="tv_clastyr"
replace framework=	36	if varname=="tv_anylost"

#delimit;
label define framework
0	"Study name"
1	"Age group"
2	"Sex"
3	"Education"
6	"Urban or rural Resident"
7	"Moved house in the last year"
11	"Calendar year (grouped)"
12	"Partner acquisition rate among peers"
13	"Partner loss rate among peers"
14	"Partner acquisition rate in potential opposite sex partners"
15	"Partner loss rate in potential opposite sex partners"
17	"Current marital status"
18	"Number of partners in the last year"
19	"Had more than one partner in the last year"
20	"Had a casual partner in the last year"
21	"Had a regular partner in the last year"
22	"Age difference(s) with partners in the last year"
23	"Prevalence of untreated infection in potential opposite sex partners"
29	"Had a new partner in the last year"
31	"Coital frequency with all partners in the last year"
32	"Is circumcised"
33	"Condoms used consistently with all partners in the last year"
36	"Ended a partnership in the last year"
,modify;
#delimit cr
label values framework framework

gen str50 varlab=""
replace varlab="Study name"	if varname=="study_name"
replace varlab="Age group"	if varname=="youth"
replace varlab="Sex"	if varname=="sex"
replace varlab="Education"	if varname=="tv_educ"
replace varlab="Urban or rural Resident"	if varname=="residence"
replace varlab="Moved house in the last year"	if varname=="mobile"
replace varlab="Calendar year (grouped)"	if varname=="fouryear"
replace varlab="Partner acquisition rate among peers"	if varname=="same_sex_par"
replace varlab="Partner loss rate among peers"	if varname=="same_sex_plr"
replace varlab="Partner acquisition rate in potential opposite sex partners"	if varname=="opp_sex_par"
replace varlab="Partner loss rate in potential opposite sex partners"	if varname=="opp_sex_plr"
replace varlab="Current marital status"	if varname=="tv_mstat_br"
replace varlab="Number of partners in the last year"	if varname=="tv_ptnrs"
replace varlab="Had more than one partner in the last year"	if varname=="tv_morethan1"
replace varlab="Had a casual partner in the last year"	if varname=="tv_casual"
replace varlab="Had a regular partner in the last year"	if varname=="tv_regular"
replace varlab="Age difference(s) with partners in the last year"	if varname=="tv_pagegrp"
replace varlab="Prevalence of untreated infection in potential opposite sex partners"	if varname=="untreated_opp_sex_prevalence"
replace varlab="Had a new partner in the last year"	if varname=="tv_new_partner"
replace varlab="Coital frequency with all partners in the last year"	if varname=="tv_cf_all"
replace varlab="Is circumcised"	if varname=="tv_circumcised"
replace varlab="Condoms used consistently with all partners in the last year"	if varname=="tv_clastyr"
replace varlab="Ended a partnership in the last year"	if varname=="tv_anylost"
label var varlab "Nice label for explan variables"


recode study_name (0=9 "Pooled") (9=1 "Ifakara") (1=2 "Karonga") (2=3 "Kisesa") (8=4 "Kisumu") (3=5 "Manicaland") (4=6 "Masaka") (5=7 "Rakai") (6=8 "uMkhanyakude") ,gen(s)
rename es_4 n_imp_used
drop es*

drop idstr
drop study_name

format %4.3f hr lb ub
format %-06.4f p

/*
*** tables to check excel results against
di "Young men"
table (framework val) (s) if sex==1 & youth==1,stat(min hr) nformat(%4.3f) nototals

di "Older men"
table (framework val) (s) if sex==1 & youth==2,stat(min hr) nformat(%4.3f) nototals

di "Young women"
table (framework val) (s) if sex==2 & youth==1,stat(min hr) nformat(%4.3f) nototals

di "Older women"
table (framework val) (s) if sex==2 & youth==2,stat(min hr) nformat(%4.3f) nototals
*/




*SAVE LONG FILE (USED TO MAKE POOLED TABLE)

save ${alphapath}/ALPHA/projects/gates_incidence_risks_2019/results/pooled/site_specific_hr_summary_long,replace

*NOW MAKDE WIDE AND TIDY FOR SITE-SPECIFIC TABLE

gen not_omitted_not_baseline=0 if omitted==1 | baseline==1
replace not_omit=1 if baseline==0  & omitted==0

bys sex youth varname s: egen compar=max(not_omit)
label var compar "Model can be estimated"

drop omitted refcat parm not_omitt int_baseline
*drop the interaction terms for reshape. NB if end up with more interactions need a better way
drop interaction interaction_var intstr


*********************************
*Some models couldn't be fitted because there were too few fails and Stata hasn't even tried so no estimate was saved
*indicate this so it can be noted in table
gen no_model_flag=0
*Ifakara (mostly affects Ifakara)
*everyone
replace no_model=1 if s==1 & varname=="tv_clastyr"
*young men
replace no_model=1 if s==1 & sex==1 & youth==1 & (varname=="tv_ptnrs" | varname=="tv_pagegrp" | varname=="fouryear"  | varname=="tv_mstat_br" | varname=="tv_morethan1" | varname=="tv_casual" | varname=="tv_regular" | varname=="tv_new_partner" | varname=="tv_anylost" | varname=="tv_circumcised")
*young women
*replace no_model=1 if s==1 & sex==2 & youth==1 & (varname=="mobile" | varname=="residence" | varname=="tv_clastyr"  | varname=="tv_mstat_br" )






*************************************



reshape wide hr p stars lb ub fup_mod fails_mod people_mod no_model_flag flag no_pyrs n_imp_used compar merge_with_N baseline,i(sex youth varname val ) j(s)


**SAVE WIDE FILE

save ${alphapath}/ALPHA/projects/gates_incidence_risks_2019/results/pooled/site_specific_hr_summary_for_green_red_table,replace

/**NB if the bit above breaks because of a reshape error due to duplicates, need to check in the folder to see if some of the
results datasets are duplicated- can happen if the models have been run at different times with different
baseline because the baseline is included in the filename */






