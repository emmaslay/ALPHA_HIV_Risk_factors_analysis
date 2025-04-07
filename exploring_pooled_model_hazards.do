
use "K:\ALPHA\Incidence_ready_data\pooled\mi_data\incidence_ready_risk_factors_MI_pooled_17.dta",clear
*====================================
****** 		YOUNG WOMEN 	  *******
*====================================

*Straightforward piecewise exponential, all hazards proportional.

streg i.agegrp ib2.fouryear i.mobile ib1.tv_educ ib1.tv_mstat_br i.tv_morethan1 i.tv_regular i.tv_casual i.tv_new_partner i.tv_anylost untreated_opp_sex_prevalence ib4.study_name if sex==2 & youth==1  ,d(e)  
estimates store yw_all

*Straightforward piecewise exponential, all hazards proportional and including study-specific effects of untreated
streg i.agegrp ib2.fouryear i.mobile ib1.tv_educ ib1.tv_mstat_br i.tv_morethan1 i.tv_regular i.tv_casual i.tv_new_partner i.tv_anylost c.untreated_opp_sex_prevalence#ib4.study_name  if sex==2 & youth==1  ,d(e)   
estimates store yw_all_int

*Straightforward piecewise exponential, all hazards proportional except study and including study-specific effects of untreated
streg i.agegrp#ib4.study_name ib2.fouryear i.mobile ib1.tv_educ ib1.tv_mstat_br i.tv_morethan1 i.tv_regular i.tv_casual i.tv_new_partner i.tv_anylost c.untreated_opp_sex_prevalence#ib4.study_name  if sex==2 & youth==1  ,d(e)   
estimates store yw_all_int_not_ph

*Straightforward piecewise exponential, all hazards proportional except study
streg i.agegrp#ib4.study_name ib2.fouryear i.mobile ib1.tv_educ ib1.tv_mstat_br i.tv_morethan1 i.tv_regular i.tv_casual i.tv_new_partner i.tv_anylost c.untreated_opp_sex_prevalence  if sex==2 & youth==1  ,d(e)   
estimates store yw_all_not_ph



*Exponential without study and age
streg ib2.fouryear i.mobile ib1.tv_educ ib1.tv_mstat_br i.tv_morethan1 i.tv_regular i.tv_casual i.tv_new_partner i.tv_anylost untreated_opp_sex_prevalence  if sex==2 & youth==1  ,d(e)  
estimates store yw_no_study_age


*Straightforward piecewise exponential, all hazards proportional except study and without untreated
streg i.agegrp#ib4.study_name ib2.fouryear i.mobile ib1.tv_educ ib1.tv_mstat_br i.tv_morethan1 i.tv_regular i.tv_casual i.tv_new_partner i.tv_anylost  if sex==2 & youth==1  ,d(e)   
estimates store yw_all_not_ph_nountreat



*Cox model for comparison
stcox ib2.fouryear i.mobile ib1.tv_educ ib1.tv_mstat_br i.tv_morethan1 i.tv_regular i.tv_casual i.tv_new_partner i.tv_anylost untreated_opp_sex_prevalence ib4.study_name if sex==2 & youth==1  
estimates store yw_cox

*Gamma model, shared param and no interaction
streg ib2.fouryear i.mobile ib1.tv_educ ib1.tv_mstat_br i.tv_morethan1 i.tv_regular i.tv_casual i.tv_new_partner i.tv_anylost untreated_opp_sex_prevalence ib4.study_name if sex==2 & youth==1  ,d(ggamma) 
estimates store yw_all_gamma

*Gamma model with sigma paramatised by study and no interaction
*anc2() parametises kappa, anc() does sigma
streg ib2.fouryear i.mobile ib1.tv_educ ib1.tv_mstat_br i.tv_morethan1 i.tv_regular i.tv_casual i.tv_new_partner i.tv_anylost untreated_opp_sex_prevalence   ib4.study_name if sex==2 & youth==1  ,d(ggamma)  anc(ib4.study) 
estimates store yw_all_gamma_param

*Gamma model with sigma and kappa paramatised by study and no interaction
streg ib2.fouryear i.mobile ib1.tv_educ ib1.tv_mstat_br i.tv_morethan1 i.tv_regular i.tv_casual i.tv_new_partner i.tv_anylost untreated_opp_sex_prevalence if sex==2 & youth==1  ,d(ggamma)  anc(ib4.study) anc2(ib4.study)
estimates store yw_all_gamma_param2


