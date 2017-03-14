proc sql;
create table work.stage as
select distinct id,
				first_name,
				last_name,
				scan(position,1,'/') as position1,
				scan(position,2,'/') as position2
from stage.stg_pfr_passing
union all
select distinct id,
				first_name,
				last_name,
				scan(position,1,'/') as position1,
				scan(position,2,'/') as position2
from stage.stg_pfr_rushing
union all
select distinct	id,
				first_name,
				last_name,
				scan(position,1,'/') as position1,
				scan(position,2,'/') as position2
from stage.stg_pfr_rushing
order by id, position1 desc;
quit;

data work.clean_positions work.no_position work.multiple_positions;
	set work.stage;
	by id;

	if first.id then do;
		qb_cnt=0;
		rb_cnt=0;
		wr_cnt=0;
		te_cnt=0;
	end;

	if position1 eq 'QB' or position2 eq 'QB' then qb_cnt+1;

	if position1 eq 'RB' or position2 eq 'RB' then rb_cnt+1;

	if position1 eq 'WR' or position2 eq 'WR' then wr_cnt+1;

	if position1 eq 'TE' or position2 eq 'TE' then te_cnt+1;

	if last.id then do;
		if qb_cnt >0 and max(rb_cnt,wr_cnt,te_cnt) = 0 then final_pos = 'QB';
		if rb_cnt >0 and max(qb_cnt,wr_cnt,te_cnt) = 0 then final_pos = 'RB';
		if wr_cnt >0 and max(rb_cnt,qb_cnt,te_cnt) = 0 then final_pos = 'WR';
		if te_cnt >0 and max(rb_cnt,wr_cnt,qb_cnt) = 0 then final_pos = 'TE';

		if sum(qb_cnt,rb_cnt,wr_cnt,te_cnt) = 0 then output work.no_position;
			else if final_pos ne '' then output work.clean_positions;
			else output work.multiple_positions;
	end;
run;
proc sql;
create table work.no_position_update as 
select	t1.id,
		t1.first_name,
		t1.last_name,
		t1.final_pos,
		sum(t2.attempts) as rushes,
		sum(t3.attempts) as attempts,
		sum(t4.targets) as targets,
		sum(calculated rushes,calculated attempts,calculated targets) as total
from work.no_position t1
left join stage.stg_pfr_rushing t2 on (t2.id = t1.id)
left join stage.stg_pfr_passing t3 on (t3.id = t1.id)
left join stage.stg_pfr_receiving t4 on (t4.id = t1.id)
group by t1.id, t1.first_name, t1.last_name, t1.final_pos
order by total desc;
quit;

proc sql;
create table work.append_np as
select id,
		first_name,
		last_name,
		final_pos as position
from work.no_position_update
where final_pos is not null;
quit;


/***** EDIT POSITIONS FOR PLAYERS WHO SHOW UP WITH MULTIPLE POSITIONS *****/


proc sql;
create table work.append_mp as
select id,
		first_name,
		last_name,
		final_pos as position
from work.multiple_positions;
quit;

proc sql;
create table stage.stg_pfr_reference as
select id,
		first_name,
		last_name,
		final_pos as position
from work.clean_positions;
quit;

proc append base=stage.stg_pfr_reference data=work.append_mp force;
run;
proc append base=stage.stg_pfr_reference data=work.append_np force;
run;
