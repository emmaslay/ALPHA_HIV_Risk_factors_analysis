cd ${alphapath}/ALPHA/projects/gates_incidence_risks_2019/results/pooled/adj_risk_models/

do ${alphapath}/ALPHA/dofiles/common/ColorBrewer9yellow_to_blue.do

*===+===+===+===+===+===+===+===+===+===+===+===+===+===+
*		OLDER MEN
*===+===+===+===+===+===+===+===+===+===+===+===+===+===+

estimates use ${alphapath}/ALPHA/projects/gates_incidence_risks_2019/results/pooled/adj_risk_models/om_pooled_exp_PREFER.ster
estimates replay
coefplot ,eform baselevels xline(1,lcolor(gs4)) xscale(log) ///
title("Men 25-49",size(36pt) span pos(11) color($cb9_9_blue5))  ///
drop(_cons 1.study_name 2.study_name 3.study_name 4.study_name 5.study_name 6.study_name 8.study_name 9.study_name /// 
0.tv_regular 9.tv_regular 3.tv_mstat_br 9.tv_mstat_br )  ///
xlabel(0.3 0.5 1 2 3 4,format(%-4.1f)  labsize(18pt)) xscale(range(0.3 4)) xtitle("Adjusted HR",size(18pt)) ///
msize(small) mcolor($cb9_7_blue3)  ciopts(lcolor($cb9_9_blue5)  lwidth(thick) ) ///
 grid(none) ///
xsize(10.6) ysize(6.5) ///
text(23 0.05 "{it:Estimates also adjusted for study}",size(18pt) ) ///
///
groups(0.tv_mstat_br 1.tv_mstat_br 2.tv_mstat_br ="Marital Status" ///
untreated_opp_sex_prevalence= "Untreated prevalence" ///
1.tv_regular 1.tv_casual="Types of partners in last year") ///
///
coeflabels(0.tv_mstat_br="Never married" 1.tv_mstat_br="Currently married" 2.tv_mstat_br= "Formerly married"   ///
 untreated_opp_sex_prevalence="%" ///
 1.tv_regular="Regular"   ///
,labsize(16pt))  ///
order(0.tv_mstat_br 1.tv_mstat_br 2.tv_mstat_br 1.tv_regular untreated_opp_sex_prevalence )


graph export om_big_model.png,width(6000) replace

*===+===+===+===+===+===+===+===+===+===+===+===+===+===+
*		YOUNGER MEN
*===+===+===+===+===+===+===+===+===+===+===+===+===+===+

estimates use ${alphapath}/ALPHA/projects/gates_incidence_risks_2019/results/pooled/adj_risk_models/ym_pooled_exp_PREFER.ster

estimates replay
coefplot ,eform baselevels xline(1,lcolor(gs4)) xscale(log) ///
title("Men 15-24",size(36pt) span pos(11) color($cb9_9_blue5))  ///
drop(_cons 1.study_name 2.study_name 3.study_name 4.study_name 5.study_name 6.study_name 8.study_name 9.study_name /// 
9.tv_mstat_br 3.tv_mstat_br  0.tv_circumcised  2.tv_circumcised )  ///
xlabel(0.3 0.5 1 2 4,format(%-4.1f)  labsize(18pt)) xscale(range(0.3 4))  xtitle("Adjusted HR",size(18pt)) ///
msize(small) mcolor($cb9_7_blue3)  ciopts(lcolor($cb9_9_blue5)  lwidth(thick) ) ///
 grid(none) ///
xsize(10.6) ysize(6.5) ///
text(19.5 0.05 "{it:Estimates also adjusted for study}",size(18pt) ) ///
///
groups(0.tv_educ 1.tv_educ 2.tv_educ 3.tv_educ 9.tv_educ="Education" 0.tv_mstat_br 1.tv_mstat_br 2.tv_mstat_br ="Marital Status" ///
untreated_opp_sex_prevalence= "Untreated prevalence" ///
1.tv_circumcised ="Circumcision status") ///
///
coeflabels(0.tv_educ="None" 1.tv_educ="Primary" 2.tv_educ="Secondary" 3.tv_educ="Tertiary" 9.tv_educ="Unknown" ///
0.tv_mstat_br="Never married" 1.tv_mstat_br="Currently married" 2.tv_mstat_br= "Formerly married"   ///
 untreated_opp_sex_prevalence="%" ///
 1.tv_circumcised="Circumcised"   ///
,labsize(16pt)) 


graph export ym_big_model.png,width(6000) replace


*===+===+===+===+===+===+===+===+===+===+===+===+===+===+
*		YOUNGER WOMEN
*===+===+===+===+===+===+===+===+===+===+===+===+===+===+


estimates use ${alphapath}/ALPHA/projects/gates_incidence_risks_2019/results/pooled/adj_risk_models/yw_pooled_exp_PREFER.ster
estimates replay

coefplot ,eform baselevels xline(1,lcolor(gs4)) xscale(log) ///
title("Women 15-24",size(36pt) span pos(11) color($cb9_9_blue5))  ///
drop(_cons 1.study_name 2.study_name 3.study_name 4.study_name 5.study_name 6.study_name 8.study_name 9.study_name /// 
0.tv_regular 9.tv_regular 0.tv_casual 9.tv_casual 3.tv_mstat_br 9.tv_mstat_br 0.tv_new_partner 9.tv_new_partner    ///
 0.tv_new_partner  3.tv_educ)  ///
