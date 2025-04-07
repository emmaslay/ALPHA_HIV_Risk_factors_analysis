/****************************************************************************
*Look at loss to follow up-
People in cohort
People never tested
People tested only once and first test was negative
Person time after last test
*********************************************/

***GET LIST OF IDS FROM INCIDENCE COHORT

use "K:\ALPHA\Incidence_ready_data\pooled\mi_data\incidence_ready_risk_factors_MI_pooled_0.dta",clear

keep if years_one>2004 & years_one<2017
keep if age>14 & age<50
drop if study_name==1 & fouryear==4
drop if study_name==3 & fouryear==4
keep study_name idno idno_orig sex _st youth
keep if _st==1
collapse (count) _st,by(study_name idno* sex youth)
reshape wide _st,i(study_name idno* sex) j(youth)
recode _st0 .=0 1/max=1
recode _st1 .=0 1/max=1
rename _st0 in_inc_ready_op
rename _st1 in_inc_ready_yp
sort study_name idno

save K:\ALPHA\Projects\Gates_incidence_risks_2019\flowchart/idnos_in_cohort,replace




foreach site in Ifakara Karonga Kisesa Kisumu Manicaland Masaka Rakai uMkhanyakude {

global sitename="`site'"

****************************************************************************
* ALPHA BASIC INCIDENCE ANALYSIS
****************************************************************************
*need an estimate for number of years after 15th birthday we make the adjustment for prevalence positives
*this could vary between sites but in the workshop everyone used 3
global maxinter=2

** *START WITH RESIDENCY EPISODES
use "L:\Gates_incidence_risk_factors_data_archive/clean_data/${sitename}/residency_${sitename}",clear

*For Manicaland, drop out the communities that weren't included in R6
if lower("${sitename}")=="manicaland" {
tempname community
gen `community'=int(hhold_id/10000)
tab `community'
drop if `community'==1 |`community'==6 |`community'==11 |`community'==12
}
** For uMkhanyakude drop TasP people
local lowsite=lower("${sitename}")
if "`lowsite'"=="umkhanyakude" {
drop if entry_type==1 & year(entry_date)==2017
}

*MERGE IN TEST DATES IN WIDE FORM, ONLY USING TESTS DONE WHEN PERSON WAS RESIDENT
merge m:1 study_name idno using "L:\Gates_incidence_risk_factors_data_archive/prepared_data/${sitename}/HIV_tests_wide_${sitename}", generate(merge_6_1_and_6_2) 	keepusing(first_neg_date last_neg_date first_pos_date last_pos_date  lasttest_date firsttest_date )
	
drop if merge_6_1_and_6_2==2



*merging in metadata
merge m:1 study_name using "L:\Gates_incidence_risk_factors_data_archive/clean_data/alpha_metadata",gen(merge_meta)
drop if merge_meta==2

*labels
label define sex 1 "Men" 2 "Women",modify
label values sex sex

** For Kisumu keep only Gem
local lowsite=lower("${sitename}")
if "`lowsite'"=="kisumu" {
	keep if residence==2
	*remove the people whose survey and residency details are very different
	*merge m:1 idno using ${alphapath}/ALPHA/prepared_data/${sitename}/imposters_kisumu
	*drop if _merge==3
	*drop _merge
	}


*STSET - death (exit type 2) is failure
*setting on mortality temporarily to organise the data- want to be able to use stsplit
cap  stset,clear
gen exit = exit_date
gen entry = entry_date
format %td entry exit
gen failure=1 if exit_type == 2
stset exit, time0(entry) failure(failure) origin(dob) id(idno) scale(365.25) 


**EARLY EXIT ISSUES- these arise in sites where the DSS interview and the HIV test don't always take place on the same day.  It is necessary to move the exit date to after
*the test dates, but there is an upper limit (defined in the metadata) beyond which the exit date shouldn't be moved.
*The upper limit depends on what is known about fieldwork and how long the lag between DSS and HIV test is likely to have been.
*If the tests are beyond the upper limit they are discarded if this is the last episode
bysort study_name idno (entry_date):gen episode_sequence=_n
bysort study_name idno (entry_date):gen episode_total=_N
gen last_episode=0
replace last_episode=1 if episode_sequence==episode_total
gen temp=exit if last_episode==1
bysort study_name idno: egen last_exit_original=max(temp)
drop temp

*if exit is on the same date as the last test, move the exit date to one day after
gen early_exit_fixed_t=1 if exit==lasttest_date & lasttest_date<. & last_episode==1
replace exit=exit+1 if exit==lasttest_date & lasttest_date<. & last_episode==1

*identify people whose latest 6.1 exit is before latest 6.2 report & calculate difference
* exit before last test
gen exitgap_test=lasttest_date-exit if exit<lasttest_date & lasttest_date<. & last_episode==1

gen early_exit_problem=.
label define early_exit_problem 1 "Exit<last6.2" 2 "Exit<last9.1" 3 "Exit<last9.2" 4 "Exit<last6.2&9.1" 5 "Exit<last6.2&9.2" 6 "Exit<last 9.1&9.2" 7 "Exit<last6.2&9.1&9.2", modify
replace early_exit_problem=1 if exitgap_test~=.
label values early_exit_problem early_exit_problem

*change exit to one day after last test, SR or clinic report [all exit types for first 2, only if not dead or out-migrated for clinic data as they could move out but still go to same clinic]
gen exit_new=.
label define early_exit_fixed 0 "No change to exit" 1 "Exit changed to last 6.2 plus 1 day" 2 "Exit changed to last 9.1 plus 1 day" 3 "Exit changed to last 9.2 plus 1 day"
replace early_exit_fixed_t=1 if exitgap_test<=earlyexit_max
replace exit_new=lasttest_date+1 if early_exit_fixed_t==1

replace early_exit_fixed=0 if early_exit_problem~=. & early_exit_fixed_t==.
bys study_name idno: egen early_exit_fixed=max(early_exit_fixed_t)
label values early_exit_fixed early_exit_fixed

replace exit=exit_new if exit_new~=.


*redo stset to account for changes in exit dates & failure updates
stset exit , time0(entry) failure(failure) origin(dob) id(idno) scale(365.25) 

************************************************************************************************************
**  				3. SPLIT USING 6.2b DATA (HIV TESTS) & CREATE HIV STATUS VARIABLE					  **
************************************************************************************************************

format %td first_neg_date last_neg_date first_pos_date last_pos_date 

gen double sero_conv_date=last_neg_date+((first_pos_date-last_neg_date)/2) if last_neg_date~=. & first_pos_date~=. 
label var sero_conv_date "Seroconversion date: midpoint"
gen timeprepos=0

do "L:\Gates_incidence_risk_factors_data_archive/DoFiles\Common/create_hivstatus_detail.do"


********* REORGANISE FOR INCIDENCE ANALYSIS  *********

** define date of 15th birthday
gen double fifteen=dob+(15*365.25)
format %td fifteen
label var fifteen "Date of 15th birthday"

* OPTION TO INCLUDE YOUNGEST RESIDENTS COMING TO FIRST SERO
* WHO WERE RESIDENT AT EARLIER SERO BUT NOT AGE ELIGIBLE
* ASSUMING THEY WERE NEGATIVE AT AGE 15
* COMMENT OUT THIS BIT IF THIS OPTION NOT NEEDED
summ nrounds_sero
local maxrounds=r(mean)

gen tested_first_opportunity=0
label var tested_first_opp "Tested for the first time at the first survey after 15th birthday"
replace tested_first_opp =1 if firsttest_date<(fifteen+${maxinter}*365.25) & firsttest_date>fifteen & firsttest_date<.

*check if resident at 15
stgen resat15=ever(fifteen>(_t0*365.25+dob) & fifteen<(_t*365.25+dob))
label var resat15 "Resident on 15th birthday"

keep if _st==1



*split the data by age group and calendar year
do "L:\Gates_incidence_risk_factors_data_archive/DoFiles/common/single_year_agegrp_split_including_kids.do"

do "L:\Gates_incidence_risk_factors_data_archive/DoFiles/common/calendar_year_split.do"

*create new categorical variables
drop if age<15
do "L:\Gates_incidence_risk_factors_data_archive/DoFiles/common/Create_agegrp_from_age.do"
do "L:\Gates_incidence_risk_factors_data_archive/DoFiles/common/Create_birth_cohort_from_dob.do"

do "L:\Gates_incidence_risk_factors_data_archive/DoFiles/common/create_fiveyear.do"
do "L:\Gates_incidence_risk_factors_data_archive/DoFiles/common/create_fouryear.do"


keep if years_one>2004 & years_one<2017
keep if age>14 & age<50
drop if study_name==1 & fouryear==4
drop if study_name==3 & fouryear==4
**************************************************************
*	WHO ENDS UP IN THE INCIDENCE ANALYSIS?			**********
**************************************************************


*Never eligible: only had one opportunity to test- ie not been in cohort long enough for two tests
*eligible: been in for at least two rounds and not a prevalent positive

** Let's assume that anyone who has been resident for more than the average time between the start of one round and the end of the next is eligible
** use round dates form meta data to estimate this average
forvalues i=1/23 {
local j=`i'+1
gen days_for_2_rounds`i'=r`j'_end_date-r`i'_start_date
}
egen average_days=rowmean(days_for_2_rounds*)


*censor everyone at the most recent test date
	stsplit afterlasttest,after(lasttest_date) at(0)
	drop if afterlasttest==0
	drop afterlasttest


	** recreate entry and exit variables- old dates no longer valid after splits- Stata isn't reliable about updating them in all versions.
	gen double start_ep_date=_t0*365.25+dob
	gen double end_ep_date=_t*365.25+dob
	gen died=_d
	format %td start_ep_date end_ep_date
	label var start_ep_date "Date this record starts on, for everyone included in midpoint file"
	label var end_ep_date "Date this record ends on, for everyone included in midpoint file"
	*CAN'T USE A FILE STSET ON INCIDENCE AS THE BASIS FOR MI ESTIMATES OF INCIDENCE RISK FACTORS. THIS IS BECAUSE 
	*THE DATASET REQUIRES ADDITIONAL SPLITTING TO PREPARE THE DATA FOR RISK FACTOR ANALYSIS. WE NEED ALL RECORDS TO BE SPLIT AS APPROPRIATE BUT
	*IF THE DATASET IS SET ON SERCONVERSION, WITH FAILURE AT THE MIDPOINT, THE STSET WILL EXCLUDE ANY SEROCONVERTORS WHO ARE NOT RESIDENT AT THE MIDPOINT
	*THIS MEANS THEY WOULD NOT BE PROPERLY INCLUDED IN THE RISK FACTOR ANALYSIS.  TO GET AROUND THIS PROBLEM, WE CREATE THE RISK FACTOR FILE FROM ONE
	*THAT IS SET ON MORTALITY SO THAT EVERYONE IS INCLUDED.
	label data "ALPHA input data for ${sitename} to be used to create the dataset for incidence risk factor analysis. Currently set on mortality."
	*save "${alphapath}/ALPHA/incidence_ready_data/${sitename}/incidence_temp_for_risk_factors_${sitename}",replace

	*NOW STSET THE DATA FOR INCIDENCE ANALYSIS USING THE MIDPOINT AS THE SEROCONVERSION DATE
	*count the number of people observed to seroconvert- no necessarily resident on this date
	stdes if first_pos_date<. & last_neg_date<. & first_pos_date>last_neg_date
	stset,clear


	** make a variable to indicate records that contain a seroconversion
	gen serocon_fail=0
	replace serocon_fail=1 if sero_conv_date>start_ep_date & sero_conv_date<=end_ep_date

	*Move the end date of episodes that contain a seroconversion- the episode will now end at the time of seroconversion
	replace end_ep_date=sero_conv_date if serocon_fail==1

	stset end_ep_date,fail(serocon_fail) id(idno) entry(fifteen) origin(dob) time0(start_ep_date) scale(365.25)

** describe person's whole time in cohort during study period

gen fup=_t-_t0
bys study_name idno:egen totalfup=total(fup)

gen retroconvertor=0
replace retroconvertor=1 if last_neg_date>first_pos_date & last_neg_date<. & last_neg_date<mdy(1,1,2017) & last_neg_date>mdy(12,31,2004) & first_pos_date<mdy(1,1,2017) & first_pos_date>mdy(12,31,2004) 

*never tested
stgen never_tested=always(hivstatus_de==13)

*mark those who were only ever positive 
stgen always_positive=always(hivstatus_de==2 | hivstatus_de==6 |hivstatus_de==7 | hivstatus_de==8 )


*mark those who were ever between two negative tests or in the seroconversion window
stgen between_tests=ever(hivstatus_detail==1 | hivstatus_detail==9 | hivstatus_detail==10 | hivstatus_detail==11 | hivstatus_detail==12)
*also keep the time of young people prior to their first test if they 1) were too young to have been tested in the previous round and 2) had their first test
* at the first opportunity


*tested negative only once- everyone of those is in post-neg time.
*but that also includes people who had time between two neg tests i.e. tested >1 time so need to remove
stgen ever_postneg=ever( hivstatus_de==4 | hivstatus_de==5)
stgen never_negative=never( hivstatus_de==1)
gen tested_once2=0 if ever_postneg==0 
replace tested_once2=1 if ever_postneg==1 & never_negative==1

*Flag those too young for two tests, but not if first test was positive
gen too_young_for_two_tests=0
replace too_young_for_two_tests=1 if tested_first_opp==1 & resat15==1 & (_t*365.25+dob)<=firsttest_date & always_pos==0 & tested_once==1


keep idno sex _* agegrp fouryear study_name fup totalfup average_days  serocon_fail fifteen hivstatus_de lasttest_date first_pos_date tested_first_opp resat15 firsttest_date last_neg_date  sero_conv_date end_ep_date start_ep_date dob never_tested always_positive  tested_once never_negative too_young_for_two_tests between_tests retroconvertor
save ${alphapath}/ALPHA\Projects\Gates_incidence_risks_2019/ltfu_data_${sitename},replace

}


********************************************************************************
**				COMBINE FILES
********************************************************************************

clear
append using ///
${alphapath}/ALPHA\Projects\Gates_incidence_risks_2019/ltfu_data_Ifakara ///
${alphapath}/ALPHA\Projects\Gates_incidence_risks_2019/ltfu_data_Karonga ///
${alphapath}/ALPHA\Projects\Gates_incidence_risks_2019/ltfu_data_Kisesa ///
${alphapath}/ALPHA\Projects\Gates_incidence_risks_2019/ltfu_data_Kisumu ///
${alphapath}/ALPHA\Projects\Gates_incidence_risks_2019/ltfu_data_Manicaland ///
${alphapath}/ALPHA\Projects\Gates_incidence_risks_2019/ltfu_data_Masaka ///
${alphapath}/ALPHA\Projects\Gates_incidence_risks_2019/ltfu_data_Rakai ///
${alphapath}/ALPHA\Projects\Gates_incidence_risks_2019/ltfu_data_uMkhanyakude 




gen double idno_orig=idno
drop idno
egen idno=group(study_name idno_orig)

order study_name idno sex

*** merge in incidence cohort idnos
merge m:1 study_name idno_orig using K:\ALPHA\Projects\Gates_incidence_risks_2019\flowchart/idnos_in_cohort
rename _m merge_with_inc_ready
egen in_inc_ready_allages=rowmax(in_inc_ready_op in_inc_ready_yp)

** NUMBER OF PEOPLE IN STUDY
gen people_resident=_st
label var people_resident "People in study"

drop if _st==0
*********************************************************************************************
*PEOPLE WITH ENOUGH TIME IN STUDY
gen people_with_enough_time=0 if totalfup<(average_days/365.25) & _st==1
replace people_with_enough_time=1 if totalfup>=(average_days/365.25)  & _st==1
label define people_with_enough_time 0 "Not enough time in study" 1 "Eligible" ,modify
label values people_with_enough_time people_with_enough_time
label var people_with_enough_time "Was this person in the study long enough to have been tested twice?"


*PEOPLE WHO WERE ALWAYS POSITIVE
gen people_always_pos=always_pos
*People who had a short time and were always positive can be counted as not enough time (we might have caught the seroconversion if they were in teh study for longer)
replace people_always_pos=0 if always_pos==1 & people_with_enough_time==0 

*and people who were always positive- take them out of people with enough time
replace people_with_enough_time=0 if people_always_pos==1

** some people without enough time were also made eligible, or were caught by two rounds anyway
*tested once but too young for two tests
replace people_with_enough_time=1 if tested_once==1 & too_young_for_two_tests==1 & always_pos==0
*we caught some people even though they were in for a short time- also add to enough time
replace people_with_enough_time=1 if between_tests==1



** now sort out eligibility

gen people_eligible=0
replace people_eli=1 if people_with_enough_time==1 & people_always==0 
label var people_eli "People with enough time for incidence cohort who were't always positive"


*********************************************************************************************

** NOW WHAT HAPPENS TO PEOPLE WHO WERE IN FOR LONG ENOUGH
*Can be never tested, tested once, retroconvertor or in the cohort
*some people had their first test after the end of follow up- put them to never tested
stgen first_neg_test_after_2016=always(hivstatus_de==3)	

*NEVER TESTED- PEOPLE WHO WERE ALWAYS HIV UNKNOWN
gen people_no_tests=never_tested 
replace people_no_tests=0 if people_with_enough_time==0

* also never tested is anyone who was first tested after the end of follow up
replace people_no_tests=1 if first_neg_test_after_2016==1 & people_eli==1

*** PEOPLE ONLY TESTED ONCE
gen people_one_test=tested_once 
*take out people who did not have enough time
replace people_one_test=0 if tested_once==1 & people_with_enough_time==0 
*and those who were first tested after 2016
replace people_one_test=0 if first_neg_test_after_2016==1 & never_tested==1 & people_eli==1

*IN COHORT

*People between two tests
gen people_in_cohort=1 if in_inc_ready_allages==1
recode people_in_cohort .=0
*Remove all those people from other categories
replace people_one_test=0 if in_inc_ready_allages==1
replace people_no_tests=0 if in_inc_ready_allages==1
replace people_always_pos=0 if in_inc_ready_allages==1 /* these are the young prevalent positives we've put in as too young for two tests */
*add the people who were in cohort to enough time
replace people_with_enough_time=1 if in_inc_ready_allages==1 & people_with_enough_time==0
replace people_eligible=1 if in_inc_ready_allages==1

**** flag people with insufficient time
gen people_insufficient_time=1-people_with_enough_time
replace people_insu=0 if people_always==1  & people_with_enough_time==0
label var people_insufficient_time "Was this person not in the study long enough for two tests?"


** remove any retroconvertors who have fallen into another category
gen people_retroconvertors=retroconvertor if people_eli==1
replace people_retroconvertor=0 if retro==1 & (always_pos==1 | people_insu==1)
replace people_retroconvertor=0 if retro==. & (always_pos==1 | people_insu==1)

replace people_retroconvertors=0 if first_neg_test_after_2016==1  & never_tested==1
replace people_retroconvertor=0 if in_inc_ready_allages==1
*but pick up those with widely spaced tests who haven't made it into cohort (i.e. no coherent test history in the middile)
egen check=rowtotal(people_retroconvertors  people_no_tests people_one_test people_in_cohort)
replace people_retroconvertor=1 if last_neg_date>first_pos_date & last_neg_date<. & retroconvertor==0 & check==0 &  people_eli==1
drop check
egen check=rowtotal(people_retroconvertors  people_no_tests people_one_test people_in_cohort)


order study_name idno idno_orig sex dob hivstatus_de  agegrp fouryear _* serocon merge people*
sort study_name idno _t0

format %td first* last*

*One person from Kisesa dropped because of overlapping residency
tab check people_eli
br if check==0 & people_eli==1
replace people_eli=0 if study_name==2 & idno_orig==20498
replace people_insu=1 if study_name==2 & idno_orig==20498
drop check
egen check=rowtotal(people_retroconvertors  people_no_tests people_one_test people_in_cohort)

br if check==2
** remaining people with check==2 are retroconvertors whose first test date was after the end of residency
replace people_retro=0 if retro==1 & check==2 & people_no_tests==1

drop check
egen check=rowtotal(people_retroconvertors  people_no_tests people_one_test people_in_cohort)
tab check people_eli,m

gen yp_in_cohort=in_inc_ready_yp
recode yp_in_cohort .=0
gen op_in_cohort=in_inc_ready_op
recode op_in_cohort .=0

**check eligible people add up to residents
egen check_eli=rowtotal(people_insu  people_always people_eli)

tab check_eli people_res,m
br if check_eli==1 & people_res==.

/*
table (study sex) people_res,command(r(unique): unique idno)
table (study sex) people_insu,command(r(unique): unique idno)
table (study sex) people_always,command(r(unique): unique idno)
table (study sex) people_eli,command(r(unique): unique idno)
table (study sex) check_eli,command(r(unique): unique idno)

table study people_retroconvertors,command(r(unique): unique idno)
table study people_no_tests,command(r(unique): unique idno)
table study people_one_test,command(r(unique): unique idno)
table study people_in_cohort,command(r(unique): unique idno)

table check people_eli,command(r(unique): unique idno)


*/

*************************************************************************************



collapse (max) op_in_cohort yp_in_cohort people_in_cohort people_one_test people_no_tests people_always_po people_insufficient_time people_retroconvertor people_eligible people_resident in_inc_ready_op in_inc_ready_yp in_inc_ready_allages, by(idno idno_orig study_name sex merge)

save ${alphapath}/ALPHA\Projects\Gates_incidence_risks_2019/ltfu_data_pooled,replace

/*
	
*/

************* SUMMARISE FOR FLOWCHART ****************
cd ${alphapath}/ALPHA\Projects\Gates_incidence_risks_2019/flowchart
use ${alphapath}/ALPHA\Projects\Gates_incidence_risks_2019/ltfu_data_pooled,clear
drop if sex==9 | sex==.



collapse (sum) people_resident people_eligible people_insufficient_time people_retroconvertor people_always_pos people_no_tests people_one_test people_in_cohort yp_in_cohort op_in_cohort,by(study_name sex)

gen people_not_eligible=people_insufficient_time+people_always_pos

gen people_not_in_cohort=people_no_tests+people_one_test + people_retro
save flowchart_data_summary,replace

**************** PREPARE FOR FLOWCHART  *************

use flowchart_data_summary,clear


count
local nrec=r(N)

forvalues x=1/`nrec' {

local study=study_name[`x']
local sex=sex[`x']
local studyname:label (study) `study'
local sexname: label (sex) `sex'

*box headings
local resident=people_resident[`x']
local notelig=people_not_eligible[`x']
local elig=people_eligible[`x']
local some=people_in_cohort[`x'] 
local never=people_not_in_cohort[`x'] 
local op=op_in_cohort[`x'] 
local yp=yp_in_cohort[`x']


**sub headings
local already_pos=people_always_pos[`x']
local not_enough_time=people_insufficient_time[`x']
local no_test=people_no_tests[`x']
local one_test=people_one_test[`x'] 
local retro=people_retro[`x']

local p1=",lcolor(black) lwidth(0.75pt) mcolor(black) mlwidth(0.75pt)"
local p2=",lcolor(black)"

local v_gap=6
local h_gap=6

local box_width=27
local box_height=10

local top_y=57
local top_x=14

local axis_top=`top_x'+3

** TITLE **
local title_text_y=`top_y'+3
local title_text_x=`top_x'+(`box_width'/2)



** BOX 1 TOP CENTRE **
local b1yt=`top_y'
local b1yb=`b1yt' - `box_height'
local b1xl=`top_x'
local b1xr=`b1xl'+`box_width'
local b1_base_mid=`b1xl'+(`box_width'/2)
local b1_side_mid=`b1yt'-(`box_height'/2)
local b1_text_y=`b1yt'-2
local b1_text_x=`b1xl'+(`box_width'/2)
local b1_text_y2=`b1yt'-5


local b1bl="`b1yb' `b1xl'"
local b1tl="`b1yt' `b1xl'"
local b1br="`b1yb' `b1xr'"
local b1tr="`b1yt' `b1xr'"
local b1_base_arrow="`b1yb' `b1_base_mid'"
local b1_right_arrow="`b1_side_mid' `b1xr'"

** BOX 2 TOP RIGHT **

local b2yt=`top_y'
local b2yb=`b2yt' - `box_height'
local b2xl=`b1xl' +`box_width'+ `h_gap'
local b2xr=`b2xl'+`box_width'
local b2_base_mid=`b2xl'+(`box_width'/2)
local b2_side_mid=`b2yt'-(`box_height'/2)
local b2_text_y=`b2yt'-2
local b2_text_x=`b2xl'+(`box_width'/2)
local b2_text_y2=`b2yt'-6

local b2bl="`b2yb' `b2xl'"
local b2tl="`b2yt' `b2xl'"
local b2br="`b2yb' `b2xr'"
local b2tr="`b2yt' `b2xr'"
local b2_base_arrow="`b2yb' `b2_base_mid'"
local b2_left_arrow="`b2_side_mid' `b2xl'"

** BOX 3 MIDDLE CENTRE **
local b3yt=`top_y'-`box_height'-`v_gap'
local b3yb=`b3yt' - `box_height'
local b3xl=`b1xl'
local b3xr=`b3xl'+`box_width'
local b3_base_mid=`b3xl'+(`box_width'/2)
local b3_side_mid=`b3yt'-(`box_height'/2)
local b3_text_y=`b3yt'-2
local b3_text_x=`b3xl'+(`box_width'/2)
local b3_text_y2=`b3yt'-5

local b3bl="`b3yb' `b3xl'"
local b3tl="`b3yt' `b3xl'"
local b3br="`b3yb' `b3xr'"
local b3tr="`b3yt' `b3xr'"
local b3_base_arrow="`b3yb' `b3_base_mid'"
local b3_right_arrow="`b3_side_mid' `b3xr'"
local b3_top_arrow="`b3yt' `b3_base_mid'"


*** BOX 4 BOTTOM CENTRE ****
local b4yt=`top_y'-`box_height'*2-`v_gap'*2
local b4yb=`b4yt' - `box_height'
local b4xl=`b1xl'
local b4xr=`b4xl'+`box_width'
local b4_base_mid=`b4xl'+(`box_width'/2)
local b4_side_mid=`b4yt'-(`box_height'/2)
local b4_text_y=`b4yt'-3
local b4_text_x=`b4xl'+(`box_width'/2)
local b4_text_y2=`b4yt'-5

local b4bl="`b4yb' `b4xl'"
local b4tl="`b4yt' `b4xl'"
local b4br="`b4yb' `b4xr'"
local b4tr="`b4yt' `b4xr'"
local b4_base_arrow="`b4yb' `b4_base_mid'"
local b4_right_arrow="`b4_side_mid' `b4xr'"
local b4_top_arrow="`b4yt' `b4_base_mid'"

** BOX 5 middle right **
local b5yt=`top_y'-`box_height'-`v_gap'
local b5yb=`b5yt' - `box_height'
local b5xl=`b1xl'+`box_width'+`h_gap'
local b5xr=`b5xl'+`box_width'
local b5_base_mid=`b5xl'+(`box_width'/2)
local b5_side_mid=`b5yt'-(`box_height'/2)
local b5_text_y=`b5yt'-2
local b5_text_x=`b5xl'+(`box_width'/2)
local b5_text_y2=`b5yt'-6

local b5bl="`b5yb' `b5xl'"
local b5tl="`b5yt' `b5xl'"
local b5br="`b5yb' `b5xr'"
local b5tr="`b5yt' `b5xr'"
local b5_base_arrow="`b5yb' `b5_base_mid'"
local b5_left_arrow="`b5_side_mid' `b5xl'"
local b5_top_arrow="`b5yt' `b5_base_mid'"


** BOX 6 very BOTTOM RIGHT **
local b6yt=`top_y'-`box_height'*3-`v_gap'*3
local b6yb=`b6yt' - `box_height'
local b6xl=`b1xl'+`box_width'*0.6 
local b6xr=`b6xl'+`box_width'
local b6_base_mid=`b6xl'+(`box_width'/2)
local b6_side_mid=`b6yt'-(`box_height'/2)
local b6_text_y=`b6yt'-3
local b6_text_x=`b6xl'+(`box_width'/2)
local b6_text_y2=`b6yt'-5

local b6bl="`b6yb' `b6xl'"
local b6tl="`b6yt' `b6xl'"
local b6br="`b6yb' `b6xr'"
local b6tr="`b6yt' `b6xr'"
local b6_base_arrow="`b6yb' `b6_base_mid'"
local b6_left_arrow="`b6_side_mid' `b6xl'"
local b6_top_arrow="`b6yt' `b6_base_mid'"

** BOX 7 very BOTTOM LEFT **
local b7yt=`top_y'-`box_height'*3-`v_gap'*3
local b7yb=`b7yt' - `box_height'
local b7xl=`b1xl'-`box_width'*0.6 
local b7xr=`b7xl'+`box_width'
local b7_base_mid=`b7xl'+(`box_width'/2)
local b7_side_mid=`b7yt'-(`box_height'/2)
local b7_text_y=`b7yt'-3
local b7_text_x=`b7xl'+(`box_width'/2)
local b7_text_y2=`b7yt'-5

local b7bl="`b7yb' `b7xl'"
local b7tl="`b7yt' `b7xl'"
local b7br="`b7yb' `b7xr'"
local b7tr="`b7yt' `b7xr'"
local b7_base_arrow="`b7yb' `b7_base_mid'"
local b7_left_arrow="`b7_side_mid' `b7xl'"
local b7_top_arrow="`b7yt' `b7_base_mid'"

*** DRAW FLOWCHART
graph twoway  /// 
 pci `b1tl' `b1tr' "Resident" `p1' mlabpos(9)|| pci `b1tl' `b1bl' `p1'  || pci `b1bl' `b1br' `p1' || pci `b1br' `b1tr' `p1'  /// /* box 1 */
,text(`b1_text_y' `b1_text_x' "{bf:Resident (`resident')}",size(9pt)) ///
,text(`b1_text_y2' `b1_text_x' "aged 15-49" "during 2005-2016",size(8pt)) ///
|| pci `b2tl' `b2tr' `p1' || pci `b2tl' `b2bl' "Not eligible" `p1' || pci `b2bl' `b2br'  `p1' || pci `b2br' `b2tr' `p1'  ////* box 2 */
,text(`b2_text_y' `b2_text_x'  "{bf:Not eligible (`notelig')}" ,size(9pt) )   ////
,text(`b2_text_y2' `b2_text_x'  "{it:Already HIV+ (`already_pos')}" "{it:Insufficient time}" "{it: in study (`not_enough_time')}" ,size(8pt) )   ////
|| pcarrowi `b1_right_arrow' `b2_left_arrow'  `p1' ///
|| pci `b3tl' `b3tr' `p1' || pci `b3tl' `b3bl' "Eligible" `p1' || pci `b3bl' `b3br'  `p1' || pci `b3br' `b3tr' `p1'  /// /* box 3 */
,text(`b3_text_y' `b3_text_x' "{bf:Eligible (`elig')}",size(9pt)) ///
,text(`b3_text_y2' `b3_text_x' "Under observation" "for ≥2 survey rounds",size(8pt)) ///
|| pcarrowi `b1_base_arrow' `b3_top_arrow'  `p1' ///
|| pci `b4tl' `b4tr' `p1' || pci `b4tl' `b4bl' "Some" `p1' || pci `b4bl' `b4br'  `p1' || pci `b4br' `b4tr' `p1'  /// /* box 4 */
|| pci `b5tl' `b5tr' `p1' || pci `b5tl' `b5bl' "Never" `p1' || pci `b5bl' `b5br'  `p1' || pci `b5br' `b5tr' `p1'  /// /* box 5 */
|| pcarrowi `b3_base_arrow' `b4_top_arrow'  `p1' ///
|| pcarrowi `b3_right_arrow' `b5_left_arrow'  `p1' ///
|| pci `b6tl' `b6tr' `p1' || pci `b6tl' `b6bl' "yp" `p1' || pci `b6bl' `b6br'  `p1' || pci `b6br' `b6tr' `p1'  /// /* box 6 */
|| pci `b7tl' `b7tr' `p1' || pci `b7tl' `b7bl' "older" `p1' || pci `b7bl' `b7br'  `p1' || pci `b7br' `b7tr' `p1'  /// /* box 7 */
|| pcarrowi `b4_base_arrow' `b6_top_arrow'  `p1' ///
|| pcarrowi `b4_base_arrow' `b7_top_arrow'  `p1' ///
,text(`b4_text_y' `b4_text_x' "{bf:Incidence cohort}" "{bf:(`some')}",size(9pt)) ///
,text(`b5_text_y' `b5_text_x' "{bf:<2 tests (`never')}",size(9pt)) ///
,text(`b7_text_y' `b7_text_x' "{bf:Aged 15-24}" "{bf:(`yp')}",size(9pt)) ///
,text(`b6_text_y' `b6_text_x' "{bf:Aged 25-49}" "{bf:(`op')}",size(9pt)) ///
,text(`title_text_y' `title_text_x' "{bf:`studyname' `sexname'}",size(11pt)) ///
,xsize(4) ysize(4) legend(off) xscale(off range(0 `axis_top')) yscale(off range(0 `axis_top')) ///
xlab(,notick nolab nogrid)  ylab(,notick nolab nogrid) xtitle("") ytitle("") 


