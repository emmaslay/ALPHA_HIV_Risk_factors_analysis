*This will make all the folders you need set up to be able to run the ALPHA data sharing do files 
*It will copy the files from the compressed folder we sent into the correct folders on your computer

*+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=
*+=+=+=  THINGS YOU NEED TO SET BEFORE RUNNING THE DO FILE +=+=+=+=
*set sitename - you must use the ALPHA sitename, as used in the filenames within the zip file
global sitename "Pooled"
*set the path to the drive/directory where you want to create the ALPHA folder and all the sub-folders
global alphapath "L:/test_risk"
*set the location of the zip file 
global zip_location "L:\test_risk/ALPHA_risk_factors_analysis.zip"


*+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=
*+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=

**************************************************
*	INSTALL USER WRITTEN COMMANDS
/**************************************************
*The do files that will be used call on two user-written commands that you may need to install
cap ssc install egenmore 
cap ssc install stpm2
*/
**************************************************
*	CREATE THE FOLDER STRUCTURE
**************************************************

*cd to where you want the new folders set up
cd ${alphapath}

*Make an ALPHA folder and go to it
cap mkdir ALPHA
cd ALPHA

	*Make the next level of directories
	cap mkdir clean_data
	cap mkdir Data_sharing
	cap mkdir DoFiles
	cap mkdir Estimates_incidence
	cap mkdir Estimates_mortality
	cap mkdir Incidence_ready_data
	cap mkdir prepared_data
	cap mkdir Prepared_data_documentation
	cap mkdir Ready_data_mortality

	*Within each directory, add in the sub-folders
	cd clean_data
		cap mkdir "${sitename}"
	cd ..
	cd Data_sharing
		cap mkdir DataFirst
		cd DataFirst
			cap mkdir ALPHA_information
			cap mkdir Blank_paperwork
			cd ..

		cap mkdir Incidence_data_for_sharing

		cap mkdir Mortality_data_for_sharing
		cd Mortality_data_for_sharing
			cap mkdir "${sitename}"
			cap mkdir dobs
			cd ..

		cap mkdir results_comparison
		cd results_comparison
			cap mkdir Incidence
			cap mkdir mortality
			cd ..

		cap mkdir dobs

		cap mkdir Study_forms_and_Doc
		cd ..

	cap mkdir DoFiles
	cd DoFiles
		cap mkdir Analysis
		cap mkdir Common
		cap mkdir Data_for_sharing
		cap mkdir Document
		cap mkdir Prepare_data
		cd ..

	cap mkdir Estimates_Incidence
	cd Estimates_Incidence
		cap mkdir Midpoint_rates
		cap mkdir Post_negative_times
		cd ..

	cap mkdir Estimates_mortality
	cd Estimates_mortality
		cap mkdir "${sitename}"
		cd ..

	cap mkdir Incidence_ready_data
	cd Incidence_ready_data
		cap mkdir "${sitename}"
		cd ..

	cap mkdir Prepared_data
	cd Prepared_data
		cap mkdir "${sitename}"
		cd ..

	cap mkdir Prepared_data_documentation
	cd Prepared_data_documentation
		cap mkdir "${sitename}"
		cd ..

	cap mkdir Ready_data_mortality
	cd Ready_data_mortality
		cap mkdir "${sitename}"
		cd ..

	cap mkdir Projects
	cd Projects
		cap mkdir flowchart
		cap mkdir Gates_incidence_risks_2019
		cd Gates_incidence_risks_2019
		cap mkdir Results
		cd Results
		cap mkdir "${sitename}"
		cap mkdir for_paper
		cd ..
		cap mkdir paper
		cd paper
		cap mkdir "Tables and graphs"
		

***********************************************************************************
** 	 		COPY OVER FILES
***********************************************************************************
cd ${alphapath}/ALPHA

unzipfile ${zip_location},replace


** do files

copy "${alphapath}/ALPHA/Make_analysis_file_untreated_prevalence.do" "${alphapath}/ALPHA\DoFiles\Analysis/Make_analysis_file_untreated_prevalence.do"  ,replace
copy "${alphapath}/ALPHA/Make_analysis_file_sexual_partnership_dynamic.do" "${alphapath}/ALPHA\DoFiles\Analysis/Make_analysis_file_sexual_partnership_dynamic.do"  ,replace
copy "${alphapath}/ALPHA/Get_opp_sex_ASPAR.do" "${alphapath}/ALPHA\Projects\Gates_incidence_risks_2019\Get_opp_sex_ASPAR.do"   ,replace
copy "${alphapath}/ALPHA/Get_opp_sex_losses.do" "${alphapath}/ALPHA\Projects\Gates_incidence_risks_2019\Get_opp_sex_losses.do"  ,replace
copy "${alphapath}/ALPHA/Make_analysis_file_incidence_risk_factors.do" "${alphapath}/ALPHA\DoFiles\Analysis/Make_analysis_file_incidence_risk_factors.do"  ,replace
copy "${alphapath}/ALPHA/Pool_analysis_file_incidence_risk_factors_ready_mi.do" "${alphapath}/ALPHA\DoFiles\Analysis/Pool_analysis_file_incidence_risk_factors_ready_mi.do"  ,replace
copy "${alphapath}/ALPHA/Look_at_loss_to_follow_up_and_participation_incidence.do" "${alphapath}/ALPHA\DoFiles\Analysis/Look_at_loss_to_follow_up_and_participation_incidence.do"  ,replace
copy "${alphapath}/ALPHA/Get_risk_factor_prevalences_from_pooled_for_paper_table.do" "${alphapath}/ALPHA\Projects\Gates_incidence_risks_2019/Get_risk_factor_prevalences_from_pooled_for_paper_table.do"  ,replace

