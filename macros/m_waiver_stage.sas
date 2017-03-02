%macro m_waiver_stage(field, iterations);
%do I = 1 %to &iterations;
data work.stage_&I;
	set work.transactions (keep=tranid franchise added dropped type);
	player= scan(&field,&I);
	if type='WAIVER' and scan(&field,&I) ne '' then output;
run;
%end;
%if &field = 'added' %then %do;
proc sql;
create table work.stage_&field as
select	t1.tranid,
		franchise,
		"&field" as sub_type,
		t1.player
From work.stage_1 t1
UNION ALL
Select	t2.tranid,
		franchise,
		"&field" as sub_type,
		t2.player
from work.stage_2 t2
UNION ALL
select	t3.tranid,
		franchise,
		"&field" as sub_type,
		t3.player
from work.stage_3 t3;
quit;
%end;
%else %do;
proc sql;
create table work.stage_&field as
select	t1.tranid,
		franchise,
		"&field" as sub_type,
		t1.player
From work.stage_1 t1
UNION ALL
Select	t2.tranid,
		franchise,
		"&field" as sub_type,
		t2.player
from work.stage_2 t2
UNION ALL
select	t3.tranid,
		franchise,
		"&field" as sub_type,
		t3.player
from work.stage_3 t3
UNION ALL
select	t4.tranid,
		franchise,
		"&field" as sub_type,
		t4.player
from work.stage_4 t4
UNION ALL
select	t5.tranid,
		franchise,
		"&field" as sub_type,
		t5.player
from work.stage_5 t5
UNION ALL
select	t6.tranid,
		franchise,
		"&field" as sub_type,
		t6.player
from work.stage_6 t6
UNION ALL
select	t7.tranid,
		franchise,
		"&field" as sub_type,
		t7.player
from work.stage_7 t7
UNION ALL
select	t8.tranid,
		franchise,
		"&field" as sub_type,
		t8.player
from work.stage_8 t8
UNION ALL
select	t9.tranid,
		franchise,
		"&field" as sub_type,
		t9.player
from work.stage_9 t9
UNION ALL
select	t10.tranid,
		franchise,
		"&field" as sub_type,
		t10.player
from work.stage_10 t10;
quit;
%end;
%mend m_waiver_stage;
