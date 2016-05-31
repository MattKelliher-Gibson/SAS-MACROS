%*****************************************************
******************************************************
** MACRO: Data_Exist                                **
** Description:	Checks if Dataset Exists,           **
**                Only to be used with %if          **
** Created: 05/19/2016                              **
** Created by: Matthew Kelliher-Gibson              **
** Parameters:                                      **
**		Dataset:  Dataset to check                    **
** MACROS:                                          **
**		N/A                                           **
** Example:                                         **
**    %if %data_exist(data1) = 1 %then ... %else ...**
******************************************************
** Version History:                                 **
** 0.1.0 - 05/24/2016 - Original File Created       **
******************************************************
******************************************************;
%macro data_exist(dataset);
	%local dataset exist;

	%let exist = %sysfunc(exist(&dataset));

	&exist
%mend data_exist;
