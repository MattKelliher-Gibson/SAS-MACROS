%*****************************************************************************
******************************************************************************
** MACRO: IMPUTE															**
** Purpose:	Impute Numeric Variables with Missing Values			 		**
** Created: 09/09/2014														**
** Created by: Matthew Kelliher-Gibson										**
** Last Modified: 10/27/2014												**
** Stage: Live																**
** Parameters:																**
**		Dataset -		Dataset with Appended Variables						**
**		Final -			Name of Final Dataset								**
** MACROS Used: 															**
**		%N_E_W																**
**		%Data_Error															**
**		%Repeat																**
**		%Time																**
**		%Final_Time															**
******************************************************************************
******************************************************************************;

%*****************************************************************
******************************************************************
** Version History:												**
** 1.0.0 - 09/09/2014 - Original File 							**
** 1.0.1 - 10/27/2014 - Added Times								**
******************************************************************
******************************************************************;

%macro impute_beta(dataset=, final=);

%************
*I. SETUP	*
*************;

	%*A. Check MACROS;

		%*1. N_E_W;

			%if %sysmacexist(N_E_W) = 0
			%then
				%do;
					%include "T:\MKG\MACROS\GENERAL\N_E_W.sas";
					%N_E_W(MACRO N_E_W Compiled, Type=N);
				%end;

		%*2. Data_Error;

			%if %sysmacexist(data_error) = 0
			%then
				%do;
					%include "T:\MKG\MACROS\GENERAL\Control MACROS\data_error.sas";
					%N_E_W(MACRO Data_Error Compiled, Type=N);
				%end;

		%*3. Dataset;

			%if %sysmacexist(dataset) = 0
			%then
				%do;
					%include "T:\MKG\MACROS\GENERAL\dataset.sas";
					%N_E_W(MACRO Dataset Compiled, Type=N);
				%end;

		%*4. Time;

			%if %sysmacexist(time) = 0
			%then
				%do;
					%include "T:\MKG\MACROS\GENERAL\support macros\time.sas";
					%N_E_W(MACRO Time Compiled, Type=N);
				%end;

		%*5. Final_Time;

			%if %sysmacexist(final_time) = 0
			%then
				%do;
					%include "T:\MKG\MACROS\GENERAL\support macros\final_time.sas";
					%N_E_W(MACRO Final_Time Compiled, Type=N);
				%end;

	%*B. Default Values;

		%*1. Local Variables;

			%local dataset data lib _vars _time _date;

	%*C. Time;

		%time(Impute);

	%*D. Check Dataset;

		%dataset(&dataset);

%************
*II. IMPUTE	*
*************;

	%*A. Gather Variables with Missing Values;

		%*1. Calculate Total Number of Missing Values Per Variable;

			proc means noprint
				data= &lib..&data (drop= Home_Market_Value year_home_built exact_age_person_2-exact_age_person_5 /*number_of_children_in_household*/);
				var _numeric_;
				output
					out= _missing
					nmiss=;
			run;

			%data_error;

		%*2. Transpose Dataset;

			proc transpose
				data= _missing
				out= _missing2;
			run;

			%data_error;

		%*3. Limited to Variables with Missing Values;

			data _missing3;
				set _missing2;
				where 
					col1 ~= 0 and 
					upcase(_name_) ~= "_FREQ_";
			run;

			%data_error;

		%*4. Store Variable Names in MACRO Variable;

			proc sql noprint;
				select
					_name_
				into
					:_vars
				separated by
					" "
				from
					_missing3
				;
			quit;

			%data_error;

			%put &_vars;

	%*B. Calculate Mean Values;

		proc means noprint
			data= &lib..&data;
			var &_vars;
			output 
				out= _median median=;
		run;

		%data_error;

	%*C. Impute;

		%*1. Transpose Dataset;

			proc transpose
				data= _median
				out= _median2(where=(_name_ not in ("_TYPE_", "_FREQ_")));
			run;

			%data_error;

		%*2. Store Variables and Medians in MACRO Arrays;

			%array(_nmissing _nmedian, data= _median2, var= _name_ col1);

			%data_error;

		%*3. Impute;

			data &final;
				set &lib..&data;
				impute=0;
				%do_over(_nmissing _nmedian, phrase= if ?_nmissing =. then do; ?_nmissing=?_nmedian; impute+1; end;)
			run;

			%data_error;

		%*4. Check Total Records Imputed;

			proc freq
				data= &final;
				table impute;
			run;

	%final_time;

%mend impute_beta;
