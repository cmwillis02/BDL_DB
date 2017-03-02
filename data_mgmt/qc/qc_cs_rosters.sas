/****************CHECK 4 *************/

proc sql;
create table work.stage as
select	t1.*,
		t2.player_id as dim_pid,
		ifc(t2.player_id is null,'Y','N') as error
from stage.stg_cs_rosters t1
left join stage.stg_dim_players t2 on (t2.player_id = t1.player_id);
quit;

%m_QC_Tables(CS_Rosters,4,Missing Record in dim_players,player_id);

