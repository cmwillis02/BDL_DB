proc sql;
create table work.stage as
select	mb.year,
		mb.week,
		w.week_key,
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
	left join bdl.dim_weeks w on (w.year = input(mb.year,4.) and w.week=mb.week)
	order by w.week_key, mb.franchise_id;
quit;

proc sql;

drop table exp.franchise_summary;

quit;

proc sql;
create table exp.franchise_summary as
select *
from work.stage;
quit;

