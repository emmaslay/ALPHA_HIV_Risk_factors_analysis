/*
1)  FINAL MODELS WITH EVERYTHING IN- three options for each age/sex combo- 
		piecewise exponential with fixed effect of study
		piecewise exponential with study#age
		piecewise exponential with study#age and study#untreated

2)  BEST MODELS with contribution from each site weighted equally

3) ESTIMATE ATTRIBUTABLE FRACTIONS

4) BEST MODELS WITH JUST THE FOUR STUDIES THAT HAVE PAR

*/

* OPENING THE MI DATASETS- TAKES AGES AND DOESN'T NEED TO BE DONE IF DO FILES ARE RUN IN ORDER


*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=
* OPEN THE DATASET
*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=
cd "${alphapath}/ALPHA\Incidence_ready_data/pooled/mi_data"
use "${alphapath}/ALPHA\Incidence_ready_data/pooled/mi_data/incidence_ready_risk_factors_mi_pooled_0",clear

*=========================

global useimp=70
*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=
* SET THE DATASET FOR MI ANALYSIS IN STATA 
*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=
*cd "L:/emma_mi"

cap mi erase incidence_risk
di "`c(current_date)'  `c(current_time)'"
mi import flongsep incidence_risk, using(${alphapath}/ALPHA\Incidence_ready_data/pooled/mi_data/incidence_ready_risk_factors_mi_pooled_{1-$useimp}) id(study_name idno ep_num) imputed(end_ep_date) 
di "`c(current_date)'  `c(current_time)'"


mi xeq:gen s_6=cond(study_name==6,1,0)

set maxiter 300


*===+===+===+===+===+===+===+===+===+===+===+===+===+===+===+==+===+===+===+===+
* PART 1: FIT FOUR DIFFERENT MODEL OPTIONS FOR EACH AGE/SEX COMBINATION

* 1) ALL PROXY AND RISK FACTORS PH MODEL
* 2) (BUT DONE LATER BEFORE PAF) ALL PROXY AND RISK FACTORS NOT-PH ALLOW AGE EFFECT TO VARY BETWEEN SITES
* 3) ALL PROXY AND RISK FACTORS NOT-PH ALLOW AGE EFFECT TO VARY BETWEEN SITES AND INCLUDE INTERACTION BETWEEN SITE AND UNTREATED
* 4) JUST RISK FACTORS (NO AGE, YEAR, MOBILE) PH
*===+===+===+===+===+===+===+===+===+===+===+===+===+===+===+==+===+===+===+===+

*======================================================
** YOUNG WOMEN **
*========================

*YOUNG WOMEN: PH
di "`c(current_date)'  `c(current_time)'"

cap mi estimate,esampvaryok eform post errorok cmdok nimp($useimp) : streg i.agegrp ib2.fouryear i.mobile ib1.tv_educ ib1.tv_mstat_br i.tv_morethan1 i.tv_regular##i.tv_new_partner i.tv_casual i.tv_anylost untreated_opp_sex_prevalence ib4.study_name if sex==2 & youth==1  ,d(e)  

if _rc==0 {
mi estimate,esampvaryok eform post errorok cmdok dots  nimp($useimp):streg i.agegrp ib2.fouryear i.mobile ib1.tv_educ ib1.tv_mstat_br i.tv_morethan1 i.tv_regular##i.tv_new_partner i.tv_casual i.tv_anylost untreated_opp_sex_prevalence ib4.study_name if sex==2 & youth==1  ,d(e)  
qui do ${alphapath}/ALPHA\Projects\Gates_incidence_trends_2019\add_mean_fails_subjects_ptime_to_ereturn.do
estimates save ${alphapath}/ALPHA/projects/gates_incidence_risks_2019/results/pooled/adj_risk_models/yw_pooled_exp_ph,replace
estimates store yw_pooled_exp_ph
parmest, eform saving("${alphapath}/ALPHA/projects/gates_incidence_risks_2019/results/pooled/adj_risk_models/yw_pooled_exp_ph",replace) idstr("pooled_adj")  idnum(0)  stars(0.1 0.05 0.01 0.001)   escal(mean_fail mean_sub mean_ptime)   
di "`c(current_date)'  `c(current_time)'"
}
*YOUNG WOMEN: NOT PH, WITH STUDY#AGE
mi estimate,esampvaryok eform post errorok cmdok dots  nimp($useimp):streg i.agegrp#ib4.study_name ib2.fouryear i.mobile ib1.tv_educ ib1.tv_mstat_br i.tv_morethan1 i.tv_regular#i.tv_new_partner i.tv_casual i.tv_anylost c.untreated_opp_sex_prevalence  if sex==2 & youth==1  ,d(e)  
qui do ${alphapath}/ALPHA\Projects\Gates_incidence_trends_2019\add_mean_fails_subjects_ptime_to_ereturn.do
estimates save ${alphapath}/ALPHA/projects/gates_incidence_risks_2019/results/pooled/adj_risk_models/yw_pooled_exp_not_ph,replace
estimates store yw_pooled_exp_not_ph
parmest, eform saving("${alphapath}/ALPHA/projects/gates_incidence_risks_2019/results/pooled/adj_risk_models/yw_pooled_exp_not_ph",replace) idstr("pooled_adj")  idnum(0)  stars(0.1 0.05 0.01 0.001)   escal(mean_fail mean_sub mean_ptime)   
di "`c(current_date)'  `c(current_time)'"

