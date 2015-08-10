%*****************************************************************************
******************************************************************************
** MACRO: Capitalize														**
** Purpose:	Capitalize All Variable Values					 				**
** Created: 04/02/2014														**
** Created by: Matthew Kelliher-Gibson										**
** Last Modified: 07/31/2014												**
** Stage: Live																**
** Parameters:																**
**		Data -		Dataset to have all variables capitalized				**
** MACROS Used: 															**
**		N_E_W																**
******************************************************************************
******************************************************************************;

%*****************************************************
******************************************************
** Version History:									**
** 1.0.0 - 04/02/2014 - Original File 				**
** 1.1.0 - 07/31/2014 - Add MACRO N_E_W				**
** 1.1.1 - 10/15/2014 - Add MACRO Data_Error		**
******************************************************
******************************************************;

%macro capitalize(data)
			/* / store source des= "Capitalizes All Values in Dataset"*/;
	data &data;
		SET &data;
		array vars(*) _CHARACTER_;/* THIS ARRAY GROUPS ALL THE CHARACTER VARIABLES TOGETHER INTO ONE ARRAY */
		do i=1 to dim(vars);
			vars(i)=upcase(vars(i));/* USE THE UPCASE FUNCTION TO UPPERCASE EACH VALUE */
		end;
		drop i;
	run;

	%data_error;

	%N_E_W(All Character Variables have been Capitalized!, type=N);
%mend capitalize;
