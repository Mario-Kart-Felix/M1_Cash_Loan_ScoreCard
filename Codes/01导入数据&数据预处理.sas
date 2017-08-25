/* ----------------------------------------
�� SAS Enterprise Guide �����Ĵ���
DATE: 2017��8��25��     TIME: 14:46:11
PROJECT: M1�ֽ���������ֿ�_DCC_FP0818
PROJECT PATH: E:\git_space\M1_Cash_Loan_ScoreCard\Codes\M1�ֽ���������ֿ�_DCC_FP0818.egp
---------------------------------------- */

/* �޷�ȷ��Ҫ�ڡ�SASApp���Ϸ����߼��⡰LF���Ĵ��� */
/* �޷�ȷ��Ҫ�ڡ�SASApp���Ϸ����߼��⡰LF���Ĵ��� */

/* ---------------------------------- */
/* MACRO: enterpriseguide             */
/* PURPOSE: define a macro variable   */
/*   that contains the file system    */
/*   path of the WORK library on the  */
/*   server.  Note that different     */
/*   logic is needed depending on the */
/*   server type.                     */
/* ---------------------------------- */
%macro enterpriseguide;
%global sasworklocation;
%local tempdsn unique_dsn path;

%if &sysscp=OS %then %do; /* MVS Server */
	%if %sysfunc(getoption(filesystem))=MVS %then %do;
        /* By default, physical file name will be considered a classic MVS data set. */
	    /* Construct dsn that will be unique for each concurrent session under a particular account: */
		filename egtemp '&egtemp' disp=(new,delete); /* create a temporary data set */
 		%let tempdsn=%sysfunc(pathname(egtemp)); /* get dsn */
		filename egtemp clear; /* get rid of data set - we only wanted its name */
		%let unique_dsn=".EGTEMP.%substr(&tempdsn, 1, 16).PDSE"; 
		filename egtmpdir &unique_dsn
			disp=(new,delete,delete) space=(cyl,(5,5,50))
			dsorg=po dsntype=library recfm=vb
			lrecl=8000 blksize=8004 ;
		options fileext=ignore ;
	%end; 
 	%else %do; 
        /* 
		By default, physical file name will be considered an HFS 
		(hierarchical file system) file. 
		*/
		%if "%sysfunc(getoption(filetempdir))"="" %then %do;
			filename egtmpdir '/tmp';
		%end;
		%else %do;
			filename egtmpdir "%sysfunc(getoption(filetempdir))";
		%end;
	%end; 
	%let path=%sysfunc(pathname(egtmpdir));
    %let sasworklocation=%sysfunc(quote(&path));  
%end; /* MVS Server */
%else %do;
	%let sasworklocation = "%sysfunc(getoption(work))/";
%end;
%if &sysscp=VMS_AXP %then %do; /* Alpha VMS server */
	%let sasworklocation = "%sysfunc(getoption(work))";                         
%end;
%if &sysscp=CMS %then %do; 
	%let path = %sysfunc(getoption(work));                         
	%let sasworklocation = "%substr(&path, %index(&path,%str( )))";
%end;
%mend enterpriseguide;

%enterpriseguide


/* Conditionally delete set of tables or views, if they exists          */
/* If the member does not exist, then no action is performed   */
%macro _eg_conditional_dropds /parmbuff;
	
   	%local num;
   	%local stepneeded;
   	%local stepstarted;
   	%local dsname;
	%local name;

   	%let num=1;
	/* flags to determine whether a PROC SQL step is needed */
	/* or even started yet                                  */
	%let stepneeded=0;
	%let stepstarted=0;
   	%let dsname= %qscan(&syspbuff,&num,',()');
	%do %while(&dsname ne);	
		%let name = %sysfunc(left(&dsname));
		%if %qsysfunc(exist(&name)) %then %do;
			%let stepneeded=1;
			%if (&stepstarted eq 0) %then %do;
				proc sql;
				%let stepstarted=1;

			%end;
				drop table &name;
		%end;

		%if %sysfunc(exist(&name,view)) %then %do;
			%let stepneeded=1;
			%if (&stepstarted eq 0) %then %do;
				proc sql;
				%let stepstarted=1;
			%end;
				drop view &name;
		%end;
		%let num=%eval(&num+1);
      	%let dsname=%qscan(&syspbuff,&num,',()');
	%end;
	%if &stepstarted %then %do;
		quit;
	%end;
