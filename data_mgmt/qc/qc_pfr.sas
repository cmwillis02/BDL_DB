proc sql;
create table work.stage as
select	t1.id,
		t2.id as pass_id,
		t2.year,
		t2.first_name,
		t2.last_name,
		t2.attempts
from stage.stg_pfr_reference t1
full join stage.stg_pfr_passing t2 on (t2.id = t1.id)
where t1.id is null;
quit;

proc sql;

delete from stage.stg_pfr_passing where id in (select pass_id from work.stage);

run;

proc sql;
create table work.stage as
select	t1.id,
		t2.id as pass_id,
		t2.year,
		t2.first_name,
		t2.last_name,
		t2.attempts
from stage.stg_pfr_reference t1
full join stage.stg_pfr_rushing t2 on (t2.id = t1.id)
where t1.id is null;
quit;
