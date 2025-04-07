
* finished July 2022

**** MAKES A DATASET WHICH CONTAINS INFORMATION NEEDED FOR DESCRIPTION OF THE DATA AND RISK FACTOR DISTRIBUTION
*output dataset called ${alphapath}/ALPHA\Projects\Gates_incidence_risks_2019\results\Pooled\Risk_dist/pooled_prev_everything_by`summary_list'

*CATAGORICAL VARIABLES- DONE FIRST. NUMBERS OF PYRS, FAILURES AND PEOPLE ACROSS IMPUTATIONS PUT IN DATASET



***** Gets the N people, person years and N failures by site
/*distribution of person years and seroconversions by:
IN FIRST LOOP 
 
sex  
youth 
fouryear 
residence
mobile 
tv_mstat_br 
 tv_circumcised 
 tv_morethan1 
tv_ptnrs 
tv_regular 
tv_casual  
tv_new_partner  
tv_clastyr 
tv_pagegrp 
tv_anylost 

AND IN SECOND LOOP
opp_sex_par 
opp_sex_plr 
same_sex_par 
same_sex_plr 
untreated_opp_sex_prevalence


**cat but not in pooled data
tv_spouse 
tv_cf_all 
tv_partners_life_grp 
tv_sumlastyear
tv_timesincefirstsex

*/

*+=+=+=+=+=+=+=+=+=*****************+=+=+=+=+=+=+=+=+=**************+=+=+=+=+=+=+=+=+=
*
* NEED TO DO EVERYTHING TWICE, ONCE BY SITE AND ONCE WITHOUT study_name TO GET POOLED
*
*+=+=+=+=+=+=+=+=+=*****************+=+=+=+=+=+=+=+=+=**************+=+=+=+=+=+=+=+=+=

*NEED TO DECIDE ON THE SUMMARY VARIABLES- do more here, can aggregate at the end (except for the rates, may have to ammend that)

local summary_list=" study_name sex youth"
local summary_list_pooled=" sex youth"

*!!!!!!!!!!!! this isn't really working as I have repeated this further down a few times

************************************************************************************
*				FIRST LOOP FOR CATEGORICAL VARIABLES
************************************************************************************
 


#delimit ;
global risklist_fv "
fouryear 
residence
mobile 
tv_mstat_br
 tv_morethan1 
tv_ptnrs 
tv_regular 
tv_casual  
tv_new_partner  
tv_clastyr 
tv_pagegrp 
tv_anylost 
tv_educ
 tv_circumcised 

tv_cf_all
 ";
#delimit cr


/*

*/

**  **  **  **  **  **  **  **
** *IMPUTATION 1
**  **  **  **  **  **  **  **
foreach risk in $risklist_fv {
cap erase ${alphapath}/ALPHA\Projects\Gates_incidence_risks_2019\results\Pooled\Risk_dist/by_study_prev_`risk'
cap erase ${alphapath}/ALPHA\Projects\Gates_incidence_risks_2019\results\Pooled\Risk_dist/pooled_prev_`risk'
cap erase ${alphapath}/ALPHA\Projects\Gates_incidence_risks_2019\results\Pooled\Risk_dist/by_study_prev_`risk'
cap erase ${alphapath}/ALPHA\Projects\Gates_incidence_risks_2019\results\Pooled\Risk_dist/pooled_and_by_study_prev_`risk'


use _* age years_one study_name idno fouryear `summary_list' `risk' using  "${alphapath}/ALPHA\Incidence_ready_data\pooled\mi_data\incidence_ready_risk_factors_MI_pooled_1.dta",clear
keep if age<50 & age>14
keep if years_one>2004 & years_one<2017
drop if study==1 & fouryear==4
drop if study==3 & fouryear==4


