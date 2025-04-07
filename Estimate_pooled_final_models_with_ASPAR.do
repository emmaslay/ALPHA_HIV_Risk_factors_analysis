

*===+===+===+===+===+===+===+===+===+===+===+===+===+===+===+
* ON THE SUBSET OF SITES WHICH HAVE DATA ON ASPAR FIT MODELS 
* WITH POP-LEVEL ASPAR & ASPLR FOR SAME SEX AND OPPOSITE SEX
*===+===+===+===+===+===+===+===+===+===+===+===+===+===+===+

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

mi xeq: bys study_name years_one:egen checkpar=mean(same_sex_par)
mi xeq: keep if checkpar<.

/*
*would be a good idea but haven't done  it- actually no because tertiary is important in some
mi xeq: recode tv_educ 3=2
mi xeq: label define tv_educ 2 "Secondary and higher",modify
*/
mi xeq: recode tv_clastyr 4=9


set maxiter 300


global tryimp=70

*YOUNG WOMEN

mi estimate,esampvaryok hr post errorok dots nimputations(${tryimp})   :streg ib1.tv_educ ib1.tv_mstat_br i.tv_regular i.tv_new_partner i.tv_casual untreated_opp_sex_prevalence ib2.study_name  if sex==2 & youth==1 & (study_name==1 | study_name==2 | study_name==5 | study_name==6),d(e)   
do ${alphapath}/ALPHA\Projects\Gates_incidence_trends_2019\add_mean_fails_subjects_ptime_to_ereturn.do
estimates save ${alphapath}/ALPHA/projects/gates_incidence_risks_2019/results/pooled/subset_risk_models/yw_big_adj_pooled_orig,replace
estimates store yw_big_adj_pooled_orig