*YOUNG WOMEN: NOT PH, with interaction between untreated and study
di "`c(current_date)'  `c(current_time)'"

cap mi estimate,esampvaryok eform post errorok cmdok nimp($useimp):streg i.agegrp#ib4.study_name ib2.fouryear i.mobile ib1.tv_educ ib1.tv_mstat_br i.tv_morethan1 i.tv_regular##i.tv_new_partner i.tv_casual i.tv_anylost c.untreated_opp_sex_prevalence#ib4.study_name  if sex==2 & youth==1  ,d(e)   
if _rc==0 {
mi estimate,esampvaryok eform post errorok cmdok dots  nimp($useimp):streg i.agegrp#ib4.study_name ib2.fouryear i.mobile ib1.tv_educ ib1.tv_mstat_br i.tv_morethan1 i.tv_regular##i.tv_new_partner i.tv_casual i.tv_anylost c.untreated_opp_sex_prevalence#ib4.study_name if sex==2 & youth==1  ,d(e)   
qui do ${alphapath}/ALPHA\Projects\Gates_incidence_trends_2019\add_mean_fails_subjects_ptime_to_ereturn.do
estimates save ${alphapath}/ALPHA/projects/gates_incidence_risks_2019/results/pooled/adj_risk_models/yw_pooled_exp_int_not_ph,replace
estimates store yw_pooled_exp_int_not_ph
parmest, eform saving("${alphapath}/ALPHA/projects/gates_incidence_risks_2019/results/pooled/adj_risk_models/yw_pooled_exp_int_not_ph",replace) idstr("pooled_adj")  idnum(0)  stars(0.1 0.05 0.01 0.001)   escal(mean_fail mean_sub mean_ptime)   
di "`c(current_date)'  `c(current_time)'"
}

*with this and non-PH model (which is below) looked like there was an interaction with regular and new, but not casual and new
*that is now included in the non-PH model below

*YOUNG WOMEN: JUST RISKS
di "`c(current_date)'  `c(current_time)'"
cap mi estimate,esampvaryok eform post errorok cmdok nimp($useimp) : streg ib1.tv_educ ib1.tv_mstat_br i.tv_morethan1 i.tv_regular##i.tv_new_partner i.tv_casual i.tv_anylost untreated_opp_sex_prevalence ib4.study_name if sex==2 & youth==1  ,d(e)  

if _rc==0 {
mi estimate,esampvaryok eform post errorok cmdok dots  nimp($useimp):streg ib1.tv_educ ib1.tv_mstat_br i.tv_morethan1 i.tv_regular##i.tv_new_partner i.tv_casual  i.tv_anylost untreated_opp_sex_prevalence ib4.study_name if sex==2 & youth==1  ,d(e)  
qui do ${alphapath}/ALPHA\Projects\Gates_incidence_trends_2019\add_mean_fails_subjects_ptime_to_ereturn.do
estimates save ${alphapath}/ALPHA/projects/gates_incidence_risks_2019/results/pooled/adj_risk_models/yw_pooled_exp_phrisks,replace
estimates store yw_pooled_exp_phrisks
parmest, eform saving("${alphapath}/ALPHA/projects/gates_incidence_risks_2019/results/pooled/adj_risk_models/yw_pooled_exp_phrisks",replace) idstr("pooled_adj")  idnum(0)  stars(0.1 0.05 0.01 0.001)   escal(mean_fail mean_sub mean_ptime)   
di "`c(current_date)'  `c(current_time)'"
}

*** YOUNG WOMEN: THE PREFERRED ONE
mi estimate,esampvaryok eform post errorok cmdok dots  nimp($useimp):streg ib1.tv_educ ib1.tv_mstat_br i.tv_regular i.tv_new_partner i.tv_casual untreated_opp_sex_prevalence ib4.study_name if sex==2 & youth==1  ,d(e)  
qui do ${alphapath}/ALPHA\Projects\Gates_incidence_trends_2019\add_mean_fails_subjects_ptime_to_ereturn.do
estimates save ${alphapath}/ALPHA/projects/gates_incidence_risks_2019/results/pooled/adj_risk_models/yw_pooled_exp_PREFER,replace
estimates store yw_pooled_exp_prefer
parmest, eform saving("${alphapath}/ALPHA/projects/gates_incidence_risks_2019/results/pooled/adj_risk_models/yw_pooled_exp_PREFER",replace) idstr("pooled_adj_YW_PREFER")  idnum(0)  stars(0.1 0.05 0.01 0.001)   escal(mean_fail mean_sub mean_ptime)   
di "`c(current_date)'  `c(current_time)'"