estimates table yw_all yw_all_int yw_all_int_not_ph yw_all_not_ph  yw_no_study_age yw_cox yw_all_gamma yw_all_gamma_param yw_all_gamma_param2,stat(aic)


estimates table yw_all yw_all_not_ph  yw_all_int_not_ph yw_no_study_age yw_all_not_ph_nountreat,stat(aic)

*====================================
****** 		OLDER WOMEN 	  *******
*====================================

gen s6=cond(study_name==6,1,0)

*Straightforward piecewise exponential, all hazards proportional.
streg i.agegrp ib2.fouryear#i.s6 i.mobile ib1.tv_educ ib1.tv_mstat_br i.tv_morethan1 i.tv_regular  i.tv_new_partner ib1.tv_clast untreated_opp_sex_prevalence ib4.study_name if sex==2 & youth==0  ,d(e)  
estimates store ow_all

*Straightforward piecewise exponential, all hazards proportional and including study-specific effects of untreated
streg i.agegrp ib2.fouryear#i.s6 i.mobile ib1.tv_educ ib1.tv_mstat_br i.tv_morethan1 i.tv_regular  i.tv_new_partner ib1.tv_clast c.untreated_opp_sex_prevalence#ib4.study_name  if sex==2 & youth==0  ,d(e)   
estimates store ow_all_int

*Straightforward piecewise exponential, all hazards proportional except study and including study-specific effects of untreated
streg i.agegrp#ib4.study_name ib2.fouryear#i.s6 i.mobile ib1.tv_educ ib1.tv_mstat_br i.tv_morethan1 i.tv_regular  i.tv_new_partner ib1.tv_clast c.untreated_opp_sex_prevalence#ib4.study_name  if sex==2 & youth==0  ,d(e)   
estimates store ow_all_int_not_ph

*Straightforward piecewise exponential, all hazards proportional except study and including study-specific effects of untreated
streg i.agegrp#ib4.study_name ib2.fouryear#i.s6 i.mobile ib1.tv_educ ib1.tv_mstat_br i.tv_morethan1 i.tv_regular  i.tv_new_partner ib1.tv_clast c.untreated_opp_sex_prevalence  if sex==2 & youth==0  ,d(e)   
estimates store ow_all_not_ph


*Exponential without study and age
streg ib2.fouryear#i.s6 i.mobile ib1.tv_educ ib1.tv_mstat_br i.tv_morethan1 i.tv_regular  i.tv_new_partner ib1.tv_clast untreated_opp_sex_prevalence  if sex==2 & youth==0  ,d(e)  
estimates store ow_no_study_age

*Straightforward piecewise exponential, all hazards proportional except study and without untreated
streg i.agegrp#ib4.study_name ib2.fouryear#i.s6 i.mobile ib1.tv_educ ib1.tv_mstat_br i.tv_morethan1 i.tv_regular  i.tv_new_partner ib1.tv_clast  if sex==2 & youth==0  ,d(e)   
estimates store ow_all_not_ph_nountreat


/*
*Cox model for comparison
stcox ib2.fouryear#i.s6 i.mobile ib1.tv_educ ib1.tv_mstat_br i.tv_morethan1 i.tv_regular  i.tv_new_partner ib1.tv_clast untreated_opp_sex_prevalence ib4.study_name if sex==2 & youth==0  
estimates store ow_cox

*Gamma model, shared param and no interaction
streg ib2.fouryear#i.s6 i.mobile ib1.tv_educ ib1.tv_mstat_br i.tv_morethan1 i.tv_regular i.tv_new_partner ib1.tv_clast untreated_opp_sex_prevalence ib4.study_name if sex==2 & youth==0  ,d(ggamma) 
estimates store ow_all_gamma

*Gamma model with sigma paramatised by study and no interaction
*anc2() parametises kappa, anc() does sigma
streg ib2.fouryear#i.s6 i.mobile ib1.tv_educ ib1.tv_mstat_br i.tv_morethan1 i.tv_regular  i.tv_new_partner ib1.tv_clast untreated_opp_sex_prevalence   ib4.study_name if sex==2 & youth==0  ,d(ggamma)  anc(ib4.study) 
estimates store ow_all_gamma_param

*Gamma model with sigma and kappa paramatised by study and no interaction
streg ib2.fouryear#i.s6 i.mobile ib1.tv_educ ib1.tv_mstat_br i.tv_morethan1 i.tv_regular  i.tv_new_partner ib1.tv_clast untreated_opp_sex_prevalence if sex==2 & youth==0  ,d(ggamma)  anc(ib4.study) anc2(ib4.study)
estimates store ow_all_gamma_param2
*/

