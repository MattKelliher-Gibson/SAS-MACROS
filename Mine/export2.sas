%macro export2(dataset, file, replace= replace, dbms=xlsx);
	%local dataset file replace dbms;
	
	proc export
		data= &dataset
		outfile = &file
		dbms = &dbms
		&replace;
	run;
%mend export2;