graph export flowchart_`studyname'_`sexname'.png,width(6000) replace
graph export flowchart_`studyname'_`sexname'.eps, replace


}


***************** POOLED ********************


use ${alphapath}/ALPHA\Projects\Gates_incidence_risks_2019/ltfu_data_pooled,clear
drop if sex==9 | sex==.



collapse (sum) people_resident people_eligible people_insufficient_time people_retroconvertor people_always_pos people_no_tests people_one_test people_in_cohort yp_in_cohort op_in_cohort,by( sex)

gen people_not_eligible=people_insufficient_time+people_always_pos

gen people_not_in_cohort=people_no_tests+people_one_test + people_retro

count
local nrec=r(N)

forvalues x=1/`nrec' {

local sex=sex[`x']
local studyname="Pooled"
local sexname: label (sex) `sex'

*box headings
local resident=people_resident[`x']
local notelig=people_not_eligible[`x']
local elig=people_eligible[`x']
local some=people_in_cohort[`x'] 
local never=people_not_in_cohort[`x'] 
local op=op_in_cohort[`x'] 
local yp=yp_in_cohort[`x']


**sub headings
local already_pos=people_always_pos[`x']
local not_enough_time=people_insufficient_time[`x']
local no_test=people_no_tests[`x']
local one_test=people_one_test[`x'] 
local retro=people_retro[`x']

local p1=",lcolor(black) lwidth(0.75pt) mcolor(black) mlwidth(0.75pt)"
local p2=",lcolor(black)"

local v_gap=6
local h_gap=6

local box_width=27
local box_height=10

local top_y=57
local top_x=14

local axis_top=`top_x'+3

** TITLE **
local title_text_y=`top_y'+3
local title_text_x=`top_x'+(`box_width'/2)



** BOX 1 TOP CENTRE **
local b1yt=`top_y'
local b1yb=`b1yt' - `box_height'
local b1xl=`top_x'
local b1xr=`b1xl'+`box_width'
local b1_base_mid=`b1xl'+(`box_width'/2)
local b1_side_mid=`b1yt'-(`box_height'/2)
local b1_text_y=`b1yt'-2
local b1_text_x=`b1xl'+(`box_width'/2)
local b1_text_y2=`b1yt'-5


local b1bl="`b1yb' `b1xl'"
local b1tl="`b1yt' `b1xl'"
local b1br="`b1yb' `b1xr'"
local b1tr="`b1yt' `b1xr'"
local b1_base_arrow="`b1yb' `b1_base_mid'"
local b1_right_arrow="`b1_side_mid' `b1xr'"

** BOX 2 TOP RIGHT **

local b2yt=`top_y'
local b2yb=`b2yt' - `box_height'
local b2xl=`b1xl' +`box_width'+ `h_gap'
local b2xr=`b2xl'+`box_width'
local b2_base_mid=`b2xl'+(`box_width'/2)
local b2_side_mid=`b2yt'-(`box_height'/2)
local b2_text_y=`b2yt'-2
local b2_text_x=`b2xl'+(`box_width'/2)
local b2_text_y2=`b2yt'-6

local b2bl="`b2yb' `b2xl'"
local b2tl="`b2yt' `b2xl'"
local b2br="`b2yb' `b2xr'"
local b2tr="`b2yt' `b2xr'"
local b2_base_arrow="`b2yb' `b2_base_mid'"
local b2_left_arrow="`b2_side_mid' `b2xl'"

** BOX 3 MIDDLE CENTRE **
local b3yt=`top_y'-`box_height'-`v_gap'
local b3yb=`b3yt' - `box_height'
local b3xl=`b1xl'
local b3xr=`b3xl'+`box_width'
local b3_base_mid=`b3xl'+(`box_width'/2)
local b3_side_mid=`b3yt'-(`box_height'/2)
local b3_text_y=`b3yt'-2
local b3_text_x=`b3xl'+(`box_width'/2)
local b3_text_y2=`b3yt'-5

local b3bl="`b3yb' `b3xl'"
local b3tl="`b3yt' `b3xl'"
local b3br="`b3yb' `b3xr'"
local b3tr="`b3yt' `b3xr'"
local b3_base_arrow="`b3yb' `b3_base_mid'"
local b3_right_arrow="`b3_side_mid' `b3xr'"
local b3_top_arrow="`b3yt' `b3_base_mid'"


*** BOX 4 BOTTOM CENTRE ****
local b4yt=`top_y'-`box_height'*2-`v_gap'*2
local b4yb=`b4yt' - `box_height'
local b4xl=`b1xl'
local b4xr=`b4xl'+`box_width'
local b4_base_mid=`b4xl'+(`box_width'/2)
local b4_side_mid=`b4yt'-(`box_height'/2)
local b4_text_y=`b4yt'-3
local b4_text_x=`b4xl'+(`box_width'/2)
local b4_text_y2=`b4yt'-5

local b4bl="`b4yb' `b4xl'"
local b4tl="`b4yt' `b4xl'"
local b4br="`b4yb' `b4xr'"
local b4tr="`b4yt' `b4xr'"
local b4_base_arrow="`b4yb' `b4_base_mid'"
local b4_right_arrow="`b4_side_mid' `b4xr'"
local b4_top_arrow="`b4yt' `b4_base_mid'"

** BOX 5 middle right **
local b5yt=`top_y'-`box_height'-`v_gap'
local b5yb=`b5yt' - `box_height'
local b5xl=`b1xl'+`box_width'+`h_gap'
local b5xr=`b5xl'+`box_width'
local b5_base_mid=`b5xl'+(`box_width'/2)
local b5_side_mid=`b5yt'-(`box_height'/2)
local b5_text_y=`b5yt'-2
local b5_text_x=`b5xl'+(`box_width'/2)
local b5_text_y2=`b5yt'-6

local b5bl="`b5yb' `b5xl'"
local b5tl="`b5yt' `b5xl'"
local b5br="`b5yb' `b5xr'"
local b5tr="`b5yt' `b5xr'"
local b5_base_arrow="`b5yb' `b5_base_mid'"
local b5_left_arrow="`b5_side_mid' `b5xl'"
local b5_top_arrow="`b5yt' `b5_base_mid'"