gen fup=_t-_t0
gen fails=_d
sort `risk' youth idno _t0
by `risk' youth idno:gen people=1 if _n==1
cap streg  i.`risk',d(e)
if _rc==0 {
qui streg  i.`risk',d(e)
gen touse=e(sample)
gen fup_mod=_t-_t0 if touse==1
gen fails_mod=_d if touse==1
gen people_mod=people if touse==1
}
else {
gen fup_mod=.
}
collapse (sum) fup fup_mod fails fails_mod people people_mod ,by(`summary_list' `risk' )


keep `summary_list' `risk'  fup fup_mod fails fails_mod people people_mod
gen imp=1
gen catagorical=1
save ${alphapath}/ALPHA\Projects\Gates_incidence_risks_2019\results\Pooled\Risk_dist/by_study_prev_`risk',replace

collapse (sum) fup fup_mod fails fails_mod people people_mod ,by(`summary_list_pooled' `risk' )
gen imp=1
gen categorical=1
save ${alphapath}/ALPHA\Projects\Gates_incidence_risks_2019\results\Pooled\Risk_dist/pooled_prev_`risk',replace


**  **  **  **  **  **  **  **
** SUBSEQUENT IMPUTATIONS
**  **  **  **  **  **  **  **

forvalues x=1/$useimp {

use  _* age years_one study_name idno fouryear `summary_list' `risk' using  "${alphapath}/ALPHA\Incidence_ready_data\pooled\mi_data\incidence_ready_risk_factors_MI_pooled_`x'.dta",clear
keep if age<50  & age>14
keep if years_one>2004 & years_one<2017
drop if study==1 & fouryear==4
drop if study==3 & fouryear==4

gen fup=_t-_t0
gen fails=_d
sort `risk' youth idno _t0
by `risk' youth idno:gen people=1 if _n==1
cap streg  i.`risk',d(e)
if _rc==0 {
qui streg  i.`risk',d(e)
gen touse=e(sample)
gen fup_mod=_t-_t0 if touse==1
gen fails_mod=_d if touse==1
gen people_mod=people if touse==1
}
else {
gen fup_mod=.
}
collapse (sum) fup fup_mod fails fails_mod people people_mod ,by(`summary_list' `risk' )

tempfile firstcollapse
save `firstcollapse',replace

keep `summary_list' `risk'  fup fup_mod fails fails_mod people people_mod
gen imp=`x'
gen categorical=1
append using ${alphapath}/ALPHA\Projects\Gates_incidence_risks_2019\results\Pooled\Risk_dist/by_study_prev_`risk'
save ${alphapath}/ALPHA\Projects\Gates_incidence_risks_2019\results\Pooled\Risk_dist/by_study_prev_`risk',replace

use `firstcollapse',clear
collapse (sum) fup fup_mod fails fails_mod people people_mod ,by(`summary_list_pooled' `risk' )
gen imp=`x'
gen categorical=1 
append using ${alphapath}/ALPHA\Projects\Gates_incidence_risks_2019\results\Pooled\Risk_dist/pooled_prev_`risk'

save ${alphapath}/ALPHA\Projects\Gates_incidence_risks_2019\results\Pooled\Risk_dist/pooled_prev_`risk',replace



}  /*close imputations loop */




**** take mean over imputations
use ${alphapath}/ALPHA\Projects\Gates_incidence_risks_2019\results\Pooled\Risk_dist/by_study_prev_`risk',clear
append using  ${alphapath}/ALPHA\Projects\Gates_incidence_risks_2019\results\Pooled\Risk_dist/pooled_prev_`risk'
replace study_name=0 if study_name==.

collapse (mean) fup fup_mod fails fails_mod people people_mod ,by(`summary_list' `risk' )
gen str20 varname="`risk'"
rename `risk' val

recode study_name (0=10 "Pooled") (9=1 "Ifakara") (1=2 "Karonga") (2=3 "Kisesa") (8=4 "Kisumu") (3=5 "Manicaland") (4=6 "Masaka") (5=7 "Rakai") (6=8 "uMkhanyakude"),gen(site)
gen var_type=1
label data "Pooled incidence risk factors- distribution of risks"
local vallab: value label val
if "`vallab'"~="" {
decode val,gen(valstr)
}
else {
gen valstr=string(val)
}

