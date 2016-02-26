%*****************************************************************************
******************************************************************************
** MACRO: IV                                                                **
** Description:	Calculates WOE and IV                                       **
** Created: 10/15/2014                                                      **
** Created by: Matthew Kelliher-Gibson                                      **
** Parameters:                                                              **
**    dataset: Dataset name                                                 **
**    n_vars: List of Numeric Variables                                     **
**    c_vars: List of Character Variables                                   **
**    final (work.IV): Name of final IV dataset                             **
**    decile (Decile): Name of the variable for groups                      **
**    target (Target): Name of Dependent Variable                           **
**    autocall (TRUE): Logical, indicates the use of autocall library       **
**    time (FALSE): Logical, indicates if program is timed                  **
** MACROS:                                                                  **
**    %N_E_W                                                                **
**    %Data_Error                                                           **
**    %Bin                                                                  **
**    %Time                                                                 **
**    %Final_Time                                                           **
**    %Macro_Check                                                          **
******************************************************************************
** Version History:                                                         **
** 0.1.0 - 10/15/2014 - Original File Created                               **
** 0.1.1 - 10/19/2014 - Added Min, Max, RR                                  **
******************************************************************************
******************************************************************************;


%macro IV_beta(dataset=, n_vars=, c_vars=, woe=work.woe, final=work.IV, decile=Decile, target=Target, autocall=TRUE, time=FALSE);
%************
*I. SETUP	*
*************;

	%*A. Local Variables;

		%local 	dataset n_vars c_vars final decile target i j k m _words _1_total _0_total _var _pct_nr _pct_r
				_words2 _time _date _endtime _enddate _RTotal _NRTotal lifestyle_names _l _check autocall time;

	%*B. Variables;

		%*1. NULL;
	
			%let null = ;

	/* 	%*2. Life Styles;

			proc sql noprint;
				select
					name
				into
					:lifestyle_names
				separated by
					" "
				from
					"D:\LOAD\Test\Load Table\Lifestyle_and_ordinal"
				;
			quit;

			%if &lifestyle_names = &null
			%then
				%do;
					%N_E_W(Error Getting Life Style Names|Program Terminate, type=E);
					%return;
				%end; */

	%*C. MACROS;

		%if %upcase(&autocall) ne TRUE and %upcase(&autocall) ne T
		%then
			%do;
				%if %upcase(&time) = TRUE or %upcase(&time) = T
				%then
					%do;
						%macro_check(N_E_W data_error bin time final_time);
					%end;
				%else
					%do;
						%macro_check(N_E_W data_error bin)
					%end;
			%end;

	%time(Information Value);