** BOX 6 very BOTTOM RIGHT **
local b6yt=`top_y'-`box_height'*3-`v_gap'*3
local b6yb=`b6yt' - `box_height'
local b6xl=`b1xl'+`box_width'*0.6 
local b6xr=`b6xl'+`box_width'
local b6_base_mid=`b6xl'+(`box_width'/2)
local b6_side_mid=`b6yt'-(`box_height'/2)
local b6_text_y=`b6yt'-3
local b6_text_x=`b6xl'+(`box_width'/2)
local b6_text_y2=`b6yt'-5

local b6bl="`b6yb' `b6xl'"
local b6tl="`b6yt' `b6xl'"
local b6br="`b6yb' `b6xr'"
local b6tr="`b6yt' `b6xr'"
local b6_base_arrow="`b6yb' `b6_base_mid'"
local b6_left_arrow="`b6_side_mid' `b6xl'"
local b6_top_arrow="`b6yt' `b6_base_mid'"

** BOX 7 very BOTTOM LEFT **
local b7yt=`top_y'-`box_height'*3-`v_gap'*3
local b7yb=`b7yt' - `box_height'
local b7xl=`b1xl'-`box_width'*0.6 
local b7xr=`b7xl'+`box_width'
local b7_base_mid=`b7xl'+(`box_width'/2)
local b7_side_mid=`b7yt'-(`box_height'/2)
local b7_text_y=`b7yt'-3
local b7_text_x=`b7xl'+(`box_width'/2)
local b7_text_y2=`b7yt'-5

local b7bl="`b7yb' `b7xl'"
local b7tl="`b7yt' `b7xl'"
local b7br="`b7yb' `b7xr'"
local b7tr="`b7yt' `b7xr'"
local b7_base_arrow="`b7yb' `b7_base_mid'"
local b7_left_arrow="`b7_side_mid' `b7xl'"
local b7_top_arrow="`b7yt' `b7_base_mid'"