%mend _eg_conditional_dropds;


/* save the current settings of XPIXELS and YPIXELS */
/* so that they can be restored later               */
%macro _sas_pushchartsize(new_xsize, new_ysize);
	%global _savedxpixels _savedypixels;
	options nonotes;
	proc sql noprint;
	select setting into :_savedxpixels
	from sashelp.vgopt
	where optname eq "XPIXELS";
	select setting into :_savedypixels
	from sashelp.vgopt
	where optname eq "YPIXELS";
	quit;
	options notes;
	GOPTIONS XPIXELS=&new_xsize YPIXELS=&new_ysize;
%mend _sas_pushchartsize;

/* restore the previous values for XPIXELS and YPIXELS */
%macro _sas_popchartsize;
	%if %symexist(_savedxpixels) %then %do;
		GOPTIONS XPIXELS=&_savedxpixels YPIXELS=&_savedypixels;
		%symdel _savedxpixels / nowarn;
		%symdel _savedypixels / nowarn;
	%end;
%mend _sas_popchartsize;


ODS PROCTITLE;
OPTIONS DEV=ACTIVEX;
GOPTIONS XPIXELS=0 YPIXELS=0;
FILENAME EGSRX TEMP;
ODS tagsets.sasreport13(ID=EGSRX) FILE=EGSRX
    STYLE=HtmlBlue
    STYLESHEET=(URL="file:///D:/SASHome/SASEnterpriseGuide/7.1/Styles/HtmlBlue.css")
    NOGTITLE
    NOGFOOTNOTE
    GPATH=&sasworklocation
    ENCODING=UTF8
    options(rolap="on")
;

/*   �ڵ㿪ʼ: 01��������&����Ԥ����   */
%LET _CLIENTTASKLABEL='01��������&����Ԥ����';
%LET _CLIENTPROCESSFLOWNAME='������';
%LET _CLIENTPROJECTPATH='E:\git_space\M1_Cash_Loan_ScoreCard\Codes\M1�ֽ���������ֿ�_DCC_FP0818.egp';
%LET _CLIENTPROJECTNAME='M1�ֽ���������ֿ�_DCC_FP0818.egp';
%LET _SASPROGRAMFILE=;

GOPTIONS ACCESSIBLE;
******************************************************************************;                                                                                                                                
*** 01��������&����Ԥ����                                                  ***;                                                                                                                                 
******************************************************************************; 

****��������******************************************************************;
proc sql;                                                                                                                               
create table f15.lf_xj_base_m1_dcc_cn_4 as                                                                                                              
select *
from tmp_dcc.tm1m3_lf_xj_base_m1_dcc
       (dbsastype=(
contract_no          ='char(30)'
putout_date          ='char(10)' 
state_date           ='char(10)'     
customerid           ='char(20)'     
acct_loan_no         ='char(30)'
person_sex           ='char(2)' 
family_state         ='char(20)'     
education            ='char(20)' 
other_person_type    ='char(20)'     
city                 ='char(60)'
is_ssi               ='char(2)'
is_insure            ='char(2)'
childrentotal        ='char(8)'  
        ));
quit; 