*==========================================================================
** OLDER WOMEN **
*=====================
*OLDER WOMEN: PH
di "`c(current_date)'  `c(current_time)'"

cap mi estimate,esampvaryok eform post errorok cmdok nimp($useimp) : streg i.agegrp ib2.fouryear#i.s_6 i.mobile ib1.tv_educ ib1.tv_mstat_br i.tv_morethan1 i.tv_regular i.tv_casual i.tv_new_partner i.tv_anylost untreated_opp_sex_prevalence ib1.tv_clastyr  ib4.study_name if sex==2 & youth==0  ,d(e)  
if _rc==0 {
mi estimate,esampvaryok eform post errorok cmdok dots  nimp($useimp): streg i.agegrp ib2.fouryear#i.s_6 i.mobile ib1.tv_educ ib1.tv_mstat_br i.tv_morethan1 i.tv_regular i.tv_casual i.tv_new_partner i.tv_anylost untreated_opp_sex_prevalence ib1.tv_clastyr  ib4.study_name if sex==2 & youth==0  ,d(e)  
qui do ${alphapath}/ALPHA\Projects\Gates_incidence_trends_2019\add_mean_fails_subjects_ptime_to_ereturn.do
estimates save ${alphapath}/ALPHA/projects/gates_incidence_risks_2019/results/pooled/adj_risk_models/ow_pooled_exp_ph,replace
estimates store ow_pooled_exp_ph
parmest, eform saving("${alphapath}/ALPHA/projects/gates_incidence_risks_2019/results/pooled/adj_risk_models/ow_pooled_exp_ph",replace) idstr("pooled_adj")  idnum(0)  stars(0.1 0.05 0.01 0.001)   escal(mean_fail mean_sub mean_ptime)   
di "`c(current_date)'  `c(current_time)'"
}

*OLDER WOMEN: NOT PH WITH STUDY#AGE
mi estimate,esampvaryok eform post errorok cmdok dots  nimp($useimp): streg i.agegrp#ib4.study_name ib2.fouryear#i.s_6 i.mobile ib1.tv_educ ib1.tv_mstat_br i.tv_morethan1 i.tv_regular i.tv_casual i.tv_new_partner i.tv_anylost c.untreated_opp_sex_prevalence ib1.tv_clastyr   if sex==2 & youth==0  ,d(e)  
qui do ${alphapath}/ALPHA\Projects\Gates_incidence_trends_2019\add_mean_fails_subjects_ptime_to_ereturn.do
estimates save ${alphapath}/ALPHA/projects/gates_incidence_risks_2019/results/pooled/adj_risk_models/ow_pooled_exp_not_ph,replace
estimates store ow_pooled_exp_not_ph
parmest, eform saving("${alphapath}/ALPHA/projects/gates_incidence_risks_2019/results/pooled/adj_risk_models/ow_pooled_exp_not_ph",replace) idstr("pooled_adj")  idnum(0)  stars(0.1 0.05 0.01 0.001)   escal(mean_fail mean_sub mean_ptime)   
di "`c(current_date)'  `c(current_time)'"

*OLDER WOMEN: NOT PH WITH SITE#UNTREATED
di "`c(current_date)'  `c(current_time)'"

cap mi estimate,esampvaryok eform post errorok cmdok nimp($useimp):streg i.agegrp#ib4.study_name ib2.fouryear#i.s_6 i.mobile ib1.tv_educ ib1.tv_mstat_br i.tv_morethan1 i.tv_regular i.tv_casual i.tv_new_partner i.tv_anylost c.untreated_opp_sex_prevalence#ib4.study_name ib1.tv_clastyr   if sex==2 & youth==0  ,d(e)   
if _rc==0 {
mi estimate,esampvaryok eform post errorok cmdok dots  nimp($useimp):streg i.agegrp#ib4.study_name ib2.fouryear#i.s_6 i.mobile ib1.tv_educ ib1.tv_mstat_br i.tv_morethan1 i.tv_regular i.tv_casual i.tv_new_partner i.tv_anylost c.untreated_opp_sex_prevalence#ib4.study_name ib1.tv_clastyr  if sex==2 & youth==0  ,d(e)   
qui do ${alphapath}/ALPHA\Projects\Gates_incidence_trends_2019\add_mean_fails_subjects_ptime_to_ereturn.do
estimates save ${alphapath}/ALPHA/projects/gates_incidence_risks_2019/results/pooled/adj_risk_models/ow_pooled_exp_int_not_ph,replace
estimates store ow_pooled_exp_int_not_ph
parmest, eform saving("${alphapath}/ALPHA/projects/gates_incidence_risks_2019/results/pooled/adj_risk_models/ow_pooled_exp_int_not_ph",replace) idstr("pooled_adj")  idnum(0)  stars(0.1 0.05 0.01 0.001)   escal(mean_fail mean_sub mean_ptime)   
di "`c(current_date)'  `c(current_time)'"
}


*OLDER WOMEN: PH -JUST RISKS
di "`c(current_date)'  `c(current_time)'"

