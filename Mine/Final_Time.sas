
%macro final_time;
	%local _endtime _enddate;
	%let _endtime = %sysfunc(time(),timeAMPM8.0);
	%let _enddate = %sysfunc(date(),weekdate29.);
	%put;
	%N_E_W(Process Started at:|%nrstr(&_time) %nrstr(&_date)|Process Ended at:|%nrstr(&_endtime) %nrstr(&_enddate), type=N);
%mend final_time;
