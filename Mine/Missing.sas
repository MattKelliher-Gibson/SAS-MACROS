%***********************************************************
************************************************************
** MACRO: Missing                                         **
** Description: To check if MACRO parameters are missing  **
** Created: 02/17/2016                                    **
** Created By: Matthew Kelliher-Gibson                    **
** Parameters:                                            **
**      Parameters - List of parameters WITHOUT '&',      **
**                   Separated by spaces ' '              **
** MACROS Used:                                           **
**      %N_E_W                                            **
************************************************************
************************************************************;

%*********************************************
**********************************************
** Version History:                         **
** 1.0.0 - 02/17/2016 - Inital File Created **
**********************************************
**********************************************;

%macro Missing(parameters);
	%local parameters i _parameter null _error;

	%do %while (&_parameter ne %scan(&parameters, -1));
		%let i = %eval(&i + 1);
		%let _parameter = %scan(&parameters, &i);

		%if &&&_parameter = &null
		%then
			%do;
				%let _error = %eval(&_error + 1);
				%N_E_W(Parameter &_parameter is missing, type = E);
			%end;
	%end;

	%if &_error > 0
	%then
		%do;
			%N_E_W(Parameter(s) are Missing|Program Cannot Continue, type = E);
			%abort;
		%end;
	%else
		%N_E_W(Parameters Checked, type = N);
%mend Missing;
