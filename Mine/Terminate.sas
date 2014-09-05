%*****************************************************************************
******************************************************************************
** MACRO: Terminate															                            **
** Purpose:	Aborts Program when Requested by User			 				              **
** Created: 06/06/2014														                          **
** Created by: Matthew Kelliher-Gibson										                  **
** Last Modified: 06/06/2014												                        **
** Stage: Live																                              **
** Parameters:																                              **
**		NONE																                                  **
** MACROS Used: 															                              **
**		%N_E_W																                                **
******************************************************************************
******************************************************************************;

	%macro terminate;
		%N_E_W(User Requested Termination, type=N);
		%abort;
	%mend terminate;
