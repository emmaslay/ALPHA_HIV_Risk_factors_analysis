/*
 ESTIMATE POOLED CRUDE HR WHERE THERE MAY BE SITE INTERACTIONS
	THIS IS BASED ON SITE-SPECIFIC CRUDE HR

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

set maxiter 300

*===+===+===+===+===+===+===+===+===+===+===+===+===+===+===+
* FIT MODELS FOR EDUCATION- YW, OW, OM
*===+===+===+===+===+===+===+===+===+===+===+===+===+===+===+

*Young women

cap mi estimate,esampvaryok hr post errorok :streg  ib1.tv_educ##ib4.study_name  if sex==2 & youth==1  ,d(e)   
if _rc==0 {
mi estimate,esampvaryok hr post errorok :streg  ib1.tv_educ##ib4.study_name  if sex==2 & youth==1  ,d(e)   
do ${alphapath}/ALPHA\Projects\Gates_incidence_trends_2019\add_mean_fails_subjects_ptime_to_ereturn.do
estimates save ${alphapath}/ALPHA/projects/gates_incidence_risks_2019/results/pooled/site_int_crude_risk_models/yw_educ_int_pooled,replace
estimates store yw_educ_int_pooled
parmest, eform saving("${alphapath}/ALPHA/projects/gates_incidence_risks_2019/results/pooled/site_int_crude_risk_models/yw_educ_int_pooled",replace) idstr(ib1.tv_educ)  idnum(9)  stars(0.1 0.05 0.01 0.001)  flist(tflist_om)  escal(mean_fail mean_sub mean_ptime)   
di "`c(current_date)'  `c(current_time)'"
}

*Older women
cap mi estimate,esampvaryok hr post errorok :streg  ib1.tv_educ##ib4.study_name  if sex==2 & youth==0  ,d(e)   
if _rc==0 {
mi estimate,esampvaryok hr post errorok :streg  ib1.tv_educ##ib4.study_name  if sex==2 & youth==0  ,d(e)   
do ${alphapath}/ALPHA\Projects\Gates_incidence_trends_2019\add_mean_fails_subjects_ptime_to_ereturn.do
estimates save ${alphapath}/ALPHA/projects/gates_incidence_risks_2019/results/pooled/site_int_crude_risk_models/ow_educ_int_pooled,replace
estimates store ow_educ_int_pooled
parmest, eform saving("${alphapath}/ALPHA/projects/gates_incidence_risks_2019/results/pooled/site_int_crude_risk_models/ow_educ_int_pooled",replace) idstr(ib1.tv_educ)  idnum(9)  stars(0.1 0.05 0.01 0.001)  flist(tflist_om)  escal(mean_fail mean_sub mean_ptime)   
di "`c(current_date)'  `c(current_time)'"
}

*Older men
cap mi estimate,esampvaryok hr post errorok :streg  ib1.tv_educ##ib4.study_name  if sex==1 & youth==0  ,d(e)   
if _rc==0 {
mi estimate,esampvaryok hr post errorok :streg  ib1.tv_educ##ib4.study_name  if sex==1 & youth==0  ,d(e)   
do ${alphapath}/ALPHA\Projects\Gates_incidence_trends_2019\add_mean_fails_subjects_ptime_to_ereturn.do
estimates save ${alphapath}/ALPHA/projects/gates_incidence_risks_2019/results/pooled/site_int_crude_risk_models/om_educ_int_pooled,replace
estimates store om_educ_int_pooled
parmest, eform saving("${alphapath}/ALPHA/projects/gates_incidence_risks_2019/results/pooled/site_int_crude_risk_models/om_educ_int_pooled",replace) idstr(ib1.tv_educ)  idnum(9)  stars(0.1 0.05 0.01 0.001)  flist(tflist_om)  escal(mean_fail mean_sub mean_ptime)   
di "`c(current_date)'  `c(current_time)'"
}



*===+===+===+===+===+===+===+===+===+===+===+===+===+===+===+
* FIT MODELS FOR MOBILITY- YM, OM
*===+===+===+===+===+===+===+===+===+===+===+===+===+===+===+
*Younger men
cap mi estimate,esampvaryok hr post errorok :streg  i.mobile##ib4.study_name  if sex==1 & youth==1  ,d(e)   
if _rc==0 {
mi estimate,esampvaryok hr post errorok :streg  i.mobile##ib4.study_name  if sex==1 & youth==1  ,d(e)   
do ${alphapath}/ALPHA\Projects\Gates_incidence_trends_2019\add_mean_fails_subjects_ptime_to_ereturn.do
estimates save ${alphapath}/ALPHA/projects/gates_incidence_risks_2019/results/pooled/site_int_crude_risk_models/ym_mobile_int_pooled,replace
estimates store ym_mobile_int_pooled
parmest, eform saving("${alphapath}/ALPHA/projects/gates_incidence_risks_2019/results/pooled/site_int_crude_risk_models/ym_mobile_int_pooled",replace) idstr(mobile)  idnum(9)  stars(0.1 0.05 0.01 0.001)  flist(tflist_om)  escal(mean_fail mean_sub mean_ptime)   
di "`c(current_date)'  `c(current_time)'"
}

*Older men
cap mi estimate,esampvaryok hr post errorok :streg  i.mobile##ib4.study_name  if sex==1 & youth==0  ,d(e)   
if _rc==0 {
mi estimate,esampvaryok hr post errorok :streg  i.mobile##ib4.study_name  if sex==1 & youth==0  ,d(e)   
do ${alphapath}/ALPHA\Projects\Gates_incidence_trends_2019\add_mean_fails_subjects_ptime_to_ereturn.do
estimates save ${alphapath}/ALPHA/projects/gates_incidence_risks_2019/results/pooled/site_int_crude_risk_models/om_mobile_int_pooled,replace
estimates store om_mobile_int_pooled
parmest, eform saving("${alphapath}/ALPHA/projects/gates_incidence_risks_2019/results/pooled/site_int_crude_risk_models/om_mobile_int_pooled",replace) idstr(mobile)  idnum(9)  stars(0.1 0.05 0.01 0.001)  flist(tflist_om)  escal(mean_fail mean_sub mean_ptime)   
di "`c(current_date)'  `c(current_time)'"
}


*===+===+===+===+===+===+===+===+===+===+===+===+===+===+===+
* FIT MODELS FOR NEW PARTNERS- YM, OM
*===+===+===+===+===+===+===+===+===+===+===+===+===+===+===+
*Younger men
cap mi estimate,esampvaryok hr post errorok :streg  i.tv_new_partner##ib4.study_name  if sex==1 & youth==1  ,d(e)   
if _rc==0 {
mi estimate,esampvaryok hr post errorok :streg  i.tv_new_partner##ib4.study_name  if sex==1 & youth==1  ,d(e)   
do ${alphapath}/ALPHA\Projects\Gates_incidence_trends_2019\add_mean_fails_subjects_ptime_to_ereturn.do
estimates save ${alphapath}/ALPHA/projects/gates_incidence_risks_2019/results/pooled/site_int_crude_risk_models/ym_newp_int_pooled,replace
estimates store ym_newp_int_pooled
parmest, eform saving("${alphapath}/ALPHA/projects/gates_incidence_risks_2019/results/pooled/site_int_crude_risk_models/ym_newp_int_pooled",replace) idstr(tv_new_partner)  idnum(9)  stars(0.1 0.05 0.01 0.001)  flist(tflist_om)  escal(mean_fail mean_sub mean_ptime)   
di "`c(current_date)'  `c(current_time)'"
}

*Older men
cap mi estimate,esampvaryok hr post errorok :streg  i.tv_new_partner##ib4.study_name  if sex==1 & youth==0  ,d(e)   
if _rc==0 {
mi estimate,esampvaryok hr post errorok :streg  i.tv_new_partner##ib4.study_name  if sex==1 & youth==0  ,d(e)   
do ${alphapath}/ALPHA\Projects\Gates_incidence_trends_2019\add_mean_fails_subjects_ptime_to_ereturn.do
estimates save ${alphapath}/ALPHA/projects/gates_incidence_risks_2019/results/pooled/site_int_crude_risk_models/om_newp_int_pooled,replace
estimates store om_newp_int_pooled
parmest, eform saving("${alphapath}/ALPHA/projects/gates_incidence_risks_2019/results/pooled/site_int_crude_risk_models/om_newp_int_pooled",replace) idstr(tv_new_partner)  idnum(9)  stars(0.1 0.05 0.01 0.001)  flist(tflist_om)  escal(mean_fail mean_sub mean_ptime)   
di "`c(current_date)'  `c(current_time)'"
}


*===+===+===+===+===+===+===+===+===+===+===+===+===+===+===+
* FIT MODELS FOR UNTREATED- ALL
*===+===+===+===+===+===+===+===+===+===+===+===+===+===+===+
*Younger men
cap mi estimate,esampvaryok hr post errorok :streg  ib4.study_name#c.untreated  if sex==1 & youth==1  ,d(e)   
if _rc==0 {
mi estimate,esampvaryok hr post errorok :streg  ib4.study_name#c.untreated  if sex==1 & youth==1  ,d(e)   
do ${alphapath}/ALPHA\Projects\Gates_incidence_trends_2019\add_mean_fails_subjects_ptime_to_ereturn.do
estimates save ${alphapath}/ALPHA/projects/gates_incidence_risks_2019/results/pooled/site_int_crude_risk_models/ym_untreated_int_pooled,replace
estimates store ym_untreated_int_pooled
parmest, eform saving("${alphapath}/ALPHA/projects/gates_incidence_risks_2019/results/pooled/site_int_crude_risk_models/ym_untreated_int_pooled",replace) idstr(untreated_opp_sex_prevalence)  idnum(9)  stars(0.1 0.05 0.01 0.001)  flist(tflist_om)  escal(mean_fail mean_sub mean_ptime)   
di "`c(current_date)'  `c(current_time)'"
}

*older men
cap mi estimate,esampvaryok hr post errorok :streg  ib4.study_name#c.untreated  if sex==1 & youth==0  ,d(e)   
if _rc==0 {
mi estimate,esampvaryok hr post errorok :streg  ib4.study_name#c.untreated  if sex==1 & youth==0  ,d(e)   
do ${alphapath}/ALPHA\Projects\Gates_incidence_trends_2019\add_mean_fails_subjects_ptime_to_ereturn.do
estimates save ${alphapath}/ALPHA/projects/gates_incidence_risks_2019/results/pooled/site_int_crude_risk_models/om_untreated_int_pooled,replace
estimates store om_untreated_int_pooled
parmest, eform saving("${alphapath}/ALPHA/projects/gates_incidence_risks_2019/results/pooled/site_int_crude_risk_models/om_untreated_int_pooled",replace) idstr(untreated_opp_sex_prevalence)  idnum(9)  stars(0.1 0.05 0.01 0.001)  flist(tflist_om)  escal(mean_fail mean_sub mean_ptime)   
di "`c(current_date)'  `c(current_time)'"
}

*Young women
cap mi estimate,esampvaryok hr post errorok :streg  ib4.study_name#c.untreated  if sex==2 & youth==1  ,d(e)   
if _rc==0 {
mi estimate,esampvaryok hr post errorok :streg  ib4.study_name#c.untreated  if sex==2 & youth==1  ,d(e)   
do ${alphapath}/ALPHA\Projects\Gates_incidence_trends_2019\add_mean_fails_subjects_ptime_to_ereturn.do
estimates save ${alphapath}/ALPHA/projects/gates_incidence_risks_2019/results/pooled/site_int_crude_risk_models/yw_untreated_int_pooled,replace
estimates store yw_untreated_int_pooled
parmest, eform saving("${alphapath}/ALPHA/projects/gates_incidence_risks_2019/results/pooled/site_int_crude_risk_models/yw_untreated_int_pooled",replace) idstr(untreated_opp_sex_prevalence)  idnum(9)  stars(0.1 0.05 0.01 0.001)  flist(tflist_om)  escal(mean_fail mean_sub mean_ptime)   
di "`c(current_date)'  `c(current_time)'"
}

*Older women
cap mi estimate,esampvaryok hr post errorok :streg  ib4.study_name#c.untreated  if sex==2 & youth==0  ,d(e)   
if _rc==0 {
mi estimate,esampvaryok hr post errorok :streg  ib4.study_name#c.untreated  if sex==2 & youth==0  ,d(e)   
do ${alphapath}/ALPHA\Projects\Gates_incidence_trends_2019\add_mean_fails_subjects_ptime_to_ereturn.do
estimates save ${alphapath}/ALPHA/projects/gates_incidence_risks_2019/results/pooled/site_int_crude_risk_models/ow_untreated_int_pooled,replace
estimates store ow_untreated_int_pooled
parmest, eform saving("${alphapath}/ALPHA/projects/gates_incidence_risks_2019/results/pooled/site_int_crude_risk_models/ow_untreated_int_pooled",replace) idstr(untreated_opp_sex_prevalence)  idnum(9)  stars(0.1 0.05 0.01 0.001)  flist(tflist_om)  escal(mean_fail mean_sub mean_ptime)   
di "`c(current_date)'  `c(current_time)'"
}
/** Make a table of the main estimates
estimates use ${alphapath}/ALPHA/projects/gates_incidence_risks_2019/results/pooled/adj_risk_models/om_big_adj_pooled.ster
estimates store om
estimates use ${alphapath}/ALPHA/projects/gates_incidence_risks_2019/results/pooled/adj_risk_models/ym_big_adj_pooled.ster
estimates store ym
estimates use ${alphapath}/ALPHA/projects/gates_incidence_risks_2019/results/pooled/adj_risk_models/yw_big_adj_pooled.ster
estimates store yw
estimates use ${alphapath}/ALPHA/projects/gates_incidence_risks_2019/results/pooled/adj_risk_models/ow_big_adj_pooled.ster
estimates store ow

estout  ym yw om ow ///
using "K:/ALPHA/projects/gates_incidence_risks_2019/results/pooled/adj_risk_models/All_sites_pooled_big_models.txt",replace eform  ///
c("b (fmt(%4.3f)) ci_l & ci_u ") incelldelimiter("-") label mlabel("Young Men" "Young Women" "Older Men" "Older Women")  ///
collabels("Adj HR" "95% CI")   drop(_cons) stats(mean_fail mean_sub mean_ptime, fmt(%5.0f)) noabbrev

*/
/**** NEED RANDOM INTERCEPT FOR SITES

mi estimate,esampvaryok hr post errorok nimp(4) :stmixed  untreated  if sex==2 & youth==0 || study_name:untreated ,d(e) cova(unstructured) showmerlin

merlin (untreated untreated#M1[study]@1 M2[study]@1, family(gaussian))

merlin (_t untreated_opp_sex_prevalence sex untreated_opp_sex_prevalence#M1[study_name]@1, family(rp, failure(_d)   ltruncated(_t0) df(3)  ) ) if _st==1 & sex==1 & youth==1