cap mi estimate,esampvaryok eform post errorok cmdok nimp($useimp) : streg i.mobile ib1.tv_educ ib1.tv_mstat_br i.tv_morethan1 i.tv_regular i.tv_casual i.tv_new_partner i.tv_anylost untreated_opp_sex_prevalence ib4.study_name ib1.tv_clastyr  if sex==2 & youth==0  ,d(e)  
if _rc==0 {
mi estimate,esampvaryok eform post errorok cmdok dots  nimp($useimp):streg i.mobile ib1.tv_educ ib1.tv_mstat_br i.tv_morethan1 i.tv_regular i.tv_casual i.tv_new_partner i.tv_anylost untreated_opp_sex_prevalence ib4.study_name ib1.tv_clastyr  if sex==2 & youth==0  ,d(e)  
qui do ${alphapath}/ALPHA\Projects\Gates_incidence_trends_2019\add_mean_fails_subjects_ptime_to_ereturn.do
estimates save ${alphapath}/ALPHA/projects/gates_incidence_risks_2019/results/pooled/adj_risk_models/ow_pooled_exp_phrisks,replace
estimates store ow_pooled_exp_phrisks
parmest, eform saving("${alphapath}/ALPHA/projects/gates_incidence_risks_2019/results/pooled/adj_risk_models/ow_pooled_exp_phrisks",replace) idstr("pooled_adj")  idnum(0)  stars(0.1 0.05 0.01 0.001)   escal(mean_fail mean_sub mean_ptime)   
di "`c(current_date)'  `c(current_time)'"
}

*OLDER WOMEN: PREFERRED- parmest didn't run here
mi xeq: recode tv_clastyr 4=9
mi estimate,esampvaryok eform post errorok cmdok dots  nimp($useimp):streg i.mobile ib1.tv_educ ib1.tv_mstat_br i.tv_new_partner untreated_opp_sex_prevalence ib4.study_name ib1.tv_clastyr  if sex==2 & youth==0  ,d(e)  
qui do ${alphapath}/ALPHA\Projects\Gates_incidence_trends_2019\add_mean_fails_subjects_ptime_to_ereturn.do
estimates save ${alphapath}/ALPHA/projects/gates_incidence_risks_2019/results/pooled/adj_risk_models/ow_pooled_exp_PREFER,replace
estimates store ow_pooled_exp_prefer
parmest, eform saving("${alphapath}/ALPHA/projects/gates_incidence_risks_2019/results/pooled/adj_risk_models/ow_pooled_exp_PREFER",replace) idstr("pooled_adj_ow_prefer")  idnum(0)  stars(0.1 0.05 0.01 0.001)   escal(mean_fail mean_sub mean_ptime)   
di "`c(current_date)'  `c(current_time)'"

*=================================================================================================
** YOUNG MEN **
*=======================

*YOUNG MEN: PH
di "`c(current_date)'  `c(current_time)'"

cap mi estimate,esampvaryok eform post errorok cmdok nimp($useimp) : streg i.agegrp ib2.fouryear i.mobile ib1.tv_educ ib1.tv_mstat_br i.tv_morethan1 i.tv_regular i.tv_casual i.tv_new_partner i.tv_anylost untreated_opp_sex_prevalence i.tv_circumcised ib4.study_name if sex==1 & youth==1  ,d(e)  

if _rc==0 {
mi estimate,esampvaryok eform post errorok cmdok dots  nimp($useimp):streg i.agegrp ib2.fouryear i.mobile ib1.tv_educ ib1.tv_mstat_br i.tv_morethan1 i.tv_regular i.tv_casual i.tv_new_partner i.tv_anylost untreated_opp_sex_prevalence i.tv_circumcised ib4.study_name if sex==1 & youth==1  ,d(e)  
do ${alphapath}/ALPHA\Projects\Gates_incidence_trends_2019\add_mean_fails_subjects_ptime_to_ereturn.do
estimates save ${alphapath}/ALPHA/projects/gates_incidence_risks_2019/results/pooled/adj_risk_models/ym_pooled_exp_ph,replace
estimates store ym_pooled_exp_ph
parmest, eform saving("${alphapath}/ALPHA/projects/gates_incidence_risks_2019/results/pooled/adj_risk_models/ym_pooled_exp_ph",replace) idstr("pooled_adj")  idnum(0)  stars(0.1 0.05 0.01 0.001)   escal(mean_fail mean_sub mean_ptime)   
di "`c(current_date)'  `c(current_time)'"
}

*YOUNG MEN: NOT PH WITH STUDY#AGE
mi estimate,esampvaryok eform post errorok cmdok dots  nimp($useimp):streg i.agegrp#ib4.study_name ib2.fouryear i.mobile ib1.tv_educ ib1.tv_mstat_br i.tv_morethan1 i.tv_regular i.tv_casual i.tv_new_partner i.tv_anylost i.tv_circumcised c.untreated_opp_sex_prevalence  if sex==1 & youth==1  ,d(e)  
do ${alphapath}/ALPHA\Projects\Gates_incidence_trends_2019\add_mean_fails_subjects_ptime_to_ereturn.do
estimates save ${alphapath}/ALPHA/projects/gates_incidence_risks_2019/results/pooled/adj_risk_models/ym_pooled_exp_not_ph,replace
estimates store ym_pooled_exp_not_ph
parmest, eform saving("${alphapath}/ALPHA/projects/gates_incidence_risks_2019/results/pooled/adj_risk_models/ym_pooled_exp_not_ph",replace) idstr("pooled_adj")  idnum(0)  stars(0.1 0.05 0.01 0.001)   escal(mean_fail mean_sub mean_ptime)   
di "YM model done `c(current_date)'  `c(current_time)'"