*** DRAW FLOWCHART
graph twoway  /// 
 pci `b1tl' `b1tr' "Resident" `p1' mlabpos(9)|| pci `b1tl' `b1bl' `p1'  || pci `b1bl' `b1br' `p1' || pci `b1br' `b1tr' `p1'  /// /* box 1 */
,text(`b1_text_y' `b1_text_x' "{bf:Resident (`resident')}",size(9pt)) ///
,text(`b1_text_y2' `b1_text_x' "aged 15-49" "during 2005-2016",size(8pt)) ///
|| pci `b2tl' `b2tr' `p1' || pci `b2tl' `b2bl' "Not eligible" `p1' || pci `b2bl' `b2br'  `p1' || pci `b2br' `b2tr' `p1'  ////* box 2 */
,text(`b2_text_y' `b2_text_x'  "{bf:Not eligible (`notelig')}" ,size(9pt) )   ////
,text(`b2_text_y2' `b2_text_x'  "{it:Already HIV+ (`already_pos')}" "{it:Insufficient time}" "{it: in study (`not_enough_time')}" ,size(8pt) )   ////
|| pcarrowi `b1_right_arrow' `b2_left_arrow'  `p1' ///
|| pci `b3tl' `b3tr' `p1' || pci `b3tl' `b3bl' "Eligible" `p1' || pci `b3bl' `b3br'  `p1' || pci `b3br' `b3tr' `p1'  /// /* box 3 */
,text(`b3_text_y' `b3_text_x' "{bf:Eligible (`elig')}",size(9pt)) ///
,text(`b3_text_y2' `b3_text_x' "Under observation" "for ≥2 survey rounds",size(8pt)) ///
|| pcarrowi `b1_base_arrow' `b3_top_arrow'  `p1' ///
|| pci `b4tl' `b4tr' `p1' || pci `b4tl' `b4bl' "Some" `p1' || pci `b4bl' `b4br'  `p1' || pci `b4br' `b4tr' `p1'  /// /* box 4 */
|| pci `b5tl' `b5tr' `p1' || pci `b5tl' `b5bl' "Never" `p1' || pci `b5bl' `b5br'  `p1' || pci `b5br' `b5tr' `p1'  /// /* box 5 */
|| pcarrowi `b3_base_arrow' `b4_top_arrow'  `p1' ///
|| pcarrowi `b3_right_arrow' `b5_left_arrow'  `p1' ///
|| pci `b6tl' `b6tr' `p1' || pci `b6tl' `b6bl' "yp" `p1' || pci `b6bl' `b6br'  `p1' || pci `b6br' `b6tr' `p1'  /// /* box 6 */
|| pci `b7tl' `b7tr' `p1' || pci `b7tl' `b7bl' "older" `p1' || pci `b7bl' `b7br'  `p1' || pci `b7br' `b7tr' `p1'  /// /* box 7 */
|| pcarrowi `b4_base_arrow' `b6_top_arrow'  `p1' ///
|| pcarrowi `b4_base_arrow' `b7_top_arrow'  `p1' ///
,text(`b4_text_y' `b4_text_x' "{bf:Incidence cohort}" "{bf:(`some')}",size(9pt)) ///
,text(`b5_text_y' `b5_text_x' "{bf:<2 tests (`never')}",size(9pt)) ///
,text(`b7_text_y' `b7_text_x' "{bf:Aged 15-24}" "{bf:(`yp')}",size(9pt)) ///
,text(`b6_text_y' `b6_text_x' "{bf:Aged 25-49}" "{bf:(`op')}",size(9pt)) ///
,text(`title_text_y' `title_text_x' "{bf:`studyname' `sexname'}",size(11pt)) ///
,xsize(4) ysize(4) legend(off) xscale(off range(0 `axis_top')) yscale(off range(0 `axis_top')) ///
xlab(,notick nolab nogrid)  ylab(,notick nolab nogrid) xtitle("") ytitle("") 


