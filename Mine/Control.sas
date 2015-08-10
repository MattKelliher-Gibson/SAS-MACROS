%macro Control_beta(dataset=, seed=, total_mailing=, response_rate=, control_preselect=, branch=branch, effect=0.15, alpha=0.05, power=0.5);
%*****************************************************************************
******************************************************************************
** MACRO: Control															**
** Purpose:	Calculate and pull a control group				 				**
**			for a dataset													**
** Created: 02/12/2014														**
** Created by: Matthew Kelliher-Gibson										**
** Last Modified: 08/14/2014												**
** Stage: BETA																**
** Parameters:																**
**		Dataset -			Input Dataset									**
**		seed - 				Seed number for proc surveyselect				**
**		total_mailing -		Total expected mailings for control				**
**								calculation									**
**		response_rate -		Expected response rate for mailings				**
**		control_preselect -	Preselected Control Quantity					**
**		branch - (branch) 	variable in dataset that inlcudes				**
**								branch name or number (must be character)	**
**		alpha - (.05) 		Type I Error allowance							**
**		power - (.5) 		Type II Error allowance							**
** MACROS Used:																**
**		%Zero_Check															**
**		%Data_Error															**
**		%Invalid_Char_Loop													**
**		%Invalid_Char_Window												**
**		%Null																**
**		%Null_Window														**
**		%Stat_Check															**
**		%Stat_Default_Window												**
**		%Stat_Range_Window													**
**		%Terminate															**
**		%Repeat																**
**		%N_E_W																**
******************************************************************************
******************************************************************************;

%*********************************************************************************************************
**********************************************************************************************************
** Version History:																						**
** 1.0.0 - 02/12/2014 - Original File Created															**
** 2.0.0 - 04/23/2014 - Complete Re-write with Proc SureveySelect										**
** 2.1.0 - 04/25/2014 - Added Quality Controls															**
** 2.2.0 - 04/28/2014 - Added Control Function to Calaculate Control Group Size							**
** 3.0.0 - 04/28/2014 - Added MACRO Windows for EFFECT and CONTROL_DATASET								**
** 3.1.0 - 04/29/2014 - Added MACRO Windows for all other Parameters									**
** 4.0.0 - 05/15/2014 - Changed calculation, added min/max, and added checks							**
** 4.1.0 - 05/16/2014 - Added Branch Check and other improvements and fixes								**
** 4.2.0 - 05/17/2014 - Change Control to flag instead of different dataset and MACRO Window updates	**
** 4.2.1 - 05/18/2014 - Fixed errors, adding more parameter and data step checks						**
** 5.0.0 - 06/06/2014 - Added Dynamic MACROs, added more parameter and data step/proc checks			**
** 5.0.1 - 06/20/2014 - Fixed Minor Errors and Changed Custom NOTES, WARNING, and ERROR Messages		**
** 5.0.2 - 06/23/2014 - Minor Fixes and Development Notes Added											**
** 5.1.0 - 07/29/2014 - Replaced Notes/Errors/Warning Messages with N_E_W MACROS						**
** 5.2.0 - 07/30/2014 - Moved MACROS to Separate Files and Replaced with Conditional %Includes			**
** 5.2.1 - 08/13/2014 - Minor Updates and Clean up														**
** 5.3.0 - 12/01/2014 - Added Control Pre-Selection Parameter											**
**********************************************************************************************************
**********************************************************************************************************;

%put NOTE: %str(********************************************************************************);
%put %str(  	Begin Processesing!);
%put NOTE: %str(********************************************************************************);
%put ;
%put ;

