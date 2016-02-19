%*****************************************************
******************************************************
** MACRO: Bin                                       **
** Description:	Automatically Bins Variables        **
** Created: 10/15/2014                              **
** Created by: Matthew Kelliher-Gibson              **
** Parameters:                                      **
**		Dataset:         Dataset to Bin               **
**		Target (Target): Var to keep after binning    **
**		Bin	(Bin):       Name of Bin variable         **
**		Var:             Variable to Bin              **
**		Final:           Name of Final Dataset        **
**		Max (10):        Maximum Number of Bins       **
**		Debug (FALSE):   If TRUE then dataset _freq_  **
**                     is not deleted               **
** MACROS Used:                                     **
**		%N_E_W                                        **
**		%Data_Error                                   **
**		%Dataset                                      **
**		%Array                                        **
**		%Do_Over                                      **
******************************************************
** Version History:                                 **
** 0.1.0 - 10/15/2014 - Original File Created       **
** 0.2.0 - 10/28/2014 - Re-Wrote to Optimal Bin     **
** 0.2.1 - 12/10/2014 - Added Max Parameter         **
** 0.2.2 - 02/19/2016 - Add Autocall and fix header **
******************************************************
******************************************************;


%macro Bin(dataset=, target=target, bin=Bin, var=, final=, max=10, debug=FALSE, _autocall = TRUE);
%************
*I. SETUP	*
*************;

	%*A. Local Variables;
	
		%local dataset target bin var final _time _date debug _autocall;

	%*B. Variables;
	
		%*1. Null;

			%let null = ;

	%*C. MACROS;

		%if %upcase(&_autocall) ne TRUE and %upcase(&_autocall) ne T
		%then
			%macro_check(N_E_W data_error dataset array do_over time final_time);

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

			%if &debug = TRUE
			%then
				%goto escape;

			proc delete
				data=_freq_;
			run;

			%data_error;

	%escape:
	%N_E_W(Binning Process Complete!, type=N);
	%final_time;

%mend Bin;
