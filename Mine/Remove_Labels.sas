%*****************************************************************************
******************************************************************************
** MACRO: Remove_Labels                                                     **
** Description:	Remove Labels from all Variables                            **
** Created: 04/02/2014                                                      **
** Created by: Matthew Kelliher-Gibson                                      **
** Parameters:                                                              **
**    dataset:  Dataset to Remove Labels                                    **
**    autocall (TRUE):  Logical, indicates use of autocall library          **
** MACROS Used:                                                             **
**    %N_E_W                                                                **
**    %Data_Error                                                           **
**    %Dataset                                                              **
**    %Macro_Check                                                          **
******************************************************************************
** Version History:                                                         **
** 0.1.0 - 04/02/2014 - Inital File                                         **
** 0.1.1 - 08/22/2016 - Misc Updates                                        **
** 0.1.2 - 02/25/2016 - Reformating and add autocall parameter              **
******************************************************************************;

%macro remove_labels(dataset, autocall=TRUE)
			/* / store source des= "Removes All Labels from Dataset"*/;

%********************
*I. DEFAULT VALUES	*
*********************;

	%*A. Local Variables;

		%local dataset data lib abc numeric everything autocall;

	%*B. MACROS;

		%if %upcase(&autocall) ne TRUE and %upcase(&autocall) ne T
		%then 
			%macro_check(data_error dataset N_E_W);

%*************
*II. SETUP	*
*************;

	%*A. Parse Dataset;

		%dataset(&dataset, autocall = &autocall);

%*********************
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

		%N_E_W(Labels have been Successfully Removed from|Dataset %upcase(&data)!, type=N, autocall = &autocall);

%mend remove_labels;
