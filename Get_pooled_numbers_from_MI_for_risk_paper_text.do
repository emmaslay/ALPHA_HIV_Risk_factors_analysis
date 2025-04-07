*** To get the headline number of people aged 15-49 for text


*how many people were eligible
*pooled midpoint file here
use "K:\ALPHA\Incidence_ready_data\pooled\incidence_ready_midpoint_pooled.dta" ,clear
keep if age<50 & age>14
keep if years_one>2004 & years_one<2017
drop if study==1 & fouryear==4
drop if study==3 & fouryear==4
keep if _st==1

stsum
stptime



*using all imputations so it agrees with numbers in Table 1

quietly {
use _* age years_one study_name idno fouryear sex using  "${alphapath}/ALPHA\Incidence_ready_data\pooled\mi_data\incidence_ready_risk_factors_MI_pooled_1.dta",clear
keep if age<50 & age>14
keep if years_one>2004 & years_one<2017
drop if study==1 & fouryear==4
drop if study==3 & fouryear==4
keep if _st==1

gen fup=_t-_t0
gen fails=_d
sort  idno _t0
by  idno:gen people=1 if _n==1

collapse (sum) fup  fails  people  ,by(sex)
gen imp=1
local tempname firstfile
save ${alphapath}/ALPHA\Projects\Gates_incidence_risks_2019\results\Pooled\Risk_dist/`firstfile',replace


**  **  **  **  **  **  **  **
** SUBSEQUENT IMPUTATIONS
**  **  **  **  **  **  **  **

forvalues x=2/$useimp {
noisily di "Imputation `x'"
use _* age years_one study_name idno fouryear sex using  "${alphapath}/ALPHA\Incidence_ready_data\pooled\mi_data\incidence_ready_risk_factors_MI_pooled_`x'.dta",clear
keep if age<50 & age>14
keep if years_one>2004 & years_one<2017
drop if study==1 & fouryear==4
drop if study==3 & fouryear==4
keep if _st==1

gen fup=_t-_t0
gen fails=_d
sort  idno _t0
by  idno:gen people=1 if _n==1

collapse (sum) fup  fails  people ,by(sex)
gen imp=`x'
append using ${alphapath}/ALPHA\Projects\Gates_incidence_risks_2019\results\Pooled\Risk_dist/`firstfile'
save ${alphapath}/ALPHA\Projects\Gates_incidence_risks_2019\results\Pooled\Numbers_from_MI_for_text,replace
}

}
use ${alphapath}/ALPHA\Projects\Gates_incidence_risks_2019\results\Pooled\Numbers_from_MI_for_text,clear

collapse (mean) fup fails people,by(sex)
table ,stat(sum fup fails people)