graph export flowchart_`studyname'_`sexname'.png,width(6000) replace
graph export flowchart_`studyname'_`sexname'.eps, replace
}



*

/*
 /*
,text(`b5_text_y2' `b5_text_x' "{it:No tests (`no_test')}" "{it:One test (`one_test')}" "{it:Invalid tests (`retro')}",size(8pt) just(right)) */

********* CHART WITH 6 BOXES, TWO ON TOP, ONE IN MIDDLE, THREE ON BOTTOM ROW


local study=study_name[1]
local sex=sex[1]
local studyname:label (study) `study'
local sexname: label (sex) `sex'

*box headings
local resident=denom_people[1]
local notelig=not_eligible[1]
local elig=was_eligible[1]
local some=sometimes[1]
local never=never[1]
local all=always[1]

**sub headings
local already_pos=already_pos[1]
local not_enough_time=not_enough_time[1]
local no_test=os_1[1]
local one_test=os_2[1] 

local p1=",lcolor(black) lwidth(0.75pt) mcolor(black) mlwidth(0.75pt)"
local p2=",lcolor(black)"

local v_gap=5
local h_gap=6

local box_width=12
local box_height=5

local top_y=38
local top_x=14

local axis_y=`top_y'+2

** TITLE **
local title_text_y=`top_y'+2
local title_text_x=`top_x'+(`box_width'/2)



