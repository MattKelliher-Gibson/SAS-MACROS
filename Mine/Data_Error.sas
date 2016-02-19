%*****************************************************************************
******************************************************************************
** MACRO: Data_Error                                                        **
** Description:	Checks for Data Step/Proc Error and Terminates if Needed    **
** Created: 06/06/2014														                          **
** Created by: Matthew Kelliher-Gibson										                  **
** Parameters:																                              **
**		NONE																                                  **
** MACROS Used: 															                              **
**		%N_E_W																                                **
******************************************************************************
** Version History:                                                         **
** 0.1.0 - 06/06/2014 - Inital File                                         **
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