save ${alphapath}/ALPHA\Projects\Gates_incidence_risks_2019\results\Pooled\Risk_dist/pooled_and_by_study_prev_`risk',replace


} /*close factor var risk loop */

*/

************************************************************************************
*				SECOND LOOP FOR CONTINUOUS VARIABLES
************************************************************************************
** Here we want the mean of the vars, weighted by the person time on each record.
*So take the mean across all obs in one imputation and then the mean of the means across imputations



#delimit ;
global risklist_fv "
opp_sex_par 
opp_sex_plr 
same_sex_par 
same_sex_plr 
untreated_opp_sex_prevalence
";
#delimit cr


**  **  **  **  **  **  **  **
** *IMPUTATION 1
**  **  **  **  **  **  **  **
foreach risk in $risklist_fv {

*first time through - loop by study
cap erase ${alphapath}/ALPHA\Projects\Gates_incidence_risks_2019\results\Pooled\Risk_dist/by_study_prev_`risk'
cap erase ${alphapath}/ALPHA\Projects\Gates_incidence_risks_2019\results\Pooled\Risk_dist/pooled_prev_`risk'
cap erase ${alphapath}/ALPHA\Projects\Gates_incidence_risks_2019\results\Pooled\Risk_dist/pooled_and_by_study_prev_`risk'

use  _* age years_one study_name idno fouryear `summary_list' `risk' using  "${alphapath}/ALPHA\Incidence_ready_data\pooled\mi_data\incidence_ready_risk_factors_MI_pooled_1.dta",clear
keep if age<50 & age>14
keep if years_one>2004 & years_one<2017
drop if study==1 & fouryear==4
drop if study==3 & fouryear==4

*** Get the mean of each var  
qui streg  `risk',d(e)
gen touse=e(sample)
gen fup_mod=_t-_t0 if touse==1
gen dummy=1


collapse (mean) `risk' (sum) fup=dummy [iw=fup_mod]if touse==1 ,by( `summary_list'  )

gen imp=1

save ${alphapath}/ALPHA\Projects\Gates_incidence_risks_2019\results\Pooled\Risk_dist/by_study_prev_`risk',replace

*second time for pooled
cap erase ${alphapath}/ALPHA\Projects\Gates_incidence_risks_2019\results\Pooled\Risk_dist/pooled_prev_`risk'
use  _* age years_one study_name idno fouryear `summary_list_pooled' `risk' using  "${alphapath}/ALPHA\Incidence_ready_data\pooled\mi_data\incidence_ready_risk_factors_MI_pooled_1.dta",clear
keep if age<50 & age>14
keep if years_one>2004 & years_one<2017
drop if study==1 & fouryear==4
drop if study==3 & fouryear==4

*** Mean of each var
qui streg  `risk',d(e)
gen touse=e(sample)
gen fup_mod=_t-_t0 if touse==1
gen dummy=1


collapse (mean) `risk' (sum) fup=dummy [iw=fup_mod] if touse==1 ,by( `summary_list_pooled'  )

gen imp=1

save ${alphapath}/ALPHA\Projects\Gates_incidence_risks_2019\results\Pooled\Risk_dist/pooled_prev_`risk',replace



**  **  **  **  **  **  **  **
** SUBSEQUENT IMPUTATIONS
**  **  **  **  **  **  **  **

forvalues x=1/$useimp {
*by study
use  _* age years_one study_name idno fouryear `summary_list' `risk' using "${alphapath}/ALPHA\Incidence_ready_data\pooled\mi_data\incidence_ready_risk_factors_MI_pooled_`x'.dta",clear
keep if age<50  & age>14
keep if years_one>2004 & years_one<2017
drop if study==1 & fouryear==4
drop if study==3 & fouryear==4

*** Mean of each var
qui streg  `risk',d(e)
gen touse=e(sample)
gen fup_mod=_t-_t0 if touse==1
gen dummy=1


collapse (mean) `risk' (sum) fup=dummy [iw=fup_mod] if touse==1,by( `summary_list'  )

gen imp=`x'
append using ${alphapath}/ALPHA\Projects\Gates_incidence_risks_2019\results\Pooled\Risk_dist/by_study_prev_`risk'

save ${alphapath}/ALPHA\Projects\Gates_incidence_risks_2019\results\Pooled\Risk_dist/by_study_prev_`risk',replace


***Pooled
use  _* age years_one study_name idno fouryear `summary_list_pooled' `risk' using "${alphapath}/ALPHA\Incidence_ready_data\pooled\mi_data\incidence_ready_risk_factors_MI_pooled_`x'.dta",clear
keep if age<50  & age>14
keep if years_one>2004 & years_one<2017
drop if study==1 & fouryear==4
drop if study==3 & fouryear==4

