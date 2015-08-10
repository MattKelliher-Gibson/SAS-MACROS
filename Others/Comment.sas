%*****************************************************************************
******************************************************************************
** MACRO: Comment															**
** Purpose:	Creates Custom Box with Comment in Log			 				**
** Created: 01/01/2014 (when brought to SourceLink)							**
** Created by: Pete Lund													**
** Last Modified: 07/30/2014 (Matt)											**
** Stage: Live																**
** Parameters:																**
**		Args -	Free Text to Write and Code Comments						**
** MACROS Used: 															**
**		%Repeat																**
**		%LeftTrim															**
******************************************************************************
******************************************************************************;

%*****************************************************
******************************************************
** Version History:									**
** 1.00 - 01/01/2014 - Original File 				**
** 1.01 - 07/30/2014 - Moved to Stand Alone File	**
** 1.10 - 07/30/2014 - Added %includes for MACROS	**
******************************************************
******************************************************;

	%macro Comment(Args) / pbuff /*store source des = "Only for AUTOEXEC.sas"*/;
		%if %sysmacexist(repeat) = 0
		%then
			%include "T:\MKG\MACROS\GENERAL\repeat.sas";

		%if %sysmacexist(TrimLeft) = 0
		%then
			%include "T:\MKG\MACROS\GENERAL\TrimLeft.sas";

		%let DLMpos = %index(%upcase(&syspbuff),DLM=);

		%if &DLMpos ne 0 
		%then 
			%let DLM = %qsubstr(&syspbuff,&DLMpos+4,1);
		%else 
			%let DLM = %str(,);

		%do _i = 1 %to %length(&syspbuff) - 1;
			%if %qsubstr(&syspbuff,&_i,2) eq %str(%str(&DLM)%str(&DLM)) 
			%then
				%let syspbuff = %qsubstr(&syspbuff,1,&_i)%str(.)%qsubstr(&syspbuff,&_i+1);
		%end;

		%if &DLMpos gt 0 
		%then
			%let _incom_ = %substr(&syspbuff,2,%eval(%length(&syspbuff)-8));
		%else 
			%let _incom_ = %substr(&syspbuff,2,%eval(%length(&syspbuff)-2));

		%let _stop_ = %length(&_incom_);

		%let _HdrLen_ = 0;

		%let _indent_ = 0;

		%do _i_ = 1 %to &_stop_ ;
			%let _ins_&_i_ = %TrimLeft(%qscan(%quote(&_incom_),&_i_,%str(&DLM)));

			%if &&_ins_&_i_ eq 
			%then
				%do;
					%let _Lines_ = %eval(&_i_ - 1);

					%let _i_ = &_stop_;
				%end;
			%else 
				%if &&_ins_&_i_ ne . 
				%then
					%do;
						%if %index(&&_ins_&_i_,/I) eq 1 
						%then
								%let _indent_ = %substr(&&_ins_&_i_,3);
						%else 
								%if %qsubstr(&&_ins_&_i_,1,1) eq %quote(/) 
								%then
									%let _indent_ = 0;
						%if %eval(%length(&&_ins_&_i_) + &_indent_) gt &_HdrLen_
						%then
							%let _HdrLen_ = %eval(%length(&&_ins_&_i_) + &_indent_);
					%end;
		%end;

		%let _Border_ = %repeat(*,&_HdrLen_ + 4);

		%put ;
		%put &_Border_;

		%let _SetInd_ = 0;

		%do _i_ = 1 %to &_Lines_;
			%if &&_ins_&_i_ eq . 
			%then
				%put * %repeat(,&_HdrLen_+1)*;
			%else 
				%if &&_ins_&_i_ eq %quote(/D) 
				%then
					%put *%repeat(-,%eval(&_HdrLen_ + 2))*;
				%else 
					%if &&_ins_&_i_ eq %quote(/H) 
					%then
						%put &_Border_;
					%else 
						%if &&_ins_&_i_ eq %quote(/C) 
						%then
							%let _SetInd_ = %nrstr(%eval((&_HdrLen_ - %length(&&_ins_&_i_)) / 2));
						%else 
							%if &&_ins_&_i_ eq %quote(/c) or &&_ins_&_i_ eq %quote(/L) 
							%then
								%let _SetInd_ = 0;
							%else 
								%if &&_ins_&_i_ eq %quote(/R) 
								%then
									%let _SetInd_ = %nrstr(%quote(%eval((&_HdrLen_ - %length(&&_ins_&_i_)))));
								%else 
									%if %index(&&_ins_&_i_,/I) eq 1 
									%then
										%let _SetInd_ = %substr(&&_ins_&_i_,3);
									%else
										%do;
											%let _indent_ = %eval(%unquote(&_SetInd_) + 1);
											%put *%repeat(,&_indent_)&&_ins_&_i_%repeat(,(((&_HdrLen_-%length(&&_ins_&_i_))+1)-(&_indent_-1)))*;
										%end;
		%end;

		%put &_Border_;
		%put ;

		%quit:

	%mend;
