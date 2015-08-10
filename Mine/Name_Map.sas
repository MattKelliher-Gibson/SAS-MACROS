%*****************************************************************************
******************************************************************************
** MACRO: Name_Map															**
** Purpose:	Take Client File, Map and Adjust Name and Address Fields 		**
** Created: 08/07/2014														**
** Created by: Matthew Kelliher-Gibson										**
** Last Modified: 09/04/2014												**
** Stage: BETA																**
** Parameters:																**
**		Dataset -	File to be Mapped and Adjusted							**
**		First - 	Name of Variable Containing First Name					**
**		Last - 		Name of Variable Containing Last Name					**
**		Address1 -	Name of Variable Containing Address1					**
**		Address2 -	Name of Variable Containing Address2					**
**		City -		Name of Variable Containing City						**
**		ST -		Name of Variable Containing State						**
**		Zip5 -		Name of Variable Containing Zip5						**
**		Plus4 -		Name of Variable Containing Plus4						**
**		Phone -		Name of Variable Containing Phone Number				**
**		Area_Code -	Name of Variable Containing Area Code					**
** MACROS Used: 															**
**		%Dataset															**
**		%Data_Error															**
**		%Array																**
**		%Do_Over															**
**		%Remove_Labels_Beta													**
**		%Capitalize															**
******************************************************************************
******************************************************************************;

%*****************************************************************************
******************************************************************************
** Version History:															**
** 1.0.0 - 08/07/2014 - Original File 										**
** 1.0.1 - 08/08/2014 - Fixed Bugs and Added Parsing and Addition of Fields	**
** 1.1.0 - 08/09/2014 - Add local, Add DATASET								**
** 1.2.0 - 08/13/2014 - Add Phone Parsing									**
** 1.2.1 - 08/13/2014 - Debug												**
** 1.3.0 - 09/03/2014 - Add MACRO Checks and Zip Code Numeric Checks 		**
** 1.4.0 - 09/04/2014 - Completely Re-Wrote Name Parsing Logic 				**
** 1.4.1 - 09/09/2014 - Added MACRO Checks for Array and Do_Over			**
******************************************************************************
******************************************************************************;

