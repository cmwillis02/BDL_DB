proc sql;
create table work.stage as
select	player_id,
		name,
		position,
		draft_round,
		draft_year,
		draft_pick
from bdl.dim_players
where draft_round is not null and draft_pick is not null;
quit;

proc sql;
create table work.scoring as
select	hp.player_id,
		hp.year,
		s.position,
		s.name,
		s.draft_year,
		s.draft_round,
		s.draft_pick,
		rd.round as bdl_round,
		rd.pick as bdl_pick,
		rd.ovr_pick as bdl_ovr,
		count(*) as games,
		sum(hp.score) as score
from bdl.hist_players hp
inner join work.stage s on (s.player_id = hp.player_id)
left join bdl.trans_rookie_draft rd on (rd.player_id = s.player_id)
where s.draft_year >=2009 and rd.ovr_pick is not null
group by hp.player_id, hp.year, s.draft_year, s.draft_round, s.draft_pick, s.position, s.name, rd.round, rd.pick, rd.ovr_pick
order by s.draft_year, s.draft_round, s.draft_pick;
quit;

proc sql;
 
drop table exp.draft_analysis;

quit;

data exp.draft_analysis;
	set work.scoring;
	by draft_year;
	retain rank year_seq;
	
	if first.draft_year then rank=0;
	
	if lag1(name) ne name then do;
		rank+1;
		year_seq=0;
	end;
	year_seq+1;

run;

