%macro check_macros(macros);
	%local macros _macro _i;
	%let _i = ;

	%do %while(&_macro ne %scan(&macros, -1));
		%let _i = %eval(&_i + 1);
		%let _macro = %scan(&macros, &_i);

		%if %sysmacexist(&_macro) = 0
		%then
			%do;
				%put ERROR: %nrstr(******************************);
				%put ERROR- MACRO &_macro is not compiled!;
				%put ERROR- Program will terminate;
				%put ERROR: %nrstr(******************************);
				
				%abort;
			%end;
	%end;

	%put NOTE: %nrstr(******************************);
	%put NOTE- All MACROS compiled!;
	%put NOTE: %nrstr(******************************);
%mend check_macros;