%************************
*II. NUMERIC VARIABLES	*
*************************;

	%*A. MACRO Variables; 

		%*1. Total Responders;

			proc sql noprint;
				select
					count(*)
				into
					:_1_total
				from
					&dataset
				where
					&target = 1
				;
			quit;

			%data_error;

			%N_E_W(Responders: &_1_total, type=N);

		%*2. Total Non-Responders;

			proc sql noprint;
				select
					count(*)
				into
					:_0_total
				from
					&dataset
				where
					&target = 0
				;
			quit;

			%data_error;

			%N_E_W(Non-Responders: &_0_total, type=N);

		%*3. Check for Variables;

			%if &n_vars = &null
			%then
				%do;
					%N_E_W(No Numeric Variables|Skip to Character Variables, type=N);
					%goto skip_n;
				%end;

		%*4. Total Variables;

			%let _words = %sysfunc(countw(&n_vars));

			%N_E_W(Bin and Process Continuous Variables, type=N);

	%*B. Variable Loop;

		%do i=1 %to &_words;

		%*1. Save Current Variable;

			%let _var = %scan(&n_vars, &i);

			%N_E_W(Process Variable %upcase(&_var), type=N);

		%*2. Bin Variable;

			%bin(dataset=&dataset, target=&target, bin=&decile, var=&_var, final=_decile);

		%*3. Create Table of Totals;

			proc sql;
				create table
					&_var as
				select
					&decile,
					&target,
					count(&target) as Total
				from
					_decile
				group by
					&decile,
					&target
				;
			quit;

			%data_error;

		%*4. Decile Loop;

			%do j=1 %to 10;

			%N_E_W(Process Variable %upcase(&_var)|Decile &j, type=N);

			%*a. Save Percent Non-Responders;

				proc sql noprint;
					select
						total/&_0_total
					into
						:_PCT_NR
					from
						&_var
					where
						&decile = &j and
						&target = 0
					;

			%*b. Save Percent Responders;

					select
						total/&_1_total
					into
						:_PCT_R
					from
						&_var
					where
						&decile = &j and
						&target = 1
					;
				quit;

				%data_error;

			%*c. Save Total Non-Repsonders;

				proc sql noprint;
					select
						total
					into
						:_NRTotal
					from
						&_var
					where
						&decile = &j and
						&target = 0
					;
				quit;

				%data_error;

			%*d. Save Total Responders;

				proc sql noprint;
					select
						total
					into
						:_RTotal
					from
						&_var
					where
						&decile = &j and
						&target = 1
					;
				quit;

				%data_error;

			%*e. Save Min and Max;

				proc sql noprint;
					select
						min(&_var),
						max(&_var)
					into
						:_Min,
						:_Max
					from
						_decile
					where
						&decile = &j
					;
				quit;

				%data_error;

				%if &_pct_r = &null
				%then
					%let _pct_r = 0;

				%if &_pct_nr = &null
				%then
					%let _pct_nr = 0;

			%*f. Caclulate WOE and IV and Save in Table;

				%if &i = 1 and &j=1
				%then
					%do;
						data &WOE;
							length Variable $32;
							length Level $32;
							length Minimum 6;
							length Maximum 6;
							length Total_NR 4;
							length Total_R 4;
							length ResponseRate 4;
							length PCT_NR 4;
							length PCT_R 4;
							length WOE 5;
							length IV 5;
							format ResponseRate percent8.2;
							Variable = "&_var";
							Level = "&j";
							Minimum = &_Min;
							Maximum = &_Max;
							Total_NR = &_NRTotal;
							Total_R = &_RTotal;
							ResponseRate = Total_R/(Total_R + Total_NR);
							PCT_NR = &_pct_nr;
							PCT_R = &_pct_r;
							WOE = log(PCT_R/PCT_NR);
							IV = (PCT_R-PCT_NR)*WOE;
							output;
						run;

						%data_error;
					%end;
				%else
					%do;
						data _temp_;
							length Variable $32;
							length Level $32;
							length Minimum 6;
							length Maximum 6;
							length Total_NR 4;
							length Total_R 4;
							length ResponseRate 4;
							length PCT_NR 4;
							length PCT_R 4;
							length WOE 5;
							length IV 5;
							format ResponseRate percent8.2;
							Variable = "&_var";
							Level = "&j";
							Minimum = &_Min;
							Maximum = &_Max;
							Total_NR = &_NRTotal;
							Total_R = &_RTotal;
							ResponseRate = Total_R/(Total_R + Total_NR);
							PCT_NR = &_pct_nr;
							PCT_R = &_pct_r;
							WOE = log(PCT_R/PCT_NR);
							IV = (PCT_R-PCT_NR)*WOE;
							output;
						run;

						%data_error;

						proc datasets nolist;
							append 
							base=&WOE
							data=_temp_;
						run;

						%data_error;

						proc delete
							data=_temp_;
						run;

						%data_error;
					%end;

				%*g. Rest MACRO Variables;

					%let _pct_nr = &null;
					%let _pct_r = &null;
					%let _RTotal = &null;
					%let _NRTotal = &null;
					%let _Min = &null;
					%let _Max = &null;

					%N_E_W(Decile &j Processed and Saved, type=N);

			%end; /*j*/

		%*5. Delete Temporary Table;

			proc delete
				data=_decile;
			run;

			%data_error;

			%N_E_W(Variable %upcase(&_var) Complete, type=N);

		%*6. Rest MACRO Variable;

			%let _var = &null;
		%end; /*i*/

%skip_n:

%****************************
*III. CHARACTER VARIABLES	*
*****************************;

	%*A. Calculate Number of Variables;

		%let _word2 = %sysfunc(countw(&c_vars));

		%N_E_W(Process Character Variables, type=N);

	%*B. Variable Loop;

		%do m=1 %to &_word2;

		%*1. Save Current Variable;

			%let _var = %scan(&c_vars, &m);

			%N_E_W(Process Variable %upcase(&_var), type=N);

