


%macro trim_pfr(type);
proc sql;
create table work.stage as
select	t1.*,
		ifc(t2.id is null,'No Rec','') as check	
from stage.stg_pfr_&type t1
left join stage.stg_pfr_reference t2 on (t2.id = t1.id)
order by id;
quit;

data stage.stg_pfr_&type(drop=check) work.norec (keep=id first_name last_name position check);
	set work.stage;
	by id;

	if last.id and check = 'No Rec' then output work.norec;
	if check = '' then output stage.stg_pfr_&type;
run;

data work.append(drop=check) work.check;
	set work.norec;

	if position in ('WR','TE','RB','QB') or check = '' then output work.append;
	if position = '' then output work.check;

run;

%mend trim_pfr;

%trim_pfr(passing);
%trim_pfr(rushing);
%trim_pfr(receiving);

proc sql;
create table work.append as
select id,
		first_name,
		last_name,
		position
from work.check
where check='';
quit;

/*proc append base=bdl.pfr_reference data=work.append force;*/
/*run;*/


proc datasets kill lib=work;
run;

/* check for Duplicate Records */

proc sort data=bdl.pfr_reference nodupkey dupout=work.dups out=work.sorted;
by id;
run;

/*proc sql;*/
/**/
/*delete from bdl.pfr_reference where id in (select id from work.dups);*/
/**/
/*quit;*/

