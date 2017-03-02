/* Load DB Tables */

proc sql;
create table work.table_list as
select * from sashelp.vmember
where libname = 'STAGE' and memname like ("STG%");
quit;

data _null_;
	set work.table_list end=eof;
	retain count;
	by memname;

	if first.memname then do;
		count + 1;
		t=cat('t_',count);
		call symputx(t,memname)
		;
	end;

	if eof then do;
		call symputx('count',count);
	end;

run;

%macro load_core;

%do i = 1 %to &count %by 1;

	
	%let table_ref=%substr(&&t_&i,5,%length(&&t_&i)-3);

	proc sql;
	create table bdl.&table_ref as
	select * from stage.&&t_&i;
	quit;

%end;

%mend load_core;
%load_core;
