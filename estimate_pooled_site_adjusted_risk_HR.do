

*=============================================================================
*
*** SUMMARISE CRUDE HR FOR RISK FACTORS FOR HIV INFECTION
*
*  ALPHA WORKSHOP 14, ENTEBBE 25TH-29TH MARCH 2019 
*
*=============================================================================

*global useimp=5

global tflist_yw
global tflist_ym
global tflist_ow
global tflist_om
global tflist_aw
global tflist_am
set maxiter 300

*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=
* OPEN THE DATASET
*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=
cd "${alphapath}/ALPHA\Incidence_ready_data/pooled/mi_data"
use "${alphapath}/ALPHA\Incidence_ready_data/pooled/mi_data/incidence_ready_risk_factors_mi_pooled_0",clear

*cd "${alphapath}/ALPHA\Incidence_ready_data/kisesa/mi_data"
*use "${alphapath}/ALPHA\Incidence_ready_data/kisesa/mi_data/incidence_ready_risk_factors_mi_kisesa_0",clear
summ study_name
local snum=r(mean)

*=========================


*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=
* SET THE DATASET FOR MI ANALYSIS IN STATA (SAME AS EARLIER IN THE WEEK)
*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=

*need to move location of temporary files when working on server as by default these sit on C: and it isn't big enough for what is coming
tempfile f
di "`f'"
! set STATATMP=L:/emma_mi/
! export STATATMP
tempfile f
di "`f'"

cd "L:/emma_mi"

cap mi erase incidence_risk

mi import flongsep incidence_risk, using(${alphapath}/ALPHA/Incidence_ready_data/pooled/mi_data/incidence_ready_risk_factors_mi_pooled_{1-$useimp}) id(study_name idno ep_num) imputed(end_ep_date) 
*mi import flongsep incidence_risk, using(incidence_ready_risk_factors_mi_kisesa_{1-$useimp}) id(study_name idno ep_num) imputed(end_ep_date) 

*restrict analysis to 15-49 and 2005-16
mi xeq: keep if age>14 & age<50 
mi xeq: keep if years_one>2004 & years_one<2017

** get rid of the year/study combinations that don't work
*Drop a few early estimates when there weren't enough people/biased sample (1995-99, Manicaland and Rakai)
*(2013-, Manicaland and Karonga)
mi xeq: drop if study==1 & fouryear==4
mi xeq: drop if study==3 & fouryear==4
*mi xeq: recode tv_new_partner 3=1 /* don't do this- these are people for whom we don't know */

mi xeq:recode tv_sexlastyear 8=9 99=9

cap mkdir ${alphapath}/ALPHA/projects/gates_incidence_risks_2019/results/${sitename}/"

*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=
* CRUDE MODELS TO LOOK AT FACTORS ASSOCIATED WITH HIV INCIDENCE
*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=


***** 	WOMEN

*global risklist_fv "i.residence ib2.fouryear i.mobile ib1.tv_educ ib1.tv_mstat_br  i.tv_morethan1 ib1.tv_ptnrs i.tv_regular i.tv_casual i.tv_new_partner ib1.tv_clastyr i.tv_pagegrp i.tv_anylost ib1.tv_cf_all opp_sex_par opp_sex_plr same_sex_par same_sex_plr untreated_opp_sex_prevalence "
global risklist_fv "ib1.tv_clastyr"

foreach risk in $risklist_fv {
di "`risk' for `sname'"


local riskname=subinstr("`risk'",".","_",.)

*Older women
cap mi estimate,esampvaryok hr post errorok :streg  `risk'  ib4.study_name if sex==2 & youth==0  ,d(e)   
if _rc==0 {

mi estimate,esampvaryok hr post errorok :streg  `risk'  ib4.study_name if sex==2 & youth==0,d(e)  
qui do ${alphapath}/ALPHA\Projects\Gates_incidence_risks_2019\add_mean_fails_subjects_ptime_to_ereturn_after_cifixstreg.do
parmest, eform saving("${alphapath}/ALPHA/projects/gates_incidence_risks_2019/results/pooled/ow_`riskname'_siteadj_pooled",replace) idstr(siteadj_`risk')  idnum(`snum')  stars(0.1 0.05 0.01 0.001)  flist(tflist_ow) escal(mean_fail mean_sub mean_ptime n_imp_used)     
	
} /*close _rc loop */

*Young women
cap mi estimate,esampvaryok hr post errorok :streg  `risk' ib4.study_name  if sex==2 & youth==1 ,d(e)  
if _rc==0 { 

mi estimate,esampvaryok hr post errorok :streg  `risk' ib4.study_name  if sex==2 & youth==1 ,d(e)   
qui do ${alphapath}/ALPHA\Projects\Gates_incidence_risks_2019\add_mean_fails_subjects_ptime_to_ereturn_after_cifixstreg.do
parmest, eform saving("${alphapath}/ALPHA/projects/gates_incidence_risks_2019/results/pooled/yw_`riskname'_siteadj_pooled",replace) idstr(siteadj_`risk')  idnum(`snum')  stars(0.1 0.05 0.01 0.001)  flist(tflist_yw) escal(mean_fail mean_sub mean_ptime n_imp_used)     
	
} /*close _rc loop */


} /*close risk loop */


