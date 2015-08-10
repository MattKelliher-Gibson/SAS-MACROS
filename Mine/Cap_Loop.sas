%macro Cap_Loop_Beta(dataset=, vars=, pct=, report=YES, file=);
%*****************************************************************************
******************************************************************************
** MACRO: Cap_Loop															**
** Purpose:	Cap Variables at a given Percentile				 				**
** Created: 10/02/2014														**
** Created by: Matthew Kelliher-Gibson										**
** Last Modified: 08/10/2015												**
** Stage: BETA																**
** Parameters:																**
**		dataset -			Input Dataset									**
**		vars - 				MACRO Variable of Variables to be Capped		**
**		pct -				Percentile to Cap Variables at					**
**		report - (YES)		If Histograms should be printed					**
**		file -				File location to save PDF of histograms			**
** MACROS Used:																**
**		%data_error															**
**		%N_E_W																**
******************************************************************************
******************************************************************************;

%*********************************************************************************************************
**********************************************************************************************************
** Version History:																						**
** 1.0.0 - 02/12/2014 - Original File Created															**
** 1.0.1 - 08/10/2015 - Added Formatting							 									**
**********************************************************************************************************
**********************************************************************************************************;

%local dataset vars file pct report _words _var i _pct;

%let _words = %sysfunc(countw(&vars));

%N_E_W(Total Variables to Cap is: &_words, type=N);

%do i=1 %to &_words;

	%N_E_W(Variable &i, type=N);

	%let _var = %scan(&vars, &i);

	%N_E_W(Calculate &pct.th Percentile, type=N);

	proc means noprint
		data=&dataset (keep=&_var);
		output
			out=_temp_
			P&pct=_pct
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
%mend Cap_Loop_Beta;
