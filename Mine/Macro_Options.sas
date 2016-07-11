%*****************************************************
******************************************************
** MACRO: Macro_Options                             **
** Description:	Turns On/Off Macro Options          **
** Created: 05/24/2016                              **
** Created by: Matthew Kelliher-Gibson              **
** Parameters:                                      **
**		Turn:       Value of "ON" or "OFF"            **
**		Mprint:     Logical "TRUE" or "FALSE"         **
**		Mlogic:     Logical "TRUE" or "FALSE"         **
**		Symbolgen:  Logical "TRUE" or "FALSE"         **
** MACROS:                                          **
**		%N_E_W                                        **
******************************************************
** Version History:                                 **
** 0.1.0 - 05/24/2016 - Original File Created       **
** 0.2.0 - 05/31/2016 - Added individual options    **
******************************************************
******************************************************;

%macro macro_options(turn, mprint=TRUE, mlogic=TRUE, symbolgen=FALSE);
	%local turn mprint mlogic symbolgen;
	
	%if %upcase(&turn) = ON
	%then
		%do;
			option 
				%if %upcase(&mprint) = TRUE %then %do; mprint %end;
				%if %upcase (&mlogic) = TRUE %then %do; mlogic %end;
				%if %upcase (&symbolgen) = TRUE %then %do; symbolgen %end;
			;
			%return;
		%end;
	%else
	%if %upcase(&turn) = OFF
	%then
		%do;
			option 
				%if %upcase(&mprint) = TRUE %then %do; nomprint %end;
				%if %upcase (&mlogic) = TRUE %then %do; nomlogic %end;
				%if %upcase (&symbolgen) = TRUE %then %do; nosymbolgen %end;
			;
			%return;
		%end;
	%else
		%N_E_W(Not a Valid Command|Type "ON" or "OFF", type = E);
		
%mend macro_options;
