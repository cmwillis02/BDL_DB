%macro assemble_seasons(start,stop);

%do i=&start %to &stop %by 1;

	proc sql;
	create table work.initial_&i as
	select	r.id,
			&i as year,
			r.first_name,
			r.last_name,
			r.position,
			max(p.age,input(ru.age,4.0),re.age) as age,
			(ifn(p.yards is null,0,p.yards)/25) + (ifn(p.TD is null,0,p.td) * 4) + (ifn(p.int is null,0,p.int) * (-2)) + (ifn(ru.yards is null,0,ru.yards)/10) + (ifn(ru.td is null,0,ru.td) *6) + (ifn(ru.fumbles is null,0,ru.fumbles) *(-2)) + (ifn(re.yards is null,0,re.yards)/10) + (ifn(re.td is null,0,re.td) *6) + (ifn(re.fumbles is null,0,re.fumbles) * (-2)) format=8.1 as points,
			max(p.games,ru.games_played, re.games) as games_played,
			p.attempts,
			ru.attempts as rushes,
			re.targets,
			re.receptions,
			p.yards as pass_yards,
			ru.yards as rush_yards,
			re.yards as rec_yards,
			p.td as pass_td,
			ru.td as rush_td,
			re.td as rec_td
	from bdl.pfr_reference r
		left join bdl.pfr_passing p on (p.id = r.id and p.year = &i)
		left join bdl.pfr_rushing ru on (ru.id = r.id and ru.year = &i)
		left join bdl.pfr_receiving re on (re.id = r.id and re.year = &i)
	order by points desc;
	quit;

%end;

data work.combined;
	set work.initial_2006
		work.initial_2007
		work.initial_2008
		work.initial_2009
		work.initial_2010
		work.initial_2011
		work.initial_2012
		work.initial_2013
		work.initial_2014
		work.initial_2015
		work.initial_2016;
run;

%mend assemble_seasons;

%assemble_seasons(2006,2016);
proc sql;

drop table EXP.consecutive_seasons;
quit;

proc sql;
create table exp.consecutive_seasons as
select	s1.id,
		s1.year,
		s1.first_name,
		s1.last_name,
		s1.position,
		s1.age,
		s1.games_played,
		s1.points,
		s2.points as last_points,
		(s1.points-s2.points)/s2.points format=8.2 as delta_points,
		s1.attempts,
		s1.rushes,
		s1.targets,
		s1.receptions,
		s1.pass_yards,
		s1.rush_yards,
		s1.rec_yards,
		s1.pass_td,
		s1.rush_td,
		s1.rec_td,
		s2.games_played as last_games,
		s2.attempts as last_attempts,
		s2.rushes as last_rushes,
		s2.targets as last_targets,
		s2.receptions as last_rec,
		s2.pass_yards as last_pass_yards,
		s2.rush_yards as last_rush_yards,
		s2.rec_yards as last_rec_yards,
		s2.pass_td as last_pass_td,
		s2.rush_td as last_rush_td,
		s2.rec_td as last_rec_td
from work.combined s1
left join work.combined s2 on (s2.id = s1.id and s2.year = s1.year-1)
where s1.year <> 2006 and (s1.points >0 or s2.points >0) and last_points <> 0 and s1.points <> 0;
quit;
