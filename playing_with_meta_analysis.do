cd "${alphapath}/ALPHA/projects/gates_incidence_risks_2019/results/pooled/adj_risk_models/"

*=========================

global useimp=70

set maxiter 300


** YOUNG WOMEN **
*parmby doesn't work with mi somehow
frame change default
foreach studystr in karonga kisesa kisumu manicaland masaka rakai umkhanyakude ifakara {
global studyname=lower("`studystr'")

di "${studyname}"
di "`c(current_date)'  `c(current_time)'"

*GET DATA
use "${alphapath}/ALPHA\Incidence_ready_data/${studyname}/mi_data/incidence_ready_risk_factors_mi_${studyname}_0",clear

summ study_name
local study=r(mean)

cap mi erase incidence_risk
mi import flongsep incidence_risk, using(${alphapath}/ALPHA\Incidence_ready_data/${studyname}/mi_data/incidence_ready_risk_factors_mi_${studyname}_{1-$useimp}) id(study_name idno ep_num) imputed(end_ep_date) 

mi xeq: recode tv_clastyr 4=9 3=2
mi xeq: label define tv_clastyr 2 "Any condom use",modify



*Young women
mi estimate,esampvaryok eform post errorok cmdok dots  nimp($useimp):streg ib1.tv_educ ib1.tv_mstat_br i.tv_regular i.tv_new_partner i.tv_casual untreated_opp_sex_prevalence  if sex==2 & youth==1  ,d(e)  
do ${alphapath}/ALPHA\Projects\Gates_incidence_trends_2019\add_mean_fails_subjects_ptime_to_ereturn.do
parmest, eform saving(youngwomen_${studyname},replace) flist(yw)  idstr("${studyname}")  idnum(`study')    escal(mean_fail mean_sub mean_ptime)   

** Older women **
mi estimate,esampvaryok eform post errorok cmdok dots  nimp($useimp):streg i.mobile ib1.tv_mstat_br ib1.tv_clastyr i.tv_new_partner untreated_opp_sex_prevalence if sex==2 & youth==0  ,d(e)  
do ${alphapath}/ALPHA\Projects\Gates_incidence_trends_2019\add_mean_fails_subjects_ptime_to_ereturn.do
parmest, eform saving(oldwomen_${studyname},replace) flist(ow) idstr("${studyname}")  idnum(`study')    escal(mean_fail mean_sub mean_ptime)   


** YOUNG MEN **
mi estimate,esampvaryok eform post errorok cmdok dots  nimp($useimp):streg ib1.tv_educ ib1.tv_mstat_br untreated_opp_sex_prevalence i.tv_circumcised  if sex==1 & youth==1  ,d(e)  
do ${alphapath}/ALPHA\Projects\Gates_incidence_trends_2019\add_mean_fails_subjects_ptime_to_ereturn.do
parmest, eform saving(youngmen_${studyname},replace) flist(ym) idstr("${studyname}")  idnum(`study')    escal(mean_fail mean_sub mean_ptime)   


**  OLDER MEN **
mi estimate,esampvaryok eform post errorok cmdok dots  nimp($useimp):streg ib1.tv_mstat_br i.tv_regular untreated_opp_sex_prevalence  if sex==1 & youth==0  ,d(e)  
do ${alphapath}/ALPHA\Projects\Gates_incidence_trends_2019\add_mean_fails_subjects_ptime_to_ereturn.do
parmest, eform saving(oldmen_${studyname},replace) flist(om) idstr("${studyname}")  idnum(`study')    escal(mean_fail mean_sub mean_ptime)   

} /*close site loop */


**** SAVE THE DATASETS CONTAINING THE RESULTS *******

clear 
append using ${yw}
save ${alphapath}/ALPHA/projects/gates_incidence_risks_2019/results/pooled/adj_risk_models/meta_youngwomen,replace

clear 
append using ${ow}
save ${alphapath}/ALPHA/projects/gates_incidence_risks_2019/results/pooled/adj_risk_models/meta_oldwomen,replace

clear 
append using ${ym}
save ${alphapath}/ALPHA/projects/gates_incidence_risks_2019/results/pooled/adj_risk_models/meta_youngmen,replace

clear 
append using ${om}
save ${alphapath}/ALPHA/projects/gates_incidence_risks_2019/results/pooled/adj_risk_models/meta_oldmen,replace


**** 		COMBINE INTO ONE 		 *******
use ${alphapath}/ALPHA/projects/gates_incidence_risks_2019/results/pooled/adj_risk_models/meta_oldmen,clear
gen sex=1
gen youth=0

append using ${alphapath}/ALPHA/projects/gates_incidence_risks_2019/results/pooled/adj_risk_models/meta_youngmen
replace sex=1 if sex==.
replace youth=1 if youth==.

append using ${alphapath}/ALPHA/projects/gates_incidence_risks_2019/results/pooled/adj_risk_models/meta_oldwomen
replace sex=2 if sex==.
replace youth=0 if youth==.

append using ${alphapath}/ALPHA/projects/gates_incidence_risks_2019/results/pooled/adj_risk_models/meta_youngwomen
replace sex=2 if sex==.
replace youth=1 if youth==.


gen hr=ln(estimate)
gen lb=ln(min95)
gen ub=ln(max95)

encode idstr,gen(study_name)
meta set hr lb ub ,studylabel(idstr) eslabel("Adj. HR")


save ${alphapath}/ALPHA/projects/gates_incidence_risks_2019/results/pooled/adj_risk_models/meta_all,replace

*** LOOK AT THE IMPACT OF TAKING OUT ONE SITE ********
** everything that ends up in adjusted models, for all age/sex groups

cap mkdir ${alphapath}/ALPHA/projects/gates_incidence_risks_2019/results/pooled/adj_risk_models/meta_analysis
cd   ${alphapath}/ALPHA/projects/gates_incidence_risks_2019/results/pooled/adj_risk_models/meta_analysis
frame create meta_output



*** LEAVE ONE OUT META-ANALYSIS AND SAVE RESULTS IN A TABLE

cap erase ${alphapath}/ALPHA/projects/gates_incidence_risks_2019/results/pooled/adj_risk_models/meta_analysis/meta_leaveoneout_output.dta

use ${alphapath}/ALPHA/projects/gates_incidence_risks_2019/results/pooled/adj_risk_models/meta_all,clear

local parmlist=`"2.tv_educ 0.tv_mstat_br 2.tv_mstat_br i.mobile 1.tv_circumcised 1.tv_regular 1.tv_casual 1.tv_new_partner untreated_opp_sex_prevalence "'

foreach rf in 2.tv_educ 0.tv_mstat_br 2.tv_mstat_br i.mobile 1.tv_circumcised 1.tv_regular 1.tv_casual 1.tv_new_partner untreated_opp_sex_prevalence 2.tv_clastyr{
forvalues sex=1/2 {
local sexname: label (sex) `sex'
forvalues youth=0/1 {
local youthname:label (youth) `youth'


cap meta summarize if sex==`sex' & youth==`youth' & parm=="`rf'" , eform(Risk ratios) leaveoneout
if _rc==0 {
meta summarize if sex==`sex' & youth==`youth' & parm=="`rf'" , eform(Risk ratios) leaveoneout
matrix mine=r(leaveoneout)


xsvmat mine, frame(meta_output,replace) rename(mine1 hr mine2 se mine3 lb mine4 ub mine5 tau mine6 q mine7 i2 mine8 h2 mine9 p)

frame  meta_output {
	replace hr=exp(hr)
	replace lb=exp(lb)
	replace ub=exp(ub)
	gen pooled=1 if _n==_N
	egen  minhr=min(hr) if pooled~=1
	egen  maxhr=max(hr) if pooled~=1
	keep if pooled==1 | minhr==hr | maxhr==hr
	gen res_ord=1 if minhr==hr
	replace res_ord=2 if maxhr==hr
	replace res_ord=3 if pooled==1
	gen str20 result=strofreal(hr,"%04.2f") + " (" + strofreal(lb,"%04.2f") + "- " + strofreal(ub,"%04.2f") + ")"
	keep res_ord result hr lb ub
	gen parm="`rf'"
	gen sex=`sex'
	gen youth=`youth'
	cap confirm file "${alphapath}/ALPHA/projects/gates_incidence_risks_2019/results/pooled/adj_risk_models/meta_analysis/meta_leaveoneout_output.dta"
	if _rc==601 {
	save "${alphapath}/ALPHA/projects/gates_incidence_risks_2019/results/pooled/adj_risk_models/meta_analysis/meta_leaveoneout_output",replace
	}
	else {
	append using "${alphapath}/ALPHA/projects/gates_incidence_risks_2019/results/pooled/adj_risk_models/meta_analysis/meta_leaveoneout_output"
	save "${alphapath}/ALPHA/projects/gates_incidence_risks_2019/results/pooled/adj_risk_models/meta_analysis/meta_leaveoneout_output",replace
	clear
	}
} /*close frame */

} /*close _rc if */

} /*close youth loop */
} /*close sex loop */
} /* close parm loop */