%********************
*I. MACRO WINDOWS	*
*********************;

	%*A. Dataset;

		%window dataset_check_invalid_char
			#3 @5 "ERROR:" color=red
			#5 @5 "Dataset Name Contains an Invalid Character:" +2 dataset_check_invalid_char color=blue attr=rev_video protect=yes
			#7 @5 "Please Enter a Valid Dataset Name Below and press " color=black "[ENTER]" color=pink attr=rev_video
			#9 @5 "OR Leave Blank and Press " color=black "[ENTER]" color=pink attr= rev_video " to Terminate Program." color=black
			#11 @5 dataset_check_invalid_new 32 color=blue attr=underline
		;

		%window data_guess_1char_1
			#3 @5 "ERROR:" color=red attr=highlight
			#5 @5 "Data Table Name Begins with Invalid Character:" +2 data2 1 color=blue attr=rev_video protect=yes
			#7 @5 "Data Table Names May ONLY Begin with Letter or ""_""."
			#9 @5 "Do You Want to Drop Invalid Character from Data Table Name?" 
			#11 @5 "If Yes Leave Blank and Press " color=black "[ENTER]" color=pink attr=rev_video
			#13 @5 "If Not Type " color=black """NO""" color=blue attr=rev_video " and Press " color=black "[ENTER]" color=pink attr=rev_video
			#15 @5 data_guess_1char_1_no 2 color=blue attr=underline
			#17 @5 "OR Type " color=black """ABORT""" color=red attr=rev_video " Below and Press " color=black "[ENTER]" color=pink attr= rev_video " to Terminate Program." color=black
			#19 @5 data_guess_1c_abort 5 color=red attr=rev_video
		;

		%window data_guess_1char_2
			#3 @5 "WARNING:" color=green
			#5 @5 "Do You want to Put an ""_"" at Beginning of Data Table Name?"
			#7 @5 "If Yes Leave Blank and Press " color=black "[ENTER]" color=pink attr=rev_video
			#9 @5 "If Not Type " color=black """ABORT""" color=red attr=rev_video " Below and Press " color=black "[ENTER]" color=pink attr= rev_video " to Terminate Program." color=black
			#11 @5 data_guess_1c_abort 5 color=red attr=rev_video
		;

		%window data_guess_name
			#3 @5 "WARNING:" color=green " Data Table Name Contains Invalid Character!" color=black
			#5 @5 "Data Table Name Contains Periods (.)"
			#7 @5 "Should Data Table Name Be:"
			#9 @5 data color=blue attr=rev_video protect=yes
			#11 @5 "If Yes Leave Blank and Press " color=black "[ENTER]" color=pink attr=rev_video
			#13 @5 "If Not Type " color=black """ABORT""" color=red attr=rev_video " Below and Press " color=black "[ENTER]" color=pink attr= rev_video " to Terminate Program." color=black
			#15 @5 data_guess_name_abort 5 color=red attr=rev_video
		;

	%*B. Seed;

		%window seed_check_null
			#3 @5 "ERROR:" color=red
			#5 @5 "You Did NOT Enter a SEED Number!"
			#7 @5 "Please Enter a SEED Number and press " color=black "[ENTER]" color=pink attr=rev_video
			#9 @5 "OR leave blank and press " color=black "[ENTER]" color=pink attr=rev_video " for a SEED to be assigned."
			#11 @5 seed_check_null 10 attr=underline color=blue
		;

	%*C. Response Rate;

		%window rr_check_guess
			#3 @5 "ERROR:" color=red
			#5 @5 "RESPONSE RATE was Out of Range"
			#7 @5 "RESPONSE RATE was Adjusted to:" +1 response_rate color=blue attr=rev_video protect=yes
			#9 @5 "If RESPONSE RATE Correct Leave Blank and Press " color=black "[ENTER]" color=pink attr=rev_video
			#11 @5 "If Not Type " color=black """ABORT""" color=red attr=rev_video " Below and Press " color=black "[ENTER]" color=pink attr= rev_video " to Terminate Program." color=black
			#13 @5 rr_guess_abort 6 attr=underline color=blue
		;

		%window rr_check_high
			#3 @5 "WARNING:" color=green
			#5 @5 "RESPONSE RATE Appears Too High at:" +1 response_rate color=blue attr=rev_video protect=yes
			#7 @5 "Did You Mean:" +1 rr_guess_correct color=blue attr=rev_video protect=yes +1 "?" color=black
			#9 @5 "Re-Enter the Correct RESPONSE RATE Below and Press " color=black "[ENTER]" color=pink attr=rev_video
			#11 @5 "If Not Type " color=black """ABORT""" color=red attr=rev_video " Below and Press " color=black "[ENTER]" color=pink attr= rev_video " to Terminate Program." color=black
			#13 @5 rr_check_high 6 color=blue attr=underline required=yes
		;

	%*D. Effect;
		
		%window effect_check
			#3 @5 "WARNING:" color=green
			#5 @5 "EFFECT Entered Larger than 1 (100%)!"
			#7 @5 "EFFECT should be between 0 and 1."
			#9 @5 "Current EFFECT Value was corrected to :" +2 effect attr=underline protect=yes
			#11 @5 "If Above Value is Correct Leave Blank and Press " color=black "[ENTER]" color=pink attr=rev_video
			#13 @5 "If Not Type " color=black """ABORT""" color=red attr=rev_video " Below and Press " color=black "[ENTER]" color=pink attr= rev_video " to Terminate Program." color=black
			#15 @5 effect_new_2 5 color=blue attr=underline
		;

		%window effect_check_range
			#3 @5 "WARNING:" color=green
			#5 @5 "EFFECT is Abnormally High."
			#7 @5 "Current EFFECT of " effect attr=underline protect=yes color=blue
			#9 @5 "Would Require an Absolute Difference Between Reponse Rates of " effect_check_size attr=underline color=blue protect=yes "%"
			#11 @5 "Typical EFFECT Values are between 10%-20%."
			#13 @5 "To Replace with EFFECT Default Value (15%) Leave Blank Below and Press " color=black "[ENTER]" color=pink attr=rev_video
			#15 @5 "To Keep Current or Change Current Effect (Re-)Type Below and Press " color=black "[ENTER]" color=pink attr=rev_video
			#17 @5 effect_check_range_new 4 color=blue attr=underline
			#19 @5 "OR Type " color=black """ABORT""" color=red attr=rev_video " Below and Press " color=black "[ENTER]" color=pink attr= rev_video " to Terminate Program." color=black
			#21 @5 effect_check_range_abort 5 color=red attr=rev_video
		;

	%*E. Control_qty;

		%window control_qty
			#3 @5 "WARNING:" color=green
			#5 @5 "The Calculated Control Size Quantity is Too Big!" color=green
			#7 @5 "Calculated Control is:" +2 control color=blue attr=underline protect=yes
			#9 @5 "Total Records in Universe is:" +2 total color=blue attr=underline protect=yes
			#11 @5 "Total Mailing is:" +2 total_mailing color=blue attr=underline protect=yes
			#13 @5 "If You Would Like to Use Remaining Qty of" +2 remaining_qty color=blue attr=underline protect=yes +2 "Type 'Yes' below and Press " color=black "[ENTER]" color=pink attr= rev_video
			#15 @5 "If Not, Leave Blank and Press " color=black "[ENTER]" color=pink attr= rev_video " to Terminate Program"
			#17 @5 use_remaining 3 color=blue attr=underline
		;

	%*F. Branch;

		%window branch_check_exist
			#3 @5 "ERROR:" color=red
			#5 @5 "Variable " color=red +1 branch color=blue attr=underline protect=yes +2 "Does NOT Exist on Dataset!" color=red
			#7 @5 "Branch Control Quantity CANNOT be checked!"
			#9 @5 "Please Enter a New Variable for BRANCH and press " color=black "[ENTER]" color=pink attr=rev_video
			#11 @5 "OR Leave Blank and Press " color=black "[ENTER]" color=pink attr=rev_video " to Terminate Program."
			#13 @5 branch_exist_new 32 color=blue attr=underline
		;

	%*G. Loop_Error;
		
		%window loop_error
			#3 @5 "ERROR:" color=red
			#5 @5 "After 10 Tries Unable to get atleast 50 records for each branch."
			#7 @5 "Would you like to continue anyway?"
			#9 @5 "If so type YES below and press " "[ENTER]" color=red
			#11 @5 loop_escape 3 color=blue attr=underline
			#13 @5 "OR Leave Blank and Press [ENTER] to ABORT."
		;