data f15.lf_xj_base_m1_dcc_cn_4;
set f15.lf_xj_base_m1_dcc_cn_4;
label DELAY_DAYS_RATE      ='��ʷ��������/��������     '; 
label BPTP_RATIO           ='BPTP����                  ';
label PAY_DELAY_NUM        ='�ۻ������ɽ����          ';
label MAX_CONDUE10         ='��ʷ�����������10�������';
label DK_RATIO             ='����ʧ�ܱ���              ';
label CS_TIMES             ='��ʷ�ܴ��մ���            ';
label CONTACT              ='��ʷ��������              ';
label PAY_DELAY_FEE        ='�ۻ������ɽ���          ';
label DELAY_DAYS           ='��������״̬������        ';
label HIS_DELAYDAYS        ='�����ڴε�����ͣ������֮��';
label MAX_ROLL_SEQ         ='����������              ';
label CON10_DUE_TIMES      ='��ʷ��������10��Ĵ���    ';
label AVG_DAYS             ='ƽ��ÿ������ͣ������      ';
label PTP_RATIO            ='PTP����                   ';
label AVG_ROLLSEQ          ='��ʷ����ƽ������          ';
label MAX_CPD              ='��ʷ�������cs_cpd        ';
label BPTP                 ='BPTP����                  ';
label SEQ_DUEDAYS          ='��������                  ';
label PTP                  ='PTP����                   ';
label HIS_PTP              ='��ʷPTP����������         ';
label ROLL_SEQ             ='�ۼƻ�������              ';
label ROLL_TIME            ='���˴���                  ';
label FINISH_PERIODS_RATIO ='ʵ��������                ';
label PERSON_SEX           ='�Ա�                      ';
label EDUCATION            ='�����̶�                  ';
label PERSON_APP_AGE       ='����                      ';
label CITY                 ='����                      ';
label FAMILY_STATE         ='����״̬                  ';
label OTHER_PERSON_TYPE    ='������ϵ������            ';
label CONTRACT_NO          ='��ͬ��                    ';
label PUTOUT_DATE          ='�ſ���                    ';
label STATE_DATE           ='�۲���                    ';
label CUSTOMERID           ='�ͻ�ID                    ';
label ACCT_LOAN_NO         ='�ſ��                    ';
label CPD                  ='CPD                       ';
label TARGET               ='Yֵ                       ';
label LOST= '��ʷ��ȫʧ������';
label CSFQ= '��ʷ����Ƶ��';
label INCM_TIMES= '�������';
label DUE_CSTIME_RATIO= '��ǰǷ����/�ܴ�������';
label DUE_CONTACT_RATIO= '��ǰǷ����/��������';
label DUE_PTP_RATIO= '��ǰǷ����/PTP����';
label KPTP= 'KPTP����';
label MAX_OVERDUE= '��ʷ������ڽ��          ';
label DELAY_TIMES= '��������״̬�Ĵ�����cpd1�����㣩';
label VALUE_BALANCE_RATIO= 'Ӧ�����ȴ������';
label CREDIT_AMOUNT= '������';
label APR_CREDIT_AMT= 'ͨ���ܴ�����';
label CHILDRENTOTAL= '��Ů����';
label IS_SSI= '�Ƿ��籣';
label IS_INSURE= '�Ƿ�����';
run;



proc sql;/*����oracle���ݱ�*/
create table lf.a0100_mst_ds as select * from f15.lf_xj_base_m1_dcc_cn_4 where target>=0 ;
quit;
/*�� 2304367 �У�36 ��*/

/*�õ������ֵ�*/
proc contents data=lf.a0100_mst_ds out=lf.a0100_mst_dict; run;
proc sort data=lf.a0100_mst_dict;by VARNUM; run;


****����̽��******************************************************************;
%let var_cont_list = TARGET
person_app_age
cs_times
csfq
contact
lost
ptp
his_ptp
incm_times
kptp
bptp
avg_days
delay_days
delay_days_rate
max_condue10
con10_due_times
seq_duedays
max_roll_seq
value_balance_ratio
due_cstime_ratio
due_contact_ratio
due_ptp_ratio
avg_rollseq
roll_time
roll_seq
his_delaydays
pay_delay_num
pay_delay_fee
apr_credit_amt
credit_amount
delay_times
max_cpd
max_overdue
ptp_ratio
bptp_ratio
finish_periods_ratio
dk_ratio
;

%let var_disc_list = TARGET
person_sex
family_state
education
is_ssi
childrentotal
other_person_type
city
is_insure

;


/*1.1 �����������ݱ�������һ��ķֲ�ͳ��----means����*/
/*DZ:���ڿɿ��ֲ��ȶ���*/
ods HTML file="&output_file./01_1_EDA_mean.xls";/*2ģ�ͱ�����ֵ����--1_2_EDA_mean.xls*/
proc means data =  lf.a0100_mst_ds   /*QMETHOD=P2*/  n nmiss mean median min max p5 p10 p25 p50 p75 p90 p95;
var &var_cont_list.;   
run;
ods html close;

/*1.2��������ɢ��������һ��ķֲ�ͳ��----freq����*/
ods HTML file="&output_file./01_2_EDA_freq.xls";/*3ģ�ͷ������Ƶ������--1_3_EDA_freq.xls*/
proc freq data =  lf.a0100_mst_ds;
tables &var_disc_list.; /*��ɢ��������*/
run;
ods html close;

