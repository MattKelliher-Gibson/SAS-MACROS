%*****************************************************************************
******************************************************************************
** MACRO: Time                                                              **
** Description:	Prints Current Time, Date, and Message to Log               **
** Created: 04/02/2014                                                      **
** Created by: Matthew Kelliher-Gibson                                      **
** Parameters:                                                              **
**    message:  Message to appear before time                               **
** MACROS Used:                                                             **
**    %N_E_W                                                                **
******************************************************************************
** Version History:                                                         **
** 0.1.0 - 04/02/2014 - Inital File                                         **
** 0.2.0 - 08/22/2016 - Change parameter from process to custom message     **
******************************************************************************;

%macro Time(message);
%local mesasge;

%let _time = %sysfunc(time(),timeAMPM8.0);
%let _date = %sysfunc(date(),weekdate29.);
%put;
%put;
%N_E_W(&message |%nrstr(&_time) %nrstr(&_date), type=N);

%mend Time;
