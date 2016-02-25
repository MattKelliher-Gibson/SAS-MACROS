%*****************************************************************************
******************************************************************************
** MACRO: Cap_Loop                                                          **
** Description:	Cap Variables at a given Percentile                         **
** Created: 10/02/2014                                                      **
** Created by: Matthew Kelliher-Gibson                                      **
** Parameters:                                                              **
**		dataset:      Input Dataset                                           **
**		vars:         List of Variables to be Capped                          **
**		pct:				  Percentile to Cap Variables at                          **
**		report (YES): If Histograms should be printed                         **
**		file:				  File location to save PDF of histograms                 **
**    autocall (TRUE):  If FALSE all MACROS must be compiled              **
** MACROS Used:                                                             **
**		%data_error                                                           **
**		%N_E_W                                                                **
******************************************************************************
** Version History:																						              **
** 0.1.0 - 02/12/2014 - Original File Created															  **
** 0.1.1 - 08/10/2015 - Added Formatting							 									    **
** 0.1.2 - 02/19/2016 - Fix Formatting and Add Autocall											**
** 0.1.3 - 02/25/2016 - Minor autocall fix                                  **
******************************************************************************
******************************************************************************;

%macro Cap_Loop(dataset=, vars=, pct=, report=YES, file=, autocall=TRUE);
%***********
*I. SETUP  *
************;

	%*A. Local Variables;
	
		%local dataset vars file pct report _words _var i _pct autocall;

	%*B. MACROS;
	
		%if %upcase(&autocall) ne TRUE and %upcase(&autocall) ne T
		%then
			%macro_check(data_error, N_E_W);
	
	%*C. Variables;
	
		%let _words = %sysfunc(countw(&vars));

		%N_E_W(Total Variables to Cap is: &_words, type=N, autocall = &autocall);

%***************
*II. CAP LOOP  *
****************;

	%do i=1 %to &_words;

		%N_E_W(Variable &i, type=N);

		%let _var = %scan(&vars, &i);

		%N_E_W(Calculate &pct.th Percentile, type=N);

	%*A. Calculate Percentile;
	
		proc means noprint
			data=&dataset (keep=&_var);
			output
				out=_temp_
				P&pct. =_pct
			;
		run;

		%data_error;

		%N_E_W(Store &pct.th Percentile, type=N);

		proc sql noprint;
			select
				_pct
			into
				:&_pct
			from
				_temp_
			;
		quit;

		%data_error;

		%N_E_W(Cap Variable %upcase(&_var), type=N);

	%*B. Cap Variable;
	
		data &dataset;
			set &dataset;
			if &_var gt &_pct
			then
				&_var = &_pct;
			else
				&_var=&_var;
		run;

		%data_error;

		%let _var = ;

		%let _pct = ;

		proc delete
			data=_temp_;
		run;

		%data_error;

	%end;

%*****************
*III. REPORTING  *
******************;

	%if &Report = YES
	%then
	%do;
		%N_E_W(Capping Complete!|Produce Histograms, type=N);

		ods html close;

		ods pdf file="&file";

		proc univariate
			data=&dataset;
			var &vars;
			histogram;
		run;

		ods pdf close;

		ods html;

		%data_error;

		%N_E_W(Report of _words Capped Variables Complete!, type=N);
	%end;

%N_E_W(Process Done!, type=N);
%mend Cap_Loop;