** BOX 1 TOP CENTRE **
local b1yt=`top_y'
local b1yb=`b1yt' - `box_height'
local b1xl=`top_x'
local b1xr=`b1xl'+`box_width'
local b1_base_mid=`b1xl'+(`box_width'/2)
local b1_side_mid=`b1yt'-(`box_height'/2)
local b1_text_y=`b1yt'-1
local b1_text_x=`b1xl'+(`box_width'/2)
local b1_text_y2=`b1yt'-3


local b1bl="`b1yb' `b1xl'"
local b1tl="`b1yt' `b1xl'"
local b1br="`b1yb' `b1xr'"
local b1tr="`b1yt' `b1xr'"
local b1_base_arrow="`b1yb' `b1_base_mid'"
local b1_right_arrow="`b1_side_mid' `b1xr'"

** BOX 2 TOP RIGHT **

local b2yt=`top_y'
local b2yb=`b2yt' - `box_height'
local b2xl=`b1xl' +`box_width'+ `h_gap'
local b2xr=`b2xl'+`box_width'
local b2_base_mid=`b2xl'+(`box_width'/2)
local b2_side_mid=`b2yt'-(`box_height'/2)
local b2_text_y=`b2yt'-1
local b2_text_x=`b2xl'+(`box_width'/2)
local b2_text_y2=`b2yt'-3

local b2bl="`b2yb' `b2xl'"
local b2tl="`b2yt' `b2xl'"
local b2br="`b2yb' `b2xr'"
local b2tr="`b2yt' `b2xr'"
local b2_base_arrow="`b2yb' `b2_base_mid'"
local b2_left_arrow="`b2_side_mid' `b2xl'"