copy "${alphapath}/ALPHA/Get_pooled_numbers_from_MI_for_risk_paper_text.do" "${alphapath}/ALPHA\Projects\Gates_incidence_risks_2019\Get_pooled_numbers_from_MI_for_risk_paper_text.do"  ,replace

copy "${alphapath}/ALPHA/estimate_site_crude_risk_HR.do" "${alphapath}/ALPHA\Projects\Gates_incidence_risks_2019/Estimate_site_crude_risk_HR.do"  ,replace

copy "${alphapath}/ALPHA/estimate_pooled_site_adjusted_risk_HR.do" "${alphapath}/ALPHA\Projects\Gates_incidence_risks_2019/estimate_pooled_site_adjusted_risk_HR.do"  ,replace

copy "${alphapath}/ALPHA/Prepare_dataset_of_crude_risk_HR_for_table.do" "${alphapath}/ALPHA\Projects\Gates_incidence_risks_2019/Prepare_dataset_of_crude_risk_HR_for_table.do"  ,replace

copy "${alphapath}/ALPHA/Make_pooled_crude_HR_table_in_word.do" "${alphapath}/ALPHA\Projects\Gates_incidence_risks_2019/Make_pooled_crude_HR_table_in_word.do"  ,replace

copy "${alphapath}/ALPHA/Make_crude_HR_green_red_table_in_word.do" "${alphapath}/ALPHA\Projects\Gates_incidence_risks_2019/Make_crude_HR_green_red_table_in_word.do"  ,replace

copy "${alphapath}/ALPHA/Estimate_pooled_models_with_site_interactions_where_needed.do" "${alphapath}/ALPHA\Projects\Gates_incidence_risks_2019\Estimate_pooled_models_with_site_interactions_where_needed.do"  ,replace

copy "${alphapath}/ALPHA/exploring_pooled_model_hazards.do" "${alphapath}/ALPHA\Projects\Gates_incidence_risks_2019\exploring_pooled_model_hazards.do"   ,replace

copy "${alphapath}/ALPHA/estimate_pooled_final_models2024.do" "${alphapath}/ALPHA\Projects\Gates_incidence_risks_2019/estimate_pooled_final_models2024.do"  ,replace

copy "${alphapath}/ALPHA/playing_with_meta_analysis.do" "${alphapath}/ALPHA\Projects\Gates_incidence_risks_2019/playing_with_meta_analysis.do"  ,replace

copy "${alphapath}/ALPHA/Estimate_pooled_final_models_with_ASPAR.do" "${alphapath}/ALPHA\Projects\Gates_incidence_risks_2019/Estimate_pooled_final_models_with_ASPAR.do" ,replace

copy "${alphapath}/ALPHA/plot_adjusted_all_in_models.do " "${alphapath}/ALPHA\Projects\Gates_incidence_risks_2019/plot_adjusted_all_in_models.do" ,replace

copy "${alphapath}/ALPHA/Risk_factor_master.do" "${alphapath}/ALPHA\Projects\Gates_incidence_risks_2019/Risk_factor_master.do"  ,replace



***********************************************************************************
** 	 		DELETE EXTRACTED FILES FROM THE ROOT
***********************************************************************************

** do files
cap erase "${alphapath}/ALPHA/Make_analysis_file_untreated_prevalence.do" 
cap erase "${alphapath}/ALPHA/Make_analysis_file_sexual_partnership_dynamic.do" 
cap erase "${alphapath}/ALPHA/Get_opp_sex_ASPAR.do" 
cap erase "${alphapath}/ALPHA/Get_opp_sex_losses.do" 
cap erase "${alphapath}/ALPHA/Make_analysis_file_incidence_risk_factors.do" 
cap erase "${alphapath}/ALPHA/Pool_analysis_file_incidence_risk_factors_ready_mi.do" 
cap erase "${alphapath}/ALPHA/Look_at_loss_to_follow_up_and_participation_incidence" 
cap erase "${alphapath}/ALPHA/Get_risk_factor_prevalences_from_pooled_for_paper_table.do" 

cap erase "${alphapath}/ALPHA/Get_pooled_numbers_from_MI_for_risk_paper_text.do" 

cap erase "${alphapath}/ALPHA/stimate_site_crude_risk_HR.do" 

cap erase "${alphapath}/ALPHA/estimate_pooled_site_adjusted_risk_HR.do" 

cap erase "${alphapath}/ALPHA/Prepare_dataset_of_crude_risk_HR_for_table.do" 

cap erase "${alphapath}/ALPHA/Make_pooled_crude_HR_table_in_word.do" 

cap erase "${alphapath}/ALPHA/Make_crude_HR_green_red_table_in_word.do" 

cap erase "${alphapath}/ALPHA/Estimate_pooled_models_with_site_interactions_where_needed.do" 

cap erase "${alphapath}/ALPHA/exploring_pooled_model_hazards.do" 

cap erase "${alphapath}/ALPHA/estimate_pooled_final_models2024.do" 

cap erase "${alphapath}/ALPHA/playing_with_meta_analysis.do" 

cap erase "${alphapath}/ALPHA/Estimate_pooled_final_models_with_ASPAR.do" 

cap erase "${alphapath}/ALPHA/plot_adjusted_all_in_models.do " 

cap erase "${alphapath}/ALPHA/Risk_factor_master.do" 
