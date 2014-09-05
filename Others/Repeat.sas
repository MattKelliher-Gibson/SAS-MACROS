%*****************************************************************************
******************************************************************************
** MACRO: Repeat															**
** Purpose:	Repeats Character(s) for Comment MACROS			 				**
** Found: 01/01/2014 (when I found it)        	    						**
** Created by: Pete Lund													**
** Last Modified: 01/01/2014												**
** Stage: Live																**
** Parameters:																**
**		Char -	Character(s) to be Repeated									**
**		Times -	How Many Times to be Repeated								**
** MACROS Used: 															**
**		NONE																**
******************************************************************************
******************************************************************************;

	%macro repeat(char,times) /*/ store source des = "Only for AUTOEXEC.sas"*/;
		%let char = %quote(&char);
		%if &char eq %then %let char = %str( );
		%sysfunc(repeat(&char,&times-1))
	%mend;
