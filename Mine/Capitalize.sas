%********************************************************************
*********************************************************************
** MACRO: Capitalize                                               **
** Description:	Capitalize All Variable Values in a Dataset        **
** Created: 04/02/2014                                             **
** Created by: Matthew Kelliher-Gibson                             **
** Parameters:                                                     **
**    data:  Dataset to have all variables capitalized             **
**    autocall (TRUE):  Logical, indicates use of autocall library **
** MACROS Used:                                                    **
**    %N_E_W                                                       **
**    %data_error                                                  **
*********************************************************************
** Version History:                                                **
** 0.1.0 - 04/02/2014 - Original File                              **
** 0.1.1 - 07/31/2014 - Add MACRO N_E_W                            **
** 0.1.2 - 10/15/2014 - Add MACRO Data_Error                       **
** 0.1.3 - 02/19/2016 - Add Autocall and and %local                **
** 0.1.4 - 02/25/2016 - Minor autocall fix and reformatting        **
*********************************************************************
*********************************************************************;

%macro capitalize(data, _autocall=TRUE)
			/* / store source des= "Capitalizes All Values in Dataset"*/;

%**********
*I. SETUP *
***********;

	%*A. Local Variables;
	
		%local data autocall;
	
	%*B. MACROS;
	
		%if &autocall ne TRUE and &autocall ne T
		%then
			%macro_check(N_E_W data_error);
	
%****************
*II. CAPITALIZE *
*****************;
	
	data &data;
		set &data;
		array vars(*) _CHARACTER_;/* THIS ARRAY GROUPS ALL THE CHARACTER VARIABLES TOGETHER INTO ONE ARRAY */
		do i=1 to dim(vars);
			vars(i)=upcase(vars(i));/* USE THE UPCASE FUNCTION TO UPPERCASE EACH VALUE */
		end;
		drop i;
	run;

	%data_error;

	%N_E_W(All Character Variables have been Capitalized!, type=N, autocall = &autocall);
%mend capitalize;