/*1.5 ����������ֵ��������������һ��ķֲ�ͳ��----univariate����*/
ods HTML file="&output_file./01_5_EDA_univ.xls";/*1ģ�͵���������--1_1_EDA_univ.xlsx*/
proc univariate data =  lf.a0100_mst_ds;
var &var_cont_list;   
run;
ods html close; 


****ȱʧֵ����****************************************************************;
data lf.a0101_mst_ds_process;
  set lf.a0100_mst_ds;
  month_diff = (substr(state_date,1,4) - substr(putout_date,1,4))*12 + (substr(state_date,6,2) - substr(putout_date,6,2));
  if month_diff >= 2;
  drop month_diff;
  /*�쳣ֵ����*/
  if childrentotal <0 then childrentotal="0";
  if state_date < '2017-07-01';
run;

/*�������ȱʧֵ����*/
/*ԭ��:��ɢ����ȱʧֵ����ȱʧֵ����1%�����ǵ������顣ȱʧֵ����1%�������������*/

/*Ƶ��ȱʧ�����������ȱʧ��<=1%)*/
%let Dsin=lf.a0101_mst_ds_process     ; %let DSout=lf.a0101_mst_ds_process_temp; %let Xvar=family_state; %let Value=; %let Method=1; %SubCat(&DSin,&Xvar,&Method,&Value,&DSout);
%let Dsin=lf.a0101_mst_ds_process_temp; %let DSout=lf.a0101_mst_ds_process     ; %let Xvar=education; %let Value=; %let Method=1; %SubCat(&DSin,&Xvar,&Method,&Value,&DSout);
%let Dsin=lf.a0101_mst_ds_process     ; %let DSout=lf.a0101_mst_ds_process_temp; %let Xvar=is_ssi; %let Value=; %let Method=1; %SubCat(&DSin,&Xvar,&Method,&Value,&DSout);
%let Dsin=lf.a0101_mst_ds_process_temp; %let DSout=lf.a0101_mst_ds_process     ; %let Xvar=childrentotal; %let Value=; %let Method=1; %SubCat(&DSin,&Xvar,&Method,&Value,&DSout);
%let Dsin=lf.a0101_mst_ds_process     ; %let DSout=lf.a0101_mst_ds_process_temp; %let Xvar=other_person_type; %let Value=; %let Method=1; %SubCat(&DSin,&Xvar,&Method,&Value,&DSout);
%let Dsin=lf.a0101_mst_ds_process_temp; %let DSout=lf.a0101_mst_ds_process     ; %let Xvar=is_insure; %let Value=; %let Method=1; %SubCat(&DSin,&Xvar,&Method,&Value,&DSout);


ods HTML file="&output_file./01_3_EDA_freq_process.xls";
proc freq data =  lf.a0101_mst_ds_process;
tables &var_disc_list.; /*��ɢ��������*/
run;
ods html close;


/*��������ȱʧֵ����*/
/*����λ����������ȱʧֵ����5%�������עһ�� ������ģ�͡�*/
data lf.a0101_mst_ds_process2;
  set lf.a0101_mst_ds_process;
run;