%************
*II. MACROS	*
*************;

	%*A. Zero_Check;

		%if %sysmacexist(zero_check) = 0
		%then
			%include "T:\MKG\MACROS\GENERAL\Control MACROS\Zero_Check.sas";;

	%*B. Terminate;

		%if %sysmacexist(terminate) = 0
		%then
			%include "T:\MKG\MACROS\GENERAL\Control MACROS\Terminate.sas";;

	%*C. Invalid Character Window;

		%if %sysmacexist(invalid_char_window) = 0
		%then
			%include "T:\MKG\MACROS\GENERAL\Control MACROS\Invalid_Char_Window.sas";;

	%*D. Invalid Character Loop;

		%if %sysmacexist(Invalid_Char_Loop) = 0
		%then
			%include "T:\MKG\MACROS\GENERAL\Control MACROS\Invalid_Char_Loop.sas";;

	%*E. Null;

		%if %sysmacexist(null) = 0
		%then
			%include "T:\MKG\MACROS\GENERAL\Control MACROS\null.sas";;

	%*F. Null_Window;

		%if %sysmacexist(null_window) = 0
		%then
			%include "T:\MKG\MACROS\GENERAL\Control MACROS\null_window.sas";;

	%*G. Data_Error;

		%if %sysmacexist(data_error) = 0
		%then
			%include "T:\MKG\MACROS\GENERAL\Control MACROS\data_error.sas";;

	%*H. Stat_Check;

		%if %sysmacexist(stat_check) = 0
		%then
			%include "T:\MKG\MACROS\GENERAL\Control MACROS\Stat_Check.sas";;

	%*I. Stat_Default_Window;

		%if %sysmacexist(stat_default_window) = 0
		%then
			%include "T:\MKG\MACROS\GENERAL\Control MACROS\Stat_Default_Window.sas";;

	%*J. State_Range_Window;

		%if %sysmacexist(stat_range_window) = 0
		%then
			%include "T:\MKG\MACROS\GENERAL\Control MACROS\Stat_Range_Window.sas";;

	%*K. N_E_W;
	
		%if %sysmacexist(N_E_W) = 0
		%then
			%include "T:\MKG\MACROS\GENERAL\N_E_W.sas";;

	%*L. Repeat;
	
		%if %sysmacexist(Repeat) = 0
		%then
			%include "T:\MKG\MACROS\GENERAL\Repeat.sas";;

%****************************
*III. SET DEFAULT VALUES	*
*****************************;

	%*A. Set Null Value;

		%let null= ;

	%*B. Set Loop Value;

		%let loop_number=1;

	%*C. Character Values;

		%let abc = ABCDEFGHIJKLMNOPQRSTUVWXYZ_;

		%let numeric = 1234567890.;

		%let everything = &abc.&numeric;

	%put ;
	%put NOTE: %repeat(*,80);
	%N_E_W(Begin Parameter Checks!, type=N);
	%put NOTE: %repeat(*,80);
	%put ;
	%put ;