xlabel(0.3 0.5 1 2 4,format(%-4.1f)  labsize(18pt)) xscale(range(0.3 4))  xtitle("Adjusted HR",size(18pt)) ///
msize(small) mcolor($cb9_7_blue3)  ciopts(lcolor($cb9_9_blue5)  lwidth(thick) ) ///
 grid(none) ///
xsize(10.6) ysize(6.5) ///
text(16.5 0.03 "{it:Estimates also adjusted for study }",size(14pt) j(l) ) ///
text(17.5 0.04 "{it:Tertiary education omitted (HR 0.32 (95% CI 0.09-1.19)}",size(14pt)  j(l) ) ///
///
groups(0.tv_educ 1.tv_educ 2.tv_educ 3.tv_educ 9.tv_educ="Education" 0.tv_mstat_br 1.tv_mstat_br 2.tv_mstat_br ="Marital Status" ///
1.tv_regular 1.tv_casual="Types of partners in last year" ///
untreated_opp_sex_prevalence= "Untreated prevalence" 1.tv_new_partner ="New partner in last year"  ///
,gap labsize(18pt))  ///
///
coeflabels(0.tv_educ="None" 1.tv_educ="Primary" 2.tv_educ="Secondary"  9.tv_educ="Unknown" ///
0.tv_mstat_br="Never married" 1.tv_mstat_br="Currently married" 2.tv_mstat_br= "Formerly married"   ///
 untreated_opp_sex_prevalence="%" ///
 1.tv_new_partner="New" 1.tv_regular="Regular" 1.tv_casual="Casual"  ///
,labsize(16pt))  ///
order(0.tv_educ 1.tv_educ 2.tv_educ 9.tv_educ 0.tv_mstat_br 1.tv_mstat_br 2.tv_mstat_br  ///
untreated_opp_sex_prevalence  1.tv_new_partner 1.tv_regular 1.tv_casual)

graph export yw_big_model.png,width(6000) replace


*===+===+===+===+===+===+===+===+===+===+===+===+===+===+
*		OLDER WOMEN
*===+===+===+===+===+===+===+===+===+===+===+===+===+===+


estimates use ${alphapath}/ALPHA/projects/gates_incidence_risks_2019/results/pooled/adj_risk_models/ow_pooled_exp_PREFER.ster

estimates replay
coefplot ,eform baselevels xline(1,lcolor(gs4)) xscale(log) ///
title("Women 25-49",size(36pt) span pos(11) color($cb9_9_blue5))  ///
drop(_cons 1.study_name 2.study_name 3.study_name 4.study_name 5.study_name 6.study_name 8.study_name 9.study_name /// 
0.tv_regular 9.tv_regular 0.tv_casual 9.tv_casual mstat_4 0.tv_new_partner 9.tv_new_partner    ///
0.mobile 00.new_partner 0.p2grp_1 0.p2grp_3 0.p2grp_4 1.p2grp_4)  ///
xlabel(0.3 0.5 1 2 4,format(%-4.1f)  labsize(18pt)) xscale(range(0.3 4))  xtitle("Adjusted HR",size(18pt)) ///
msize(small) mcolor($cb9_7_blue3)  ciopts(lcolor($cb9_9_blue5)  lwidth(thick) ) ///
 grid(none) ///
xsize(10.6) ysize(6.5) ///
text(22.5 0.15 "{it:Estimates also adjusted for study}",size(18pt) ) ///
///
groups(0.mobile 1.mobile ="Residential mobility"  mstat_1 mstat_3="Marital status" ///
 2.fouryear 3.fouryear  4.fouryear="Calendar time"  ///
 untreated_opp_sex_prevalence= "Untreated prevalence" ///
0.tv_new_partner 1.tv_new_partner 9.tv_new_partner="New partner in last year"  ///
1.p2grp_1 1.p2grp_3="Number of partners in last year" ///
1.tv_regular 1.tv_casual="Types of partners in last year" ///
0.tv_sumlastyear 1.tv_sumlastyear 2.tv_sumlastyear 3.tv_sumlastyear 4.tv_sumlastyear 5.tv_sumlastyear ///
6.tv_sumlastyear 9.tv_sumlastyear="Partnerships",gap labsize(18pt))  ///
///
coeflabels(0.mobile ="No" 1.mobile="Yes" mstat_1 ="Never" mstat_3= "Formerly"   ///
 untreated_opp_sex_prevalence="%" ///
2.fouryear="2005-08" 3.fouryear="2009-12"  4.fouryear="2013-16"  ///
 1.tv_new_partner="Yes" 1.p2grp_1="0" 1.p2grp_3="2+" 1.tv_regular="Regular" 1.tv_casual="Casual"  ///
,labsize(16pt)) ///
///
order(1.mobile mstat_1 mstat_3 1.p2grp_1 1.p2grp_3 1.tv_new_partner ///
untreated_opp_sex_prevalence 2.fouryear 3.fouryear 4.fouryear 1.tv_regular 1.tv_casual)
 
graph export ow_big_model.png,width(6000) replace



