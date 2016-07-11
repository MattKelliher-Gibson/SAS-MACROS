%macro reset_macro_var/parmbuff;
	%local __l syspbuff total_vars;

	%let total_vars = %sysfunc(countw(&syspbuff));

	%do __l = 1 %to &total_vars;
		%let %scan(&syspbuff, &__l) = ;
	%end;
%mend reset_macro_var;
