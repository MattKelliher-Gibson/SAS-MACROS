%*****************************************************
******************************************************
** MACRO: Total_Records                             **
** Description:	Calculates Total Records in Dataset **
**                and Saves to MACRO Variable       **
** Created: 05/19/2016                              **
** Created by: Matthew Kelliher-Gibson              **
** Parameters:                                      **
**    Dataset:    Dataset                           **
**    Macro_var:  MACRO Variable to store total     **
**  	            !!MACRO Variable Must exist in    **
**                  higher scope!!                  **
** MACROS:                                          **
**		%data_error                                   **
******************************************************
** Version History:                                 **
** 0.1.0 - 05/19/2016 - Original File Created       **
******************************************************
******************************************************;

%macro total_records(dataset=, macro_var=);
	%local dataset macro_var;
	
	proc sql noprint;
		select
			count(*)
		into
			:&macro_var
		from
			&dataset
		;
	quit;
	
	%data_error;
%mend total_records;