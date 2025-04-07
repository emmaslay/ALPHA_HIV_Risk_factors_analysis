

*=============================================================================
*
*** SUMMARISE CRUDE HR FOR RISK FACTORS FOR HIV INFECTION
*
*  ALPHA WORKSHOP 14, ENTEBBE 25TH-29TH MARCH 2019 
*
*=============================================================================
/*
*global useimp=5

global tflist_yw
global tflist_ym
global tflist_ow
global tflist_om
global tflist_aw
global tflist_am
*global sitelist "Ifakara Karonga Kisesa Manicaland Masaka Rakai uMkhanyakude Kisumu"
*global sitelist "Manicaland uMkhanyakude" 
*/
set maxiter 100
global sitelist "Ifakara Karonga Kisesa Manicaland Masaka Rakai uMkhanyakude Kisumu pooled"

foreach site in $sitelist {

global sitename="`site'"
*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=
* OPEN THE DATASET
*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=
cd "${alphapath}/ALPHA\Incidence_ready_data/${sitename}/mi_data"
use "${alphapath}/ALPHA\Incidence_ready_data/${sitename}/mi_data/incidence_ready_risk_factors_mi_${sitename}_0",clear

*cd "${alphapath}/ALPHA\Incidence_ready_data/kisesa/mi_data"
*use "${alphapath}/ALPHA\Incidence_ready_data/kisesa/mi_data/incidence_ready_risk_factors_mi_kisesa_0",clear
summ study_name
local snum=r(mean)

*=========================


*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=
* SET THE DATASET FOR MI ANALYSIS IN STATA (SAME AS EARLIER IN THE WEEK)
*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=

cap mi erase incidence_risk

mi import flongsep incidence_risk, using(incidence_ready_risk_factors_mi_${sitename}_{1-$useimp}) id(study_name idno ep_num) imputed(end_ep_date) 

*restrict estimates to 15-49 and 2005-2016 (pooled dataset already restricted but site ones aren't)
mi xeq: keep if fouryear>=2 & fouryear<=4
mi xeq: keep if agegrp>=3 & agegrp<=9
** get rid of the year/study combinations that don't work
*Drop a few early estimates when there weren't enough people/biased sample (1995-99, Manicaland and Rakai)
*(2013-, Manicaland and Karonga)
mi xeq: drop if study==1 & fouryear==4
mi xeq: drop if study==3 & fouryear==4

cap mkdir ${alphapath}/ALPHA/projects/gates_incidence_risks_2019/results/${sitename}/"

*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=
* CRUDE MODELS TO LOOK AT FACTORS ASSOCIATED WITH HIV INCIDENCE
*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=

global risklist_fv "i.residence ib2.fouryear i.mobile ib1.tv_educ ib1.tv_mstat_br  i.tv_morethan1 ib1.tv_ptnrs i.tv_regular i.tv_casual i.tv_new_partner ib1.tv_clastyr i.tv_pagegrp i.tv_anylost ib1.tv_cf_all opp_sex_par opp_sex_plr same_sex_par same_sex_plr untreated_opp_sex_prevalence "
*global risklist_fv "ib1.tv_clastyr"

***** 	WOMEN


foreach risk in $risklist_fv {

*changed this to switch baseline on calendar year for sites that don't have data 2005-08 
di "`risk' for `site'"
if lower("`risk'")=="ib2.fouryear" & (lower("`site'")=="kisumu" |lower("`site'")=="ifakara")   {
local risk="ib3.fouryear"
di "`risk' for  `site'"

}


*** name riskname to use in filename
local riskname=subinstr("`risk'",".","_",.)

*Older women
*fouryear with study interaction for older women
if lower("${sitename}")=="pooled" & lower("`risk'")=="ib2.fouryear" {
mi xeq:tab study_name,gen(s_)
mi estimate,esampvaryok hr post errorok :streg  ib2.fouryear#i.s_6 ib4.study_name if sex==2 & youth==0,d(e)  
do ${alphapath}/ALPHA\Projects\Gates_incidence_trends_2019\add_mean_fails_subjects_ptime_to_ereturn.do
parmest, eform saving("${alphapath}/ALPHA/projects/gates_incidence_risks_2019/results/pooled/ow_ib2_fouryear_int_pooled",replace) idstr(`risk')  idnum(`snum')  stars(0.1 0.05 0.01 0.001)  flist(tflist_ow) escal(mean_fail mean_sub mean_ptime n_imp_used)     
} /*close if for pooled interaction */

else {

cap  mi estimate,esampvaryok eform cmdok post errorok dots :cifixstreg  `risk' if sex==2 & youth==0,d(e)  	
if _rc==0 {

mi estimate,esampvaryok eform cmdok post errorok dots :cifixstreg  `risk' if sex==2 & youth==0,d(e)  
qui do ${alphapath}/ALPHA\Projects\Gates_incidence_risks_2019\add_mean_fails_subjects_ptime_to_ereturn_after_cifixstreg.do
parmest, eform saving("${alphapath}/ALPHA/projects/gates_incidence_risks_2019/results/pooled/ow_`riskname'_`site'",replace) idstr(`risk')  idnum(`snum')  stars(0.1 0.05 0.01 0.001)  flist(tflist_ow) escal(mean_fail mean_sub mean_ptime n_imp_used)     
	
} /*close else */
} /*close _rc loop */

*Young women

cap mi estimate,esampvaryok eform cmdok post errorok dots :cifixstreg `risk' if sex==2 & youth==1 ,d(e)  
if _rc==0 { 

mi estimate,esampvaryok eform cmdok post errorok dots :cifixstreg  `risk' if sex==2 & youth==1 ,d(e)   
qui do ${alphapath}/ALPHA\Projects\Gates_incidence_risks_2019\add_mean_fails_subjects_ptime_to_ereturn_after_cifixstreg.do
parmest, eform saving("${alphapath}/ALPHA/projects/gates_incidence_risks_2019/results/pooled/yw_`riskname'_`site'",replace) idstr(`risk')  idnum(`snum')  stars(0.1 0.05 0.01 0.001)  flist(tflist_yw) escal(mean_fail mean_sub mean_ptime n_imp_used)     
	
} /*close _rc loop */


} /*close risk loop */


*************************************************
*MEN
global risklist_fv "i.residence ib2.fouryear i.mobile ib1.tv_educ i.tv_circumcised ib1.tv_mstat_br  i.tv_morethan1 ib1.tv_ptnrs i.tv_regular i.tv_casual i.tv_new_partner ib1.tv_clastyr i.tv_pagegrp i.tv_anylost ib1.tv_cf_all opp_sex_par opp_sex_plr same_sex_par same_sex_plr untreated_opp_sex_prevalence "
*global risklist_fv "ib1.tv_clastyr "

foreach risk in $risklist_fv {

*changed this to switch baseline on calendar year for sites that don't have data 2005-08 
di "`risk' for `site'"
if lower("`risk'")=="ib2.fouryear" & (lower("`site'")=="kisumu" | lower("`site'")=="ifakara")  {
local risk="ib3.fouryear"
}


local riskname=subinstr("`risk'",".","_",.)

*Young men
cap mi estimate,esampvaryok eform cmdok post errorok dots :cifixstreg  `risk' if sex==1 & youth==0  ,d(e)  
if _rc==0 {

mi estimate,esampvaryok eform cmdok post errorok dots :cifixstreg  `risk' if sex==1 & youth==0,d(e)  
qui do ${alphapath}/ALPHA\Projects\Gates_incidence_risks_2019\add_mean_fails_subjects_ptime_to_ereturn_after_cifixstreg.do
parmest, eform saving("${alphapath}/ALPHA/projects/gates_incidence_risks_2019/results/pooled/om_`riskname'_`site'",replace) idstr(`risk')  idnum(`snum')  stars(0.1 0.05 0.01 0.001)  flist(tflist_om)  escal(mean_fail mean_sub mean_ptime n_imp_used)   
	
} /*close _rc loop */

*older men
cap mi estimate,esampvaryok eform cmdok post errorok dots :cifixstreg  `risk' if sex==1 & youth==1 ,d(e)  
if _rc==0 {

mi estimate,esampvaryok eform cmdok post errorok dots :cifixstreg  `risk' if sex==1 & youth==1 ,d(e)  
qui do ${alphapath}/ALPHA\Projects\Gates_incidence_risks_2019\add_mean_fails_subjects_ptime_to_ereturn_after_cifixstreg.do
parmest, eform saving("${alphapath}/ALPHA/projects/gates_incidence_risks_2019/results/pooled/ym_`riskname'_`site'",replace) idstr(`risk')  idnum(`snum')  stars(0.1 0.05 0.01 0.001)  flist(tflist_ym)   escal(mean_fail mean_sub mean_ptime n_imp_used)  
	
} /*close _rc loop */


} /*close risk loop */


cap mi erase incidence_risk
} /*close site loop */


exit

