%*****************************************************************************
******************************************************************************
** MACRO: Remove_Labels														**
** Purpose:	Remove Labels from all Variables				 				**
** Created: 04/02/2014														**
** Created by: Matthew Kelliher-Gibson										**
** Last Modified: 08/22/2014												**
** Stage: BETA																**
** Parameters:																**
**		Dataset -		Dataset to Remove Labels							**
** MACROS Used: 															**
**		%N_E_W																**
**		%Data_Error															**
**		%Dataset															**
******************************************************************************
******************************************************************************;

%macro remove_labels(dataset)
			/* / store source des= "Removes All Labels from Dataset"*/;

%********************
*I. DEFAULT VALUES	*
*********************;

	%*A. Local Variables;

		%local dataset data lib abc numeric everything;

	%*B. MACROS;

		%if %sysmacexist(data_error) = 0
		%then
			%include "C:\SAS-MACROS\Mine\data_error.sas";;

		%if %sysmacexist(dataset) = 0
		%then
			%include "C:\SAS-MACROS\Mine\DATASET.sas";;

*************
*II. SETUP	*
*************;

	%*A. Parse Dataset;

		%dataset(&dataset);

*********************
*III. REMOVE LABELS	*
*********************;

	%*A. Remove Lables;

		proc datasets nolist
				lib=&lib 
				memtype=data;
			modify &data; 
			attrib _all_ label=' ';
		run;
		quit;

		%data_error;

		%N_E_W(Labels have been Successfully Removed from|Dataset %upcase(&data)!, type=N);

%mend remove_labels;
