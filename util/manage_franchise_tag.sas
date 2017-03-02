PROC IMPORT DATAFILE="/home/cwillis/BDL/data/reference/Franchise_tag_ref.xlsx"
	DBMS=XLSX
	replace
	OUT=work.stage;
	GETNAMES=YES;
RUN;



proc sql;
create table bdlref.franchise_tag as
select *
from work.stage;
quit;
