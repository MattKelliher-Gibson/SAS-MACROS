%*********************************************************************
**********************************************************************
** MACRO: Decile                                                    **
** Purpose: To sort data and assigns to equal                       **
**          groups (usually deciles)                                **
** Created: 2/11/2014                                               **
** Created By: Matthew Kelliher-Gibson                              **
** Parameters:                                                      **
**    Dataset:             Input Datase that will be sorted         **
**                           and assigned to groups                 **
**    Target (P_Target1):  The variable to be sorted on	            **
**    Decile (GLOBAL_DECILE):  Variable name for the                **
**                               group assignments                  **
**    Site (NO):  By variable for additionally assinged             **
**                  grouping                                        **
**    S_Decile (SITE_DECILE):  Variable name for group by           **
**                               assignment                         **
**    Number_of_Groups:  Number of groups to be assigned            **
**    autocall:  Logical, indicates use of autocall library         **
** MACROS:                                                          **
**    %N_E_W                                                        **
**    %Dataset                                                      **
**    %Terminate                                                    **
**    %Data_Error                                                   **
**    %Array                                                        **
**    %Do_Over                                                      **
**    %Time                                                         **
**    %Final_Time                                                   **
**    %Macro_Check                                                  **
**********************************************************************
** Version History:                                                 **
** 0.1.0 - 02/11/2014 - Original File                               **
** 0.2.0 - 03/06/2014 - Site Deciling Added                         **
** 0.2.1 - 04/30/2014 - Added Grouping by any number                **
** 0.2.2 - 04/30/2014 - Added MACRO Windows and Parameter Checks    **
** 0.2.3 - 10/29/2014 - Added MACRO Calls and Minor Updates         **
** 0.2.4 - 02/19/2016 - Formatting Fixed                            **
** 0.2.5 - 02/25/2016 - Updates, add %local, and autocall addition  **
**********************************************************************
**********************************************************************;

%macro Decile(dataset=, target=P_target1, decile=GLOBAL_DECILE, site=NO, branch=branch, s_decile=SITE_DECILE, number_of_groups=10, autocall = TRUE)
				/* / store source des= "Divides File into Ordered Groups (Usually Deciles)"*/;
%**********
*I. SETUP *
***********;

	%*A. Local Variables;
	
		%local dataset target decile site site branch s_decile number_of_groups autocall target_new site_new number_of_groups_new target_exist branch_exist zz total i;

	%*B. MACROS;
	
		%if %upcase(&autocall) ne TRUE and %upcase(&autocall) ne T
		%then
			%macro_check(N_E_W dataset terminate data_error array do_over time final_time);

	%*C. Default Variables;
	
		%*1. NULL;
	
			%let null= ;
			
	%*D. MACRO Windows;

		%*1. Target;

			%window target_check
				#3 @5 "ERROR!" color=red
				#5 @5 "You Did NOT Enter a variable for TARGET!" color=red
				#7 @5 "Please Enter a TARGET variable and press [ENTER]."
				#9 @5 target_new 10 attr=underline color=blue
				#11 @5 "OR leave blank and press [ENTER] to ABORT."
			;

		%*2. Site;

			%window site_check
				#3 @5 "SITE Decile is currently set to" +2 site 3 attr=underline protect=yes +1 "."
				#5 @5 "If you would like to change SITE Decile type new value below and press [ENTER]."
				#7 @5 site_new 3 attr=underline color=blue
				#9 @5 "OR to keep current settings leave blank and press [ENTER]."
			;

		%*3. Number of Groups;

			%window groups_check
				#3 @5 "NUMBER of GROUPS is currently set to" +2 number_of_groups 2 attr=underline protect=yes +1 "."
				#5 @5 "If you would like to change NUMBER of GROUPS type new value below and press [ENTER]."
				#7 @5 number_of_groups_new 2 attr=underline color=blue
				#9 @5 "OR to keep current settings leave blank and press [ENTER]."
			;

	%time(Decile);

