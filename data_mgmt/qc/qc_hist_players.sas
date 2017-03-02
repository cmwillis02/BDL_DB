proc sql;
create table work.stage as
select	t1.player_id,
		t2.player_id as dim_player_id,
		ifc(t2.player_id is null,'Y','N') as error
from stage.stg_hist_players t1
left join stage.stg_dim_players t2 on (t2.player_id = t1.player_id);
quit;

%m_QC_Tables(hist_players,12,Missing Record in dim_players,player_id);

proc sql;
create table work.stage as
select	t1.year,
		t1.week,
		t1.player_id,
		catx('-',t1.year,t1.week,t1.player_id) as year_week_id,
		count(*) as count,
		ifc(calculated count >1,'Y','N') as error
from stage.stg_hist_players t1
group by t1.year, t1.week, t1.player_id, calculated year_week_id;
quit;

%m_QC_Tables(hist_players,13,Year Week ID Non Unique,year_week_id);
