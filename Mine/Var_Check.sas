%macro Var_Check(dataset, var);

%local dataset var data data2;

%let data = %sysfunc(open(&dataset));
%if (&data)
%then
	%do;
		%if %sysfunc(varnum(&data, %upcase(&var)))
		%then
			%N_E_W(Variable "%upcase(&var)" Exists!, type=N);
		%else
			%do;
				%N_E_W(Variable "%upcase(&var)" Does NOT Exist!, type=E);
				%let error_check = 1;
			%end;
		%let data2 = %sysfunc(close(&data));
	%end;
%else
	%do;
		%N_E_W(Unable to Open Dataset "%upcase(&dataset)", type=E);
		%let error_check = 1;
	%end;

%mend Var_Check;