estimates table ow_all ow_all_int ow_all_int_not_ph ow_all_not_ph ow_no_study_age ow_cox ,stat(aic)
*ow_all_gamma ow_all_gamma_param ow_all_gamma_param2

estimates table ow_all ow_all_int_not_ph  ow_all_not_ph ow_no_study_age ow_all_not_ph_nountreat ,stat(aic)




*====================================
****** 		YOUNG MEN 	  *******
*====================================

*Straightforward piecewise exponential, all hazards proportional.

streg i.agegrp ib2.fouryear i.mobile i.tv_circumcised ib1.tv_mstat_br i.tv_morethan1 i.tv_regular  i.tv_new_partner i.tv_anylost untreated_opp_sex_prevalence ib4.study_name if sex==1 & youth==1  ,d(e)  
estimates store ym_all

*Straightforward piecewise exponential, all hazards proportional and including study-specific effects of untreated
streg i.agegrp ib2.fouryear i.mobile i.tv_circumcised ib1.tv_mstat_br i.tv_morethan1 i.tv_regular  i.tv_new_partner i.tv_anylost c.untreated_opp_sex_prevalence#ib4.study_name  if sex==1 & youth==1  ,d(e)   
estimates store ym_all_int

*Straightforward piecewise exponential, all hazards proportional except study and including study-specific effects of untreated
streg i.agegrp#ib4.study_name ib2.fouryear i.mobile i.tv_circumcised ib1.tv_mstat_br i.tv_morethan1 i.tv_regular  i.tv_new_partner i.tv_anylost c.untreated_opp_sex_prevalence#ib4.study_name  if sex==1 & youth==1  ,d(e)   
estimates store ym_all_int_not_ph

*Straightforward piecewise exponential, all hazards proportional except study
streg i.agegrp#ib4.study_name ib2.fouryear i.mobile i.tv_circumcised ib1.tv_mstat_br i.tv_morethan1 i.tv_regular  i.tv_new_partner i.tv_anylost c.untreated_opp_sex_prevalence  if sex==1 & youth==1  ,d(e)   
estimates store ym_all_not_ph



*Exponential without study and age
streg ib2.fouryear i.mobile i.tv_circumcised ib1.tv_mstat_br i.tv_morethan1 i.tv_regular  i.tv_new_partner i.tv_anylost untreated_opp_sex_prevalence  if sex==1 & youth==1  ,d(e)  
estimates store ym_no_study_age


*Straightforward piecewise exponential, all hazards proportional except study and without untreated
streg i.agegrp#ib4.study_name ib2.fouryear i.mobile i.tv_circumcised ib1.tv_mstat_br i.tv_morethan1 i.tv_regular  i.tv_new_partner i.tv_anylost  if sex==1 & youth==1  ,d(e)   
estimates store ym_all_not_ph_nountreat



*Cox model for comparison
stcox ib2.fouryear i.mobile i.tv_circumcised ib1.tv_mstat_br i.tv_morethan1 i.tv_regular  i.tv_new_partner i.tv_anylost untreated_opp_sex_prevalence ib4.study_name if sex==1 & youth==1  
estimates store ym_cox

/*Gamma model, shared param and no interaction
streg ib2.fouryear i.mobile i.tv_circumcised ib1.tv_mstat_br i.tv_morethan1 i.tv_regular  i.tv_new_partner i.tv_anylost untreated_opp_sex_prevalence ib4.study_name if sex==1 & youth==1  ,d(ggamma) 
estimates store ym_all_gamma

*Gamma model with sigma paramatised by study and no interaction
*anc2() parametises kappa, anc() does sigma
streg ib2.fouryear i.mobile i.tv_circumcised ib1.tv_mstat_br i.tv_morethan1 i.tv_regular  i.tv_new_partner i.tv_anylost untreated_opp_sex_prevalence   ib4.study_name if sex==1 & youth==1  ,d(ggamma)  anc(ib4.study) 
estimates store ym_all_gamma_param

*Gamma model with sigma and kappa paramatised by study and no interaction
streg ib2.fouryear i.mobile i.tv_circumcised ib1.tv_mstat_br i.tv_morethan1 i.tv_regular  i.tv_new_partner i.tv_anylost untreated_opp_sex_prevalence if sex==1 & youth==1  ,d(ggamma)  anc(ib4.study) anc2(ib4.study)
estimates store ym_all_gamma_param2

*/

