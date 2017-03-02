proc sql;
create table work.stage as
select	t1.tranid as tranid_detail,
		t2.tranid as tranid_fact,
		count(t2.tranid) as count_fact,
		count(t1.tranid) as count_detail,
		ifc(calculated count_fact = 0 OR calculated count_detail = 0 ,'Y','N') as error
from stage.stg_trans_trade_detail t1
full join stage.stg_trans_trade_fact t2 on (t2.tranid = t1.tranid)
group by t1.tranid;
quit;

%m_QC_Tables(trans_trades,14,Missing Trans_trade_fact Record,tranid_detail);

proc sql;
create table work.stage as
select tranid,
		count(*) as count,
		ifc(calculated count <> 1,'Y','N') as error
from stage.stg_trans_trade_fact
group by tranid;
quit;

%m_QC_Tables(trans_trades,15,Duplicate tranid,tranid);

proc sql;
create table work.stage as
select t1.tranid,
		t1.player as player_id,
		ifc(t2.player_id is null,'Y','N') as error
from stage.stg_trans_trade_detail t1
left join stage.stg_dim_players t2 on (t2.player_id = t1.player)
where t1.player is not null
group by tranid;
quit;

%m_QC_Tables(trans_trades,16,Missing Record in dim_players,tranid);
