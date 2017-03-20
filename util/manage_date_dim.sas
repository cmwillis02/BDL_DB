FILENAME REFFILE '/home/cwillis/BDL/data/reference/Week_dim.xlsx';

PROC IMPORT DATAFILE=REFFILE
	DBMS=XLSX
	OUT=WORK.IMPORT1
	REPLACE;
	GETNAMES=YES;
RUN;


data work.dates;
	set work.import1;
	retain key date date_new;
	key+1;
	if date ne . then date_new = date+4;
	if date eq . then date_new = date_new + 7;
	last_date=lag1(date_new);

	
run;
proc sql;
create table work.stage as
select	year,
		week,
		key as week_key,
		case
			when year=2009 and week =1 then '01Jan2009'd
			when year<>2009 and week = 1 then intnx('day',last_date,1)
			when week<>1 then intnx('day',last_date,1)
		end format=date9. as start_date,
		date_new format=date9. as end_date
from work.dates;
quit;

proc sql;
create table bdl.dim_weeks as
select *
from work.stage;
quit;
