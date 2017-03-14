proc sql;
create table work.stage_draft as
select	d.player_id,
		d.round,
		d.pick,
		d.year,
		d.franchise_id
from bdl.trans_rookie_draft d
order by year, round, pick;
quit;

proc sql;
create table work.scores as
select	player_id,
		year,
		sum(score) as score
from bdl.hist_players
where player_id in (select player_id from work.stage_draft)
group by player_id, year;
quit;

proc sql;
create table work.combined as
select	s.player_id,
		p.name,
		p.position,
		s.round,
		s.pick,
		s.year,
		f.team_name,
		sum(ifn(sc.year=s.year,sc.score,0)) as score_r,
		sum(ifn(sc.year=s.year+1,sc.score,0)) as score_1,
		sum(ifn(sc.year=s.year+2,sc.score,0)) as score_2,
		sum(ifn(sc.year=s.year+3,sc.score,0)) as score_3,
		sum(ifn(sc.year=s.year+4,sc.score,0)) as score_4,
		sum(ifn(sc.year=s.year+5,sc.score,0)) as score_5,
		sum(ifn(sc.year=s.year+6,sc.score,0)) as score_6,
		sum(ifn(sc.year=s.year+7,sc.score,0)) as score_7
from work.stage_draft s
	left join work.scores sc on (sc.player_id = s.player_id)
	left join bdl.dim_players p on (p.player_id = s.player_id)
	left join bdl.dim_franchise f on (f.franchise_id = s.franchise_id)
group by s.player_id,s.round,s.pick,s.year, p.name,f.team_name, p.position
order by s.year, s.round,s.pick;
quit;

proc sql;
create table work.pick_averages as
select	round,
		pick,
		position,
		mean(score_r) as avg_r,
		mean(score_1) as avg_1,
		mean(score_2) as avg_2,
		mean(score_3) as avg_3,
		mean(score_4) as avg_4,
		mean(score_5) as avg_5,
		mean(score_6) as avg_6,
		mean(score_7) as avg_7
from work.combined
group by round, pick, position;
quit;
