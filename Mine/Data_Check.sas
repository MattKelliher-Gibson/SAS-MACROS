%*******************************************************************
********************************************************************
** MACRO: Data_Check                                              **
** Description:	Checks if Dataset Name is valid and exists        **
** Created: 10/15/2014                                            **
** Created by: Matthew Kelliher-Gibson                            **
** Parameters:                                                    **
**		Dataset:            Dataset to Check                        **
**     _autocall (TRUE):  If FALSE all MACROS                     **
**                        must be compiled                        **
** MACROS:                                                        **
**		%N_E_W                                                      **
********************************************************************
** Version History:                                               **
** 0.1.0 - 10/15/2014 - Original File Created                     **
** 0.1.1 - 02/19/2016 - Add Header and Autocall                   **
********************************************************************
********************************************************************;

%macro data_check(dataset, _autocall=TRUE);
%************
*I. SETUP	*
*************;

	%*A. Local Variables;

		%local dataset data lib null _alphanumeric;

	%*B. Variables;

		%*1. Null;

			%let null = ;

		%*2. _AlphaNumeric;

			%let _AlphaNumeric = %str(ABCDEFGHIJKLMNOPQRSTUVXYZ_.);

	%*C. MACROS;
	
		%if &_autocall ne TRUE and &_autocall ne T
		%then
			%macro_check(N_E_W);

%********************
*II. Check Dataset	*
*********************;

	%*A. Check if Null;

		%if &dataset = &null
		%then
			%do;
				%N_E_W(No Dataset Provided, type=E);
				%let error_check = 1;
				%return;
			%end;

	%*B. Parse Dataset Name;

		%*1. Check for Invalid Characters;
		
			%if %verify(%upcase(&dataset), &_alphanumeric) > 0
			%then
				%do;
					%N_E_W(Invalid Characters in Variable|Dataset: %upcase(&dataset), type=E);
					%let error_check = 1;
					%return;
				%end;

		%*2. Parse Library and Dataset;

			%if %sysfunc(countc(%quote(&dataset), ".")) = 0
			%then
				%do;
					%let lib = WORK;
					%let data = &dataset;
				%end;
			%else
				%do;
					%if %sysfunc(countc(%quote(&dataset), ".")) = 1
					%then
						%do;
							%let lib = %scan(&dataset, 1);
							%let data = %scan(&dataset, 2);
						%end;
					%else
						%do;
							%N_E_W(Too Many Periods in DATASET, type=E);
							%let error_check = 1;
							%return;
						%end;
				%end;

		%*3. Check Library;

			%if &lib ~= WORK
			%then
				%do;
					%if %sysfunc(libref(&lib)) ~= 0
					%then
						%do;
							%N_E_W(Library "%upcase(&lib)" Does Not Exist, type=E);
							%let error_check = 1;
							%return;
						%end;
				%end;

		%*4. Check Dataset;

			%if %sysfunc(exist(&lib..&data)) ~= 1
			%then
				%do;
					%N_E_W(Dataset "%upcase(&data)" Does NOT Exist|In Library "%upcase(&lib)", type=E);
					%let error_check = 1;
					%return;
				%end;
			%else
				%do;
					%N_E_W(Dataset "%upcase(&data)" EXISTS|In Library "%upcase(&lib)", type=N);
					%return;
				%end;

%mend Data_Check;
