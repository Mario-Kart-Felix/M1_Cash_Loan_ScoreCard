/* ----------------------------------------
�� SAS Enterprise Guide �����Ĵ���
DATE: 2017��8��25��     TIME: 14:46:23
PROJECT: M1�ֽ���������ֿ�_DCC_FP0818
PROJECT PATH: E:\git_space\M1_Cash_Loan_ScoreCard\Codes\M1�ֽ���������ֿ�_DCC_FP0818.egp
---------------------------------------- */

/* �޷�ȷ��Ҫ�ڡ�SASApp���Ϸ����߼��⡰LF���Ĵ��� */
/* �޷�ȷ��Ҫ�ڡ�SASApp���Ϸ����߼��⡰LF���Ĵ��� */
/* �޷�ȷ��Ҫ�ڡ�SASApp���Ϸ����߼��⡰LF���Ĵ��� */
/* �޷�ȷ��Ҫ�ڡ�SASApp���Ϸ����߼��⡰LF���Ĵ��� */
/* �޷�ȷ��Ҫ�ڡ�SASApp���Ϸ����߼��⡰LF���Ĵ��� */
/* �޷�ȷ��Ҫ�ڡ�SASApp���Ϸ����߼��⡰LF���Ĵ��� */
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

/*   �ڵ㿪ʼ: 03����������ŷ�����   */
%LET _CLIENTTASKLABEL='03����������ŷ�����';
%LET _CLIENTPROCESSFLOWNAME='������';
%LET _CLIENTPROJECTPATH='E:\git_space\M1_Cash_Loan_ScoreCard\Codes\M1�ֽ���������ֿ�_DCC_FP0818.egp';
%LET _CLIENTPROJECTNAME='M1�ֽ���������ֿ�_DCC_FP0818.egp';
%LET _SASPROGRAMFILE=;

GOPTIONS ACCESSIBLE;
******************************************************************************;                                                                                                                                
*** 03����������ŷ�����                                                   ***;                                                                                                                                 
******************************************************************************;   

****����������ŷ�����********************************************************;
/*���ú����*/
%let DSin   = lf.a0203_train; /*�������ݼ�*/
%let DVVar  = target;         /*�����*/
%let Method = 4;              /*1.���᷽�2.�ط��3.Ƥ��ɭ����ͳ������4.��Ϣֵ*/
%let Mmax   = 5;              /*����������*/

%let IVVar=person_sex; %let DSVarMap=lf.a0301_&IVVar._map; %ReduceCats(&DSin,&IVVar,&DVVar,&Method,&Mmax,&DSVarMap);
%let IVVar=family_state; %let DSVarMap=lf.a0301_&IVVar._map; %ReduceCats(&DSin,&IVVar,&DVVar,&Method,&Mmax,&DSVarMap);
%let IVVar=education; %let DSVarMap=lf.a0301_&IVVar._map; %ReduceCats(&DSin,&IVVar,&DVVar,&Method,&Mmax,&DSVarMap);
%let IVVar=is_ssi; %let DSVarMap=lf.a0301_&IVVar._map; %ReduceCats(&DSin,&IVVar,&DVVar,&Method,&Mmax,&DSVarMap);
%let IVVar=childrentotal; %let DSVarMap=lf.a0301_&IVVar._map; %ReduceCats(&DSin,&IVVar,&DVVar,&Method,&Mmax,&DSVarMap);
%let IVVar=other_person_type; %let DSVarMap=lf.a0301_&IVVar._map; %ReduceCats(&DSin,&IVVar,&DVVar,&Method,&Mmax,&DSVarMap);
%let IVVar=city; %let DSVarMap=lf.a0301_&IVVar._map; %ReduceCats(&DSin,&IVVar,&DVVar,&Method,&Mmax,&DSVarMap);
%let IVVar=is_insure; %let DSVarMap=lf.a0301_&IVVar._map; %ReduceCats(&DSin,&IVVar,&DVVar,&Method,&Mmax,&DSVarMap);


/*�鿴�������������*/
data var_list_char;
  input Var_Name $32.;
  cards;
person_sex
family_state
education
is_ssi
childrentotal
other_person_type
city
is_insure
  ;
run;

data _null_;                                          
  set var_list_char;                                          
  call symput('varn'||left(put(_n_,4.)),compress(_n_));                                                   
  call symput('name'||left(put(_n_,4.)),trim(Var_Name));                                                           
run;  
%put &=varn1 &=name1; 
%put &=varn2 &=name2; 

proc sql; 
select count(Var_Name) into: varnum_count from var_list_char; 
quit;   

%macro var_char_group;
proc sql;  
create table lf.a0302_var_char_group
(
  Var_Name  CHAR(32),
  Var_Value CHAR(60),
  total     INTEGER,
  Bin       INTEGER,
  Category  CHAR(60)
);

%do i= 1 %to &varnum_count.;
insert into lf.a0302_var_char_group
select distinct "&&name&i." as VAR_NAME
       ,strip(&&name&i.) as Var_Value
       ,total
       ,Bin
       ,strip(Category) as Category
from  lf.a0301_&&name&i.._map
;
%end;
quit;

%mend;
%var_char_group;





GOPTIONS NOACCESSIBLE;
%LET _CLIENTTASKLABEL=;
%LET _CLIENTPROCESSFLOWNAME=;
%LET _CLIENTPROJECTPATH=;
%LET _CLIENTPROJECTNAME=;
%LET _SASPROGRAMFILE=;

;*';*";*/;quit;run;
ODS _ALL_ CLOSE;