*** Mean of each var
qui streg  `risk',d(e)
gen touse=e(sample)
gen fup_mod=_t-_t0 if touse==1
gen dummy=2


collapse (mean) `risk' (sum) fup=dummy [iw=fup_mod] ,by( `summary_list_pooled'  )

gen imp=`x'
append using ${alphapath}/ALPHA\Projects\Gates_incidence_risks_2019\results\Pooled\Risk_dist/pooled_prev_`risk'

save ${alphapath}/ALPHA\Projects\Gates_incidence_risks_2019\results\Pooled\Risk_dist/pooled_prev_`risk',replace



}  /*close imputations loop */



use ${alphapath}/ALPHA\Projects\Gates_incidence_risks_2019\results\Pooled\Risk_dist/by_study_prev_`risk',clear
append using ${alphapath}/ALPHA\Projects\Gates_incidence_risks_2019\results\Pooled\Risk_dist/pooled_prev_`risk',
replace study_name=0 if study_name==.

collapse (mean) `risk' fup  ,by(`summary_list' )
gen str30 varname="`risk'"
rename `risk' table_contents
gen var_type=2
recode study_name (9=1 "Ifakara") (1=2 "Karonga") (2=3 "Kisesa") (8=4 "Kisumu") (3=5 "Manicaland") (4=6 "Masaka") (5=7 "Rakai") (6=8 "uMkhanyakude"),gen(site)

label data "Pooled incidence risk factors- distribution of risks"

save ${alphapath}/ALPHA\Projects\Gates_incidence_risks_2019\results\Pooled\Risk_dist/pooled_and_by_study_prev_`risk',replace


} /*close CONTINUOUS var risk loop for studies */


************************************************************************************
* REPEAT JUST FOR SITE AS AN EXPOSURE FOR POOLED DATA
************************************************************************************
cap erase ${alphapath}/ALPHA\Projects\Gates_incidence_risks_2019\results\Pooled\Risk_dist/pooled_prev_SITE
cap erase ${alphapath}/ALPHA\Projects\Gates_incidence_risks_2019\results\Pooled\Risk_dist/pooled_and_by_study_prev_SITE


use _* age years_one study_name idno fouryear sex youth using  "${alphapath}/ALPHA\Incidence_ready_data\pooled\mi_data\incidence_ready_risk_factors_MI_pooled_1.dta",clear
keep if age<50 & age>14
keep if years_one>2004 & years_one<2017
drop if study==1 & fouryear==4
drop if study==3 & fouryear==4


gen fup=_t-_t0
gen fails=_d
sort study_name idno youth _t0
by study_name idno youth:gen people=1 if _n==1
cap streg  i.study_name,d(e)
if _rc==0 {
qui streg  i.study_name,d(e)
gen touse=e(sample)
gen fup_mod=_t-_t0 if touse==1
gen fails_mod=_d if touse==1
gen people_mod=people if touse==1
}
else {
gen fup_mod=.
}
collapse (sum) fup fup_mod fails fails_mod people people_mod ,by(sex youth study_name)


keep sex youth study_name  fup fup_mod fails fails_mod people people_mod

collapse (sum) fup fup_mod fails fails_mod people people_mod ,by(sex youth study_name )
gen imp=1
gen categorical=1
save ${alphapath}/ALPHA\Projects\Gates_incidence_risks_2019\results\Pooled\Risk_dist/pooled_prev_SITE,replace


**  **  **  **  **  **  **  **
** SUBSEQUENT IMPUTATIONS
**  **  **  **  **  **  **  **

