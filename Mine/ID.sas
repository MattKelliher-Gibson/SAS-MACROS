%*****************************************************************************
******************************************************************************
** MACRO: ID																**
** Purpose:	Add an ID to each Record with Prefix and Number	 				**
** Created: 02/07/2014														**
** Created by: Matthew Kelliher-Gibson										**
** Last Modified: 07/31/2014												**
** Stage: Live																**
** Parameters:																**
**		Prefix -		Three Characters to Precede Number					**
**		Dataset -		Dataset to have ID added							**
**		Zero -	(YES)	If counting will start at 0							**
**		Count - 	 	Starting Count (only when ZERO=NO)					**
** MACROS Used: 															**
**		%N_E_W																**
**		%Data_Error															**
**		%Repeat																**
******************************************************************************
******************************************************************************;

%macro ID(dataset=,prefix=,zero=YES,count=)
			/* / store source des= "Adds ID"*/;

%************
*I. SETUP	*
*************;

	%*A. Declare Varible Scope;

		%*1. Global;

			%global _count;

		%*2. Local;

			%local prefix dataset zero start count null _z;

	%*B. Defaults;

		%*1. Null;

			%let null = ;


%put ;
%put ;
%N_E_W(Begin MACRO ID Process, type=N);
%put ;
%put ;

%N_E_W(Prefix Set to "&prefix", type=N);
%put ;

%N_E_W(File to be Processes is %upcase(&dataset), type=N);
%put ;

	%*C. Check for ZERO and COUNT;

		%if %upcase(&zero) = YES and &count ~= &null
		%then
			%do;
				%N_E_W(Cannot Have ZERO Set to "YES"|And Use COUNT Parameter, type=E);
				%return;
			%end;

	%*D. Determine COUNT;

		%if %upcase(&zero)=YES
			%then 
				%do;
					%let _count=0;
					
					%N_E_W(ID# Set to 0, type=N);
					%put ;
				%end;
			%else
				%do;
					%if &count ~= &null
					%then
						%let _count = &count;

					%let start = %eval(&_count + 1);
					%N_E_W(ID# Starts at &start, type=N);
					%put ;
				%end;

%********
*II. ID	*
*********;

	%*A. Add ID;

		data &dataset;
			retain ID;
			set &dataset;
			format ID $ 13.;
			ID = catx("-", &prefix, (put(&_count + _n_, z9.)))
		run;

		%data_error;

	%*B. Store High ID;

		proc sql noprint;
			select
				max(input(substr(id, 5, 9), 9.))
			into 
				:_count trimmed
			from 
				&dataset
			;
		quit;

		%data_error;

	%*C. Print Final ID;

		%let _z = %repeat(0,%sysevalf(9-%length(&_count)));

		%put ;
		%N_E_W(LAST ID USED WAS: &prefix.-&_z.&_COUNT, type=N);
		%put ;
		%put ;

%N_E_W(MACRO ID Process Complete!, type=N);
%put ;
%put ;

%mend ID;