%macro Name_Map_Beta(dataset=,first=,last=,address1=,address2=,city=,st=, zip5=,plus4=,phone=,area_code=);
%****************
*I. DEFAULTS	*
*****************;

	%*A. Local MACRO Variables;

		%local dataset data lib first last address1 address2 city st zip5 plus4 phone area_code null alpha _f _l _a1 _a2 _c _st _z5 _p4 _ph _ac _dsid _z5_pos _dsid2 _close _close2 _p4_pos _last1 _last2 _suffix;

	%*B. Null;

		%let null = ;

	%*C. Alpha;

		%let alpha = %str(ABCDEFGHIJKLMNOPQRSTUVWXYZ %');

	%*D. Last Name Prefix 1;

		%let _last1 = %str("MC", "DE", "DEL", "LA", "DI", "DA", "VAN", "SAN", "LE", "ST", "LOS", "MAC");

	%*E. Last Name Prefix 2;

		%let _last2 = %str("LA", "MC", "DI", "MAC");

	%*F. Suffix;

		%let _suffix = %str("SR", "JR", "III", "IV", "II");

%************
*II. MACROS	*
*************;

	%*A. Dataset;
	
		%if %sysmacexist(dataset) = 0
		%then
			%do;
				%include "T:\MKG\MACROS\GENERAL\dataset.sas";
				%N_E_W(MACRO Dataset Compiled, type=N);
			%end;

	%*B. Data_Error;
	
		%if %sysmacexist(data_error) = 0
		%then
			%do;
				%include "T:\MKG\MACROS\GENERAL\Control MACROS\data_error.sas";
				%N_E_W(MACRO Data_Error Compiled, type=N);
			%end;

	%*C. Remove Labels;

		%if %sysmacexist(remove_labels_beta) = 0
		%then
			%do;
				%include "T:\MKG\MACROS\GENERAL\BETA\remove_labels_beta.sas";
				%N_E_W(MACRO Remove_Labels_Beta Compiled, type=N);
			%end;

	%*D. Capitalize;

		%if %sysmacexist(capitalize) = 0
		%then
			%do;
				%include "T:\MKG\MACROS\GENERAL\capitalize.sas";
				%N_E_W(MACRO Capitalize Compiled, type=N);
			%end;

	%*E. Array;

		%if %sysmacexist(array) = 0
		%then
			%do;
				%include "T:\MKG\MACROS\GENERAL\array.sas";
				%N_E_W(MARCO Array Compiled, type=N);
			%end;

	%*F. Do_Over;

		%if %sysmacexist(do_over) = 0
		%then
			%do;
				%include "T:\MKG\MACROS\GENERAL\do_over.sas";
				%N_E_W(MACRO Do_Over Compiled, type=N);
			%end;

%********************
*III. PARAMETERS	*
*********************;

	%*A. Dataset;

		%dataset(&dataset);

	%*B. First;

		%if &first ~= &null
		%then
			%let _f = 1;
		%else
			%let _f = 0;

	%*B. Last;

		%if &last ~= &null
		%then
			%let _l = 1;
		%else
			%let _l = 0;

	%*C. Address1;
	
		%if &address1 ~= &null
		%then
			%let _a1 = 1;
		%else
			%let _a1 = 0;

	%*D. Address2;
	
		%if &address2 ~= &null and &address2 ~= NULL
		%then
			%let _a2 = 1;
		%else
			%let _a2 = 0;

	%*E. City;

		%if &city ~= &null
		%then
			%let _c = 1;
		%else
			%let _c = 0;

	%*F. State;

		%if &st ~= &null
		%then
			%let _st = 1;
		%else
			%let _st = 0;

	%*G. Zip5;
	
		%if &zip5 ~= &null
		%then
			%let _z5 = 1;
		%else
			%let _z5 = 0;

	%*H. Plus4;

		%if &plus4 ~= &null and &plus4 ~= NULL
		%then
			%let _p4 = 1;
		%else
			%let _p4 = 0;

	%*I. Area Code;

		%if &area_code ~= &null
		%then
			%let _ac = 1;
		%else
			%let _ac = 0;

	%*J. Phone;

		%if &phone ~= &null
		%then
			%let _ph = 1;
		%else
			%let
				_ph = 0;

%************
*IV. MODIFY	*
*************;

	%*A. Zipcode Parse;

		%if &_z5=1 and &_p4=1 and &zip5 = &plus4 
		%then
			%do;
				%let _z5 = 0;
				%let _p4 = 0;

				data &lib..&data;
					set &lib..&data;
					length Zip5 $5;
					length Plus4 $4;

					if length(&zip5) = 4
					then
						do;
							Zip5 = cat("0",trim(&zip5));
							Plus4 = "";
						end;
					else
						do;
							Zip5 = substr(&zip5,1,5);

							if length(&zip5) lt 10
							then
								do;
									if length(&zip5) = 9 and %sysfunc(findc(&zip5, "-")) = 0
									then
										Plus4 = substr(&zip5,6,4);
									else
										Plus4 = "";
								end;
							else
								Plus4 = substr(&zip5,7,4);
						end;
				run;

				%data_error;
			%end;

	%*B. Zip Numeric Check;

		%*1. Zip5;

			%if &_z5 = 1
			%then
				%do;
					%let _dsid = %sysfunc(open(&lib..&data));
					%let _z5_pos = %sysfunc(varnum(&_dsid, &zip5));
					%if (%sysfunc(vartype(&_dsid,&_z5_pos)) = N)
					%then
						%do;
							%let _close = %sysfunc(close(&_dsid));

							data &lib..&data (drop=_z5);
								set &lib..&data (rename=(&zip5=_z5));
								length Zip5 $5;
								Zip5 = put(_z5, z5.);
							run;

							%data_error;
							
							%let _z5 = 0;

							%N_E_W(Zip5 Converted to Character, type=N);
						%end;
					%else
						%let _close = %sysfunc(close(&_dsid));
				%end;

		%*2. Plus4;

			%if &_p4 = 1
			%then
				%do;
					%let _dsid2 = %sysfunc(open(&lib..&data));
					%let _p4_pos = %sysfunc(varnum(&_dsid2, &plus4));
					%if (%sysfunc(vartype(&_dsid2,&_p4_pos)) = N)
					%then
						%do;
							%let _close2 = %sysfunc(close(&_dsid2));

							data &lib..&data (drop=_p4);
								set &lib..&data (rename=(&plus4=_p4));
								length Plus4 $4;
								Plus4 = put(_p4, z4.);
							run;

							%data_error;
							
							%let _p4 = 0;
						%end;
					%else
						%let _close2 = %sysfunc(close(&_dsid2));
				%end;

	%*C. Name Parse;

		%if &_f=1 and &_l=1 and &first = &last
		%then
			%do;
				%let _f = 0;
				%let _l = 0;

				data &lib..&data;
					set &lib..&data;
					length WordCount 3;
					length First $15;
					length Middle $15;
					length MI $1;
					length Last $30;
					length Suffix $5;
					length _name $50;

					_name = compress(upcase(&first), "&alpha", "k");
					word1 = trim(scan(_name, 1));
					word2 = trim(scan(_name, 2));
					word3 = trim(scan(_name, 3));
					word4 = trim(scan(_name, 4));
					word5 = trim(scan(_name, 5));
					WordCount = countw(_name);

					if WordCount = 1
					then
						do;
							First = "";
							Middle = "";
							MI = "";
							Last = word1;
							Suffix = "";
						end;
					else
						if WordCount = 2
						then
							do;
								First = word1;
								Middle = "";
								MI = "";
								Last = word2;
								Suffix = "";
							end;
						else
							if WordCount = 3
							then	
								do;
									if upcase(word3) in (&_suffix)
									then
										do;
											First = word1;
											Middle = "";
											MI = "";
											Last = word2;
											Suffix = word3;
										end;
									else
										do;
											if length(word2) = 1
											then
												do;
													First = word1;
													Middle = word2;
													MI = word2;
													Last = word3;
													Suffix = "";
												end;
											else
												do;
													if upcase(word2) in (&_last1)
													then
														do;
															if upcase(word2) in (&_last2)
															then
																do;
																	First = word1;
																	Middle = "";
																	MI = "";
																	Last = cat(trim(word2), trim(word3));
																	Suffix = "";
																end;
															else
																do;
																	First = word1;
																	Middle = "";
																	MI = "";
																	Last = catx(" ", word2, word3);
																	Suffix = "";
																end;
														end;
													else
														do;
															First = word1;
															Middle = word2;
															MI = substr(word2, 1, 1);
															Last = word3;
															Suffix = "";
														end;
												end;
										end;
								end;
							else
								if WordCount = 4
								then
									do;
										if upcase(word4) in (&_suffix)
										then
											do;
												if length(word2) = 1
												then
													do;
														First = word1;
														Middle = word2;
														MI = word2;
														Last = word3;
														Suffix = word4;
													end;
												else
													do;
														if upcase(word2) in (&_last1)
														then
															do;
																if upcase(word2) in (&_last2)
																then
																	do;
																		First = word1;
																		Middle = "";
																		MI = "";
																		Last = cat(trim(word2), trim(word3));
																		Suffix = word4;
																	end;
																else
																	do;
																		First = word1;
																		Middle = "";
																		MI = "";
																		Last = catx(" ", word2, word3);
																		Suffix = word4;
																	end;
															end;
														else;
															do;
																First = word1;
																Middle = word2;
																MI = substr(word2, 1, 1);
																Last = word3;
																Suffix = word4;
																Check = 1;
															end;
													end;
											end;
										else
											do;
												if length(word2) = 1
												then
													do;
														if upcase(word3) in (&_last1)
														then
															do;
																if upcase(word3) in (&_last2)
																then
																	do;
																		First = word1;
																		Middle = word2;
																		MI = word2;
																		Last = cat(trim(word3), trim(word4));
																		Suffix = "";
																	end;
																else;
																	do;
																		First = word1;
																		Middle = word2;
																		MI = word2;
																		Last = catx(" ", word3, word4);
																		Suffix = "";
																	end;
															end;
														else
															do;
																First = word1;
																Middle = word2;
																MI = word2;
																Last = catx(" ", word3, word4);
																Suffix = "";
																Check = 1;
															end;
													end;
												else;
													do;
														if upcase(word2) in (&_last1)
														then
															do;	
																First = word1;
																Middle = "";
																MI = "";
																Last = catx(" ", word2, word3, word4);
																Suffix = "";
																Check = 1;
															end;
														else
															do;
																if upcase(word3) in (&_last1)
																then
																	do;
																		if upcase(word3) in (&_last2)
																		then
																			do;
																				First = word1;
																				Middle = word2;
																				MI = substr(word2, 1, 1);
																				Last = cat(trim(word3), trim(word4));
																				Suffix = "";
																			end;
																		else
																			do;
																				First = word1;
																				Middle = word2;
																				MI = substr(word2, 1, 1);
																				Last = catx(" ", word3, word4);
																				Suffix = "";
																			end;
																	end;
																else
																	do;
																		First = word1;
																		Middle = word2;
																		MI = substr(word2, 1, 1);
																		Last = catx(" ", word3, word4);
																		Suffix = "";
																		Check = 1;
																	end;
															end;
													end;
											end;
									end;
								else
									if WordCount = 5
									then
										do;
											if upcase(word5) in (&_suffix)
											then
												do;
													if upcase(word3) in (&_last1)
													then
														do;
															if upcase(word3) in (&_last2)
															then
																do;
																	First = word1;
																	Middle = word2;
																	MI = substr(word2, 1, 1);
																	Last = cat(trim(word3), trim(word4));
																	Suffix = word5;
																end;
															else
																do;
																	First = word1;
																	Middle = word2;
																	MI = substr(word2, 1, 1);
																	Last = catx(" ", word3, word4);
																	Suffix = word5;
																end;
														end;
													else
														do;
															First = word1;
															Middle = word2;
															MI = substr(word2, 1, 1);
															Last = catx(" ", word3, word4);
															Suffix = word5;
															Check = 1;
														end;
												end;
											else
												do;
													First = word1;
													Middle = word2;
													MI = substr(word2, 1, 1);
													Last = catx(" ", word3, word4, word5);
													Suffix = "";
													Check = 1;
												end;
										end;
									else
										do;
											Error = 1;
										end;

				run;

				%data_error;

				proc sql noprint;
					select
						sum(check),
						sum(error)
					into
						:_check trimmed,
						:_error trimmed
					from
						&lib..&data
					;
				quit;

				%data_error;

				%N_E_W(There are &_check Records to Check|There are &_error Records with Errors, type=N);
			%end;
		
	%*D. Phone Number Parse;

		%if &_ac=1 and &_ph=1 and &area_code = &phone
		%then
			%do;
				%let _ac = 0;
				%let _ph = 0;

				data &lib..&data;
					set &lib..&data(%if %upcase(&phone) = PHONE_NUMBER %then %do; %let phone = org_phone; rename=(phone_number=org_phone) %end;);
					length Area_Code $3;
					length Phone_Number $7;

					_phone_ = compress(&phone, "1234567890", "k");
					if length(_phone_) = 10
					then
						do;
							Area_Code = substr(_phone_,1,3);
							Phone_Number = substr(_phone_,4,7);
						end;
					else
						if length(_phone_) = 7
						then
							do;
								Area_Code = "";
								Phone_Number = _phone_;
							end;
						else
							do;
								Area_Code = "";
								Phone_number = "";
							end;
				run;

				%data_error;
			%end;

	%*E. Null;

		%if &address2 = NULL or &plus4 = NULL
		%then
			%do;
				data &lib..&data;
					set &lib..&data;
					%if &address2 = NULL
					%then
						%do;
							length Address2 $35;
						%end;
					%if &plus4 = NULL
					%then
						%do;
							length Plus4 $4;
						%end;
				run;

				%data_error;
			%end;

	%*F. Rename;

		proc datasets
			library= &lib
			nolist;
			modify &data;
				%if &_f = 1 
				%then
					%do;
						rename &first = First;
					%end;
				%if &_l = 1 
				%then
					%do;
						rename &last = Last;
					%end;
				%if &_a1 = 1 
				%then
					%do;
						rename &address1 = Address1;
					%end;
				%if &_a2 = 1 
				%then
					%do;
						rename &address2 = Address2;
					%end;
				%if &_c = 1 
				%then
					%do;
						rename &city = City;
					%end;
				%if &_st = 1
				%then
					%do;
						rename &st = ST;
					%end;
				%if &_z5 = 1 
				%then
					%do;
						rename &zip5 = Zip5;
					%end;
				%if &_p4 = 1 
				%then
					%do;
						rename &plus4 = Plus4;
					%end;
				%if &_ac = 1 
				%then
					%do;
						rename &area_code = Area_Code;
					%end;
				%if &_ph = 1 
				%then
					%do;
						rename &phone = Phone_Number;
					%end;
		quit;

		%data_error;

	%*G. Remove Labels;

		%remove_labels_beta(dataset=&lib..&data);

	%*H. Capitalize;

		%capitalize(&lib..&data);

%mend Name_Map_Beta;