forvalues x=1/$useimp {

use _* age years_one study_name idno fouryear sex youth  using  "${alphapath}/ALPHA\Incidence_ready_data\pooled\mi_data\incidence_ready_risk_factors_MI_pooled_`x'.dta",clear
keep if age<50 & age>14
keep if years_one>2004 & years_one<2017
drop if study==1 & fouryear==4
drop if study==3 & fouryear==4
keep if _st==1

gen fup=_t-_t0
gen fails=_d
sort study_name idno youth _t0
by study_name idno youth:gen people=1 if _n==1
cap streg  i.study_name,d(e)
if _rc==0 {
qui streg  i.study_name,d(e)
gen touse=e(sample)
gen fup_mod=_t-_t0 if touse==1
gen fails_mod=_d if touse==1
gen people_mod=people if touse==1
}
else {
gen fup_mod=.
}
collapse (sum) fup fup_mod fails fails_mod people people_mod ,by(sex youth study_name)


keep sex youth study_name  fup fup_mod fails fails_mod people people_mod

collapse (sum) fup fup_mod fails fails_mod people people_mod ,by(sex youth study_name )
gen imp=`x'
gen categorical=1
append using ${alphapath}/ALPHA\Projects\Gates_incidence_risks_2019\results\Pooled\Risk_dist/pooled_prev_SITE
save ${alphapath}/ALPHA\Projects\Gates_incidence_risks_2019\results\Pooled\Risk_dist/pooled_prev_SITE,replace

}  /*close imputations loop */


**** take mean over imputations
use ${alphapath}/ALPHA\Projects\Gates_incidence_risks_2019\results\Pooled\Risk_dist/pooled_prev_SITE,clear

collapse (mean) fup fup_mod fails fails_mod people people_mod ,by(sex youth study_name)
gen str20 varname="Study"
rename study_name val

gen var_type=1

local vallab: value label val
if "`vallab'"~="" {
decode val,gen(valstr)
}
else {
gen valstr=string(val)
}
save ${alphapath}/ALPHA\Projects\Gates_incidence_risks_2019\results\Pooled\Risk_dist/pooled_and_by_study_prev_SITE,replace




************************************************************************************
*				COMBINE ALL THE DATASETS INTO ONE
************************************************************************************
local summary_list="study_name sex youth"
local summary_list_pooled=" sex youth"
local summary_list=subinstr("`summary_list'"," ","_",.)

cd ${alphapath}/ALPHA\Projects\Gates_incidence_risks_2019\results\Pooled\Risk_dist/
clear
local filelist: dir . files "pooled_and_by_study_prev_*.dta"
append using `filelist'
label values val

label var table_contents "Mean of mean across impuations for continuous variables"
label var val "Value of categorical variable"
label var varname "Name of variable"
label var var_type "Continuous or categorical variable"
label var valstr "String of categorical variable values"

label var fup "Follow up time, mean across imputations"
label var fup_mod "Follow up time, mean across imputations, only people in st models"

label var people "N individuals, mean across imputations"
label var people_mod "N individuals, mean across imputations, only people in st models"

label var fails "N seroconversions, mean across imputations"
label var fails_mod "N seroconversions, mean across imputations, only people in st models"




label define var_type 1 "categorical" 2 "continuous",modify
label values var_type var_type

local summary_list=subinstr("`summary_list'"," ","_",.)

*** add description into valstr for the continuous variables as otherwise they don't feature in the table
replace valstr="-" if var_type==2


label define study_name 0 "pooled",modify
recode site 0=10

*make a numeric var for the risk factor
#delimit ;

label define risklab 
0 "Study"
1 "youth"
2 "sex"
3 "tv_educ"
6 "residence"
7 "mobile"
11 "fouryear"
12 "same_sex_par"
13 "same_sex_plr"
14 "opp_sex_par"
15 "opp_sex_plr"
17 "tv_mstat_br"
18 "tv_ptnrs"
19 "tv_morethan1"
20 "tv_casual"
21 "tv_regular"
22 "tv_pagegrp"
23 "untreated_opp_sex_prevalence"
29 "tv_new_partner"
31 "tv_cf_all"
32 "tv_circumcised"
33 "tv_clastyr"
36 "tv_anylost"

,modify;
#delimit cr

encode varname,gen(explan_var) label(risklab)
label var explan_var "Nicely coded and labelled version of varname"

*Now give each risk factor a nice label
#delimit ;

label define risklab 
0 	"Study name"
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

*fup for continuous is in fup and not fup_mod so move over
replace fup_mod=fup if var_type==2
label var fup_mod "fup"
label var fails_mod "fails"
label var people_mod "people"
label var val ""
label var valstr "Categories:"

recode  youth (1=0 "15-24") (0=1 "25-49"),gen(youth2)
label var youth2 "Age"
label var sex "Sex"
label var site "Study"

replace valstr="No" if val==0 & (varname=="mobile" | varname=="tv_morethan1" | varname=="tv_anylost" | varname=="tv_regular" | varname=="tv_casual")
replace valstr="Yes" if val==1 & (varname=="mobile" | varname=="tv_morethan1" | varname=="tv_anylost" | varname=="tv_regular" | varname=="tv_casual")
replace valstr="Don't know" if val==9 & (varname=="mobile" | varname=="tv_morethan1" | varname=="tv_anylost" | varname=="tv_regular" | varname=="tv_casual")

