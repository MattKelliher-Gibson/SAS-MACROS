%*********************************************************************
**********************************************************************
** MACRO: N_E_W                                                     **
** Description:  Add Custom NOTE, ERROR, and WARNING Messages to Log**
** Created: 07/29/2014                                              **
** Created by: Matthew Kelliher-Gibson                              **
** Parameters:                                                      **
**     text:    Message to Appear in Log                            **
**     type:    Type of Message:                                    **
**                 N or NOTE                                        **
**                 E or ERROR                                       **
**                 W or WARNING                                     **
**     delim: (|)    Character to Indicate Carriage Returns         **
**     autocall (TRUE):  If FALSE all MACROS must be compiled     **
** MACROS Used:                                                     **
**     %Repeat                                                      **
**********************************************************************
** Version History:                                                 **
** 0.1.0 - 07/29/2014 - Original File Created                       **
** 0.1.1 - 07/30/2014 - Minor Updates                               **
** 0.1.2 - 09/08/2014 - Bug Fix                                     **
** 0.1.3 - 01/25/2016 - Changed MACRO directory                     **
** 0.1.4 - 02/17/2016 - Added Extra Spacing                         **
** 0.1.5 - 02/19/2016 - Corrected autocall logic                    **
** 0.1.6 - 02/19/2016 - Revert Back to Original autocall logic      **
** 0.1.7 - 02/25/2016 - Minor autocall fix and formatting           **
** 0.1.8 - 05/17/2016 - Revert autocall fix                         **
**********************************************************************
**********************************************************************;

%macro N_E_W(text, type=, delim=|, autocall = TRUE)
									/* / store source des= "Adds Custom NOTE, ERROR, and WARNING Messages to Log"*/;
									

	
	
%**********
*I. SETUP *
***********;

	%*A. Local Variables;

		%local text type delim null i _n autocall;

	%*B. MACROS;
	
		%if %upcase(&autocall) ne TRUE and %upcase(&autocall) ne T
		%then 
			%Macro_check(repeat);
	
	%*C. Variables;
	
		%*1. Null;

			%let null = ;

		%*2. Delimintor;

			%let delim = %bquote(&delim);

		%*3. Number of Lines in Message (_n);

			%let _n = %sysevalf(%sysfunc(countc(&text, &delim))+1);

	%*D. Message Type;

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
