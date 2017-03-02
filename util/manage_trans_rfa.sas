PROC IMPORT DATAFILE="/home/cwillis/BDL/data/reference/rfa_results.xlsx"
	DBMS=XLSX
	replace
	OUT=work.stage;
	GETNAMES=YES;
RUN;
PROC IMPORT DATAFILE="/home/cwillis/BDL/data/reference/RFA_2016.xlsx"
	DBMS=XLSX
	replace
	OUT=work.stage2;
	GETNAMES=YES;
RUN;

proc sql;
create table work.stage_final as
select	t1.id as player_id,
		2016 as year,
		t1.name,
		t1.pos,
		t2.franchise_id,
		t3.franchise_id as win_franchise_id,
		t1.tag_status,
		t1.max_bid,
		ifn(t1.tag_status = 'Y',10+t1.price,t1.price) as price,
		t1.match
from work.stage2 t1
left join stage.stg_dim_franchise t2 on (t2.team_name = t1.team)
left join stage.stg_dim_franchise t3 on (t3.team_name = t1.winning_team)
union all
select	t1.player_id,
		t1.year,
		t1.player as name,
		t2.position as pos,
		t1.owner_id as franchise_id,
		input(t1.winner_id,2.) as win_franchise_id,
		ifc(t3.player_id is not null,'Y','') as tag_status,
		ifn(calculated tag_status = 'Y',20+t1.price * 2,t1.price) as max_bid,
		ifn(calculated tag_status = 'Y',calculated max_bid/2,t1.price) as price,	
		ifc(t1.owner_id = input(t1.winner_id,2.),'Y','N') as match
from work.stage t1
left join stage.stg_dim_players t2 on (t2.player_id = t1.player_id)
left join bdlref.franchise_tag t3 on (t3.year = t1.year and t3.player_id = t1.player_id);
quit;