%************************
*IV. CHECK PARAMETERS	*
*************************;

	%*A. Input Dataset;

		%*1. Check if NULL;

			%null(dataset);

		%*2. Check if Name has Valid Characters;

			%let dataset_loop_valid_char = FASLSE;
			%do %until(&dataset_loop_valid_char = TRUE); /* 1 valid loop */
				%let dataset_check_valid_char = %verify(%upcase(%str(&dataset)),&everything);
				%if &dataset_check_valid_char gt 0
				%then
					%do; /* 2 OPEN w/ 1 OPEN*/
						%let dataset_check_invalid_char = %substr(&dataset,&dataset_check_valid_char,1);

						%N_E_W(Invalid character in dataset|"&dataset_check_invalid_char" not valid character|
								Display Window, type=W);

						%display dataset_check_invalid_char;

						%if %str(&dataset_check_invalid_new) eq &null
						%then
							%terminate;
						%else
							%do; /*4 OPEN  w/ 1,2 OPEN */
								%let dataset = %str(%upcase(&dataset_check_invalid_new));
								%let dataset_check_invalid_new = &null;
							%end;  /* 4 CLOSE w/ 1,2 OPEN */
					%end; /* 2 CLOSE w/ 1 OPEN */
				%else
					%let dataset_loop_valid_char = TRUE;
			%end; /* 1 CLOSE */

		%*3. Check Library and Data Names;

			%if %sysfunc(findc(%str(&dataset), ".")) gt 0
			%then
				%do; /* 5 OPEN */
					%let lib = %scan(&dataset, 1);
					/*%put &lib;*/

					%if %length(&lib) gt 8
					%then
						%do; /* 6 OPEN w/ 5 OPEN */
							%N_E_W(Library name too long!|Library Name is %length(&lib) characters long|Name must be 8 characters or less, type=E);
							%return;
							/* ---------------------------------------------------------------------> Create Window to take new library value */
						%end; /* 6 CLOSE w/ 5 OPEN */
					%else
						%do; /* 7 OPEN w/ 5 OPEN */
							%let lib_check_1char = %verify(%upcase(%substr(&lib,1,1)), &abc);
							/*%put &lib_check_1char;*/

							%if &lib_check_1char gt 0
							%then
								%do; /* 11 OPEN w/ 5,7 OPEN */
									%N_E_W(Library name MUST begin with letter or "_"|"%substr(&lib,1,1)" is not a valid character, type=E);
									%return;
									/* -------------------------------------------------------------> Create Window to fix library value */
								%end; /* 11 CLOSE w/ 5,7 OPEN */
							%else
								%if (%sysfunc(libref(&lib))) gt 0
								%then
									%do; /* 8 OPEN w/ 5,7 OPEN */
										%N_E_W(Library "&lib" does NOT Exist, type=E);
										%return;
										/* ---------------------------------------------------------> Create Window to take new value */
									%end; /* 8 CLOSE w/ 5,7 OPEN */
						%end; /* 7 CLOSE w/ 5 OPEN */

					%let data = %scan(&dataset, -1);
					/*%put &data;*/
					%let data2 = %scan(&dataset, 2);
					/*%put &data2;*/
					%if %str(&data) ne %str(&data2)
					%then
						%let data_check_equal = 1;
					%else
						%let data_check_equal = 0;

					%let data_check_1char = %verify(%upcase(%substr(&data2,1,1)), &abc);
					/*%put &data_check_1char;*/

					%if &data_check_1char gt 0
					%then
						%do; /* 12 OPEN w/ 5 OPEN */
							%N_E_W(Dataset name must begin with letter or "_"|"%substr(&data2,1,1)" is not a valid character|Display Window, type=W);
							%put ;

							%let length= %length(&data2);
							%let length2 = %eval(&length*1);
							%let length3 = %eval(&length2 - 1);
							%let data_guess_1char_1 = %substr(&data2., 2, &length3.);

							%display data_guess_1char_1; 

							%if &data_guess_1c_abort ne &null
							%then
								%terminate;
							%else
								%do; /* 17 OPEN w/ 5,12 OPEN */
									%if &data_guess_1char_1_no ne &null
									%then
										%do; /* 18 OPEN w/ 5,12,17 OPEN */
											%let data_guess_1char_2 = %str(_&data2);

											%N_E_W(Dataset "%upcase(&data2)" Still Begins with Invalid Character|Display Window, type=W);
											%put ;

											%display data_guess_1char_2; 

											%if &data_guess_1c_abort ~= &null
											%then
												%terminate;
											%else
												%let data2 = &data_guess_1char_2;
										%end; /*18 CLOSE w/ 5,12,17 OPEN */
									%else
										%let data2 = &data_guess_1char_1;
								%end; /* 17 CLOSE w/ 5,12 OPEN */
						%end; /* 12 CLOSE w/ 5 OPEN */

					%let data_check_length = %length(%substr(&dataset,%length(&lib),%eval(%length(&dataset)-%length(&lib))));

					%if &data_check_length gt 32
					%then
						%do; /* 10 OPEN w/ 5 OPEN */
							%N_E_W(Dataset Name is too long!|Dataset Name is %length(&data) characters long|Nume must be 32 character or less, type=E);
							%return;
							/* ----------------------------------------------------------------------> Add Window to fix dataset */
						%end; /* 10 CLOSE w/ 5 OPEN */

					%if &data_check_equal = 1
					%then
						%do; /* 8 OPEN w/ 5 OPEN */
							%let l = 3;
							%let data_loop_name = FALSE;

							%do %until(&data_loop_name eq TRUE); /* 19 OPEN w/ 5,8 OPEN */
								%let data&l = %str(%scan(&dataset, &l));
								%if &data eq &&data&l
								%then
									%let data_loop_name = TRUE;
								%else
									%let l = %eval(&l +1);
							%end; /* 19 CLOSE w/ 5,8 OPEN */

							%do q=3 %to &l; /* 20 OPEN w/ 5,8 OPEN */
								%if &q = 3
								%then 
									%let data = &data2._&&data&q;
								%else
									%let data = &data._&&data&q;
							%end; /* 20 CLOSE w/ 5,8 OPEN */

							%display data_guess_name; 

							%if &data_guess_name_abort ne &null
							%then
								%terminate;
						%end; /* 8 CLOSE w/ 5 OPEN */
					%else
						%let data = &data2;

					%if %sysfunc(exist(&lib..&data, data)) = 1
					%then
						%do; /* 23 OPEN w/ 5, OPEN */
							%let dataset = &lib..&data;
							%N_E_W(Dataset "%upcase(&data)" Exists in Library "%upcase(&lib)", type=N);
							%put ;
						%end; /* 23 CLOSE w/ 5, OPEN */
					%else
						%do; /* 21 OPEN w/ 5 OPEN */
							%N_E_W(Dataset "%upcase(&data)" does NOT Exist in Library "%upcase(&lib)", type=E);
							%return;
							/* ----------------------------------------------------------> Create Window to take new value */
						%end; /* 21 CLOSE w/ 5 OPEN */
				%end; /* 5 CLOSE */
			%else
				%do; /* 13 OPEN */
					%let dataset_check_work = %verify(%upcase(%substr(&dataset,1,1)), &abc);

					%if &dataset_check_work gt 0
					%then
						%do; /* 14 OPEN w/ 13 OPEN */
							%N_E_W(Dataset Name Must Begin with a Letter or "_"|"%substr(&dataset,1,1)" is NOT a Valid Character, type=E);
							%return;
							/* ------------------------------------------------------------------> Create Window to fix or take new value */
						%end; /* 14 CLOSE w/ 13 OPEN */
					%else
						%do; /* 15 OPEN w/ 13 OPEN */
							%if %length(&dataset) gt 32
							%then
								%do; /* 16 OPEN w/ 13,15 OPEN */
									%N_E_W(Dataset Name is too Long!|Dataset Name is %length(&dataset) Characters Long|Name must be 32 character or Less, type=E);
									%return;
									/* -------------------------------------------------------------> Create Window to fix dataset */
								%end; /* 16 CLOSE w/ 13,15 OPEN */
							%else
								%do; /* 21 OPEN w/ 13,15 OPEN */
									%if %sysfunc(exist(&dataset, data)) = 1
									%then
										%do;
											%N_E_W(Dataset "%upcase(&dataset)" Exists in Library WORK, type=N);
											%put ;
										%end;
									%else 
										%do; /* 22 OPEN w/ 13,15,21 OPEN */
											%N_E_W(Dataset "%upcase(&dataset)" does NOT Exist in WORK Library, type=E);
											%return;
											/* ---------------------------------------------------------------> Create Window to take new value */
										%end; /* 22 CLOSE w/ 13,15,21 OPEN */
								%end; /* 21 CLOSE w/ 13,15 OPEN */
						%end; /* 15 CLOSE w/ 13 OPEN */
				%end; /* 13 CLOSE */
						
		%*3. Check if Dataset Has Reserved Name;
	
			%if %upcase(&dataset) = MAIL_TEMP
			%then
				%do;
					%N_E_W(Input Dataset CANNOT be Named MAIL_TEMP|Rename Dataset and Re-Submit, type=E);
					%return;
				%end;