*YOUNG MEN: NOT PH WITH SITE#UNTREATED
di "`c(current_date)'  `c(current_time)'"

cap mi estimate,esampvaryok eform post errorok cmdok nimp($useimp):streg i.agegrp#ib4.study_name ib2.fouryear i.mobile ib1.tv_educ ib1.tv_mstat_br i.tv_morethan1 i.tv_regular i.tv_casual i.tv_new_partner i.tv_anylost i.tv_circumcised c.untreated_opp_sex_prevalence#ib4.study_name  if sex==1 & youth==1  ,d(e)   
if _rc==0 {
mi estimate,esampvaryok eform post errorok cmdok dots  nimp($useimp):streg i.agegrp#ib4.study_name ib2.fouryear i.mobile ib1.tv_educ ib1.tv_mstat_br i.tv_morethan1 i.tv_regular i.tv_casual i.tv_new_partner i.tv_anylost i.tv_circumcised c.untreated_opp_sex_prevalence#ib4.study_name if sex==1 & youth==1  ,d(e)   
do ${alphapath}/ALPHA\Projects\Gates_incidence_trends_2019\add_mean_fails_subjects_ptime_to_ereturn.do
estimates save ${alphapath}/ALPHA/projects/gates_incidence_risks_2019/results/pooled/adj_risk_models/ym_pooled_exp_int_not_ph,replace
estimates store ym_pooled_exp_int_not_ph
parmest, eform saving("${alphapath}/ALPHA/projects/gates_incidence_risks_2019/results/pooled/adj_risk_models/ym_pooled_exp_int_not_ph",replace) idstr("pooled_adj")  idnum(0)  stars(0.1 0.05 0.01 0.001)   escal(mean_fail mean_sub mean_ptime)   
di "`c(current_date)'  `c(current_time)'"
}

*YOUNG MEN: PH RISKS ONLY
di "`c(current_date)'  `c(current_time)'"

cap mi estimate,esampvaryok eform post errorok cmdok nimp($useimp) : streg i.mobile ib1.tv_educ ib1.tv_mstat_br i.tv_morethan1 i.tv_regular i.tv_casual i.tv_new_partner i.tv_anylost untreated_opp_sex_prevalence i.tv_circumcised ib4.study_name if sex==1 & youth==1  ,d(e)  

if _rc==0 {
mi estimate,esampvaryok eform post errorok cmdok dots  nimp($useimp):streg i.mobile ib1.tv_educ ib1.tv_mstat_br i.tv_morethan1 i.tv_regular i.tv_casual i.tv_new_partner i.tv_anylost untreated_opp_sex_prevalence i.tv_circumcised ib4.study_name if sex==1 & youth==1  ,d(e)  
do ${alphapath}/ALPHA\Projects\Gates_incidence_trends_2019\add_mean_fails_subjects_ptime_to_ereturn.do
estimates save ${alphapath}/ALPHA/projects/gates_incidence_risks_2019/results/pooled/adj_risk_models/ym_pooled_exp_phrisks,replace
estimates store ym_pooled_exp_phrisks
parmest, eform saving("${alphapath}/ALPHA/projects/gates_incidence_risks_2019/results/pooled/adj_risk_models/ym_pooled_exp_phrisks",replace) idstr("pooled_adj")  idnum(0)  stars(0.1 0.05 0.01 0.001)   escal(mean_fail mean_sub mean_ptime)   
di "`c(current_date)'  `c(current_time)'"
}

*YOUNG MEN: PREFERRED
mi estimate,esampvaryok eform post errorok cmdok dots  nimp($useimp):streg ib1.tv_educ ib1.tv_mstat_br untreated_opp_sex_prevalence i.tv_circumcised ib4.study_name if sex==1 & youth==1  ,d(e)  
do ${alphapath}/ALPHA\Projects\Gates_incidence_trends_2019\add_mean_fails_subjects_ptime_to_ereturn.do
estimates save ${alphapath}/ALPHA/projects/gates_incidence_risks_2019/results/pooled/adj_risk_models/ym_pooled_exp_prefer,replace
estimates store ym_pooled_exp_prefer
parmest, eform saving("${alphapath}/ALPHA/projects/gates_incidence_risks_2019/results/pooled/adj_risk_models/ym_pooled_exp_prefer",replace) idstr("pooled_adj_ym_prefer")  idnum(0)  stars(0.1 0.05 0.01 0.001)   escal(mean_fail mean_sub mean_ptime)   
di "`c(current_date)'  `c(current_time)'"

