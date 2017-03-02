PROC IMPORT DATAFILE="/home/cwillis/BDL/data/reference/xml_map.xlsx"
	DBMS=XLSX
	replace
	OUT=work.stage;
	GETNAMES=YES;
RUN;

/*data work.append;*/
/**/
/*infile datalines;*/
/*input program $ map_file $;*/
/**/
/*datalines;*/
/**/
/*;*/
/*run;*/
/**/
/*proc append base=work.stage data=work.append;*/
/*run;*/


proc sql;
create table bdlref.xml_map as
select * from work.stage;
quit;