/*-------------------------------------> ADD WINDOW TO RENAME DATASET */

		%*4. Check for Old Dataset Called Mail_Temp and Delete (if exists);

			%if %sysfunc(exist(work.mail_temp)) ~= 0
			%then
				%do;
					proc delete
						data=mail_temp;
					run;
				%end;

	%*B. Total Mailing Number;

		%*1. Check if Null;

			%null(total_mailing);

		%*2. Check for Invalid Characters;

			%invalid_char_loop(total_mailing);

		%*3. Round to Whole Number;

			%if %sysfunc(findc(&total_mailing, ".")) gt 0
			%then
				%do;
					%let total_mailing = %sysevalf(&total_mailing, ceil);

					%N_E_W(TOTAL HOUSEHOLDS to be Mailed is: &total_mailing, type=N);
					%put ;
				%end;
			%else
				%do;
					%N_E_W(TOTAL HOUSEHOLDS to be Mailed is: &total_mailing, type=N);
					%put ;
				%end;

	%*C. Seed Number;

		%if &seed= &null
		%then 
			%do;
				%N_E_W(Parameter SEED is Null|Display Window, type=W);
				%put ;

				%display seed_check_null;

				%if %str(&seed_check_null) = &null
				%then
					%do;
						%seed_assign:

						%let seed=%sysevalf(%sysfunc(datetime()),ceil);

						%N_E_W(SEED will be assigned|SEED assigned is: &seed, type=N);
						%put ;
						;
					%end;
				%else
					%do;
						%let seed = %str(&seed_check_null);
						%goto seed_check_abc;
					%end;
			%end;
		%else
			%do;
				%seed_check_abc:

				%if %upcase(&seed)= ASSIGN
				%then
					%goto seed_assign;
				%else
					%do;
						%invalid_char_loop(seed);
					%end;

				%if %sysfunc(findc(&seed, ".")) gt 0
				%then
					%let seed = %sysevalf(&seed, ceil);

				%N_E_W(Initial SEED is: &seed, type=N);
				%put ;
			%end;

	%*D. Response Rate;

		%*1. Check if NULL;

			%null(response_rate);

		%*2. Check if All Numeric;

			%invalid_char_loop(response_rate)

		%*3. Check if within Range;

			%zero_check(response_rate);

			%if &response_rate ge 1
			%then
				%do;
					%if &response_rate ge 10
					%then
						%let response_rate = %sysevalf(&response_rate/10000);
					%else
						%do;
							%if &response_rate ge 3
							%then
								%let response_rate = %sysevalf(&response_rate/1000);
							%else
								%let response_rate = %sysevalf(&response_rate/100);
						%end;

					%N_E_W(RESPONSE RATE Out if Range|RESPONSE RATE Has Been Adjusted|Display Window, type=W);
					%put ;

					%display rr_check_guess;

					%if &rr_guess_abort ~= &null
					%then
						%terminate;
				%end;
			%else
				%do;
					%if &response_rate ge 0.1
					%then
						%do;
							%let rr_guess_correct = %sysevalf(&response_rate / 100);
							%goto rr_check_decimal;
						%end;
					%else
						%do;
							%if &response_rate gt 0.03
							%then
								%do;
									%let rr_guess_correct = %sysevalf(&response_rate / 10);

									%rr_check_decimal:

									%N_E_W(RESPONSE RATE Appears High|RESPONSE RATE Adjusted|Display Window, type=W);
									%put ;

									%display rr_check_high;

									%if %str(&rr_check_high) ~= %str(&response_rate)
									%then
										%do;
											%if %str(&rr_check_high) ~= %str(&rr_guess_correct)
											%then 
												%terminate;
											%else
												%let response_rate = &rr_guess_correct;
										%end;
								%end;
						%end;
				%end;
			%N_E_W(RESPONSE RATE is &response_rate, type=N);
			%put ;

	%*E. Effect;

		%*1. Check if NULL;

			%if &effect = &null
			%then
				%do;
					%let effect = 0.15;
					%N_E_W(EFFECT was Left Blank|Default EFFECT will be Used, type=N);
					%put ;
				%end;

		%*2. Check if Numeric;
			
			%invalid_char_loop(effect);

		%*3. Check if in Range;

			%effect_loop:

			%zero_check(effect);

			%if &effect ge 1
			%then
				%do;
					%if &effect ge 10
					%then
						%let effect = %sysevalf(&effect / 100);
					%else
						%let effect = %sysevalf(&effect / 10);

					%N_E_W(EFFECT is Out of Range|EFFECT Has Been Adjusted|Display Window, type=W);
					%put ;

					%display effect_check;

					%if &effect_new_2 ~= &null
					%then 
						%terminate;
					%else
						%goto effect_loop;
				%end;
			%else
				%do;
					%if &effect gt 0.2
					%then
						%do;
							%let effect_check_size = %sysevalf(&effect*&response_rate);

							%N_E_W(EFFECT Appears High|EFFECT Has Been Adjusted|Display Window, type=W);
							%put ;

							%display effect_check_range;

							%if &effect_check_range_abort ~= &null
							%then
								%terminate;
							%else
								%do;
									%if &effect_check_range_new = &null
									%then
										%let effect = 0.15;
									%else;
										%do;
											%let effect = &effect_check_range_new;
											%goto effect_loop;
										%end;
								%end;
						%end;
				%end;

			%N_E_W(EFFECT is: &effect, type=N);
			%put ;

	%*F. Alpha;

		%if %str(&alpha) = &null
		%then
			%let alpha = 0.05;
		%else
			%do;
				%stat_check(alpha, 0.05);
			%end;

	%*G. Power;

		%if %str(&power) = &null
		%then
			%let power = 0.5;
		%else
			%do;
				%stat_check(power, 0.5);
			%end;

	%*H. Branches;

		%*1. Check if Variable Exists;

			%null(branch);

			%do %until(&branch_exist_loop=TRUE);
				data _null_;
					dsid=open("&dataset");
					check=varnum(dsid, "&branch");
					call symputx ('branch_exist', check);
					type=vartype(dsid, check);
					call symputx ('branch_type', type);
					dsid2=close(dsid);
				run;