mi estimate,esampvaryok hr post errorok dots nimputations(${tryimp})   :streg ib1.tv_educ ib1.tv_mstat_br i.tv_regular i.tv_new_partner i.tv_casual untreated_opp_sex_prevalence ib2.study_name same_sex_par  opp_sex_par same_sex_plr opp_sex_plr  if sex==2 & youth==1 & (study_name==1 | study_name==2 | study_name==5 | study_name==6),d(e)   
do ${alphapath}/ALPHA\Projects\Gates_incidence_trends_2019\add_mean_fails_subjects_ptime_to_ereturn.do
estimates save ${alphapath}/ALPHA/projects/gates_incidence_risks_2019/results/pooled/subset_risk_models/yw_big_adj_pooled,replace
estimates store yw_big_adj_pooled_sub
parmest, eform saving("${alphapath}/ALPHA/projects/gates_incidence_risks_2019/results/pooled/subset_risk_models/yw_big_adj_pooled",replace) idstr(`risk')  idnum(`snum')  stars(0.1 0.05 0.01 0.001)  flist(tflist_om)  escal(mean_fail mean_sub mean_ptime)   

di "YW model done `c(current_date)'  `c(current_time)'"

*OLDER WOMEN

mi estimate,esampvaryok eform post errorok cmdok dots  nimp($useimp):streg i.mobile ib1.tv_educ ib1.tv_mstat_br i.tv_new_partner untreated_opp_sex_prevalence ib1.tv_clastyr  ib2.study_name  if sex==2 & youth==0  & (study_name==1 | study_name==2 | study_name==5 | study_name==6),d(e)  
do ${alphapath}/ALPHA\Projects\Gates_incidence_trends_2019\add_mean_fails_subjects_ptime_to_ereturn.do
estimates save ${alphapath}/ALPHA/projects/gates_incidence_risks_2019/results/pooled/subset_risk_models/ow_big_adj_pooled_orig,replace
estimates store ow_big_adj_pooled_orig


mi estimate,esampvaryok hr post errorok dots nimputations(${tryimp})   :streg i.mobile   ib1.tv_educ  ib1.tv_mstat_br  i.tv_new_partner untreated_opp_sex_prevalence ib1.tv_clastyr   same_sex_par  opp_sex_par same_sex_plr opp_sex_plr ib2.study_name  if sex==2 & youth==0 & (study_name==1 | study_name==2 | study_name==5 | study_name==6),d(e)   
do ${alphapath}/ALPHA\Projects\Gates_incidence_trends_2019\add_mean_fails_subjects_ptime_to_ereturn.do
estimates save ${alphapath}/ALPHA/projects/gates_incidence_risks_2019/results/pooled/subset_risk_models/ow_big_adj_pooled,replace
estimates store ow_big_adj_pooled_sub
parmest, eform saving("${alphapath}/ALPHA/projects/gates_incidence_risks_2019/results/pooled/subset_risk_models/ow_big_adj_pooled",replace) idstr(`risk')  idnum(`snum')  stars(0.1 0.05 0.01 0.001)  flist(tflist_om)  escal(mean_fail mean_sub mean_ptime)   

di "OW model done `c(current_date)'  `c(current_time)'"
*===+===+===+===+===+===+===+

*YOUNG MEN
* same_sex_par 
mi estimate,esampvaryok hr post errorok dots nimputations(${tryimp}) :streg ib1.tv_educ ib1.tv_mstat_br untreated_opp_sex_prevalence i.tv_circumcised ib2.study_name if sex==1 & youth==1 & (study_name==1 | study_name==2 | study_name==5 | study_name==6),d(e)   
do ${alphapath}/ALPHA\Projects\Gates_incidence_trends_2019\add_mean_fails_subjects_ptime_to_ereturn.do
estimates save ${alphapath}/ALPHA/projects/gates_incidence_risks_2019/results/pooled/subset_risk_models/ym_big_adj_pooled_orig,replace
estimates store ym_big_adj_pooled_orig

mi estimate,esampvaryok hr post errorok dots nimputations(${tryimp}) :streg ib1.tv_educ ib1.tv_mstat_br untreated_opp_sex_prevalence i.tv_circumcised ib2.study_name same_sex_par  opp_sex_par same_sex_plr opp_sex_plr if sex==1 & youth==1 & (study_name==1 | study_name==2 | study_name==5 | study_name==6),d(e)   
do ${alphapath}/ALPHA\Projects\Gates_incidence_trends_2019\add_mean_fails_subjects_ptime_to_ereturn.do
estimates save ${alphapath}/ALPHA/projects/gates_incidence_risks_2019/results/pooled/subset_risk_models/ym_big_adj_pooled,replace
estimates store ym_big_adj_pooled_sub
parmest, eform saving("${alphapath}/ALPHA/projects/gates_incidence_risks_2019/results/pooled/subset_risk_models/ym_big_adj_pooled",replace) idstr(`risk')  idnum(`snum')  stars(0.1 0.05 0.01 0.001)  flist(tflist_om)  escal(mean_fail mean_sub mean_ptime)   

di "YM model done `c(current_date)'  `c(current_time)'"


*OLDER MEN

mi estimate,esampvaryok hr post errorok dots nimputations(${tryimp}) :streg ib1.tv_mstat_br i.tv_regular untreated_opp_sex_prevalence ib2.study_name if sex==1 & youth==0 ,d(e)   
do ${alphapath}/ALPHA\Projects\Gates_incidence_trends_2019\add_mean_fails_subjects_ptime_to_ereturn.do
estimates save ${alphapath}/ALPHA/projects/gates_incidence_risks_2019/results/pooled/subset_risk_models/om_big_adj_pooled_orig,replace
estimates store om_big_adj_pooled_orig

*mi estimate,esampvaryok hr post errorok dots nimputations(${tryimp}) :streg ib1.tv_mstat_br i.tv_regular untreated_opp_sex_prevalence ib4.study_name same_sex_par  opp_sex_par same_sex_plr opp_sex_plr if sex==1 & youth==0 ,d(e)   

mi estimate,esampvaryok hr post errorok dots nimputations(${tryimp}) :streg ib1.tv_mstat_br i.tv_regular untreated_opp_sex_prevalence ib2.study_name same_sex_par  if sex==1 & youth==0 ,d(e)   
do ${alphapath}/ALPHA\Projects\Gates_incidence_trends_2019\add_mean_fails_subjects_ptime_to_ereturn.do
estimates save ${alphapath}/ALPHA/projects/gates_incidence_risks_2019/results/pooled/subset_risk_models/om_big_adj_pooled,replace
estimates store om_big_adj_pooled_sub
parmest, eform saving("${alphapath}/ALPHA/projects/gates_incidence_risks_2019/results/pooled/subset_risk_models/om_big_adj_pooled",replace) idstr(`risk')  idnum(`snum')  stars(0.1 0.05 0.01 0.001)  flist(tflist_om)  escal(mean_fail mean_sub mean_ptime)   

di "OM model done `c(current_date)'  `c(current_time)'"

label var same_sex_par "Partner acquisition rate"
label var same_sex_plr "Partner loss rate"

estout  ow_big_adj_pooled_orig ow_big_adj_pooled_sub om_big_adj_pooled_orig om_big_adj_pooled_sub ///
using "K:/ALPHA/projects/gates_incidence_risks_2019/results/pooled/subset_risk_models/older_people.txt",replace eform  ///
c("b (fmt(%4.3f)) ci_l & ci_u ") incelldelimiter("-") label mlabel("Older women" "Older women with PAR" "Older men" "Older men with PAR")  ///
collabels("Adj HR" "95% CI")   drop(_cons) stats(mean_fail mean_sub mean_ptime, fmt(%5.0f)) noabbrev

estout  yw_big_adj_pooled_orig yw_big_adj_pooled_sub ym_big_adj_pooled_orig ym_big_adj_pooled_sub ///
using "K:/ALPHA/projects/gates_incidence_risks_2019/results/pooled/subset_risk_models/young_people.txt",replace eform  ///
c("b (fmt(%4.3f)) ci_l & ci_u ") incelldelimiter("-") label mlabel("Young women" "Young women with PAR" "Young men" "Young men with PAR")  ///
collabels("Adj HR" "95% CI")   drop(_cons) stats(mean_fail mean_sub mean_ptime, fmt(%5.0f)) noabbrev


estout  yw_big_adj_pooled_orig yw_big_adj_pooled_sub ow_big_adj_pooled_orig ow_big_adj_pooled_sub  ym_big_adj_pooled_orig ym_big_adj_pooled_sub om_big_adj_pooled_orig om_big_adj_pooled_sub ///
using "K:/ALPHA/projects/gates_incidence_risks_2019/results/pooled/subset_risk_models/everyone.txt",replace eform  ///
c("b (fmt(%4.3f)) ci_l & ci_u ") incelldelimiter("-") label mlabel("Young women" "Young women with PAR" "Older women" "Older women with PAR" "Young men" "Young men with PAR"  "Older men" "Older men with PAR")  ///
collabels("Adj HR" "95% CI")   drop(_cons) stats(mean_fail mean_sub mean_ptime, fmt(%5.0f)) noabbrev


estout  ow_big_adj_pooled_orig ow_big_adj_pooled_sub ///
using "K:/ALPHA/projects/gates_incidence_risks_2019/results/pooled/subset_risk_models/older_women.txt",replace eform  ///
c("b (fmt(%4.3f)) ci_l & ci_u ") incelldelimiter("-") label mlabel("Older women" "Older women with PAR")  ///
collabels("Adj HR" "95% CI")   drop(_cons) stats(mean_fail mean_sub mean_ptime, fmt(%5.0f)) noabbrev



