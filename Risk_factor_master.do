*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=
***  Risk factor analysis master
*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=

global nimp=70
*global nimp=7
global useimp=70





*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=
** data prep
*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=

*Needs recoded sexual behaviour and the incidence midpoint and mi ready file

** PULLS IN PARTNERSHIPS AND UNTREATED PREVALENCE READY DATA


/*
do K:\ALPHA\DoFiles\Analysis/Make_analysis_file_untreated_prevalence.do /*site loop */
do K:\ALPHA\DoFiles\Analysis/Make_analysis_file_sexual_partnership_dynamic.do /*site loop */

*/
*these use pooled data (pooled in the do file)
do "K:\ALPHA\Projects\Gates_incidence_risks_2019\Get_opp_sex_ASPAR.do" 
do  "K:\ALPHA\Projects\Gates_incidence_risks_2019\Get_opp_sex_losses.do" 


do K:\ALPHA\DoFiles\Analysis/Make_analysis_file_incidence_risk_factors.do /*site loop */

do K:\ALPHA\DoFiles\Analysis/Pool_analysis_file_incidence_risk_factors_ready_mi

/*
** id bodge
forvalues x=1/70 {
use  ${alphapath}/ALPHA\Incidence_ready_data/pooled/mi_data/incidence_ready_risk_factors_MI_pooled_`x'.dta,clear
drop idno
egen double idno=group(study_name idno_orig)
streset
save ${alphapath}/ALPHA\Incidence_ready_data/pooled/mi_data/incidence_ready_risk_factors_MI_pooled_`x'.dta,replace
}

use  ${alphapath}/ALPHA\Incidence_ready_data/pooled/mi_data/incidence_ready_risk_factors_MI_pooled_0.dta,clear
drop idno
egen double idno=group(study_name idno_orig)
save ${alphapath}/ALPHA\Incidence_ready_data/pooled/mi_data/incidence_ready_risk_factors_MI_pooled_0.dta,replace


*/
*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=
** table showing who is in the incidence cohort,
** by site age and sex, AND WHO ISN'T AND WHY
*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=

do K:\ALPHA\DoFiles\Analysis/Look_at_loss_to_follow_up_and_participation_incidence.do

*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=
** prevalence of risk factors table
*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=

***FEB 2024-
do K:\ALPHA\Projects\Gates_incidence_risks_2019/Get_risk_factor_prevalences_from_pooled_for_paper_table.do

**and numbers for text
do  "K:\ALPHA\Projects\Gates_incidence_risks_2019\Get_pooled_numbers_from_MI_for_risk_paper_text.do" 


*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=
** throwaway incidence rate estimates
*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=
*not especially useful but reviewers will want them
forvalues x=1/$useimp {
	use "${alphapath}/ALPHA\Incidence_ready_data/pooled\mi_data\incidence_ready_mi_pooled_`x'",clear
keep if age<50 & age>14
keep if years_one>2004 & years_one<2017
drop if study==1 & fouryear==4
drop if study==3 & fouryear==4
gen youth=0 if age>24 & age<50
replace youth=1 if age>14 & age<25
	strate study_name sex youth if age>14 & age<50 & years_one>2004 & years_one<2017,per(1000) output("${alphapath}/ALPHA\Estimates_Incidence\MI_rates/pooled/runs/MI_rates_sex_youth_risk_paper_`x'",replace)
		} /*end of forvalues  x=1/$useimp */

		**COMBINE RATE ESTIMATES
clear
	use "${alphapath}/ALPHA\Estimates_Incidence\MI_rates/pooled/runs/MI_rates_sex_youth_risk_paper_1"
	gen imputation=1
	*get the date the imputations were run and store this in the dataset
	char _dta[imputationdate] `c(filedate)'
	forvalues x=2/$useimp {
		append using "${alphapath}/ALPHA\Estimates_Incidence\MI_rates/pooled/runs/MI_rates_sex_youth_risk_paper_`x'"
		replace imputation=`x'
		} /*end of forvalues x=2/$useimp*/
		
	*now combine using Rubin's rules
	do "${alphapath}/ALPHA\dofiles/common/rubins_rules_for_strate_output_generic.do" sex youth
	rename Qhat rate	
	save "${alphapath}/ALPHA\Estimates_Incidence\MI_rates/pooled/MI_rates_sex_youth_risk_paper",replace

gen str40 format_rate=strofreal(rate,"%4.1f") + " (" + strofreal(lb,"%4.1f") + "-" + strofreal(ub,"%4.1f") + ")"
br sex youth format_r

*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=
** crude site risk factors
*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=

*** this program adapts miestimate so that it ignores models where there were no failures in the comparison groups
*otherwise CI go to plus infinity which is a bit odd when there are no failures in that group. nb would also set to that if 
*there were no failures in baseline but all baselines have plenty of failures.
cap program drop cifixstreg
program cifixstreg
  streg `0'
  local K = colsof(e(b))
  forvalues i = 1/`K' {
	if e(b)[1,`i'] < -14 error 498   
  }