%*********************
*II. PARAMETER CHECK *
**********************;

	%*A. Dataset;

		%dataset(&dataset, autocall = &autocall);

	%*B. Target;

		%if &target = &null
			%then 
				%do; /* NULL DO */
					%display target_check;
					%if &target_new = &null
						%then
							%do; /* ABORT DO */
								%terminate
							%end; /* ABORT DO */
						%else
						%do; /* NEW TARGET DO*/
							%let target = &target_new;

							%goto target_exist_check;
							
						%end; /* NEW TARGET DO */
				%end; /* NULL DO */
			%else 
				%do; /* TARGET EXIST DO */
					%target_exist_check: 

					data _null_;
						dsid=open("&dataset");
						check=varnum(dsid, "&target");
						call symput ('target_exist', check);
						dsid2=close(dsid);
					run;

					%if &target_exist = 0
						%then 
							%do; /* ABORT DO */
								%N_E_W(Variable &target does NOT Exist in Dataset &dataset, type=E, autocall = &autocall);
								%abort;
							%end; /* ABORT DO */
						%else
							%N_E_W(Variable &target exists on Dataset &dataset, type = N);
				%end; /* TARGET EXIST DO */

	%*C. Site;
/*		
		%Display site_check;

		%if &site_new ne &null
			%then
				%let site = %upcase(&site_new);
*/
	%*D. Branch;

		%if &site = YES
			%then
				%do;

					data_null;
						dsid=open(%quote(&dataset));
						check=varnum(dsid, %quote(&branch));
						call symput ('branch_exist', check);
						dsid2=close(%quote(&dataset));
					run;

					%if &branch_exist = 0
						%then
							%do;
								%N_E_W(Variable &branch does NOT Exist in Dataset &dataset, type = E);
								%abort;
							%end;
						%else
							%N_E_W(Variable &branch exists on Dataset &dataset, type = N);
				%end;

	%*E. Number of Groups;
/*
		%display groups_check;

		%if &number_of_groups_new ne &null
			%then
				%let number_of_groups = &number_of_groups_new;
*/
	%*F. List Parameters;

		%N_E_W(Dataset to be used is: &dataset|Target Varaible is: &target|Final Decile Variable will be called: &decile|
				Creating Site Deciles: &site, type=N);
		%if &site = YES
			%then
				%N_E_W(Branch Variable to be used is: &branch|Final Site Decile Variable will be called: &s_decile, type=N);
				
		%N_E_W(Number of Groups to be assigned is: &number_of_groups, type=N);
		
		%N_E_W(BEGIN PROCESSING, type=N);

	%*G. Site Decile Check;

		%*1. Check if Site Deciles will be Used;

			%let SITE=%upcase(&site);

			%N_E_W(USING SITE DECILES?  &site, type=N);

		%*2. Site Decile Prep;

			%if &site = YES
				%then
					%do;
						proc sql;
							create table 
								branches as
							select 
								distinct &branch as BRANCHES
							from 
								&dataset
							;
						quit;

						%data_error;

						%dataset(branches);
					

						proc sql noprint;
							select 
								count(*)
							into 
								:zz
							from 
								branches
							;
						quit;

						%if %symexist(zz)=0 or &zz=&null or &zz=0
							%then
								%do;
									%N_E_W(MUST HAVE MORE THAN ZERO BRANCHES!, type=E);
									%return;
								%end;

						%N_E_W(Number of Branches: &zz, type = N);

						%array(bra, data=branches, var=BRANCHES);

					%end;

