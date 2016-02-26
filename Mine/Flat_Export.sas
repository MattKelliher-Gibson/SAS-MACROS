%*****************************************************************************
******************************************************************************
** MACRO: Flat_Export                                                       **
** Description:	Exports Dataset as Flat File and Creates Layout             **
** Created: 10/24/2014                                                      **
** Created by: Matthew Kelliher-Gibson                                      **
** Parameters:                                                              **
**    dataset: Dataset to be exported                                       **
**    layout: Layout dataset name                                           **
**    layout_Path: Location for the layout file (.xlsx extension)           **
**    final_Path: Location for final file (.txt extension)                  **
**    lib (WORK):  Library for layout dataset                               **
**    autocall (TRUE):  Logical, indicates the use of autocall library      **
**    time (FALSE): Logical, indicates if program will be timed             **
** MACROS:                                                                  **
**    %N_E_W                                                                **
**    %Data_Error                                                           **
**    %Array                                                                **
**    %Do_Over                                                              **
**    %Time                                                                 **
**    %Final_Time                                                           **
**    %Macro_Check                                                          **
******************************************************************************
** Version History:                                                         **
** 0.1.0 - 10/24/2014 - Original File Created                               **
** 0.1.1 - 02/26/2016 - Add autocall and time parameters and reformat       **
******************************************************************************
******************************************************************************;


%macro Flat_Export(dataset=, layout=, layout_path=, final_path=, lib=WORK, autocall=TRUE, time=FALSE);
%************
*I. SETUP	*
*************;

	%*A. Local Variables;

		%local dataset layout layout_path lib null _width _open _numobs _close _time _date _endtime _enddate autocall;

	%*B. Variables;

		%*1. Null;

			%let null = ;

/*		%*2. Layout Path;*/
/**/
/*			%let layout_path = %nrbquote(&layout_path);*/
/**/
/*		%*3. Final Path;*/
/**/
/*			%let final_path = %nrbquote(&final_path);*/

	%*C. MACROS;
	
		%if %upcase(&autocall) ne TRUE and %upcase(&autocall) ne T
		%then
			%do;
				%if %upcase(&time) = TRUE or %upcase(&time) = TRUE
				%then 
					%do;
						%macro_check(N_E_W data_error array do_over time final_time);
					%end;
				%else 
					%do;
						%macro_check(N_E_W data_error array do_over);
					%end;
			%end;

	%*D. Start Time;

		%if %upcase(&time) = TRUE or %upcase(&time) = TRUE
		%then
			%do;
				%time(Flat File Export);
			%end;
	
%************
*II. LAYOUT	*
*************;

	%*A. Create Table of Variables;

		%N_E_W(Create File Layout, type=N, autocall = &autocall);

		proc contents 
			varnum 
			data = &dataset 
			out = &lib..export_contents (keep = varnum name type length formatl formatd);
		run;

		%data_error;

	%*B. Sort;

		proc sort 
			data = &lib..export_contents;
			by varnum;
		run;

		%data_error;

	%*C. Calculate Width of Variables;

		data &lib..export_contents;
			format Final_Width  8.;
			set &lib..export_contents;
			Final_Width = max(formatl,length);	
		run;

		%data_error;

	%*D. Calculate Total Records Length;

		proc means noprint 
			data = &lib..export_contents ;
			var final_width;
			output 
				out = &lib..width (keep = width)
				sum(final_width)=width;
		run;

		%data_error;

	%*E. Save Total Length;

		data width;
			set width;
			call symput ('_width',width);
		run;

		%data_error;

		%N_E_W(The Total Record Width is:  &_width, type=N);

	%*F. Caculate Start and End of Variables;

		data &lib..export_contents;
			format start end 8.;
			set &lib..export_contents;
			if varnum = 1 
			then 
				do;
					Start = 1;
					End = Final_Width;
				end;
			else if 
				varnum >1 
			then 
				do;
					Start = end + 1;
					End = end + final_width;
				end;
			retain end;
		run;

		%data_error;

	%*G. Create Layout Dataset;

		%*1. Create Inital Table;

			data &layout (keep = varnum name start end format final_width formatd rename=(final_width=length formatd=decimals));
				format Format $ 4.;
				set &lib..export_contents;
				if type = 1 
				then 
					Format = 'Num';
				else if 
					type = 2 
				then 
					Format = 'Char';
			run;

			%data_error;

		%*2. Clean Up;

			data &layout;
				retain varnum name start end format length decimals;
				set &layout;
				Name=upcase(Name);
			run;

			%data_error;

		%*3. Save Total Records to Table;

			%*a. Save Total Records;

				%let _open = %sysfunc(open(&dataset));
				%let _numobs = %sysfunc(attrn(&_open,nobs));
				%let _close = %sysfunc(close(&_open));

				%N_E_W(Number of Records in Table is: &_numobs, type=N);

			%*b. Create Record;

				data _temp_ (keep = name);
					format Num 12.; format NumC $ 12.;
					format Name $ 32.;
					num = &_numobs;
					NumC = put(num,comma12.);
					Name = catx(" ",'Number of Records:',numc);
				run;

				%data_error;

			%*c. Append to Layout;

				proc datasets;
					append 
					base = &layout 
					data = _temp_;
				quit;

	%*H. Export;

		proc export 
			data = &layout
			outfile = "&layout_path"
			dbms = xlsx
			replace;
		run;

		%data_error;

		%N_E_W(Layout Successfully Created!, type=N);

%********************
*III. FINAL FILE	*
*********************;

	%*A. Create Export String;

		%N_E_W(Create Final File, type=N);

		data &lib..export_macro;
			format string $ 70.;
			format num 8.;
			set &lib..export_contents;
			if type = 1 
			then 
				do;
					if formatd >1 
					then 
						string = "@ "||compress(start)||" "||compress(name)||" "||compress(final_width)||"."||compress(formatd);
					else if 
						formatd = 0 
					then 
						string = "@ "||compress(start)||" "||compress(name)||" "||compress(final_width)||".";
				end;
			else if 
				type = 2 
			then 
				do;
					string = "@ "||compress(start)||" "||compress(name)||" $"||compress(final_width)||".";
				end;
			num+1;
		run;

		%data_error;

	%*B. Save String in MACRO Array;

		%array(_export, data=&lib..export_macro, var=string);

		%data_error;

	%*C. Export Final File;

		data _null_;
			set &dataset;
			file "&final_path"
			lrecl = &_width;
			put
				%do_over(_export);
		run;

		%data_error;

		%N_E_W(Final Flat File Created!|Flat File Export Process Complete!, type=N);

		%if %upcase(&time) = TRUE or %upcase(&time) = TRUE
		%then
			%do;
				%final_time;
			%end;
%mend Flat_Export;