end



*this saves all the HR
do K:\ALPHA\Projects\Gates_incidence_risks_2019/Estimate_site_crude_risk_HR.do /*site loop includes pooled for totally crude HR */


*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=
* pooled site-adjusted risk factors- 
*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=

do K:\ALPHA\Projects\Gates_incidence_risks_2019/estimate_pooled_site_adjusted_risk_HR.do


*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=
** compile these into table- colour coded one
*  makes the forest plots
*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=

do K:\ALPHA\Projects\Gates_incidence_risks_2019/Prepare_dataset_of_crude_risk_HR_for_table.do

** Make word table of pooled (site-adj) crude HR (with shading) and saves it in K:\ALPHA\Projects\Gates_incidence_risks_2019\results\for_paper/Table_of_pooled_siteadj_crude_HR.docx
do K:\ALPHA\Projects\Gates_incidence_risks_2019/Make_pooled_crude_HR_table_in_word

** Make word table of site specific and pooled (site-adj) crude HR (with shading) and saves it in K:\ALPHA\Projects\Gates_incidence_risks_2019\results\for_paper/Crude_HR_green_red_everyone.docx
do K:\ALPHA\Projects\Gates_incidence_risks_2019/Make_crude_HR_green_red_table_in_word.do

/*obselete
*this do file makes the table that contains the CI for the HR and saves it in K:\ALPHA\Projects\Gates_incidence_risks_2019\results\for_paper
do K:\ALPHA\Projects\Gates_incidence_risks_2019/Make_crude_HR_table_in_excel_by_site_red_green_shading.do
*/

/* needs checking/revision May 24, if they are to be used
do K:\ALPHA\Projects\Gates_incidence_risks_2019/Make_table_of_numbers_fup_underlying_crude_hr_table

do K:\ALPHA\Projects\Gates_incidence_risks_2019/Make_forest_plots_of_crude_hr
*/

*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=
** decide on the structure for the pooled models- PH or not, interactions with age and study etc
*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=
*check where there may be site interactions based on red/green table
do "K:\ALPHA\Projects\Gates_incidence_risks_2019\Estimate_pooled_models_with_site_interactions_where_needed.do" 

*figure out what structure of model works best
*uses a single imputation for this one just to get an idea of which fits are best
do  "K:\ALPHA\Projects\Gates_incidence_risks_2019\exploring_pooled_model_hazards.do" 

*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=
** pooled adjusted risk factor models & PAF
*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=
*takes the best three options based on exploration above and fits all three for each age/sex group
*also fits a model without age, calendar year and study for each - though actually should this one be equally weighted otherwise behaviour that is common in uMkhanyakude will be risky
do K:\ALPHA\Projects\Gates_incidence_risks_2019/estimate_pooled_final_models2024.do


*then repeats this, with all sites weighted equally
*[TBD May 24]
** hmm weighting tricky, given that the weights need to change by fouryear, and then it complains that the
*ids have different weights over time. Options- 1) try to trick Stata or 2) meta-analysis
*metaanalysis ought to work if save all the site-specific estimates in a dataset and then load them all in with meta set
*means running all the site specific models, but does get over the need to combine weights with MI which suspect will be tricky

do K:\ALPHA\Projects\Gates_incidence_risks_2019/playing_with_meta_analysis.do

*THen estimate PAFs
* estimate_PAF_from_pooled_multivariate_model.do- needs rewriting to work from saved estimates

*Run models again for studies which have PAR- NEEDS UPDATING TO THE FINAL CHOICE OF MODEL
do K:\ALPHA\Projects\Gates_incidence_risks_2019/Estimate_pooled_final_models_with_ASPAR.do