%**************
*III. Deciles *
***************;

	%*A. Sort by TARGET Variable;

		proc sort 
			data=&dataset;
			by decending &target;
		run;

		%data_error;

	%*B. Calculate Total Records in Dataset and Store in MACRO Variable TOTAL;

		proc sql noprint;
			select 
				count(*)
			into 
				:total
			from 
				&dataset
			;
		quit;

		%data_error;

		%if %symexist(total)=0 or &total=&null or &total=0
			%then 
				%do;
					%N_E_W(Dataset has Zero Records!, type=E);
					%return;
				%end;

		%N_E_W(Total records in file: &total, type=N);

	%*C. Prepare Number of Groups;

		data number_of_groups;
			do i=1 to &number_of_groups;
				x=i;
				output;
			end;
		run;

		%data_error;

		%array(splits, data=number_of_groups, var=x);

	%*D. Assign Groups;

		data &dataset;
			set &dataset;
			format &decile 2.;
			%do_over(splits, phrase=
				if _n_ le ((&total/&number_of_groups)*?) then &decile=?;,
				between=else);
		run;

		%data_error;

	%*E. Assign Site Groups;

		%if &site = YES
			%then
				%do; /* SITE  DO */
					%do_over(bra, 
						phrase=
							data _?_i_ ;
								set &dataset (keep=slkid &target &branch);
								where &branch eq "?";
							run;)
						
					%do i=1 %to &zz; /* GROUP LOOP */
						proc sql noprint;
							select 
								count(*)
							into 
								:T_&i
							from 
								_&i
							;
						quit;

						%N_E_W(Number of Records in Branch &&bra&i:|&&T_&i, type=N);

						proc sort 
							data=_&i;
							by decending &target;
						run;

						data _&i;
							set _&i;
							format &s_decile 2.;
							%do_over(splits, phrase=
								if _n_ le ((&&T_&i/&number_of_groups)*?) then &s_decile=?;,
								between=else);
							/*if _n_ le (&&T_&i/10*1)	then &s_decile=1;else
							if _n_ le (&&T_&i/10*2)	then &s_decile=2;else
							if _n_ le (&&T_&i/10*3)	then &S_decile=3;else
							if _n_ le (&&T_&i/10*4)	then &S_decile=4;else
							if _n_ le (&&T_&i/10*5)	then &S_decile=5;else
							if _n_ le (&&T_&i/10*6)	then &S_decile=6;else
							if _n_ le (&&T_&i/10*7)	then &S_decile=7;else
							if _n_ le (&&T_&i/10*8)	then &S_decile=8;else
							if _n_ le (&&T_&i/10*9)	then &S_decile=9;else
							if _n_ le &&T_&i		then &S_decile=10;*/
						run;

						%if &i = &zz
							%then
								%do; /* COMBINE DO */
									data total;
										set _1 - _&i;
									run;
								%end; /* COMBINE DO */
					%end; /* GROUP LOOP */

					proc sql noprint;
						select 
							count(*)
						into 
							:ll
						from 
							total
						;
					quit;

					%if &ll=&total
						%then
							%do; /* FINAL DO */
								proc sort 
									data=total;
									by 
										slkid 
										&branch 
										&target
									;
								run;

								proc sort 
									data=&dataset;
									by 
										slkid 
										&branch 
										&target
									;
								run;

								data &dataset;
									merge 
										&dataset (in=flag) 
										total;
									by 
										slkid 
										&branch 
										&target
									;
									if flag=1;
								run;

								proc delete 
									data=_1-_&zz;
								run;

								proc delete 
									data=total;
								run;

							%end; /* FINAL DO */
						%else
							%do; /* ABORT */
								%N_E_W(Datasets NOT Equal|&total Records in Original|&ll Records in Other, type = E);
								%abort;
							%end; /* ABORT DO */
				%end; /* SITE DO */

%*************
*IV. REPORTS *
**************;
/*
	%if &report= &null
		%then 
			%goto exit;
		%else
			%do;
				ods pdf file="&report_file";
					title "Global Deciles";
					proc sql;
						select 
							&decile as "Global Decile", 
							count(*) as Total
						from 
							&dataset
						group by 
							&decile
						;
					quit;

					%if &site = YES
						%then
							%do;

								title "Global Decile by Branch";
								proc freq 
									data=&dataset;
									table &decile*&branch 
										/ nocol nocum noprecent norow;
								run;
							%end;
				ods pdf close;
				ods html;
			%end;
			
%exit:*/

%*************
*V. CLEAN UP *
**************;

	%*A. Delete Tables;

		proc delete
			data=number_of_groups;
		run;

	%N_E_W(PROCESSING SUCCESSFULLY COMPLETED|All Temporary Datasets and Variables Deleted, type=N);
	%final_time()
%mend Decile;
