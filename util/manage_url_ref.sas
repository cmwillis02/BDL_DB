PROC IMPORT DATAFILE="/home/cwillis/BDL/data/reference/url.xlsx"
	DBMS=XLSX
	replace
	OUT=work.stage;
	GETNAMES=YES;
RUN;

data work.append;

infile datalines;
input year url league_id;

datalines;
2017 61 21676
;
run;

proc append base=work.stage data=work.append;
run;

proc sql;
create table bdlref.url as
select * from work.stage;
quit;
