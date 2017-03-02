PROC IMPORT DATAFILE="/home/cwillis/BDL/data/reference/playoff_reference.xlsx"
	DBMS=XLSX
	replace
	OUT=work.stage;
	GETNAMES=YES;
RUN;

data work.stage (drop=home away);
	set work.stage;
run;

data work.append;

infile datalines missover delimiter=',';
input year week home_id away_id;

datalines;
2016,14,4,8
2016,14,6,7
2016,15,2,4
2016,15,5,6
2016,16,6,2
;
run;

proc append base=bdlref.playoff_reference data=work.append;
run;
