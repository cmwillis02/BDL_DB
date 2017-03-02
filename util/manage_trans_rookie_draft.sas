%import_type(2009,2016,draftResults,draftpick,draft);
proc sql;
create table work.rookie_stage as
select	draftunit_ordinal,
		draftpick_ordinal - 250 as draftpick_ordinal,
		draftpick_round - 25 as draftpick_round,
		draftpick_pick,
		draftpick_franchise,
		draftpick_player,
		draftpick_timestamp,
		draftpick_comments,
		year
from work.draft2009
where draftpick_round >= 26
union all
select *
from work.draft2010
union all
select *
from work.draft2011
union all
select *
from work.draft2012
union all
select *
from work.draft2013
union all
select *
from work.draft2014
union all
select *
from work.draft2015
union all
select *
from work.draft2016;
quit;

proc sql;
create table stage.stg_trans_rookie_draft as
select	t1.draftpick_ordinal as Ovr_pick,
		t1.draftpick_round as round,
		t1.draftpick_pick as pick,
		t1.draftpick_franchise as franchise_id,
		t1.draftpick_player as player_id,
		t1.year
from work.rookie_stage t1;
quit;