** BOX 3 MIDDLE CENTRE **
local b3yt=`top_y'-`box_height'-`v_gap'
local b3yb=`b3yt' - `box_height'
local b3xl=`b1xl'
local b3xr=`b3xl'+`box_width'
local b3_base_mid=`b3xl'+(`box_width'/2)
local b3_side_mid=`b3yt'-(`box_height'/2)
local b3_text_y=`b3yt'-1
local b3_text_x=`b3xl'+(`box_width'/2)
local b3_text_y2=`b3yt'-3

local b3bl="`b3yb' `b3xl'"
local b3tl="`b3yt' `b3xl'"
local b3br="`b3yb' `b3xr'"
local b3tr="`b3yt' `b3xr'"
local b3_base_arrow="`b3yb' `b3_base_mid'"
local b3_right_arrow="`b3_side_mid' `b3xr'"
local b3_top_arrow="`b3yt' `b3_base_mid'"


*** BOX 4 BOTTOM CENTRE ****
local b4yt=`top_y'-`box_height'*2-`v_gap'*2
local b4yb=`b4yt' - `box_height'
local b4xl=`b1xl'
local b4xr=`b4xl'+`box_width'
local b4_base_mid=`b4xl'+(`box_width'/2)
local b4_side_mid=`b4yt'-(`box_height'/2)
local b4_text_y=`b4yt'-1
local b4_text_x=`b4xl'+(`box_width'/2)
local b4_text_y2=`b4yt'-3

local b4bl="`b4yb' `b4xl'"
local b4tl="`b4yt' `b4xl'"
local b4br="`b4yb' `b4xr'"
local b4tr="`b4yt' `b4xr'"
local b4_base_arrow="`b4yb' `b4_base_mid'"
local b4_right_arrow="`b4_side_mid' `b4xr'"
local b4_top_arrow="`b4yt' `b4_base_mid'"