/*				%put WARNING: branch_exist = &branch_exist; *<-------REMOVE;
				%put WARNING: branch_type = &branch_type; *<--------REMOVE;
*/					
				%if &branch_exist=0
				%then
					%do;
						%N_E_W(BRANCH variable "%upcase(&branch)" Does NOT Exist on DATASET|Display Window, type=W);
						%put ;

						%display branch_check_exist;

						%if &branch_exist_new = &null
						%then
							%terminate;
						%else
							%do;
								%let branch = &branch_exist_new;
								%let branch_exist = &null;
								%let branch_exist_new = &null;
							%end;
					%end;
				%else
					%do;
						%let branch_exist_loop=TRUE;

						%N_E_W(Branch Variable &Branch Exists!, type=N);
						%put ;
					%end;
			%end;

			%if &branch_type ~= C
			%then
				%do;
					%N_E_W(Variable "%upcase(&branch)" is Numeric|BRANCH Variable MUST be Character, type=E);
					%return;
				%end;
/*------------------------------------------> Crate Window to Change Branch Variable to Character */

		%*2. Check Branch Names;

			%branch_loop_name:
			proc sql noprint;
				select
					distinct &branch
				into
					:branch_name1- notrim
				from
					&dataset
				;
			%let total_branches = &sqlobs;
			quit;

			%data_error;

			%do i=1 %to %eval(&total_branches-1);
				 %let start=&i;
				 %do k=2 %to &total_branches;
				 	%if &k gt &start
					%then
					 	%if %upcase(&&branch_name&start) = %upcase(&&branch_name&k)
						%then
							%do;
								%N_E_W(Branch Names Are Mixed Cased|Branches Will be Capitalized, type=W);
								%put ;

								data &dataset;
									set &dataset;
									&branch = upcase(&branch);
								run;

								%if &syserr ~= 0
								%then
									%do;
										%N_E_W(Problem Upcasing Branch Names|See Log for Error and Warning Messages, type=E);
										%return;
									%end;
								%else
									%goto branch_loop_name;
							%end;
				%end;
			%end;

			%N_E_W(Branch Name Check Successfully Completed|Total Number of Branches: &total_branches, type=N);
			%put;

	%put;
	%put NOTE: %repeat(*,80);
	%N_E_W(Parameter Checks Complete!, type=N);
	%put NOTE: %repeat(*,80);
	%put ;
	%put ;

	%put NOTE: %repeat(*,80);
	%N_E_W(Begin Processing Control Group!, type=N);
	%put NOTE: %repeat(*,80);
	%put ;


