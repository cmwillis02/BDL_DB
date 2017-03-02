PROC IMPORT DATAFILE='/home/cwillis/BDL/data/reference/Week_dim.xlsx'
	DBMS=XLSX
	REPLACE
	OUT=WORK.stage;
	GETNAMES=YES;
RUN;

data work.stage2;
	set work.stage;
	retain start_date;

		start_date2='01Jan2000'd;
		start_date3=lag1(date) + 1;
		start_date=coalesce(start_date3,start_date2);
		
run;

proc sql;
create table stage.stg_dim_weeks as
select	year,
		week,
		week_key,
		date format=date9. as date,
		start_date format=date9. as start_date
from work.stage2;
quit;