*put val to 99 for continuous variables so they don't drop out nicelab
replace val=99 if var_type==2




egen nicelab=axis(varname val valstr), label(valstr)


save ${alphapath}/ALPHA\Projects\Gates_incidence_risks_2019\results\Pooled\Risk_dist/everything_pooled_prev_by_study_name_sex_youth,replace


************************************************************************************
*				MAKE TABLES
************************************************************************************

use "${alphapath}/ALPHA\Projects\Gates_incidence_risks_2019\results\Pooled\Risk_dist/everything_pooled_prev_by_study_name_sex_youth",clear



**********************************************************
***FIRST ALL THE GROUPS- I.E EVERYTHING IN SUMMARY LIST
**********************************************************
bys sex youth2 site explan_var:egen var_tot_fup=sum(fup_mod)
bys sex youth2 site explan_var:egen var_tot_fail=sum(fails_mod)  if var_type==1
gen var_percent_fup=fup_mod/var_tot_fup*100  
gen var_percent_fail=fails_mod/var_tot_fail*100  if var_type==1

gen str30 tab_cont_allgrps=strofreal(var_percent_fup,"%4.1f") + " (" + strofreal(var_percent_fail,"%4.1f") + ")"  if var_type==1


replace tab_cont_allgrps=strofreal(var_percent_fup,"%4.1f") + " (" + strofreal(table_contents,"%4.2f") + ")"  if var_type==2


* drop urban - don't want in table
drop if varname=="urban"

* drop youth - don't want in table
drop if varname=="youth"


*+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=
****** TABLE OF RISK FACTOR distribution (%) BY SITE, SEX AND AGE GROUP
*+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=

*draw table for percentages
table (sex youth2 explan_var nicelab) (site)  ,stat( sum var_percent_fup var_percent_fail) nformat(%4.2f) nototal name(mean_fup_fail_by_all) replace

