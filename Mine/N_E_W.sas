%*********************************************************************
**********************************************************************
** MACRO: N_E_W														**
** Purpose:	Add Custom NOTE, ERROR, and WARNING Messages to Log	    **
** Created: 07/29/2014												**
** Created by: Matthew Kelliher-Gibson							    **
** Last Modified: 07/29/2014									    **
** Stage: Live									         		    **
** Parameters:														**
**		Text= 		Message to Appear in Log						**
**		Type= 		Type of Message:								**
**						N or NOTE									**
**						E or ERROR									**
**						W or WARNING								**
**		Delim= (|) 	Character to Indicate Carriage Returns 			**
** MACROS Used:														**
**		%Repeat														**
**********************************************************************
**********************************************************************;

%macro N_E_W(text, type=, delim=|)
									/* / store source des= "Adds Custom NOTE, ERROR, and WARNING Messages to Log"*/;
%************
*I. MACROS	*
*************;

	%*A. Repeat;
	
		%if %sysmacexist(repeat) = 0
		%then
			%include "T:\MKG\MACROS\GENERAL\repeat.sas";

%********************
*II. DEFAULT VALUES	*
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

%****************
*III. MESSAGE	*
*****************;

	%*A. Top Boarder;

		%put &type.: %repeat(*,80);

	%*B. Message;

		%*1. Notes;

			%if &type = NOTE
			%then
				%do i=1 %to &_n;
					%put %bquote(	  %sysfunc(strip(%scan(&text,&i,&delim)));
				%end;

		%*2. Errors and Warnings;

			%else
				%do i=1%to &_n;
					%put &type.- %sysfunc(strip(%scan(&text,&i,&delim)));
				%end;

	%*C. Bottom Boarder;

		%put &type.: %repeat(*,80);

%mend N_E_W;
