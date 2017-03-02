%macro m_compile(type);
%let yr9=%sysfunc(CAT(&type,_2009));
%let yr10=%sysfunc(CAT(&type,_2010));
%let yr11=%sysfunc(CAT(&type,_2011));
%let yr12=%sysfunc(CAT(&type,_2012));
%let yr13=%sysfunc(CAT(&type,_2013));
%let yr14=%sysfunc(CAT(&type,_2014));
%let yr15=%sysfunc(CAT(&type,_2015));
%let yr16=%sysfunc(CAT(&type,_2016));
/*%let yr17=%sysfunc(CAT(&type,_2017));*/
Proc sql;
create table work.&type as
select * from work.&yr9
union all
select * from work.&yr10
union all
select * from work.&yr11
union all
select * from work.&yr12
union all
select * from work.&yr13
union all
select * from work.&yr14
union all
select * from work.&yr15
union all
select * from work.&yr16
/*union all*/
/*select * from work.&yr17*/
;quit;
%mend m_compile;