*results next to each other in adjacant columns rather than underneath
collect layout (sex#youth2#explan_var#nicelab#result) (site#var)

// REMOVE THE VERTICAL LINE
collect style cell border_block, border(right, pattern(nil))
*centre results
collect style cell cell_type[item column-header], halign(center)

*only show the first label for each group (explan variable in this set of results)  
collect style row stack, nobinder 

*put brackets round column containing fails (which is var_percent_fail and in var dimension)
 collect style cell var[var_percent_fail]#result,nformat(%4.1f) sformat("(%s)")

*Hide the column headings for the two variables (which are var_percent_fup var_percent_fail)
collect style header var, level(hide)
*Hide the title (var labs) for the row headings variables
collect style header nicelab sex explan_var youth2, title(hide)

*collect preview

*OUTPUT PERCENT PERSON TIME TABLE, BY SITE, SEX AND AGE
cap putdocx clear 
putdocx begin,landscape font("ArialNarrow",8)
putdocx collect,tablename(res) name(mean_fup_fail_by_all) 

putdocx table res(1,.),bold border(top) 
putdocx table res(2,.),bold border(bottom)
putdocx table res(.,1),bold width(4cm)
putdocx save ${alphapath}/ALPHA\Projects\Gates_incidence_risks_2019\results/for_paper/descriptive_table_by_sex_and_age.docx,replace
**NB this table is pretty much there. In Word need to take of "resize table to fit contents" and ctrl-h ^w^w. Then just juggle columns to fit on page

*+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=
*DRAW TABLE FOR PEOPLE AND PERSON TIME
*+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=

table (sex youth2 explan_var nicelab) (site)  ,stat( sum fup_mod fails_mod) nformat(%4.0f) nototal name(N_fup_fail_by_all) replace


*results next to each other in adjacant columns rather than underneath
collect layout (sex#youth2#explan_var#nicelab#result) (site#var)

// REMOVE THE VERTICAL LINE
collect style cell border_block, border(right, pattern(nil))
*centre results
collect style cell cell_type[item column-header], halign(center)

*only show the first label for each group (explan variable in this set of results)  
collect style row stack, nobinder 

*put brackets round column containing fails (which is var_percent_fail and in var dimension)
 *collect style cell var[var_percent_fail]#result,nformat(%4.1f) sformat("(%s)")

collect style cell var[fup_mod]#result,nformat(%6.0f) 
collect style cell var[fails_mod]#result,nformat(%4.0f) 



*Hide the column headings for the two variables (which are var_percent_fup var_percent_fail)
*collect style header var, level(hide)
collect label dim fup_mod "PY",modify
collect label dim fails_mod "S",modify
collect label levels var fails_mod "S" fup_mod "PY" ,modify
*Hide the title (var labs) for the row headings variables
collect style header nicelab sex explan_var youth2, title(hide)

*collect preview

*OUTPUT PERCENT PERSON TIME TABLE, BY SITE, SEX AND AGE
cap putdocx clear 
putdocx begin,landscape font("ArialNarrow",8)
putdocx collect,tablename(res) name(N_fup_fail_by_all)

putdocx table res(1,.),bold border(top) 
putdocx table res(2,.),bold border(bottom)
putdocx table res(.,1),bold width(4cm)
putdocx table res(.,2), width(1cm)
*consider not merging in collect but doing it here, after setting column width
*can only set col width for one col at a time, despite what help says
*also can't set cell margin with putdocx collect
putdocx paragraph
putdocx text ("Person-years of follow up (PY) and seroconversions (S) observed in the incidence cohort by sex, age and study between 2005-16 among 15-49 year olds.")
putdocx save ${alphapath}/ALPHA\Projects\Gates_incidence_risks_2019\results/for_paper/descriptive_table_numbers_by_sex_and_age.docx,replace
**NB this table is pretty much there. In Word need to take off "resize table to fit contents" and ctrl-h ^w^w. Then just juggle columns to fit on page





*+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=
*DRAW TABLE FOR PEOPLE AND PERSON TIME only for pooled data and with the four age sex groups side by side (Table 2 in paper)
*+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=

use "${alphapath}/ALPHA\Projects\Gates_incidence_risks_2019\results\Pooled\Risk_dist/everything_pooled_prev_by_study_name_sex_youth",clear
replace site=10 if explan_var==0
*keep only pooled results
keep if site==10

table ( explan_var nicelab) (sex youth2)  if var_type==1,stat( sum people_mod fup_mod fails_mod) nformat(%4.0f) nototal name(N_people_fup_fail_pooled) replace
table ( explan_var nicelab ) (sex youth2)  if var_type==2,stat( sum people_mod fup_mod table_contents)  nformat(%4.0f) nototal name(N_people_fup_fail_pooled) append


*results next to each other in adjacant columns rather than underneath
collect layout (explan_var#nicelab#result) (sex#youth2#var)

// REMOVE THE VERTICAL LINE
collect style cell border_block, border(right, pattern(nil))
*centre results
collect style cell cell_type[item column-header], halign(center)

*only show the first label for each group (explan variable in this set of results)  
collect style row stack, nobinder 

*put brackets round column containing fails (which is var_percent_fail and in var dimension)
 *collect style cell var[table_contents]#result,nformat(%4.1f) 

collect style cell var[people_mod]#result,nformat(%5.0f) 
collect style cell var[fup_mod]#result,nformat(%6.0f) 
collect style cell var[fails_mod]#result,nformat(%4.0f) 
collect style cell var[table_contents]#result,nformat(%4.1f) 



*Hide the column headings for the two variables (which are var_percent_fup var_percent_fail)
*collect style header var, level(hide)
collect label dim people_mod "N",modify
collect label dim fup_mod "PY",modify
collect label dim fails_mod "S",modify
collect label dim table_contents "M",modify
collect label levels var fails_mod "S" fup_mod "PY" people_mod "N" table_contents "M",modify
*Hide the title (var labs) for the row headings variables
collect style header nicelab sex explan_var youth2, title(hide)

*collect preview

*OUTPUT Table 1by sex and age for pooled data only
cap putdocx clear 
putdocx begin,landscape font("ArialNarrow",8)
putdocx collect,tablename(res) name(N_people_fup_fail_pooled)

putdocx table res(1,.),bold border(top) 
putdocx table res(2,.),bold border(bottom)
putdocx table res(.,1),bold width(4cm)
putdocx table res(.,2), width(1cm)
*consider not merging in collect but doing it here, after setting column width
*can only set col width for one col at a time, despite what help says
*also can't set cell margin with putdocx collect
putdocx paragraph
putdocx text ("Numbers of people (N), person-years of follow up (PY) and seroconversions (S) observed in the incidence cohort by sex and age between 2005-16 among 15-49 year olds from all studies.  NB. For some variables, the number of individuals sums to more than the total number in the incidence cohort because an individual may feature in more than one category during the period of follow up. Some small fluctuations in the total numbers across the different risk factors (e.g. plus or minus one seroconversion) arises due to rounding differences when taking the mean across imputations.")
putdocx save ${alphapath}/ALPHA\Projects\Gates_incidence_risks_2019\results/for_paper/Table2_numbers_by_sex_and_age_for_pooled.docx,replace
**NB this table is pretty much there. In Word need to take off "resize table to fit contents" and ctrl-h ^w^w. Then just juggle columns to fit on page





************************************************************************************
*				MAKE TABLE of the percents without the missings
************************************************************************************

use "${alphapath}/ALPHA\Projects\Gates_incidence_risks_2019\results\Pooled\Risk_dist/everything_pooled_prev_by_study_name_sex_youth",clear

keep if var_type==1

drop if varname=="Study"
drop if varname=="residence"
drop if varname=="fouryear"
drop if varname=="mobile"
drop if varname=="youth"

drop if val==9

bys sex study_name youth varname:egen denom=total(fup_mod)
gen percent=fup_mod/denom*100

keep sex study_name youth2 explan_var val nicelab percent 
format percent %4.1f

sort sex youth2 study explan_var nicelab

*draw table
table (explan_var nicelab) (sex youth study),stat(min percent) nototals nformat(%4.1f) name(percents_ignoring_missings) replace


table (sex youth study) (explan_var nicelab) if explan_var==32 & val<2 ,stat(min percent) nototals nformat(%4.1f) name(percents_ignoring_missings) replace

*TIDY UP A BIT
*results next to each other in adjacant columns rather than underneath
collect layout (explan_var#nicelab#result) (sex#youth2#study_name#var)

* remove the vertical line
collect style cell border_block, border(right, pattern(nil))
*centre results
collect style cell cell_type[item column-header], halign(center)

*only show the first label for each group (explan variable in this set of results)  
collect style row stack, nobinder 

*Hide the title (var labs) for the row headings variables
collect style header nicelab  explan_var  , title(hide)
*get rid of the stat label
collect style header result, level(hide)

*Hide the title (var labs) for the col headings variables
collect style header  sex  youth2 study_name percent, title(hide)





use "${alphapath}/ALPHA\Projects\Gates_incidence_risks_2019\results\Pooled\Risk_dist/everything_pooled_prev_by_study_name_sex_youth",clear


keep sex study_name youth2 explan_var val nicelab fup_mod 

sort sex youth2 study explan_var nicelab

*draw table
table (explan_var nicelab) (sex youth study),stat(min fup_mod) nototals nformat(%4.0f) name(ptime_for_sup_mat) replace

*TIDY UP A BIT
*results next to each other in adjacant columns rather than underneath
collect layout (explan_var#nicelab#result) (sex#youth2#study_name#var)

* remove the vertical line
collect style cell border_block, border(right, pattern(nil))
*centre results
collect style cell cell_type[item column-header], halign(center)

*only show the first label for each group (explan variable in this set of results)  
collect style row stack, nobinder 

*Hide the title (var labs) for the row headings variables
collect style header nicelab  explan_var  , title(hide)
*get rid of the stat label
collect style header result, level(hide)

*Hide the title (var labs) for the col headings variables
collect style header  sex  youth2 study_name , title(hide)


*SEND TO EXCEL


putexcel set "K:\ALPHA\Projects\Gates_incidence_risks_2019\paper/Table2_from_paper_used_for_writing_results.xlsx",modify sheet(Sup Table percents , replace)   

putexcel a1=collect, name(percents_ignoring_missings) 
putexcel close

putexcel set "K:\ALPHA\Projects\Gates_incidence_risks_2019\paper/Table2_from_paper_used_for_writing_results.xlsx",modify sheet(Sup Table numbers , replace)   

putexcel a1=collect, name(ptime_for_sup_mat)
putexcel close












