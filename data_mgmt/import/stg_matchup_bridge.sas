proc sql;
create table stage.stg_hist_matchup_bridge as
select	input(m.year,4.) as year,
		m.week,
		m.home_id as franchise_id,
		m.home_score as score,
		m.playoffs,
		m.regular_season,
		m.home_result as result,
		m.away_id as opponent,
		m.home_starters as starters,
		m.home_optimal as optimal
from stage.stg_hist_matchup m
where away_id is not null
union all
select	input(m2.year,4.) as year,
		m2.week,
		m2.away_id as franchise_id,
		m2.away_score as score,
		m2.playoffs,
		m2.regular_season,
		m2.away_result as result,
		m2.home_id as opponent,
		m2.away_starters as starters,
		m2.away_optimal as optimal
from stage.stg_hist_matchup m2
where away_id is not null;
quit;