%let Dsin=lf.a0101_mst_ds_process2     ; %let DSout=lf.a0101_mst_ds_process2_temp; %let Xvar=cs_times; %let Value=0; %let Method=value; %SubCont(&DSin,&Xvar,&Method,&Value,&DSout);
%let Dsin=lf.a0101_mst_ds_process2_temp; %let DSout=lf.a0101_mst_ds_process2     ; %let Xvar=csfq; %let Value=0; %let Method=value; %SubCont(&DSin,&Xvar,&Method,&Value,&DSout);
%let Dsin=lf.a0101_mst_ds_process2     ; %let DSout=lf.a0101_mst_ds_process2_temp; %let Xvar=contact; %let Value=0; %let Method=value; %SubCont(&DSin,&Xvar,&Method,&Value,&DSout);
%let Dsin=lf.a0101_mst_ds_process2_temp; %let DSout=lf.a0101_mst_ds_process2     ; %let Xvar=lost; %let Value=0; %let Method=value; %SubCont(&DSin,&Xvar,&Method,&Value,&DSout);
%let Dsin=lf.a0101_mst_ds_process2     ; %let DSout=lf.a0101_mst_ds_process2_temp; %let Xvar=ptp; %let Value=0; %let Method=value; %SubCont(&DSin,&Xvar,&Method,&Value,&DSout);
%let Dsin=lf.a0101_mst_ds_process2_temp; %let DSout=lf.a0101_mst_ds_process2     ; %let Xvar=his_ptp; %let Value=0; %let Method=value; %SubCont(&DSin,&Xvar,&Method,&Value,&DSout);
%let Dsin=lf.a0101_mst_ds_process2     ; %let DSout=lf.a0101_mst_ds_process2_temp; %let Xvar=incm_times; %let Value=0; %let Method=value; %SubCont(&DSin,&Xvar,&Method,&Value,&DSout);
%let Dsin=lf.a0101_mst_ds_process2_temp; %let DSout=lf.a0101_mst_ds_process2     ; %let Xvar=kptp; %let Value=0; %let Method=value; %SubCont(&DSin,&Xvar,&Method,&Value,&DSout);
%let Dsin=lf.a0101_mst_ds_process2     ; %let DSout=lf.a0101_mst_ds_process2_temp; %let Xvar=bptp; %let Value=0; %let Method=value; %SubCont(&DSin,&Xvar,&Method,&Value,&DSout);
%let Dsin=lf.a0101_mst_ds_process2_temp; %let DSout=lf.a0101_mst_ds_process2     ; %let Xvar=value_balance_ratio; %let Value=0; %let Method=value; %SubCont(&DSin,&Xvar,&Method,&Value,&DSout);
%let Dsin=lf.a0101_mst_ds_process2     ; %let DSout=lf.a0101_mst_ds_process2_temp; %let Xvar=due_cstime_ratio; %let Value=0; %let Method=value; %SubCont(&DSin,&Xvar,&Method,&Value,&DSout);
%let Dsin=lf.a0101_mst_ds_process2_temp; %let DSout=lf.a0101_mst_ds_process2     ; %let Xvar=due_contact_ratio; %let Value=0; %let Method=value; %SubCont(&DSin,&Xvar,&Method,&Value,&DSout);
%let Dsin=lf.a0101_mst_ds_process2     ; %let DSout=lf.a0101_mst_ds_process2_temp; %let Xvar=due_ptp_ratio; %let Value=0; %let Method=value; %SubCont(&DSin,&Xvar,&Method,&Value,&DSout);
%let Dsin=lf.a0101_mst_ds_process2_temp; %let DSout=lf.a0101_mst_ds_process2     ; %let Xvar=avg_rollseq; %let Value=0; %let Method=value; %SubCont(&DSin,&Xvar,&Method,&Value,&DSout);
%let Dsin=lf.a0101_mst_ds_process2     ; %let DSout=lf.a0101_mst_ds_process2_temp; %let Xvar=ptp_ratio; %let Value=0; %let Method=value; %SubCont(&DSin,&Xvar,&Method,&Value,&DSout);
%let Dsin=lf.a0101_mst_ds_process2_temp; %let DSout=lf.a0101_mst_ds_process2     ; %let Xvar=bptp_ratio; %let Value=0; %let Method=value; %SubCont(&DSin,&Xvar,&Method,&Value,&DSout);
%let Dsin=lf.a0101_mst_ds_process2     ; %let DSout=lf.a0101_mst_ds_process2_temp; %let Xvar=dk_ratio; %let Value=0; %let Method=value; %SubCont(&DSin,&Xvar,&Method,&Value,&DSout);

data lf.a0101_mst_ds_process2;
  set lf.a0101_mst_ds_process2_temp;
run;


ods HTML file="&output_file./01_4_EDA_mean_process.xls";
proc means data =  lf.a0101_mst_ds_process2  n nmiss mean median min max p5 p10 p25 p50 p75 p90 p95;
var &var_cont_list.;   
run;
ods html close;


GOPTIONS NOACCESSIBLE;
%LET _CLIENTTASKLABEL=;
%LET _CLIENTPROCESSFLOWNAME=;
%LET _CLIENTPROJECTPATH=;
%LET _CLIENTPROJECTNAME=;
%LET _SASPROGRAMFILE=;

;*';*";*/;quit;run;
ODS _ALL_ CLOSE;