%********************
*V. PULL CONTROL	*
*********************;

	%*A. Calculate Total Records in Input Dataset and Store in MACRO Variable TOTAL;


		proc sql noprint;
			select
				count(*)
			into
				:total trimmed
			from
				&dataset
			;
		quit;

		%data_error;

		%N_E_W(Total Records = &total, type=N);
		%put ;
		
		%if &control_preselect ~= &null
		%then
			%do;
				%let control = &control_preselect;
				%N_E_W(Control Pre-Selected|Skip Calculations, type=N);
				%goto :skip_calculate;
			%end;

	%*B. Check for Too Low Quantity;

		%if &total_mailing lt 50000
		%then
			%do;
				%let control = &total_mailing;
				%N_E_W(Initial Control Group Size = &control, type=N);
				%put ;
				%goto control_check_qty;
			%end;
		%else
			%if &total_mailing lt 100000
			%then
				%do;
					%let control = 50000;
					%N_E_W(Initial Control Group Size = &control, type=N);
					%put ;

					%goto control_check_gty;
				%end;

	%*C. Calculate Control Group Size and Store in MACRO Variable CONTROL;

		data _null_;
			delta=&response_rate*&effect;
			e1=probit(1-(&alpha/2));
			e2=probit(1-&power);
			pool=&response_rate;
			top=pool-(pool**2);
			esquare=(e1+e2)**2;
			delta2=delta**2;
			bottom=(delta2/esquare)-(top/&total_mailing);
			final=ceil(top/bottom);
			call symput('control', final);
		run;

		%data_error;

		%if &control lt 50000
		%then 
			%let control = 50000;

		%else
			%if &control gt %eval(&total_mailing/2)
			%then 
				%let control = %eval(&total_mailing/2);

		%skip_calculate:
		%N_E_W(Initial Control Group Size = &control, type=N);
		%put ;

	%*D. Check if Enough Quantity;

		%control_check_qty:
		%if %eval(&total-&control) lt &total_mailing
		%then
			%do;
				%N_E_W(NOT ENOUGHT QUANTITY FOR CONTROL|Calculated Control: &control|Available for Control: %eval(&total-&total_mailing)|Display Window, type=W);
				%put ;

				%let remaining_qty = %eval(&total-&total_mailing);

				%display control_qty;

				%if %upcase(&use_remaining) = YES
				%then
					%do;
						%let control = %eval(&total-&total_mailing);

						%N_E_W(Control Group Adjusted to: &control, type=C);
						%put ;
					%end;
				%else
					%terminate;
			%end;	

	%*E. Check if GroupID Already Exists;

		data _null_;
			dsid=open("&dataset");
			check=varnum(dsid, "GroupID");
			call symputx ('GroupID_exist', check);
			dsid2=close(dsid);
		run;

		%if &groupID_exist gt 0
		%then
			%do;
				%N_E_W(Variable GroupID CANNOT be present on Dataset|Rename or Drop Variable and Rerun Program, type=E);
				%return;
			%end;

		/* -------------------------------------------------------------------------------> Add Window to rename or drop GroupID */
				
	%*F. Randomly Assign Records to Control Group;
		
		%loop_attempt:

		proc surveyselect
			data=&dataset
			groups=(&control, %eval(&total-&control))
			seed=&seed
			out=mail_temp
			noprint;
		run;
		
		%data_error;

	%*G. Check that Output Dataset was Made Properly;

		%*1. Calculate How Many Records in Dataset (if any) and Store in MACRO Variable;

			proc sql noprint;
				select
					count(*)
				into
					:control_assign_test trimmed
				from
					mail_temp
				;
			quit;

			%data_error;

		%*2. Check if MACRO Variable Exists (aka does dataset exist);

			%if %symexist(control_assign_test)=0
				or &control_assign_test ~= &total
			%then 
				%do;
					%return;
				%end;

		%*3. Check if Total Records is Correct;

			data mail_temp (rename=(groupid=CONTROL));
				set mail_temp;
				label groupid=' ';
				if groupid=2
					then groupid=0;
			run;

			%data_error;

		%*4. Check that Dataset has Correct Number of Control and Mail Records;

			%*a. Calculate Total Control and Mail Records and Store in MACRO Variable;

				%*i. Control Records;

					proc sql noprint;
						select
							count(*)
						into
							:control_dataset_test trimmed
						from
							mail_temp
						where
							control=1
						;
					quit;

					%data_error;

					%N_E_W(Total Control Records: &control_dataset_test, type=N);
					%put ;

				%*ii. Mail Records;

					proc sql noprint;
						select
							count(*)
						into
							:mail_dataset_test trimmed
						from
							mail_temp
						where
							control=0
						;
					quit;

					%data_error;

					%N_E_W(Total Mail Records: &mail_dataset_test, type=N);
					%put ;

			%*b. Check Number of Records;

				%*i. Control;

					%if &control_dataset_test ~= &control
						%then 
							%do;
								%N_E_W(Number of Control Records is NOT Equal to Calculated Control|CONTROL Records = &control_dataset_test|Calculated CONTROL = &control, type=E);
								%return;
							%end;
				%*ii. Mail;

					%if &mail_dataset_test ~= %eval(&total-&control)
						%then
							%do;
								%N_E_W(Mail Numbers is NOT correct, type=E);
								%return;
							%end;

		%*5. Check Branch Quantity;

			%do i=1 %to &total_branches;
				proc sql noprint;
					select
						count(*)
					into
						:branch_qty_&i trimmed
					from
						mail_temp
					where
						&branch = "&&branch_name&i" and
						control=1
					;
				quit;

				%data_error;

				%N_E_W(Total Control Records for Branch &&branch_name&i is &&branch_qty_&i, type=N);
				%put ;

				%if &&branch_qty_&i lt 50
				%then
					%do;
						%if &loop_number gt 10
						%then
							%do;
								%display loop_error;
								%if %upcase(&loop_escape) = YES
								%then 
									%do;
										%N_E_W(User Requested to Continue|Despite Minimum Branch Quantity of 50 NOT being Met, type=W);
										%put ;
										%put ;
										%N_E_W(Final SEED: &seed, type=N);
										%put;

										%goto escape;
									%end;
								%else
									%terminate;
							%end;
						%else;
							%do;
								%N_E_W(Quantity of 50 per Branch NOT Reached|Attempt &loop_number of 10, type=W);
								%put ;

								%let loop_number = %eval(&loop_number + 1);
								%let seed = %eval(&seed+&loop_number);
								%goto loop_attempt;
							%end;
					%end;
			%end;
				%N_E_W(Final SEED: &seed, type=N);
				%put ;

%****************************
*VI. FINAL DATASET CHECK	*
*****************************;

	%*A. Calculate Total Records and Store in MACRO Variable;

		%escape:

		proc sql noprint;
			select
				count(*)
			into
				:final_mail_test trimmed
			from
				mail_temp
			;
		quit;

		%data_error;

	%*B. Check Number of Records;

		%if &final_mail_test ~= &total
			%then 
				%do;
					%N_E_W(Final Dataset Does NOT have Proper Number of Records|Final Dataset has &final_mail_test Records|Final Dataset SHOULD have &total Records, type=E);
					%return;
				%end;

	%*C. Create Final Dataset;

			%else 
				%do;
					data &dataset;
						set mail_temp;
					run;

	%*D. Delete Tempory Dataset;

					proc delete
						data=mail_temp;
					run;

/* --------------------> Delete all work folder MACROS? */

					%N_E_W(Processing Successfully Completed!|All Temporary Datasets and Local MACRO Variables Deleted, type=N);
				%end;

%mend Control_beta;