*************************************************
*MEN
*global risklist_fv "i.residence ib2.fouryear i.mobile ib1.tv_educ i.tv_circumcised ib1.tv_mstat_br  i.tv_morethan1 ib1.tv_ptnrs i.tv_regular i.tv_casual i.tv_new_partner ib1.tv_clastyr i.tv_pagegrp i.tv_anylost ib1.tv_cf_all opp_sex_par opp_sex_plr same_sex_par same_sex_plr untreated_opp_sex_prevalence "
global risklist_fv "ib1.tv_clastyr"


foreach risk in $risklist_fv {

*changed this to switch baseline on calendar year for sites that don't have data 2005-08 done 20/1/20 but not tested
di "`risk' for pooled"
if lower("`risk'")=="ib2.fouryear" & (lower("pooled")=="kisumu" | lower("pooled")=="ifakara")  {
local risk="ib3.fouryear"
}


local riskname=subinstr("`risk'",".","_",.)

*Older men
cap mi estimate,esampvaryok hr post errorok :streg  `risk' ib4.study_name  if sex==1 & youth==0  ,d(e)  
if _rc==0 {

mi estimate,esampvaryok hr post errorok :streg  `risk' if sex==1 & youth==0,d(e)  
qui do ${alphapath}/ALPHA\Projects\Gates_incidence_risks_2019\add_mean_fails_subjects_ptime_to_ereturn_after_cifixstreg.do
parmest, eform saving("${alphapath}/ALPHA/projects/gates_incidence_risks_2019/results/pooled/om_`riskname'_siteadj_pooled",replace) idstr(siteadj_`risk')  idnum(`snum')  stars(0.1 0.05 0.01 0.001)  flist(tflist_om)  escal(mean_fail mean_sub mean_ptime n_imp_used)   
	
} /*close _rc loop */

*young men
cap mi estimate,esampvaryok hr post errorok :streg  `risk' ib4.study_name  if sex==1 & youth==1 ,d(e)  
if _rc==0 {

mi estimate,esampvaryok hr post errorok :streg  `risk' ib4.study_name  if sex==1 & youth==1 ,d(e)  
qui do ${alphapath}/ALPHA\Projects\Gates_incidence_risks_2019\add_mean_fails_subjects_ptime_to_ereturn_after_cifixstreg.do
parmest, eform saving("${alphapath}/ALPHA/projects/gates_incidence_risks_2019/results/pooled/ym_`riskname'_siteadj_pooled",replace) idstr(siteadj_`risk')  idnum(`snum')  stars(0.1 0.05 0.01 0.001)  flist(tflist_ym)   escal(mean_fail mean_sub mean_ptime n_imp_used)  
	
} /*close _rc loop */


} /*close risk loop */