do K:\ALPHA\Projects\Gates_incidence_risks_2019/plot_adjusted_all_in_models.do
/*
*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=
* estimate PAF
*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=

*LOOK AT THE FILE WHICH ESTIMATES THESE FROM STORED ESTIMATION RESULTS



use K:\ALPHA\Projects\Gates_incidence_risks_2019/asplr_for_merge,clear
merge 1:1 study_name sex age fouryear using K:\ALPHA\Projects\Gates_incidence_risks_2019/aspar_for_merge
scatter same_sex_plr same_sex_par
scatter opp_sex_plr opp_sex_par,by(sex)
scatter opp_sex_plr same_sex_plr,by(sex)
scatter opp_sex_par same_sex_par,by(sex)



use K:\ALPHA\Projects\Gates_incidence_risks_2019/opp_sex_asplr_for_merge
merge m:1 study_name sex age fouryear using K:\ALPHA\Projects\Gates_incidence_risks_2019/fouryear_ASPLR.dta

 use "K:\ALPHA\Incidence_ready_data\pooled\mi_data\incidence_ready_risk_factors_MI_pooled_1.dta",clear
merge m:1 study_name sex age fouryear using K:\ALPHA\Projects\Gates_incidence_risks_2019/aspar_for_merge
keep if _m==3
drop _m
merge m:1 study_name sex age fouryear using K:\ALPHA\Projects\Gates_incidence_risks_2019/asplr_for_merge

keep if _m==3
drop _m

*young women
streg i.mobile mstat_1 mstat_3 mstat_4 ib0.tv_new_partner i.p2grp_1 i.p2grp_3 i.p2grp_4 ib0.tv_regular ib0.tv_casual  untreated_opp_sex_pre ib3.fouryear ib4.study_name if sex==2 & youth==1 ,d(e)   
streg same_sex_par opp_sex_par i.mobile mstat_1 mstat_3 mstat_4 ib0.tv_new_partner i.p2grp_1 i.p2grp_3 i.p2grp_4 ib0.tv_regular ib0.tv_casual  untreated_opp_sex_pre ib3.fouryear ib4.study_name if sex==2 & youth==1 ,d(e)   
streg same_sex_plr opp_sex_plr i.mobile mstat_1 mstat_3 mstat_4 ib0.tv_new_partner i.p2grp_1 i.p2grp_3 i.p2grp_4 ib0.tv_regular ib0.tv_casual  untreated_opp_sex_pre ib3.fouryear ib4.study_name if sex==2 & youth==1 ,d(e)   

*older women
streg  i.mobile mstat_1 mstat_3 mstat_4 ib0.tv_new_partner i.p2grp_1 i.p2grp_3 i.p2grp_4 ib0.tv_regular untreated_opp_sex_pre ib3.fouryear  ib2.study_name  if sex==2 & youth==0,d(e)   
streg same_sex_par opp_sex_par i.mobile mstat_1 mstat_3 mstat_4 ib0.tv_new_partner i.p2grp_1 i.p2grp_3 i.p2grp_4 ib0.tv_regular untreated_opp_sex_pre ib3.fouryear  ib2.study_name  if sex==2 & youth==0,d(e)   
streg same_sex_plr opp_sex_plr i.mobile mstat_1 mstat_3 mstat_4 ib0.tv_new_partner i.p2grp_1 i.p2grp_3 i.p2grp_4 ib0.tv_regular untreated_opp_sex_pre ib3.fouryear  ib2.study_name  if sex==2 & youth==0,d(e)   

streg same_sex_plr opp_sex_par i.mobile mstat_1 mstat_3 mstat_4 ib0.tv_new_partner i.p2grp_1 i.p2grp_3 i.p2grp_4 ib0.tv_regular untreated_opp_sex_pre ib3.fouryear  ib2.study_name  if sex==2 & youth==0,d(e)   

*older men
streg i.mobile mstat_1 mstat_3 mstat_4 i.tv_circumcised ib0.tv_new_partner i.p2grp_1 i.p2grp_3 i.p2grp_4   ib0.tv_regular  untreated_opp_sex_pre ib3.fouryear   ib2.study_name if sex==1 & youth==0,d(e)   
streg same_sex_par opp_sex_par i.mobile mstat_1 mstat_3 mstat_4 i.tv_circumcised ib0.tv_new_partner i.p2grp_1 i.p2grp_3 i.p2grp_4   ib0.tv_regular  untreated_opp_sex_pre ib3.fouryear   ib2.study_name if sex==1 & youth==0,d(e)   
streg same_sex_plr opp_sex_plr i.mobile mstat_1 mstat_3 mstat_4 i.tv_circumcised ib0.tv_new_partner i.p2grp_1 i.p2grp_3 i.p2grp_4   ib0.tv_regular  untreated_opp_sex_pre ib3.fouryear   ib2.study_name if sex==1 & youth==0,d(e)   


*young men
streg i.mobile mstat_1 mstat_3 mstat_4 i.tv_circumcised  ib0.tv_new_partner i.p2grp_1 i.p2grp_3 i.p2grp_4  untreated_opp_sex_pre ib3.fouryear  ib2.study_name  if sex==1 & youth==1 ,d(e)   
streg same_sex_par opp_sex_par i.mobile mstat_1 mstat_3 mstat_4 i.tv_circumcised  ib0.tv_new_partner i.p2grp_1 i.p2grp_3 i.p2grp_4  untreated_opp_sex_pre ib3.fouryear  ib2.study_name  if sex==1 & youth==1 ,d(e)   
streg same_sex_plr opp_sex_plr i.mobile mstat_1 mstat_3 mstat_4 i.tv_circumcised  ib0.tv_new_partner i.p2grp_1 i.p2grp_3 i.p2grp_4  untreated_opp_sex_pre ib3.fouryear  ib2.study_name  if sex==1 & youth==1 ,d(e)   


*mi erase incidence_risk

/*
*this just looks at them
do K:\ALPHA\Projects\Gates_incidence_risks_2019/alpha_study_risk_factors_analysis.do



/**==**==**==**==**==**==
** DO POWER CALCS- not sure this is worth pursuing
**==**==**==**==**==**==

*NEED AGE DISTRIBUTION & DISTRIBUTION OF TESTS BY AGE FOR SIM

do K:\ALPHA\Projects\Gates_incidence_risks_2019/Get_age_dist_and_last_tests_by_site.do


*need prevalence of risk factors for the sim - get this as the mean across all imputations
do K:\ALPHA\Projects\Gates_incidence_risks_2019/Get_risk_factor_prevalences_from_pooled.do

*need baseline hazards for the sim - get this as the mean across all imputations BUT NOT CURRENTLY
do K:\ALPHA\Projects\Gates_incidence_risks_2019/Get_baseline_hazards.do

use ${alphapath}/ALPHA/projects/gates_incidence_risks_2019/results/pooled/site_specific_hr_summary,clear
keep if varname=="tv_circumcised"
*drop the estiamtes for 15-49
drop if youth==0
*put youth back to teh coding used in the dataset
recode youth 2=0
label define youth 0 "25-49" ,modify
merge 1:1 study_name sex youth varname val using K:\ALPHA\Projects\Gates_incidence_risks_2019\results\Pooled\Risk_dist/pooled_prev_tv_circumcised
drop _m
merge m:1 study_name sex youth using K:\ALPHA\Projects\Gates_incidence_risks_2019\Power/baseline_hazards
drop _m

drop idstr parm stars
order study_name sex youth varname val refcat prop base_haz hr lb ub p es_1 es_2 es_3
label var prop "Proportion of person time with risk factor, mean across imputations"
label var base_haz "Baseline hazard, mean across imputations"
save K:\ALPHA\Projects\Gates_incidence_risks_2019\results\Pooled\Ingredients_for_power_and_PAF,replace


use K:\ALPHA\Projects\Gates_incidence_risks_2019\results\Pooled\Ingredients_for_power_and_PAF,clear
cap frame drop sim
frame create sim
*Circumcision only at the moment
drop if sex==2
drop if refcat==1
gen prop_sig=.
*loop through the records
count
local nrec=r(N)
forvalues x=1/`nrec' {
local prev=prop[`x']
local hr=hr[`x']
local basehaz=base_haz[`x']
local age=youth[`x']
local sex=sex[`x']
local study=study_name[`x']
local fail=es_1[`x']
local sitename=study_name[`x']
local sitename:label (study_name)  `sitename'
local val=val[`x']
frame sim {
do K:\ALPHA\Projects\Gates_incidence_risks_2019\Power/sim_to_be_called.do `prev' `hr' `basehaz' `age' `sex' `study' `fail' `sitename' `val'
}
replace prop_sig=`prop_sig' in `x'
local prop_sig=.
}
** estimate adjusted models for each site
*age, mstat sex=12 per site- not enough power?

*/


** estimate pooled HR?




*estimate PAF using pooled HR and own prevalences



