

%macro data_check(dataset);
%************
*I. SETUP	*
*************;

	%*A. Local Variables;

		%local dataset data lib null _alphanumeric;

	%*B. Variables;

		%*1. Null;

			%let null = ;

		%*2. _AlphaNumeric;

			%let _AlphaNumeric = %str(ABCDEFGHIJKLMNOPQRSTUVXYZ_.);

	%*C. MACROS;
	
		%*1. N_E_W;

			%if %sysmacexist(N_E_W) = 0
			%then
				%do;
					%inc "T:\MKG\MACROS\GENERAL\n_e_w.sas"
					%N_E_W(MACRO N_E_W Compiled!, type=N);
				%end;

%********************
*II. Check Dataset	*
*********************;

	%*A. Check if Null;

		%if &dataset = &null
		%then
			%do;
				%N_E_W(No Dataset Provided, type=E);
				%let error_check = 1;
				%return;
			%end;

	%*B. Parse Dataset Name;

		%*1. Check for Invalid Characters;
		
			%if %verify(%upcase(&dataset), &_alphanumeric) > 0
			%then
				%do;
					%N_E_W(Invalid Characters in Variable|Dataset: %upcase(&dataset), type=E);
					%let error_check = 1;
					%return;
				%end;

		%*2. Parse Library and Dataset;

			%if %sysfunc(countc(%quote(&dataset), ".")) = 0
			%then
				%do;
					%let lib = WORK;
					%let data = &dataset;
				%end;
			%else
				%do;
					%if %sysfunc(countc(%quote(&dataset), ".")) = 1
					%then
						%do;
							%let lib = %scan(&dataset, 1);
							%let data = %scan(&dataset, 2);
						%end;
					%else
						%do;
							%N_E_W(Too Many Periods in DATASET, type=E);
							%let error_check = 1;
							%return;
						%end;
				%end;

		%*3. Check Library;

			%if &lib ~= WORK
			%then
				%do;
					%if %sysfunc(libref(&lib)) ~= 0
					%then
						%do;
							%N_E_W(Library "%upcase(&lib)" Does Not Exist, type=E);
							%let error_check = 1;
							%return;
						%end;
				%end;

		%*4. Check Dataset;

			%if %sysfunc(exist(&lib..&data)) ~= 1
			%then
				%do;
					%N_E_W(Dataset "%upcase(&data)" Does NOT Exist|In Library "%upcase(&lib)", type=E);
					%let error_check = 1;
					%return;
				%end;
			%else
				%do;
					%N_E_W(Dataset "%upcase(&data)" EXISTS|In Library "%upcase(&lib)", type=N);
					%return;
				%end;

%mend Data_Check;
