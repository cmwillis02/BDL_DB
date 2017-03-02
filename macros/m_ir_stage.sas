%macro m_ir_stage(field,iterations);
%do I=1 %to &iterations;
data work.stage_&I;
	set work.transactions (keep=tranid franchise activated deactivated type);
	player= scan(&field,&I);
	if type='IR' and scan(&field,&I) ne '' then output;
run;
%end;
proc sql;
create table work.stage_&field as
select	t1.tranid,
		franchise,
		"&field" as type,
		t1.player
from work.stage_1 t1
union all
select	t2.tranid,
		franchise,
		"&field" as type,
		t2.player
from work.stage_2 t2
union all
select	t3.tranid,
		franchise,
		"&field" as type,
		t3.player
from work.stage_3 t3;
quit;
%mend m_ir_stage;