********
*fouryear with study interaction for older women
mi xeq:tab study_name,gen(s_)
mi estimate,esampvaryok hr post errorok :streg  ib2.fouryear#i.s_6 ib4.study_name if sex==2 & youth==0,d(e)  
qui do ${alphapath}/ALPHA\Projects\Gates_incidence_risks_2019\add_mean_fails_subjects_ptime_to_ereturn_after_cifixstreg.do
parmest, eform saving("${alphapath}/ALPHA/projects/gates_incidence_risks_2019/results/pooled/ow_ib2_fouryear_int_siteadj_pooled",replace) idstr(siteadj_ib2.fouryear#i.s_6)  idnum(`snum')  stars(0.1 0.05 0.01 0.001)  flist(tflist_ow) escal(mean_fail mean_sub mean_ptime n_imp_used)     


/*===+===+===+===+===+===+===+===+===+===+===+===+===+===+===+
*ADJUSTED MODELS

*===+===+===+===+===+===+===+===+===+===+===+===+===+===+===+

global risklist_adj "i.mobile ib1.tv_mstat_br i.tv_circumcised i.tv_clastyr i.tv_pagegrp  i.tv_cf_all "



foreach risk in $risklist_adj {


local riskname=subinstr("`risk'",".","_",.)
*MEN
cap mi estimate,esampvaryok hr post errorok :streg  `risk' ib1.tv_sumlastyear untreated_opp_sex_pre ib3.fouryear ib4.study_name if sex==1  ,d(e)  
if _rc==0 {

mi estimate,esampvaryok hr post errorok :streg  `risk' ib1.tv_sumlastyear untreated_opp_sex_pre ib3.fouryear  ib4.study_name  if sex==1 ,d(e)  
do ${alphapath}/ALPHA\Projects\Gates_incidence_trends_2019\add_mean_fails_subjects_ptime_to_ereturn.do
estimates save ${alphapath}/ALPHA/projects/gates_incidence_risks_2019/results/pooled/adj_risk_models/am_`riskname'_adj_pooled,replace
parmest, eform saving("${alphapath}/ALPHA/projects/gates_incidence_risks_2019/results/pooled/adj_risk_models/am_`riskname'_adj_pooled",replace) idstr(`risk')  idnum(`snum')  stars(0.1 0.05 0.01 0.001)  flist(tflist_am)   escal(mean_fail mean_sub mean_ptime)  
	
} /*close _rc loop */

cap mi estimate,esampvaryok hr post errorok :streg  `risk' ib1.tv_sumlastyear untreated_opp_sex_pre ib3.fouryear  ib4.study_name  if sex==1 & youth==0  ,d(e)  
if _rc==0 {

mi estimate,esampvaryok hr post errorok :streg  `risk' ib1.tv_sumlastyear untreated_opp_sex_pre ib3.fouryear   ib4.study_name if sex==1 & youth==0,d(e)  
do ${alphapath}/ALPHA\Projects\Gates_incidence_trends_2019\add_mean_fails_subjects_ptime_to_ereturn.do
estimates save ${alphapath}/ALPHA/projects/gates_incidence_risks_2019/results/pooled/adj_risk_models/om_`riskname'_adj_pooled,replace
parmest, eform saving("${alphapath}/ALPHA/projects/gates_incidence_risks_2019/results/pooled/adj_risk_models/om_`riskname'_adj_pooled",replace) idstr(`risk')  idnum(`snum')  stars(0.1 0.05 0.01 0.001)  flist(tflist_om)  escal(mean_fail mean_sub mean_ptime)   
	
} /*close _rc loop */

cap mi estimate,esampvaryok hr post errorok :streg  `risk' ib1.tv_sumlastyear untreated_opp_sex_pre ib3.fouryear  ib4.study_name  if sex==1 & youth==1 ,d(e)  
if _rc==0 {

mi estimate,esampvaryok hr post errorok :streg  `risk' ib1.tv_sumlastyear untreated_opp_sex_pre ib3.fouryear  ib4.study_name  if sex==1 & youth==1 ,d(e)  
do ${alphapath}/ALPHA\Projects\Gates_incidence_trends_2019\add_mean_fails_subjects_ptime_to_ereturn.do
estimates save ${alphapath}/ALPHA/projects/gates_incidence_risks_2019/results/pooled/adj_risk_models/ym_`riskname'_adj_pooled,replace
parmest, eform saving("${alphapath}/ALPHA/projects/gates_incidence_risks_2019/results/pooled/adj_risk_models/ym_`riskname'_adj_pooled",replace) idstr(`risk')  idnum(`snum')  stars(0.1 0.05 0.01 0.001)  flist(tflist_ym)   escal(mean_fail mean_sub mean_ptime)  
	
} /*close _rc loop */

*WOMEN

cap mi estimate,esampvaryok hr post errorok :streg  `risk' ib1.tv_sumlastyear untreated_opp_sex_pre ib3.fouryear  ib4.study_name  if sex==2  ,d(e)  
if _rc==0 {

mi estimate,esampvaryok hr post errorok :streg  `risk' ib1.tv_sumlastyear untreated_opp_sex_pre ib3.fouryear  ib4.study_name  if sex==2 ,d(e)  
do ${alphapath}/ALPHA\Projects\Gates_incidence_trends_2019\add_mean_fails_subjects_ptime_to_ereturn.do
estimates save ${alphapath}/ALPHA/projects/gates_incidence_risks_2019/results/pooled/adj_risk_models/aw_`riskname'_adj_pooled,replace
parmest, eform saving("${alphapath}/ALPHA/projects/gates_incidence_risks_2019/results/pooled/adj_risk_models/aw_`riskname'_adj_pooled",replace) idstr(`risk')  idnum(`snum')  stars(0.1 0.05 0.01 0.001)  flist(tflist_am)   escal(mean_fail mean_sub mean_ptime)  
	
} /*close _rc loop */

cap mi estimate,esampvaryok hr post errorok :streg  `risk' ib1.tv_sumlastyear untreated_opp_sex_pre ib3.fouryear  ib4.study_name  if sex==2 & youth==0  ,d(e)  
if _rc==0 {

mi estimate,esampvaryok hr post errorok :streg  `risk' ib1.tv_sumlastyear untreated_opp_sex_pre ib3.fouryear  ib4.study_name  if sex==2 & youth==0,d(e)  
do ${alphapath}/ALPHA\Projects\Gates_incidence_trends_2019\add_mean_fails_subjects_ptime_to_ereturn.do
estimates save ${alphapath}/ALPHA/projects/gates_incidence_risks_2019/results/pooled/adj_risk_models/ow_`riskname'_adj_pooled,replace
parmest, eform saving("${alphapath}/ALPHA/projects/gates_incidence_risks_2019/results/pooled/adj_risk_models/ow_`riskname'_adj_pooled",replace) idstr(`risk')  idnum(`snum')  stars(0.1 0.05 0.01 0.001)  flist(tflist_om)  escal(mean_fail mean_sub mean_ptime)   
	
} /*close _rc loop */

cap mi estimate,esampvaryok hr post errorok :streg  `risk' ib1.tv_sumlastyear untreated_opp_sex_pre ib3.fouryear  ib4.study_name  if sex==2 & youth==1 ,d(e)  
if _rc==0 {

mi estimate,esampvaryok hr post errorok :streg  `risk' ib1.tv_sumlastyear untreated_opp_sex_pre ib3.fouryear ib4.study_name if sex==2 & youth==1 ,d(e)  
do ${alphapath}/ALPHA\Projects\Gates_incidence_trends_2019\add_mean_fails_subjects_ptime_to_ereturn.do
estimates save ${alphapath}/ALPHA/projects/gates_incidence_risks_2019/results/pooled/adj_risk_models/yw_`riskname'_adj_pooled,replace
parmest, eform saving("${alphapath}/ALPHA/projects/gates_incidence_risks_2019/results/pooled/adj_risk_models/yw_`riskname'_adj_pooled",replace) idstr(`risk')  idnum(`snum')  stars(0.1 0.05 0.01 0.001)  flist(tflist_ym)   escal(mean_fail mean_sub mean_ptime)  
	
} /*close _rc loop */



} /*close risk loop */




*===+===+===+===+===+===+===+===+===+===+===+===+===+===+===+
* TRY PAGEGRP WITHOUT UNTREATED PREV
*===+===+===+===+===+===+===+===+===+===+===+===+===+===+===+

*MEN
mi estimate,esampvaryok hr post errorok :streg  i.tv_pagegrp ib1.tv_sumlastyear  ib3.fouryear  ib4.study_name  if sex==1 ,d(e)  
do ${alphapath}/ALPHA\Projects\Gates_incidence_trends_2019\add_mean_fails_subjects_ptime_to_ereturn.do
estimates save ${alphapath}/ALPHA/projects/gates_incidence_risks_2019/results/pooled/adj_risk_models/am_pagegrp_adj_pooled_no_untreat,replace
parmest, eform saving("${alphapath}/ALPHA/projects/gates_incidence_risks_2019/results/pooled/adj_risk_models/am_tv_pagegrp_adj_pooled_no_untreat",replace) idstr(`risk')  idnum(`snum')  stars(0.1 0.05 0.01 0.001)  flist(tflist_am)   escal(mean_fail mean_sub mean_ptime)  
	
mi estimate,esampvaryok hr post errorok :streg  i.tv_pagegrp ib1.tv_sumlastyear  ib3.fouryear   ib4.study_name if sex==1 & youth==0,d(e)  
do ${alphapath}/ALPHA\Projects\Gates_incidence_trends_2019\add_mean_fails_subjects_ptime_to_ereturn.do
estimates save ${alphapath}/ALPHA/projects/gates_incidence_risks_2019/results/pooled/adj_risk_models/om_tv_pagegrp_adj_pooled_no_untreat,replace
parmest, eform saving("${alphapath}/ALPHA/projects/gates_incidence_risks_2019/results/pooled/adj_risk_models/om_tv_pagegrp_adj_pooled_no_untreat",replace) idstr(`risk')  idnum(`snum')  stars(0.1 0.05 0.01 0.001)  flist(tflist_om)  escal(mean_fail mean_sub mean_ptime)   
	
mi estimate,esampvaryok hr post errorok :streg  i.tv_pagegrp ib1.tv_sumlastyear  ib3.fouryear  ib4.study_name  if sex==1 & youth==1 ,d(e)  
do ${alphapath}/ALPHA\Projects\Gates_incidence_trends_2019\add_mean_fails_subjects_ptime_to_ereturn.do
estimates save ${alphapath}/ALPHA/projects/gates_incidence_risks_2019/results/pooled/adj_risk_models/ym_tv_pagegrp_adj_pooled_no_untreat,replace
parmest, eform saving("${alphapath}/ALPHA/projects/gates_incidence_risks_2019/results/pooled/adj_risk_models/ym_tv_pagegrp_adj_pooled_no_untreat",replace) idstr(`risk')  idnum(`snum')  stars(0.1 0.05 0.01 0.001)  flist(tflist_ym)   escal(mean_fail mean_sub mean_ptime)  
	
*WOMEN

mi estimate,esampvaryok hr post errorok :streg  i.tv_pagegrp ib1.tv_sumlastyear  ib3.fouryear  ib4.study_name  if sex==2 ,d(e)  
do ${alphapath}/ALPHA\Projects\Gates_incidence_trends_2019\add_mean_fails_subjects_ptime_to_ereturn.do
estimates save ${alphapath}/ALPHA/projects/gates_incidence_risks_2019/results/pooled/adj_risk_models/aw_tv_pagegrp_adj_pooled_no_untreat,replace
parmest, eform saving("${alphapath}/ALPHA/projects/gates_incidence_risks_2019/results/pooled/adj_risk_models/aw_tv_pagegrp_adj_pooled_no_untreat",replace) idstr(`risk')  idnum(`snum')  stars(0.1 0.05 0.01 0.001)  flist(tflist_am)   escal(mean_fail mean_sub mean_ptime)  


mi estimate,esampvaryok hr post errorok :streg  i.tv_pagegrp ib1.tv_sumlastyear  ib3.fouryear  ib4.study_name  if sex==2 & youth==0,d(e)  
do ${alphapath}/ALPHA\Projects\Gates_incidence_trends_2019\add_mean_fails_subjects_ptime_to_ereturn.do
estimates save ${alphapath}/ALPHA/projects/gates_incidence_risks_2019/results/pooled/adj_risk_models/ow_tv_pagegrp_adj_pooled_no_untreat,replace
parmest, eform saving("${alphapath}/ALPHA/projects/gates_incidence_risks_2019/results/pooled/adj_risk_models/ow_tv_pagegrp_adj_pooled_no_untreat",replace) idstr(`risk')  idnum(`snum')  stars(0.1 0.05 0.01 0.001)  flist(tflist_om)  escal(mean_fail mean_sub mean_ptime)   


mi estimate,esampvaryok hr post errorok :streg  i.tv_pagegrp ib1.tv_sumlastyear  ib3.fouryear ib4.study_name if sex==2 & youth==1 ,d(e)  
do ${alphapath}/ALPHA\Projects\Gates_incidence_trends_2019\add_mean_fails_subjects_ptime_to_ereturn.do
estimates save ${alphapath}/ALPHA/projects/gates_incidence_risks_2019/results/pooled/adj_risk_models/yw_tv_pagegrp_adj_pooled_no_untreat,replace
parmest, eform saving("${alphapath}/ALPHA/projects/gates_incidence_risks_2019/results/pooled/adj_risk_models/yw_tv_pagegrp_adj_pooled_no_untreat",replace) idstr(`risk')  idnum(`snum')  stars(0.1 0.05 0.01 0.001)  flist(tflist_ym)   escal(mean_fail mean_sub mean_ptime)  
	
*END PAGEGRP



*===+===+===+===+===+===+===+===+===+===+===+===+===+===+===+
*CONDOMS SUB MODELS
*===+===+===+===+===+===+===+===+===+===+===+===+===+===+===+

*streg  i.tv_clastyr untreated_opp_sex_pre ib3.fouryear   ib4.study_name if sex==1 & youth==1 & (tv_morethan1==1 | tv_new_partner==1),d(e)



/*
*===+===+===+===+===+===+===+===+===+===+===+===+===+===+===+
*ADJUSTED MODELS WITH INTERACTIONS- not enough power

*===+===+===+===+===+===+===+===+===+===+===+===+===+===+===+

global risklist_adj "i.mobile ib1.tv_mstat_br i.tv_circumcised i.tv_clastyr i.tv_pagegrp  i.tv_cf_all "



foreach risk in $risklist_adj {


local riskname=subinstr("`risk'",".","_",.)
*MEN
cap mi estimate,esampvaryok hr post errorok :streg  `risk'##ib4.study_name ib1.tv_sumlastyear untreated_opp_sex_pre ib3.fouryear if sex==1  ,d(e)  
if _rc==0 {

mi estimate,esampvaryok hr post errorok :streg  `risk'##ib4.study_name ib1.tv_sumlastyear untreated_opp_sex_pre ib3.fouryear  if sex==1 ,d(e)  
do ${alphapath}/ALPHA\Projects\Gates_incidence_trends_2019\add_mean_fails_subjects_ptime_to_ereturn.do
estimates save {alphapath}/ALPHA/projects/gates_incidence_risks_2019/results/pooled/adj_risk_models/am_`riskname'_adj_pooled_int,replace
parmest, eform saving("${alphapath}/ALPHA/projects/gates_incidence_risks_2019/results/pooled/adj_risk_models/am_`riskname'_adj_pooled_int",replace) idstr(`risk')  idnum(`snum')  stars(0.1 0.05 0.01 0.001)  flist(tflist_am)   escal(mean_fail mean_sub mean_ptime)  
	
} /*close _rc loop */

cap mi estimate,esampvaryok hr post errorok :streg  `risk'##ib4.study_name ib1.tv_sumlastyear untreated_opp_sex_pre ib3.fouryear  if sex==1 & youth==0  ,d(e)  
if _rc==0 {

mi estimate,esampvaryok hr post errorok :streg  `risk'##ib4.study_name ib1.tv_sumlastyear untreated_opp_sex_pre ib3.fouryear if sex==1 & youth==0,d(e)  
do ${alphapath}/ALPHA\Projects\Gates_incidence_trends_2019\add_mean_fails_subjects_ptime_to_ereturn.do
estimates save {alphapath}/ALPHA/projects/gates_incidence_risks_2019/results/pooled/adj_risk_models/ao_`riskname'_adj_pooled_int,replace
parmest, eform saving("${alphapath}/ALPHA/projects/gates_incidence_risks_2019/results/pooled/adj_risk_models/om_`riskname'_adj_pooled_int",replace) idstr(`risk')  idnum(`snum')  stars(0.1 0.05 0.01 0.001)  flist(tflist_om)  escal(mean_fail mean_sub mean_ptime)   
	
} /*close _rc loop */

cap mi estimate,esampvaryok hr post errorok :streg  `risk'##ib4.study_name ib1.tv_sumlastyear untreated_opp_sex_pre ib3.fouryear if sex==1 & youth==1 ,d(e)  
if _rc==0 {

mi estimate,esampvaryok hr post errorok :streg  `risk'##ib4.study_name ib1.tv_sumlastyear untreated_opp_sex_pre ib3.fouryear  if sex==1 & youth==1 ,d(e)  
do ${alphapath}/ALPHA\Projects\Gates_incidence_trends_2019\add_mean_fails_subjects_ptime_to_ereturn.do
estimates save {alphapath}/ALPHA/projects/gates_incidence_risks_2019/results/pooled/adj_risk_models/ym_`riskname'_adj_pooled_int,replace
parmest, eform saving("${alphapath}/ALPHA/projects/gates_incidence_risks_2019/results/pooled/adj_risk_models/ym_`riskname'_adj_pooled_int",replace) idstr(`risk')  idnum(`snum')  stars(0.1 0.05 0.01 0.001)  flist(tflist_ym)   escal(mean_fail mean_sub mean_ptime)  
	
} /*close _rc loop */

*WOMEN

cap mi estimate,esampvaryok hr post errorok :streg  `risk'##ib4.study_name ib1.tv_sumlastyear untreated_opp_sex_pre ib3.fouryear if sex==2  ,d(e)  
if _rc==0 {

mi estimate,esampvaryok hr post errorok :streg  `risk'##ib4.study_name ib1.tv_sumlastyear untreated_opp_sex_pre ib3.fouryear  if sex==2 ,d(e)  
do ${alphapath}/ALPHA\Projects\Gates_incidence_trends_2019\add_mean_fails_subjects_ptime_to_ereturn.do
estimates save {alphapath}/ALPHA/projects/gates_incidence_risks_2019/results/pooled/adj_risk_models/aw_`riskname'_adj_pooled_int,replace
parmest, eform saving("${alphapath}/ALPHA/projects/gates_incidence_risks_2019/results/pooled/adj_risk_models/aw_`riskname'_adj_pooled_int",replace) idstr(`risk')  idnum(`snum')  stars(0.1 0.05 0.01 0.001)  flist(tflist_am)   escal(mean_fail mean_sub mean_ptime)  
	
} /*close _rc loop */

cap mi estimate,esampvaryok hr post errorok :streg  `risk'##ib4.study_name ib1.tv_sumlastyear untreated_opp_sex_pre ib3.fouryear  if sex==2 & youth==0  ,d(e)  
if _rc==0 {

mi estimate,esampvaryok hr post errorok :streg  `risk'##ib4.study_name ib1.tv_sumlastyear untreated_opp_sex_pre ib3.fouryear  if sex==2 & youth==0,d(e)  
do ${alphapath}/ALPHA\Projects\Gates_incidence_trends_2019\add_mean_fails_subjects_ptime_to_ereturn.do
estimates save {alphapath}/ALPHA/projects/gates_incidence_risks_2019/results/pooled/adj_risk_models/ow_`riskname'_adj_pooled_int,replace
parmest, eform saving("${alphapath}/ALPHA/projects/gates_incidence_risks_2019/results/pooled/adj_risk_models/ow_`riskname'_adj_pooled_int",replace) idstr(`risk')  idnum(`snum')  stars(0.1 0.05 0.01 0.001)  flist(tflist_om)  escal(mean_fail mean_sub mean_ptime)   
	
} /*close _rc loop */

cap mi estimate,esampvaryok hr post errorok :streg  `risk'##ib4.study_name ib1.tv_sumlastyear untreated_opp_sex_pre ib3.fouryear if sex==2 & youth==1 ,d(e)  
if _rc==0 {

mi estimate,esampvaryok hr post errorok :streg  `risk'##ib4.study_name ib1.tv_sumlastyear untreated_opp_sex_pre ib3.fouryear if sex==2 & youth==1 ,d(e)  
do ${alphapath}/ALPHA\Projects\Gates_incidence_trends_2019\add_mean_fails_subjects_ptime_to_ereturn.do
testparm `risk'##ib4.study_name
estimates save {alphapath}/ALPHA/projects/gates_incidence_risks_2019/results/pooled/adj_risk_models/am_`riskname'_adj_pooled_int,replace
parmest, eform saving("${alphapath}/ALPHA/projects/gates_incidence_risks_2019/results/pooled/adj_risk_models/yw_`riskname'_adj_pooled_int",replace) idstr(`risk')  idnum(`snum')  stars(0.1 0.05 0.01 0.001)  flist(tflist_ym)   escal(mean_fail mean_sub mean_ptime)  
	
} /*close _rc loop */



} /*close risk loop */



*/

*cap mi erase incidence_risk