/*		%*2. Local Variable;*/
/**/
/*			%local &_var._levels;*/

		%*3. Calculate and Store Number of Levels;

			proc sql noprint;
				select distinct
					&_var
				into
					:_level_1-
				from
					&dataset
				;
				%let _num_levels = &sqlobs;
			quit;

		%*4. Check if LifeStyle Variable;

			%let _check = %index(%upcase(&lifestyle_names), %upcase(&_var));
			%put &_check;

			%if &_check ~= 0
			%then
				%let _l = 1;
			%else
				%let _l = 0;

		%*4. Level Loop;

			%do k=1 %to &_num_levels;

			%N_E_W(Process Variable %upcase(&_var)|Level &&_level_&k., type=N);

			%*a. Create Table;

				proc sql;
					create table
						_freq as
					select
						&_var,
						&target,
						count(*) as Total
					from
						&dataset
					group by
						&_var,
						&target
					;
				quit;

				%data_error;

			%*b. Save Percent Non-Responders;

				proc sql noprint;
					select
						total/&_0_total
					into
						:_PCT_NR
					from
						_freq
					where
						&_var = %if &_l = 1 %then &&_level_&k; %else "&&_level_&k"; and
						&target = 0
					;

			%*c. Save Percent Responders;

					select
						total/&_1_total
					into
						:_PCT_R
					from
						_freq
					where
						&_var = %if &_l = 1 %then &&_level_&k; %else "&&_level_&k"; and
						&target = 1
					;
				quit;

				%data_error;

			%*d. Save Total Responders;

				proc sql noprint;
					select
						total
					into
						:_RTotal
					from
						_freq
					where
						&_var = %if &_l = 1%then &&_level_&k; %else "&&_level_&k"; and
						&target = 1
					;
				quit;

				%data_error; 

			%*e. Save Total Non-Responders;

				proc sql noprint;
					select
						total
					into
						:_NRTotal
					from
						_freq
					where
						&_var = %if &_l = 1 %then &&_level_&k; %else "&&_level_&k"; and
						&target = 0
					;
				quit;

				%data_error;

				%if &_pct_r = &null
				%then
					%let _pct_r = 0;

				%if &_pct_nr = &null
				%then
					%let _pct_nr = 0;

				%if &_RTotal = &null
				%then
					%let _RTotal = 0;

				%if &_NRTotal = &null
				%then
					%let _NRTotal = 0;

			%*c. Calculate WOE and IV and Save in Table;

				data _temp_;
					length Variable $32;
					length Level $32;
					length Minimum 6;
					length Maximum 6;
					length Total_NR 4;
					length Total_R 4;
					length ResponseRate 4;
					length PCT_NR 4;
					length PCT_R 4;
					length WOE 5;
					length IV 5;
					Variable = "&_var";
					Level = "&&_level_&k";
					Minimum =.;
					Maximum =.;
					Total_NR = &_NRTotal;
					Total_R = &_RTotal;
					ResponseRate = Total_R/(Total_R + Total_NR);
					PCT_NR = &_pct_nr;
					PCT_R = &_pct_r;
					WOE = log(PCT_R/PCT_NR);
					IV = (PCT_R-PCT_NR)*WOE;
					output;
				run;

				%data_error;

				proc datasets nolist;
					append 
					base=&WOE
					data=_temp_;
				run;

				%data_error;

				proc delete
					data=_temp_;
				run;

				%data_error;

				proc delete
					data=_freq;
				run;

				%data_error;

			%*d. Rest MACRO Variables;

				%let _pct_nr = &null;
				%let _pct_r = &null;

				%N_E_W(Level &&_level_&k Process and Saved, type=N);

				%let _level_&k = &null;

			%end; /*k*/

		%*5. Reset MACRO Variable;

			%let _var = &null;
			%let _num_levels = &null;
			%let _check = &null;
			%let _l = &null;

		%end;

		%N_E_W(All Variables Processes and Saved, type=N);

%********************
*IV. FINAL TABLE	*
*********************;

		proc sql;
			create table
				&final as
			select
				variable,
				sum(iv) as InformationValue
			from
				&WOE
			group by
				variable
			order by
				InformationValue descending
			;
		quit;

		%N_E_W(Final Table with Information Value Complete!|IV Process Complete!, type=N);
		%final_time;

%mend IV;
