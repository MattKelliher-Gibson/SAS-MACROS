%********************************************************
*********************************************************
** MACRO: Delete_Data                                  **
** Description:	Delete Dataset(s)                      **
** Created: 05/17/2016                                 **
** Created by: Matthew Kelliher-Gibson                 **
** Parameters:                                         **
**		Datasets:  List of Space Separated Datasets      **
** MACROS:                                             **
**		%data_exist                                      **
**    %data_error                                      **
*********************************************************
** Version History:                                    **
** 0.1.0 - 05/17/2016 - Original File Created          **
** 0.2.0 - 05/26/2016 - Add a check for if data exists **
*********************************************************
*********************************************************;

%macro delete_data(datasets);
	%local datasets _l _data datasets2;

	%do _l = 1 %to %sysfunc(countw(&datasets, " "));
		%let _data = %scan(&datasets, &_l, " ");
		
		%if %data_exist(&_data) = 1
		%then
			%let datasets2 = &datasets2 &_data;
	%end;
	
	proc delete
		data = &datasets2;
	run;

	%data_error;
%mend delete_data;