** BOX 5 BOTTOM LEFT **
local b5yt=`top_y'-`box_height'*2-`v_gap'*2
local b5yb=`b5yt' - `box_height'
local b5xl=`b1xl'-`box_width'-`h_gap'
local b5xr=`b5xl'+`box_width'
local b5_base_mid=`b5xl'+(`box_width'/2)
local b5_side_mid=`b5yt'-(`box_height'/2)
local b5_text_y=`b5yt'-1
local b5_text_x=`b5xl'+(`box_width'/2)
local b5_text_y2=`b5yt'-3

local b5bl="`b5yb' `b5xl'"
local b5tl="`b5yt' `b5xl'"
local b5br="`b5yb' `b5xr'"
local b5tr="`b5yt' `b5xr'"
local b5_base_arrow="`b5yb' `b5_base_mid'"
local b5_right_arrow="`b5_side_mid' `b5xr'"
local b5_top_arrow="`b5yt' `b5_base_mid'"


** BOX 6 BOTTOM RIGHT **
local b6yt=`top_y'-`box_height'*2-`v_gap'*2
local b6yb=`b6yt' - `box_height'
local b6xl=`b1xl'+`box_width'+`h_gap'
local b6xr=`b6xl'+`box_width'
local b6_base_mid=`b6xl'+(`box_width'/2)
local b6_side_mid=`b6yt'-(`box_height'/2)
local b6_text_y=`b6yt'-1
local b6_text_x=`b6xl'+(`box_width'/2)
local b6_text_y2=`b6yt'-3

local b6bl="`b6yb' `b6xl'"
local b6tl="`b6yt' `b6xl'"
local b6br="`b6yb' `b6xr'"
local b6tr="`b6yt' `b6xr'"
local b6_base_arrow="`b6yb' `b6_base_mid'"
local b6_left_arrow="`b6_side_mid' `b6xl'"
local b6_top_arrow="`b6yt' `b6_base_mid'"


*** DRAW FLOWCHART
graph twoway  /// 
 pci `b1tl' `b1tr' "Resident" `p1' mlabpos(9)|| pci `b1tl' `b1bl' `p1'  || pci `b1bl' `b1br' `p1' || pci `b1br' `b1tr' `p1'  /// /* box 1 */
,text(`b1_text_y' `b1_text_x' "{bf:Resident (`resident')}",size(12pt)) ///
,text(`b1_text_y2' `b1_text_x' "aged 15-49" "during 2005-2016",size(11pt)) ///
|| pci `b2tl' `b2tr' `p1' || pci `b2tl' `b2bl' "Not eligible" `p1' || pci `b2bl' `b2br'  `p1' || pci `b2br' `b2tr' `p1'  ////* box 2 */
,text(`b2_text_y' `b2_text_x'  "{bf:Not eligible (`notelig')}" ,size(12pt) )   ////
,text(`b2_text_y2' `b2_text_x'  "{it:Already HIV+ (`already_pos')}" "{it:Insufficient time in study (`not_enough_time')}" ,size(11pt) )   ////
|| pcarrowi `b1_right_arrow' `b2_left_arrow'  `p1' ///
|| pci `b3tl' `b3tr' `p1' || pci `b3tl' `b3bl' "Eligible" `p1' || pci `b3bl' `b3br'  `p1' || pci `b3br' `b3tr' `p1'  /// /* box 3 */
,text(`b3_text_y' `b3_text_x' "Eligible (`elig')",size(12pt)) ///
|| pcarrowi `b1_base_arrow' `b3_top_arrow'  `p1' ///
|| pci `b4tl' `b4tr' `p1' || pci `b4tl' `b4bl' "Some" `p1' || pci `b4bl' `b4br'  `p1' || pci `b4br' `b4tr' `p1'  /// /* box 4 */
|| pci `b5tl' `b5tr' `p1' || pci `b5tl' `b5bl' "Never" `p1' || pci `b5bl' `b5br'  `p1' || pci `b5br' `b5tr' `p1'  /// /* box 5 */
|| pci `b6tl' `b6tr' `p1' || pci `b6tl' `b6bl' "All" `p1' || pci `b6bl' `b6br'  `p1' || pci `b6br' `b6tr' `p1'  /// /* box 6 */
|| pcarrowi `b3_base_arrow' `b4_top_arrow'  `p1' ///
|| pcarrowi `b3_base_arrow' `b5_top_arrow'  `p1' ///
|| pcarrowi `b3_base_arrow' `b6_top_arrow'  `p1' ///
,text(`b4_text_y' `b4_text_x' "{bf:In incidence cohort (`some')}",size(12pt)) ///
,text(`b5_text_y' `b5_text_x' "{bf:Fewer than 2 tests (`never')}",size(12pt)) ///
,text(`b5_text_y2' `b5_text_x' "{it:No tests (`no_test')}" "{it:One test (`one_test')}",size(11pt) just(right)) ///
,text(`b6_text_y' `b6_text_x' "All time in cohort (`all')",size(12pt)) ///
,text(`title_text_y' `title_text_x' "`studyname' `sexname' ",size(16pt)) ///
,xsize(10) ysize(10) legend(off) xscale(range(0 `axis_top')) yscale(range(0 `axis_top')) ///
xlab(,notick nolab nogrid)  ylab(,notick nolab nogrid) xtitle("") ytitle("")
