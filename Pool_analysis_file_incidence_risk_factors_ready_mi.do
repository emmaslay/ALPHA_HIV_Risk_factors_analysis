

local poolsites="Ifakara Karonga Kisesa  Kisumu Manicaland Masaka Rakai uMkhanyakude"
*local poolsites=" Kisesa   Masaka "

#delimit;

global varkeeplist="idno sex dob residence study_name age years_one agegrp fouryear 
start_ep_date end_ep_date untreated_opp_sex_prevalence tv_circumcised youth 
 sero_conv_date serocon_fail _st _d _origin _t _t0 ep_num idno
tv_ptnrs
which_survey
mobile
tv_mstat*
tv_new_partner
tv_regular
tv_casual
 tv_clastyr
 tv_sexlastyear 
 tv_morethan1
 tv_pagegrp
tv_anylost
opp_sex_par 
same_sex_par 
opp_sex_plr 
same_sex_plr 
tv_cf_all
tv_educ
"  ; 

#delimit cr
*quietly {


*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=
* POOL THE MI FILES
*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=
*** NEED TO DO THIS FOR AS MANY IMPUTATIONS AS THERE ARE IN ALL THE DIRECTORIES

*LOOK IN EACH SITE'S FOLDER AND COUNT THE IMPUTATIONS, find the minimum number available for all sites
global min_imp=1000

foreach p in `poolsites' {
local counter=1
local keepgoing=1

while `keepgoing'==1 {
*see if the file can be found
cap confirm file "${alphapath}/ALPHA\Incidence_ready_data/`p'/mi_data/incidence_ready_risk_factors_MI_`p'_`counter'.dta"
*if it can't be found stop the loop
if _rc~=0 {
local keepgoing=0
} /*close _rc if */

local site_imp=`counter'-1
local counter=`counter'+1
} /*close while loop */


*make this the new minimum number of imputations, if it is lower than the current number
if `site_imp'<$min_imp {
global min_imp=`site_imp'
}

} /*close site loop */


*** NOW POOL THE NUMBER OF IMPUATIONS THAT ARE AVAILABLE FOR EACH SITE

*set up the loop to run until there are no more files - no more imputations
forvalues x=0/$min_imp {

clear
*loop through each site, append datasets for this imputation into a pooled file
foreach p in `poolsites' {
*check the  file exists, if it does not exist then exit the loop by setting while to 0
cap confirm file ${alphapath}/ALPHA\Incidence_ready_data/`p'/mi_data/incidence_ready_risk_factors_MI_`p'_`x'.dta
if _rc~=0 {
local withinrange=0
}
append using ${alphapath}/ALPHA\Incidence_ready_data/`p'/mi_data/incidence_ready_risk_factors_MI_`p'_`x'.dta,keep(${varkeeplist})

} /*close site loop */

rename idno idno_orig
gen double idno=study_name*1000000 + idno_orig



/*==================
*code the missings to don't know- mix up all the different sorts of not knowing- not asked, resp didn't know/answer and outside survey ref period
*==================
recode tv_sexlastyear 8=9 99=9 .=9
recode tv_ptnrs 99=9 .=9 .a=9
recode tv_new_partner 3/9=9 .=9
recode tv_morethan1 .=9
recode tv_casual .=9
recode tv_regular .=9
recode tv_pagegrp .=9


*That doesn't work for all, rather than try to figure it out just replace =9 if which_survey<5
*It is because some surveys didn't ask the questions, but the data is within the reference period of a survey
replace tv_morethan1=9 if which_survey<5
replace tv_sexlastyear=9 if which_survey<5
replace tv_ptnrs=9 if which_survey<5
replace tv_casual=9 if which_survey<5
replace tv_regular=9 if which_survey<5
replace tv_clastyr=9 if which_survey<5
replace tv_anylost=9 if which_survey<5
*/

label drop which_survey
label define which_survey 1 "Never interviewed" 2 "Before first survey" 3 "After last survey" 4 "In grey area",modify
label values which_survey which_survey
recode which_survey (1/4=0 "Not in period covered by data") (5/max=1 "In data window") ,gen(data_window) label(data_window)


tab tv_mstat_br,gen(mstat_)

*==================
*restrict analysis to 15-49 and 2005-16
*==================
keep if age>14 & age<50 
keep if years_one>2004 & years_one<2017

*==================
** get rid of the year/study combinations that don't work
*==================
*Drop a few early estimates when there weren't enough people/biased sample (1995-99, Manicaland and Rakai)
*(2013-, Manicaland and Karonga)
drop if study==1 & fouryear==4
drop if study==3 & fouryear==4


recode tv_ptnrs (0=0) (1=1) (2=2 "2+") (3=2)  (9=9 "No data"),gen(p2grp) label(p2grp)
tab p2grp,gen(p2grp_)

recode which_survey 5/max=5

qui compress

*==================
*save the pooled file for this imputation
*==================
label data "ALPHA incidence risk factors data, pooled imputation `x'"
save ${alphapath}/ALPHA\Incidence_ready_data/pooled/mi_data/incidence_ready_risk_factors_MI_pooled_`x'.dta,replace

} /*close forvalues */


** NOW DO THIS AGAIN FOR THE SMALL FILES
forvalues x=0/$min_imp {

clear
*loop through each site, append datasets for this imputation into a pooled file
foreach p in `poolsites' {
*check the  file exists, if it does not exist then exit the loop by setting while to 0
cap confirm file ${alphapath}/ALPHA\Incidence_ready_data/`p'/mi_data/incidence_ready_risk_factors_MI_`p'_small_`x'.dta
if _rc~=0 {
local withinrange=0
}
append using ${alphapath}/ALPHA\Incidence_ready_data/`p'/mi_data/incidence_ready_risk_factors_MI_`p'_small_`x'.dta,
} /*close site loop */

rename idno idno_orig
gen double idno=study_name*1000000 + idno_orig
*save the poold file for this imputation


drop if study==3 & fouryear==0
drop if study==5 & fouryear==0
drop if study==8 & fouryear==1 

*(2013-, Manicaland and Karonga)
drop if study==1 & fouryear==4
drop if study==3 & fouryear==4
*Exclude 2017-20 as not enough data
drop if fouryear==5
** drop over 50 year olds as not all sites have data
drop if agegrp>9
keep if years_one>2004 & years_one<2017

label data "ALPHA incidence risk factors data, pooled imputation `x'"
save ${alphapath}/ALPHA\Incidence_ready_data/pooled/mi_data/incidence_ready_risk_factors_MI_pooled_small_`x'.dta,replace

} /*close forvalues */

} /*close quietly */




