/****************************************************************************************/
/*			Create Trade Dim                                                            */
/****************************************************************************************/
proc sql;
create table work.stage as
select	input(t1.tranid,7.) as tranid,
		t1.comments,
		datepart(datetime) as date,
		t1.franchise as franchise_1,
		t1.franchise2 as franchise_2,
		IFC(SCAN(t1.franchise_gaveup,1)='00','',SCAN(t1.franchise_gaveup,1)) as franchise1_1,
		IFC(SCAN(t1.franchise_gaveup,2)='00','',SCAN(t1.franchise_gaveup,2)) as franchise1_2,
		IFC(SCAN(t1.franchise_gaveup,3)='00','',SCAN(t1.franchise_gaveup,3)) as franchise1_3,
		IFC(SCAN(t1.franchise_gaveup,4)='00','',SCAN(t1.franchise_gaveup,4)) as franchise1_4,
		IFC(SCAN(t1.franchise_gaveup,5)='00','',SCAN(t1.franchise_gaveup,5)) as franchise1_5,
		IFC(SCAN(t1.franchise2_gave_up,1)='00','',SCAN(t1.franchise2_gave_up,1)) as franchise2_1,
		IFC(SCAN(t1.franchise2_gave_up,2)='00','',SCAN(t1.franchise2_gave_up,2)) as franchise2_2,
		IFC(SCAN(t1.franchise2_gave_up,3)='00','',SCAN(t1.franchise2_gave_up,3)) as franchise2_3,
		IFC(SCAN(t1.franchise2_gave_up,4)='00','',SCAN(t1.franchise2_gave_up,4)) as franchise2_4,
		IFC(SCAN(t1.franchise2_gave_up,5)='00','',SCAN(t1.franchise2_gave_up,5)) as franchise2_5
from work.transactions t1
where t1.type = 'TRADE'
order by t1.tranid;
quit;
proc sql;
create table stage.stg_trans_trade_fact as
select	tranid,
		comments,
		franchise_1,
		franchise_2,
		date
from work.stage;
quit;
proc sql;
create table work.stage_transpose as
select	tranid,
		franchise1_1,
		franchise1_2,
		franchise1_3,
		franchise1_4,
		franchise1_5,
		franchise2_1,
		franchise2_2,
		franchise2_3,
		franchise2_4,
		franchise2_5
from work.stage
order by tranid;
quit;

proc transpose	data=work.stage_transpose
				out=work.trans_detail;
				by tranid;
				var franchise1_1 franchise1_2 franchise1_3 franchise1_4 franchise1_5 franchise2_1
					franchise2_2 franchise2_3 franchise2_4 franchise2_5;
run;
proc sql;
create table stage.stg_trans_trade_detail as
select	tranid,
		ifn(substr(_name_,10,1) = '1',1,2) as franchise,
		case
			when substr(col1,1,2) = 'BB' then 'Bones'
			when substr(col1,1,2) = 'FP' then 'Draft Pick'
			else 'Player'
		end as type,
		ifn(calculated type = 'Player',input(COL1,6.),.) as player,
		ifn(calculated type = 'Bones',input(substr(col1,4,2),3.),.) as bones,
		ifn(calculated type = 'Draft Pick',input(substr(col1,9,4),4.),.) as pick_year,
		ifn(calculated type = 'Draft Pick',input(substr(col1,14,1),1.),.) as pick_round
from work.trans_detail
where col1 is not null;
quit;	
