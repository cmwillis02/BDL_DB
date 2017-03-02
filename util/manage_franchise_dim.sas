PROC IMPORT DATAFILE="/home/cwillis/BDL/data/reference/franchise_ref.xlsx"
	DBMS=XLSX
	replace
	OUT=work.stage;
	GETNAMES=YES;
RUN;

data work.stage;
	set work.stage;
	twitter='';
run;

proc sql;
create table stage.stg_dim_franchise as
select *
from work.stage;
quit;
