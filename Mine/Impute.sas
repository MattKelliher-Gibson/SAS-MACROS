%*****************************************************************************
******************************************************************************
** MACRO: IMPUTE                                                            **
** Description:	Impute Numeric Variables with Missing Values                **
** Created: 09/09/2014                                                      **
** Created by: Matthew Kelliher-Gibson                                      **
** Parameters:                                                              **
**    dataset:         Dataset with Appended Variables                      **
**    final:           Name of Final Dataset                                **
**    autocall (TRUE): Logical, indicates the use of an autocall library    **
** MACROS Used:                                                             **
**    %Data_Error                                                           **
**    %Dataset                                                              **
**    %Time                                                                 **
**    %Final_Time                                                           **
**    %Macro_Check                                                          **
**    %Array                                                                **
**    %Do_Over                                                              **
******************************************************************************
** Version History:                                                         **
** 0.1.0 - 09/09/2014 - Original File                                       **
** 0.1.1 - 10/27/2014 - Added Times                                         **
** 0.1.2 - 02/25/2016 - Reformatted Header and added autocall check         **
******************************************************************************
******************************************************************************;

%macro impute_beta(dataset=, final=, autocall=TRUE);

%************
*I. SETUP	*
*************;

	%*A. Check MACROS;

		%if %upcase(&autocall) ne TRUE and %upcase(&autocall) ne T
		%then	
			%macro_check(data_error dataset time final_time array do_over);

	%*B. Default Values;

		%*1. Local Variables;

			%local dataset data lib _vars _time _date autocall;

	%*C. Time;

		%time(Impute);

	%*D. Check Dataset;

		%dataset(&dataset, autocall = &autocall);

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
