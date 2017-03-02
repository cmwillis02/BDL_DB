proc sql;
create table stage.stg_trans_startup_draft as
select	t1.draftpick_ordinal as ovr_pick,
		t1.draftpick_round as round,
		t1.draftpick_pick as pick,
		t1.draftpick_franchise as franchise_id,
		t1.draftpick_player as player_id
from work.draft2009 t1
where t1.draftpick_round < 26;
quit;