** OLDER MEN **

*OLDER MEN: PH
di "`c(current_date)'  `c(current_time)'"

cap mi estimate,esampvaryok eform post errorok cmdok nimp($useimp) : streg i.agegrp ib2.fouryear i.mobile ib1.tv_educ ib1.tv_mstat_br i.tv_morethan1 i.tv_regular i.tv_casual i.tv_new_partner i.tv_anylost i.tv_circumcised untreated_opp_sex_prevalence ib4.study_name if sex==1 & youth==0  ,d(e)  

if _rc==0 {
mi estimate,esampvaryok eform post errorok cmdok dots  nimp($useimp):streg i.agegrp ib2.fouryear i.mobile ib1.tv_educ ib1.tv_mstat_br i.tv_morethan1 i.tv_regular i.tv_casual i.tv_new_partner i.tv_anylost i.tv_circumcised untreated_opp_sex_prevalence ib4.study_name if sex==1 & youth==0  ,d(e)  
do ${alphapath}/ALPHA\Projects\Gates_incidence_trends_2019\add_mean_fails_subjects_ptime_to_ereturn.do
estimates save ${alphapath}/ALPHA/projects/gates_incidence_risks_2019/results/pooled/adj_risk_models/om_pooled_exp_ph,replace
estimates store om_pooled_exp_ph
parmest, eform saving("${alphapath}/ALPHA/projects/gates_incidence_risks_2019/results/pooled/adj_risk_models/om_pooled_exp_ph",replace) idstr("pooled_adj")  idnum(0)  stars(0.1 0.05 0.01 0.001)   escal(mean_fail mean_sub mean_ptime)   
di "`c(current_date)'  `c(current_time)'"
}

*OLDER MEN: NOT PH WITH STUDY#AGE
mi estimate,esampvaryok hr post errorok dots :streg i.agegrp#ib4.study_name ib2.fouryear i.mobile ib1.tv_educ ib1.tv_mstat_br i.tv_morethan1 i.tv_regular i.tv_casual i.tv_new_partner i.tv_anylost c.untreated_opp_sex_prevalence   if sex==1 & youth==0,d(e)

