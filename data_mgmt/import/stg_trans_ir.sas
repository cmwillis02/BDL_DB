/****************************************************************************************/
/*			Compile IR DIMENSION                                                        */
/****************************************************************************************/

%m_IR_Stage(activated,3);
%m_IR_Stage(deactivated,3);
proc sql;
create table work.stg_trans_ir as
select	input(tranid,6.) as tranid,
		franchise as franchise_id,
		type,
		input(player,6.) as player_id
from work.stage_activated
union all
select input(tranid,6.) as tranid,
		franchise as franchise_id,
		type,
		input(player,6.) as player_id
from work.stage_deactivated;
quit;