use "${alphapath}/ALPHA/projects/gates_incidence_risks_2019/results/pooled/adj_risk_models/meta_analysis/meta_leaveoneout_output",clear

gen rftmp="Prevalence of untreated infection in opposite sex potential partners" if parm=="untreated_opp_sex_prevalence"
replace rftmp="Never married" if parm=="0.tv_mstat_br"
replace rftmp="Formerly married" if parm=="2.tv_mstat_br"
replace rftmp="Secondary education" if parm=="2.tv_educ"
replace rftmp="Regular partner" if parm=="1.tv_regular"
replace rftmp="Casual partner" if parm=="1.tv_casual"
replace rftmp="New partner" if parm=="1.tv_new_partner"
replace rftmp="Circumcision" if parm=="1.tv_circumcised"
replace rftmp="Condom use" if parm=="2.tv_clastyr"

#delimit;
label define rf 
5 "Casual partner"
7 "Circumcision"
3 "Formerly married"
2 "Never married"
6 "New partner"
9 "Prevalence of untreated infection in opposite sex potential partners"
4 "Regular partner"
1 "Secondary education"
8 "Condom use"
,modify;
#delimit cr

encode rftmp ,gen(rf) label(rf)

gen str20 ci="(" + strofreal(lb,"%04.2f") + "-" + strofreal(ub,"%04.2f") + ")"


