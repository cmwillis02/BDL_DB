/*  -Waiver Dimension*/

%m_waiver_stage(added,10);
%m_waiver_stage(dropped,10);

Proc sql;
create table stage.stg_trans_waiver_detail as
Select	input(tranid,6.) as tranid,
		franchise as franchise_id,
		sub_type as type,
		input(player,6.) as player_id
from work.stage_added
union all
select input(tranid,6.) as tranid,
		franchise as franchise_id,
		sub_type as type,
		input(player,6.) as player_id
from work.stage_dropped;
quit;
