%*********************************************************************
**********************************************************************
** MACRO: N_E_W                                                     **
** Description:  Add Custom NOTE, ERROR, and WARNING Messages to Log**
** Created: 07/29/2014                                              **
** Created by: Matthew Kelliher-Gibson                              **
** Parameters:                                                      **
**     Text=    Message to Appear in Log                            **
**     Type=    Type of Message:                                    **
**                 N or NOTE                                        **
**                 E or ERROR                                       **
**                 W or WARNING                                     **
**     Delim= (|)    Character to Indicate Carriage Returns         **
** MACROS Used:                                                     **
**     %Repeat                                                      **
**********************************************************************
** Version History:                                                 **
** 1.0.0 - 07/29/2014 - Original File Created                       **
** 1.0.1 - 07/30/2014 - Minor Updates                               **
** 1.0.2 - 09/08/2014 - Bug Fix                                     **
** 1.0.3 - 01/25/2016 - Changed MACRO directory                     **
** 1.0.4 - 02/17/2016 - Added Extra Spacing                         **
** 1.0.5 - 02/19/2016 - Corrected autocall logic                    **
** 1.0.6 - 02/19/2016 - Revert Back to Original autocall logic      **
**********************************************************************
**********************************************************************;

%macro N_E_W(text, type=, delim=|, _autocall = TRUE)
									/* / store source des= "Adds Custom NOTE, ERROR, and WARNING Messages to Log"*/;
									
%**************
*0. AUTOCALL  *
***************;

	%local _autocall;
	
	%if %upcase(&_autocall) ne TRUE and %upcase(&_autocall) ne T
	%then 
		%Macro_check(repeat);
	
%********************
*I. DEFAULT VALUES  *
*********************;

	%*A. Declare MACRO Variables Local;

		%local text type delim null i _n;

	%*B. Null;

		%let null = ;

	%*C. Delimintor;

		%let delim = %bquote(&delim);

	%*D. Number of Lines in Message (_n);

		%let _n = %sysevalf(%sysfunc(countc(&text, &delim))+1);

	%*E. Message Type;

		%if 
			%upcase(&type) = N or
			%upcase(&type) = NOTE
		%then
			%let type = NOTE;
		%else
			%if
				%upcase(&type) = E or
				%upcase(&type) = ERROR
			%then
				%let type = ERROR;
			%else
				%if
					%upcase(&type) = W or
					%upcase(&type) = WARNING
				%then
					%let type = WARNING;
				%else
					%do;
						%put ERROR: %repeat(*,80);
						%put ERROR- Invalid Comment Type;
						%put ERROR- Comment Type Must be "N", "E", or "W" only;
						%put ERROR: %repeat(*,80);
						%return;
					%end;

%**************
*II. MESSAGE  *
***************;

	%*A. Top Boarder;

		%put ;
		%put &type.: %repeat(*,80);

	%*B. Message;

		%*1. Notes;

			%if &type = NOTE
			%then
				%do i=1 %to &_n;
					%put %bquote(	     %sysfunc(strip(%scan(&text,&i,&delim))));
				%end;

		%*2. Errors and Warnings;

			%else
				%do i=1%to &_n;
					%put &type.- %sysfunc(strip(%scan(&text,&i,&delim)));
				%end;

	%*C. Bottom Boarder;

		%put &type.: %repeat(*,80);
		%put ;

%mend N_E_W;
