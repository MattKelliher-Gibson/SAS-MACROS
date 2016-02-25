%*********************************************************************
**********************************************************************
** MACRO: VAR_CHECK                                                 **
** Description: Checks if variable exists on dataset                **
** Created: 10/24/2014                                              **
** Created by: Matthew Kelliher-Gibson                              **
** Parameters:                                                      **
**    dataset:          Dataset to check                            **
**    var:              Variable name to check                      **
**    autocall (TRUE):  Logical, indicates use of autocall library  **
** MACROS:                                                          **
**    %N_E_W                                                        **
**    %Macro_Check                                                  **
**********************************************************************
** Version History:                                                 **
** 0.1.0 - 10/24/2014 - Inital File                                 **
** 0.1.1 - 02/25/2016 - Reformat and add autocall parameter         **
**********************************************************************
**********************************************************************;

%macro Var_Check(dataset, var, autocall = TRUE);
%**********
*I. SETUP *
***********;

	%*A. Local Variables;
	
		%local dataset var data data2;
		
	%*B. MACROS;
	
		%if %upcase(&autocall) ne TRUE and %upcase(&autocall) ne T
		%then
			%macro_check(N_E_W);

%********************
*II. VARIABLE CHECK *
*********************;

	%*A. Open Dataset;
	
		%let data = %sysfunc(open(&dataset));
		
	%*B. Check Variable;
	
		%if (&data)
		%then
			%do;
				%if %sysfunc(varnum(&data, %upcase(&var)))
				%then
					%N_E_W(Variable "%upcase(&var)" Exists!, type=N);
				%else
					%do;
						%N_E_W(Variable "%upcase(&var)" Does NOT Exist!, type=E);
%*						%let error_check = 1;
					%end;
				%let data2 = %sysfunc(close(&data));
			%end;
		%else
			%do;
				%N_E_W(Unable to Open Dataset "%upcase(&dataset)", type=E, autocall = &autocall);
%*				%let error_check = 1;
			%end;

%mend Var_Check;
