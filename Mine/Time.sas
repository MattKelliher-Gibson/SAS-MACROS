
%macro Time(process);
%local process;

%let _time = %sysfunc(time(),timeAMPM8.0);
%let _date = %sysfunc(date(),weekdate29.);
%put;
%put;
%N_E_W(&process Process Began at:|%nrstr(&_time) %nrstr(&_date), type=N);

%mend Time;