do ${alphapath}/ALPHA\Projects\Gates_incidence_trends_2019\add_mean_fails_subjects_ptime_to_ereturn.do
estimates save ${alphapath}/ALPHA/projects/gates_incidence_risks_2019/results/pooled/adj_risk_models/om_pooled_exp_not_ph,replace
estimates store om_pooled_exp_not_ph
parmest, eform saving("${alphapath}/ALPHA/projects/gates_incidence_risks_2019/results/pooled/adj_risk_models/om_pooled_exp_not_ph",replace) idstr(`risk')  idnum(`snum')  stars(0.1 0.05 0.01 0.001)  flist(tflist_om)  escal(mean_fail mean_sub mean_ptime)   
di "`c(current_date)'  `c(current_time)'"

*OLDER MEN:NOT PH WITH SITE#UNTREATED
di "`c(current_date)'  `c(current_time)'"

cap mi estimate,esampvaryok eform post errorok cmdok nimp($useimp):streg i.agegrp#ib4.study_name ib2.fouryear i.mobile ib1.tv_educ ib1.tv_mstat_br i.tv_morethan1 i.tv_regular i.tv_casual i.tv_new_partner i.tv_anylost i.tv_circumcised c.untreated_opp_sex_prevalence#ib4.study_name  if sex==1 & youth==0  ,d(e)   
if _rc==0 {
mi estimate,esampvaryok eform post errorok cmdok dots  nimp($useimp):streg i.agegrp#ib4.study_name ib2.fouryear i.mobile ib1.tv_educ ib1.tv_mstat_br i.tv_morethan1 i.tv_regular i.tv_casual i.tv_new_partner i.tv_anylost i.tv_circumcised c.untreated_opp_sex_prevalence#ib4.study_name if sex==1 & youth==0  ,d(e)   
do ${alphapath}/ALPHA\Projects\Gates_incidence_trends_2019\add_mean_fails_subjects_ptime_to_ereturn.do
estimates save ${alphapath}/ALPHA/projects/gates_incidence_risks_2019/results/pooled/adj_risk_models/om_pooled_exp_int_not_ph,replace
estimates store om_pooled_exp_int_not_ph
parmest, eform saving("${alphapath}/ALPHA/projects/gates_incidence_risks_2019/results/pooled/adj_risk_models/om_pooled_exp_int_not_ph",replace) idstr("pooled_adj")  idnum(0)  stars(0.1 0.05 0.01 0.001)   escal(mean_fail mean_sub mean_ptime)   
di "`c(current_date)'  `c(current_time)'"
}

*OLDER MEN: PH RISKS ONLY
di "`c(current_date)'  `c(current_time)'"

cap mi estimate,esampvaryok eform post errorok cmdok nimp($useimp) : streg i.mobile ib1.tv_educ ib1.tv_mstat_br i.tv_morethan1 i.tv_regular i.tv_casual i.tv_new_partner i.tv_anylost i.tv_circumcised untreated_opp_sex_prevalence ib4.study_name if sex==1 & youth==0  ,d(e)  

if _rc==0 {
mi estimate,esampvaryok eform post errorok cmdok dots  nimp($useimp):streg i.mobile ib1.tv_educ ib1.tv_mstat_br i.tv_morethan1 i.tv_regular i.tv_casual i.tv_new_partner i.tv_anylost i.tv_circumcised untreated_opp_sex_prevalence ib4.study_name if sex==1 & youth==0  ,d(e)  
do ${alphapath}/ALPHA\Projects\Gates_incidence_trends_2019\add_mean_fails_subjects_ptime_to_ereturn.do
estimates save ${alphapath}/ALPHA/projects/gates_incidence_risks_2019/results/pooled/adj_risk_models/om_pooled_exp_phrisks,replace
estimates store om_pooled_exp_phrisks
parmest, eform saving("${alphapath}/ALPHA/projects/gates_incidence_risks_2019/results/pooled/adj_risk_models/om_pooled_exp_phrisks",replace) idstr("pooled_adj")  idnum(0)  stars(0.1 0.05 0.01 0.001)   escal(mean_fail mean_sub mean_ptime)   
di "`c(current_date)'  `c(current_time)'"
}

*OLDER MEN: PREFER
mi estimate,esampvaryok eform post errorok cmdok dots  nimp($useimp):streg ib1.tv_mstat_br i.tv_regular untreated_opp_sex_prevalence ib4.study_name if sex==1 & youth==0  ,d(e)  
do ${alphapath}/ALPHA\Projects\Gates_incidence_trends_2019\add_mean_fails_subjects_ptime_to_ereturn.do
estimates save ${alphapath}/ALPHA/projects/gates_incidence_risks_2019/results/pooled/adj_risk_models/om_pooled_exp_prefer,replace
estimates store om_pooled_exp_prefer
parmest, eform saving("${alphapath}/ALPHA/projects/gates_incidence_risks_2019/results/pooled/adj_risk_models/om_pooled_exp_prefer",replace) idstr("pooled_adj_om_prefer")  idnum(0)  stars(0.1 0.05 0.01 0.001)   escal(mean_fail mean_sub mean_ptime)   
di "`c(current_date)'  `c(current_time)'"



*********************************************************
** EXPORT ALL THE MODELS USING ESTOUT
*********************************************************
*young women
estimates use K:\ALPHA\Projects\Gates_incidence_risks_2019\results\Pooled\adj_risk_models/yw_pooled_exp_ph,
estimates store yw_pooled_exp_ph
estimates use K:\ALPHA\Projects\Gates_incidence_risks_2019\results\Pooled\adj_risk_models/yw_pooled_exp_int_not_ph
estimates store yw_pooled_exp_int_not_ph

estimates use K:\ALPHA\Projects\Gates_incidence_risks_2019\results\Pooled\adj_risk_models/yw_pooled_exp_not_ph
estimates store yw_pooled_exp_not_ph

estimates use K:\ALPHA\Projects\Gates_incidence_risks_2019\results\Pooled\adj_risk_models/yw_pooled_exp_phrisks
estimates store yw_pooled_exp_phrisks

estimates use K:\ALPHA\Projects\Gates_incidence_risks_2019\results\Pooled\adj_risk_models/yw_pooled_exp_prefer
estimates store yw_pooled_exp_prefer

estout  yw_pooled_exp_ph yw_pooled_exp_not_ph yw_pooled_exp_int_not_ph yw_pooled_exp_phrisks yw_pooled_exp_prefer ///
using "K:/ALPHA/projects/gates_incidence_risks_2019/results/pooled/adj_risk_models/young_women.txt",replace eform  ///
c("b (fmt(%4.2f)) ci_l & ci_u ") incelldelimiter("-") label mlabel("PH" "Not PH, no interaction" "Not PH with interaction"  "PH risks only" "Preferred")  ///
collabels("Adj HR" "95% CI")   drop(_cons) stats(mean_fail mean_sub mean_ptime, fmt(%5.0f)) noabbrev

*older women
estimates use K:\ALPHA\Projects\Gates_incidence_risks_2019\results\Pooled\adj_risk_models/ow_pooled_exp_ph,
estimates store ow_pooled_exp_ph
estimates use K:\ALPHA\Projects\Gates_incidence_risks_2019\results\Pooled\adj_risk_models/ow_pooled_exp_int_not_ph
estimates store ow_pooled_exp_int_not_ph

estimates use K:\ALPHA\Projects\Gates_incidence_risks_2019\results\Pooled\adj_risk_models/ow_pooled_exp_not_ph
estimates store ow_pooled_exp_not_ph


estimates use K:\ALPHA\Projects\Gates_incidence_risks_2019\results\Pooled\adj_risk_models/ow_pooled_exp_phrisks
estimates store ow_pooled_exp_phrisks

estimates use K:\ALPHA\Projects\Gates_incidence_risks_2019\results\Pooled\adj_risk_models/ow_pooled_exp_prefer
estimates store ow_pooled_exp_prefer

estout ow_pooled_exp_ph ow_pooled_exp_not_ph ow_pooled_exp_int_not_ph ow_pooled_exp_phrisks ow_pooled_exp_prefer ///
using "K:/ALPHA/projects/gates_incidence_risks_2019/results/pooled/adj_risk_models/older_women.txt",replace eform  ///
c("b (fmt(%4.2f)) ci_l & ci_u ") incelldelimiter("-") label mlabel("PH" "Not PH, no interaction" "Not PH with interaction"  "PH risks only" "Preferred")  ///
collabels("Adj HR" "95% CI")   drop(_cons) stats(mean_fail mean_sub mean_ptime, fmt(%5.0f)) noabbrev

*young men
estimates use K:\ALPHA\Projects\Gates_incidence_risks_2019\results\Pooled\adj_risk_models/ym_pooled_exp_ph,
estimates store ym_pooled_exp_ph
estimates use K:\ALPHA\Projects\Gates_incidence_risks_2019\results\Pooled\adj_risk_models/ym_pooled_exp_int_not_ph
estimates store ym_pooled_exp_int_not_ph

estimates use K:\ALPHA\Projects\Gates_incidence_risks_2019\results\Pooled\adj_risk_models/ym_pooled_exp_not_ph
estimates store ym_pooled_exp_not_ph

estimates use K:\ALPHA\Projects\Gates_incidence_risks_2019\results\Pooled\adj_risk_models/ym_pooled_exp_phrisks
estimates store ym_pooled_exp_phrisks

estimates use K:\ALPHA\Projects\Gates_incidence_risks_2019\results\Pooled\adj_risk_models/ym_pooled_exp_prefer
estimates store ym_pooled_exp_prefer

estout ym_pooled_exp_ph ym_pooled_exp_not_ph ym_pooled_exp_int_not_ph ym_pooled_exp_phrisks ym_pooled_exp_prefer ///
using "K:/ALPHA/projects/gates_incidence_risks_2019/results/pooled/adj_risk_models/young_men.txt",replace eform  ///
c("b (fmt(%4.2f)) ci_l & ci_u ") incelldelimiter("-") label mlabel("PH" "Not PH, no interaction" "Not PH with interaction"  "PH risks only" "Preferred")  ///
collabels("Adj HR" "95% CI")   drop(_cons) stats(mean_fail mean_sub mean_ptime, fmt(%5.0f)) noabbrev

*older men

estimates use K:\ALPHA\Projects\Gates_incidence_risks_2019\results\Pooled\adj_risk_models/om_pooled_exp_ph,
estimates store om_pooled_exp_ph
estimates use K:\ALPHA\Projects\Gates_incidence_risks_2019\results\Pooled\adj_risk_models/om_pooled_exp_int_not_ph
estimates store om_pooled_exp_int_not_ph

estimates use K:\ALPHA\Projects\Gates_incidence_risks_2019\results\Pooled\adj_risk_models/om_pooled_exp_not_ph
estimates store om_pooled_exp_not_ph

estimates use K:\ALPHA\Projects\Gates_incidence_risks_2019\results\Pooled\adj_risk_models/om_pooled_exp_phrisks
estimates store om_pooled_exp_phrisks
estimates use K:\ALPHA\Projects\Gates_incidence_risks_2019\results\Pooled\adj_risk_models/om_pooled_exp_prefer
estimates store om_pooled_exp_prefer

estout om_pooled_exp_ph om_pooled_exp_not_ph om_pooled_exp_int_not_ph  om_pooled_exp_phrisks om_pooled_exp_prefer ///
using "K:/ALPHA/projects/gates_incidence_risks_2019/results/pooled/adj_risk_models/older_men.txt",replace eform  ///
c("b (fmt(%4.2f)) ci_l & ci_u ") incelldelimiter("-") label mlabel("PH" "Not PH, no interaction" "Not PH with interaction" "PH risks only" "Preferred")  ///
collabels("Adj HR" "95% CI")   drop(_cons) stats(mean_fail mean_sub mean_ptime, fmt(%5.0f)) noabbrev


*And the last one for the paper table

estout yw_pooled_exp_prefer ow_pooled_exp_prefer ym_pooled_exp_prefer  om_pooled_exp_prefer ///
using "K:\ALPHA\Projects\Gates_incidence_risks_2019\paper\Tables and graphs/pooled_adjusted_preferred.txt",replace eform  ///
c("b (fmt(%4.2f)) ci_l & ci_u ") incelldelimiter("-") label mlabel("Young Women" "Older Women" "Young Men" "Older Men")  ///
collabels("Adj HR" "95% CI")   drop(_cons) stats(mean_fail mean_sub mean_ptime, fmt(%5.0f)) noabbrev


estimates table om_pooled_exp_ph om_pooled_exp_not_ph om_pooled_exp_int_not_ph  om_pooled_exp_phrisks om_pooled_exp_prefer,eform stats(aic) newpanel b(%4.2f)







