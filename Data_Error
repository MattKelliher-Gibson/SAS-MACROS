%*****************************************************************************
******************************************************************************
** MACRO: Data_Error														                            **
** Purpose:	Checks for Data Step/Proc Error and Terminates if Needed		    **
** Created: 06/06/2014														                          **
** Created by: Matthew Kelliher-Gibson										                  **
** Last Modified: 06/06/2014												                        **
** Stage: Live															                              	**
** Parameters:																                              **
**		NONE																                                  **
** MACROS Used: 															                              **
**		%N_E_W																                                **
******************************************************************************
******************************************************************************;

	%macro data_error;
		%if &syserr ~= 0
		%then
			%do;
				%N_E_W(Problem Occured with last Data Step/Proc|Check Log for WARNING and ERROR Messages|
						Program Terminated, type=E);
				%abort;
			%end;	
	%mend data_error;
