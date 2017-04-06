/****************************/
/*   FRANCHISE_SUMMARY      */
/****************************/

proc sql;
create table work.stage as
select	mb.year,
		mb.week,
		w.week_key,
		w.end_date,
		mb.franchise_id,
		f.team_name,
		mb.score,
		mb.playoffs,
		mb.regular_season,
		mb2.franchise_id as opponent_id,
		f2.team_name as opponent_name,
		mb2.score as opponent_score,
		ifc(mb.opponent = mb2.franchise_id,'Y','N') as actual_matchup,
		case
			when mb.score > mb2.score then 'W'
			when mb.score < mb2.score then 'L'
			when mb.score = mb2.score then 'T'
			else ''
		end as result
from bdl.hist_matchup_bridge mb
	left join bdl.hist_matchup_bridge mb2 on (mb2.year = mb.year and mb2.week = mb.week and mb2.franchise_id <> mb.franchise_id)
	left join bdl.dim_franchise f on (f.franchise_id = mb.franchise_id)
	left join bdl.dim_franchise f2 on (f2.franchise_id = mb2.franchise_id)
	left join bdl.dim_weeks w on (w.year = mb.year and w.week=mb.week)
	order by w.week_key, mb.score desc, mb.franchise_id;
quit;

proc sql;

drop table exp.franchise_summary;

quit;

proc sql;
create table exp.franchise_summary as
select *
from work.stage;
quit;

/****************************/
/*   FRANCHISE_PLAYERS      */
/****************************/

proc sql;
create table work.stage as
select	mb.year,
		mb.week,
		w.week_key,
		w.end_date,
		mb.franchise_id,
		mb.opponent as opponent_id,
		case
			when mb.regular_season = 'Y' then 'Regular Season'
			when mb.playoffs = 'Y' then 'Playoffs'
			else 'none'
		end as reg_playoffs,
		f2.team_name as opponent,
		f.team_name,
		hp.player_id,
		p.position,
		p.name,
		hp.score,
		case
			when hp.player_status = 'starter' then 'Start'
			when hp.roster_status = 'DNP' then 'DNP'
			when hp.player_status = 'nonstarter' then 'Bench'
			when hp.roster_status = 'FA' then 'FA'
		end as status
from bdl.hist_matchup_bridge mb
	left join bdl.dim_weeks w on (w.year = mb.year and w.week = mb.week)
	left join bdl.dim_franchise f on (f.franchise_id = mb.franchise_id)
	left join bdl.dim_franchise f2 on (f2.franchise_id = mb.opponent)
	left join bdl.hist_players hp on (hp.year = mb.year and hp.week=mb.week and hp.franchise_id = mb.franchise_id)
	left join bdl.dim_players p on (p.player_id = hp.player_id)
where hp.roster_status <> 'FA'
order by mb.year, mb.week, mb.franchise_id, p.position, hp.score desc;
quit;

data work.pos_ranked work.bench;
	set work.stage;
	by  year week franchise_id position;

	if first.position then rank=0;
	if status = 'Start' then do;
		rank+1;
		output pos_ranked;
	end;
	if status ne 'Start' then do;
		rank=.;
		output bench;
	end;
run;
proc sql;
create table work.stage_final as
select	year,
		week,
		week_key,
		end_date,
		franchise_id,
		opponent,
		team_name,
		player_id,
		position,
		reg_playoffs,
		name,
		score,
		status,
		case
			when position = 'QB' then cat(trim(position),rank)
			when position in ('RB','WR') and rank in (1,2) then cat(trim(position),rank)
			when position in ('RB','WR') and rank = 3 then 'FLEX'
			when position = 'TE' and rank = 1 then cat(trim(position),rank)
			when position = 'TE' and rank = 2 then 'FLEX'
			when position in ('PK','Def') then cat(trim(position),rank)
			else 'CHECK CHECK CHECK'
		end as start_pos
from work.pos_ranked
union all
select	year,
		week,
		week_key,
		end_date,
		franchise_id,
		opponent,
		team_name,
		player_id,
		position,
		reg_playoffs,
		name,
		score,
		status,
		'BENCH' as start_pos
from work.bench
order by year, week, franchise_id, start_pos;
quit;

proc sql;

drop table exp.franchise_summary_players;

quit;

proc sql;
create table exp.franchise_summary_players as
select *
from work.stage_final;
quit;
