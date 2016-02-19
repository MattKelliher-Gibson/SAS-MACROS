%*****************************************************
******************************************************
** MACRO: Bin_Beta                                  **
** Description:	Automatically Bins Variables        **
** Created: 10/15/2014                              **
** Created by: Matthew Kelliher-Gibson              **
** Parameters:                                      **
**		Dataset                                       **
**		Target	(Target)                              **
**		Bin	(Bin)                                     **
**		Var                                           **
**		Final                                         **
**		Max (10)                                      **
**		Debug (NO)                                    **
** MACROS Used:                                     **
**		%N_E_W                                        **
**		%Data_Error                                   **
**		%Dataset                                      **
**		%Array                                        **
**		%Do_Over                                      **
******************************************************
******************************************************;

%*****************************************************
******************************************************
** Version History:                                 **
** 0.1.0 - 10/15/2014 - Original File Created       **
** 0.2.0 - 10/28/2014 - Re-Wrote to Optimal Bin     **
** 0.2.1 - 12/10/2014 - Added Max Parameter         **
******************************************************
******************************************************;


%macro Bin_beta(dataset=, target=target, bin=Bin, var=, final=, max=10, debug=NO);
%************
*I. SETUP	*
*************;

	%*A. Local Variables;
	
		%local dataset target bin var final _time _date debug;

	%*B. Variables;
	
		%*1. Null;

			%let null = ;

	%*C. MACROS;

		%*1. N_E_W;

			%if %sysmacexist(n_e_w) = 0
			%then
				%do;
					%inc "T:\MKG\MACROS\GENERAL\n_e_w.sas";
					%N_E_W(MACRO N_E_W Compiled!, type=N);
				%end;

		%*2. Data_Error;

			%if %sysmacexist(data_error) = 0
			%then
				%do;
					%inc "T:\MKG\MACROS\GENERAL\control macros\data_error.sas";
					%N_E_W(MACRO Data_Error Compiled!, type=N);
				%end;

		%*3. Dataset;

			%if %sysmacexist(dataset) = 0
			%then
				%do;
					%inc "T:\MKG\MACROS\GENERAL\dataset.sas";
					%N_E_W(MACRO Dataset Compiled!, type=N);
				%end;

		%*4. Array;

			%if %sysmacexist(array) = 0
			%then
				%do;
					%inc "T:\MKG\MACROS\GENERAL\array.sas";
					%N_E_W(MACRO Array Compiled!, type=N);
				%end;

		%*5. Do_Over;

			%if %sysmacexist(do_over) = 0
			%then
				%do;
					%inc "T:\MKG\MACROS\GENERAL\do_over.sas";
					%N_E_W(MACRO Do_Over Compiled!, type=N);
				%end;

		%*6. Time;

			%if %sysmacexist(time) = 0
			%then
				%do;
					%inc "T:\MKG\MACROS\GENERAL\support macros\time.sas";
					%N_E_W(MACRO Time Compiled!, type=N);
				%end;

		%*&. Final_Time;

		%if %sysmacexist(final_time) = 0
		%then
			%do;
				%inc "T:\MKG\MACROS\GENERAL\support macros\final_time.sas";
				%N_E_W(MACRO Final_Time Compiled!, type=N);
			%end;

	%*D. Time;

		%Time(Bin);

	%*E. Check Dataset;

		%dataset(&dataset);

%************
*II. BIN	*
*************;

	%*A. Calculate Frequency;

		proc freq noprint
			data= &dataset;
			table &var
				/ out= _freq_ missing;
		run;

		%data_error;

	%*B. Calculate Bins;

		%*1. Assign Bins;

			data _freq_;
				set _freq_;
				total + percent;
				retain bin total;
				if total > &max
				then
					do;
						bin = bin + 1;
						total = PERCENT;
					end;
				if _n_ = 1
				then
					do;
						bin = 1;
						if &var=.
						then
							total= &max;
					end;
			run;

			%data_error;

		%*2. Sort;

			proc sort
				data= _freq_;
				by
					bin
					&var
				;
			run;

			%data_error;

		%*3. Create Final Bin Table;

			data _freq_;
				set _freq_;
				by
					bin
					&var
				;
				if last.bin;
			run;

			%data_error;

	%*C. Assign Bins;

		%*1. Save Bin and Values in MACRO Arrays;

			%array(bin value, data=_freq_, var=bin &var);

		%*2. Assign;

			data &final;
				set &dataset (keep=&target &var);
				%do_over(bin value, phrase= if &var <= ?value then &bin = ?bin;, between=else)
			run;

			%data_error;

%****************
*III. CLEAN UP	*
*****************;

	%*A. Delete Tables;

		%*1. Freq;

			%if &debug = YES
			%then
				%goto escape;

			proc delete
				data=_freq_;
			run;

			%data_error;

	%escape:
	%N_E_W(Binning Process Complete!, type=N);
	%final_time;

%mend Bin_beta;
