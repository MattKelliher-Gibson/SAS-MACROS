%***********************************************************
************************************************************
** MACRO: Missing                                         **
** Description: To check if MACRO parameters are missing  **
** Created: 02/17/2016                                    **
** Created By: Matthew Kelliher-Gibson                    **
** Parameters:                                            **
**    parameters:  List of parameters WITHOUT '&',        **
**                 Separated by spaces ' '                **
**    autocall (TRUE):  Logical, indicates the use of     **
**                      autocall library                  **
** MACROS Used:                                           **
**      %N_E_W                                            **
************************************************************
** Version History:                                       **
** 0.1.0 - 02/17/2016 - Inital File Created               **
** 0.1.1 - 02/25/2016 - Reformat and add autocall         **
************************************************************
************************************************************;

%macro Missing(parameters);
%**********
*I. SETUP *
***********;

	%*A. Local Variables;
	
		%local parameters i _parameter null _error autocall;
		
	%*B. MACROS;
	
		%if %upcase(&autocall) ne TRUE and %upcase(&autocall) = T
		%then
			%macro_check(N_E_W);

%**********
* MISSING *
***********;

	%*A. Check Parameters;
	
		%do %while (&_parameter ne %scan(&parameters, -1));
			%let i = %eval(&i + 1);
			%let _parameter = %scan(&parameters, &i);

			%if &&&_parameter = &null
			%then
				%do;
					%let _error = %eval(&_error + 1);
					%N_E_W(Parameter &_parameter is missing, type = E, autocall = &autocall);
				%end;
		%end;

	%*B. Report Missing Parameters;
	
		%if &_error > 0
		%then
			%do;
				%N_E_W(Parameter(s) are Missing|Program Cannot Continue, type = E);
				%abort;
			%end;
		%else
			%N_E_W(Parameters Checked, type = N);
%mend Missing;
