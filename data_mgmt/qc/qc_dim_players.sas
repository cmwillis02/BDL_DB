proc sql;
create table work.stage as
select	t1.player_id,
		count(*) as count,
		ifc(calculated count >1,'Y','N') as error
from stage.stg_dim_players t1
group by t1.player_id;
quit;

%m_QC_Tables(dim_players,6,Non Unique Player_id,player_id);

proc sql;
create table work.stage as
select	t1.player_id,
		t1.position,
		ifc(t1.position not in ('QB','RB','WR','TE','PK','Def'),'Y','N') as error	
from stage.stg_dim_players t1;
quit;

%m_QC_Tables(dim_players,7,Non Eligible Position,player_id);