estimates table ym_all ym_all_int ym_all_int_not_ph ym_all_not_ph  ym_no_study_age ym_cox ,stat(aic)
*ym_all_gamma ym_all_gamma_param ym_all_gamma_param2

estimates table ym_all  ym_all_not_ph yw_no_study_age yw_all_not_ph_nountreat,stat(aic)

*====================================
****** 		OLDER MEN 	  *******
*====================================

*Straightforward piecewise exponential, all hazards proportional.

streg i.agegrp ib2.fouryear   ib1.tv_mstat_br  i.tv_regular  i.tv_new_partner ib1.tv_clast untreated_opp_sex_prevalence ib4.study_name if sex==1 & youth==0  ,d(e)  
estimates store om_all

*Straightforward piecewise exponential, all hazards proportional and including study-specific effects of untreated
streg i.agegrp ib2.fouryear   ib1.tv_mstat_br  i.tv_regular  i.tv_new_partner ib1.tv_clast c.untreated_opp_sex_prevalence#ib4.study_name  if sex==1 & youth==0  ,d(e)   
estimates store om_all_int

*Straightforward piecewise exponential, all hazards proportional except study and including study-specific effects of untreated
streg i.agegrp#ib4.study_name ib2.fouryear   ib1.tv_mstat_br  i.tv_regular  i.tv_new_partner ib1.tv_clast c.untreated_opp_sex_prevalence#ib4.study_name  if sex==1 & youth==0  ,d(e)   
estimates store om_all_int_not_ph

*Straightforward piecewise exponential, all hazards proportional except study and including study-specific effects of untreated
streg i.agegrp#ib4.study_name ib2.fouryear   ib1.tv_mstat_br  i.tv_regular  i.tv_new_partner ib1.tv_clast c.untreated_opp_sex_prevalence  if sex==1 & youth==0  ,d(e)   
estimates store om_all_not_ph


*Exponential without study and age
streg ib2.fouryear   ib1.tv_mstat_br  i.tv_regular  i.tv_new_partner ib1.tv_clast untreated_opp_sex_prevalence  if sex==1 & youth==0  ,d(e)  
estimates store om_no_study_age

*Straightforward piecewise exponential, all hazards proportional except study and without untreated
streg i.agegrp#ib4.study_name ib2.fouryear   ib1.tv_mstat_br  i.tv_regular  i.tv_new_partner ib1.tv_clast  if sex==1 & youth==0  ,d(e)   
estimates store om_all_not_ph_nountreat



*Cox model for comparison
stcox ib2.fouryear   ib1.tv_mstat_br  i.tv_regular  i.tv_new_partner ib1.tv_clast untreated_opp_sex_prevalence ib4.study_name if sex==1 & youth==0  
estimates store om_cox

/*Gamma model, shared param and no interaction
streg ib2.fouryear   ib1.tv_mstat_br  i.tv_regular  i.tv_new_partner ib1.tv_clast untreated_opp_sex_prevalence ib4.study_name if sex==1 & youth==0  ,d(ggamma) 
estimates store om_all_gamma

*Gamma model with sigma paramatised by study and no interaction
*anc2() parametises kappa, anc() does sigma
streg ib2.fouryear   ib1.tv_mstat_br  i.tv_regular  i.tv_new_partner ib1.tv_clast untreated_opp_sex_prevalence   ib4.study_name if sex==1 & youth==0  ,d(ggamma)  anc(ib4.study) 
estimates store om_all_gamma_param

*Gamma model with sigma and kappa paramatised by study and no interaction
streg ib2.fouryear   ib1.tv_mstat_br  i.tv_regular  i.tv_new_partner ib1.tv_clast untreated_opp_sex_prevalence if sex==1 & youth==0  ,d(ggamma)  anc(ib4.study) anc2(ib4.study)
estimates store om_all_gamma_param2
*/

estimates table om_all om_all_int om_all_int_not_ph om_all_not_ph om_no_study_age om_cox ,stat(aic)
*om_all_gamma om_all_gamma_param om_all_gamma_param2

estimates table om_all  om_all_not_ph om_no_study_age om_all_not_ph_nountreat ,stat(aic)



/**Best models
YW: exponential with study/age interaction, very slightly better than model that also has study/untreated interaction

OW: exponential with fixed effect for study, no interaction between age and study and none between untreated and study

YM: exponential with study/age interaction and study/untreated interaction

OM: exponential with fixed effect for study, no interaction between age and study and none between untreated and study 

*/

estimates table yw_all_not_ph ow_all ym_all_int_not_ph om_all ,stat(aic) eform