tabdisp ( rf) ( res_ord youth),cell(hr ci) by(sex) format(%4.2f)
keep rf res_ord youth hr ci sex
gen result1=strofreal(hr,"%04.2f")
rename ci result2

reshape long result ,i(youth rf sex res_ord) j(what)

drop hr 
reshape wide result,i(youth rf sex what) j(res_ord)
rename result1 min
rename result2 max
rename result3 all
reshape wide min max all,i(rf sex what) j(youth)

reshape wide min0 min1 max0 max1 all0 all1,i(rf what) j(sex)

sort  rf what
gen rf2=rf
replace rf2=99 if what==2
label values rf2 rf
label define rf 99 " ",modify


cap putdocx clear
putdocx begin,pagesize(A4) landscape

putdocx paragraph,style(Heading1)
putdocx text ("Output from leave-one-out meta-analysis")

putdocx paragraph
order rf2 min12 max12 all12 min02 max02 all02 min11 max11 all11  min01 max01 all01 
putdocx table tab1=data(rf2 min12 max12 all12 min02 max02 all02 min11 max11 all11  min01 max01 all01) 

putdocx table tab1(1,.),addrows(2,before)
putdocx table tab1(3,.),addrows(1,before)
putdocx table tab1(6,.),addrows(1,before)
putdocx table tab1(9,.),addrows(1,before)
putdocx table tab1(12,.),addrows(1,before)
putdocx table tab1(15,.),addrows(1,before)
putdocx table tab1(18,.),addrows(1,before)
putdocx table tab1(21,.),addrows(1,before)
putdocx table tab1(24,.),addrows(1,before)
putdocx table tab1(27,.),addrows(1,before)


putdocx table tab1(.,5),addcols(1,before)
putdocx table tab1(.,9),addcols(1,before)
putdocx table tab1(.,13),addcols(1,before)

putdocx table tab1(.,1),width(4cm)

putdocx table tab1(1,3)=("Young Women") 
putdocx table tab1(1,7)=("Older Women") 

putdocx table tab1(2,1)=("Risk factor") 
putdocx table tab1(2,2)=("Lowest HR") 
putdocx table tab1(2,3)=("Highest HR") 
putdocx table tab1(2,4)=("Pooled HR") 
putdocx table tab1(2,6)=("Lowest HR") 
putdocx table tab1(2,7)=("Highest HR") 
putdocx table tab1(2,8)=("Pooled HR") 

putdocx table tab1(1,11)=("Young Men") 
putdocx table tab1(1,15)=("Older Men") 

putdocx table tab1(2,10)=("Lowest HR") 
putdocx table tab1(2,11)=("Highest HR") 
putdocx table tab1(2,12)=("Pooled HR") 
putdocx table tab1(2,14)=("Lowest HR") 
putdocx table tab1(2,15)=("Highest HR") 
putdocx table tab1(2,16)=("Pooled HR") 

putdocx save "${alphapath}/ALPHA\Projects\Gates_incidence_risks_2019\paper\Tables and graphs/meta_analysis_results.docx",replace








