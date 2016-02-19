%*****************************************************************************
******************************************************************************
** MACRO: Dataset                                                           **
** Purpose:	Parse Dataset Name and Assign MACRO Variables Lib and Data      **
** Created: 08/09/2014                                                      **
** Created by: Matthew Kelliher-Gibson                                      **
** Parameters:                                                              **
**		Dataset -	Dataset Name to be Parsed                                   **
**                **Lib and Data MUST be GLOBAL Variables                   **
** MACROS:                                                                  **
**		%N_E_W                                                                **
******************************************************************************
** Version History:                                                         **
** 0.1.0 - 08/09/2014 - Inital File                                         **
** 0.1.1 - 02/19/2016 - Add Autocall and fix formatting                     **
******************************************************************************;

%macro Dataset(dataset);
%********************
*I. MACRO VARIABLES	*
*********************;

	%*A. Delcare Macro Variable Local;

		%local dataset lib data;

%****************
*II. DATASET	*
*****************;

	%*A. Parse Dataset;

		%*1. Check for Period;

			%if %sysfunc(countc(%quote(&dataset), ".")) = 0
			%then
				%do;

			%*a. True;
			
				%*i. Assign Lib and Data;

					%let lib = WORK;
					%let data = &dataset;

				%*ii. Check if Table Exists;

					%if %sysfunc(exist(&lib..&data)) = 1
					%then
						%do;
							%N_E_W(Dataset %upcase(&data) Is Present|In WORK Library!|
									Data is: &data|
									Library is: WORK, type=N);
							%return;
						%end;
					%else
						%do;
							%N_E_W(Dataset %upcase(&data) Does Not Exist in WORK Library, type=E);
							%abort;
						%end;
				%end;
			%else
				%do;

			%*b. False;

				%*i. Check for Extra Periods;

					%if %sysfunc(countc(%quote(&dataset), ".")) gt 1
					%then
						%do;
							%N_E_W(Invalid Value for DATASET|More than one ".", type=E);
							%abort;
						%end;
					%else
						%do;

				%*ii. Parse Lib and Data;

							%let lib = %scan(&dataset, 1);
							%let data = %scan(&dataset, 2);

				%*iii. Check if Library Exists;

							%if %sysfunc(libref(&lib)) ~= 0
							%then
								%do;
									%N_E_W(Library "%upcase(&lib)" Does Not Exist, type=E);
									%abort;
								%end;
							%else;
								%do;

				%*iv. Check if Table Exists;

									%if %sysfunc(exist(&lib..&data)) ~= 1
									%then
										%do;
											%N_E_W(Dataset "%upcase(&data)" Does Not Exist|
													In Library "%upcase(&lib)", type=E);
											%abort;
										%end;
									%else
										%do;
											%N_E_W(Dataset "%upcase(&data)" is Present|
													In Library "%upcase(&lib)"!, type=N);
											%return;
										%end;
								%end;
						%end;
				%end;
%mend dataset;
