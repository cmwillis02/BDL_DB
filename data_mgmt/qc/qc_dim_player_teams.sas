/****************CHECK 5 *************/

proc sql;
create table work.stage as
select	t1.*,
		t2.player_id as dim_pid,
		ifc(t2.player_id is null,'Y','N') as error
from stage.stg_dim_player_teams t1
left join stage.stg_dim_players t2 on (t2.player_id = t1.player_id);
quit;

%m_QC_Tables(dim_player_teams,5,Missing Record in dim_players,player_id);

