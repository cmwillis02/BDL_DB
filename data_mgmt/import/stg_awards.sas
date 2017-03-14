%macro probowl(start,end);

	%do year=&start %to &end %by 1;

		proc sql;
		create table work.pos_avg as
		select	p.position,
				mean(hp.score)*12 as avg
		from BDL.hist_players hp
			left join bdl.dim_players p on (p.player_id = hp.player_id)
		where hp.player_status = 'starter' and hp.week <=13 and hp.year = &year
		group by p.position;
		quit;

		proc sql;
		create table work.players_all as
		select	p.name,
				p.player_id,
				p.position,
				hp.franchise_id,
				sum(hp.score) as total_points,
				count(*) as starts,
				calculated total_points - pa.avg as pts_above_repl
		from bdl.hist_players hp
			left join bdl.dim_players p on (p.player_id = hp.player_id)
			left join work.pos_avg pa on (pa.position = p.position)
		where hp.player_status = 'starter' and hp.week <=13 and hp.year = &year
		group by p.name,p.position, pa.avg, hp.franchise_id, p.player_id
		order by p.name, calculated starts desc;
		quit;
		
		data work.conference;
			set work.players_all;
			by name;
			
			if first.name then output;
		run;
		
		proc sql;
		create table work.players as
		select	pa.name,
				pa.position,
				pa.player_id,
				IFC(c.franchise_id in (1,4,5,6,10),'EAST','WEST') as conference,
				f.team_name,
				pa.total_points,
				pa.starts,
				int(pa.pts_above_repl) as pts_above_repl
		from work.players_all pa
			left join work.conference c on (c.player_id = pa.player_id)
			left join BDL.dim_franchise f on (c.franchise_id = f.franchise_id)
		order by pa.position, pa.total_points desc;
		quit;
		
		proc sql noprint;
		select max(pts_above_repl)
				into: par
		from work.players;
		quit;

		%put "MVP PTS ABOVE REPLACEMENT" | &par;
		
		data work.probowl_stage;
			set work.players;
			by position;
			retain pos_rank_e pos_rank_w;
			
			if pts_above_repl ge &par then do;
				MVP = 'Y';
			end;
			
			if first.position then do;
				pos_rank_e = 0;
				pos_rank_w = 0;
				first_team_BDL = 'Y';
			end;
			
			if conference = 'EAST' then do;
				pos_rank_e + 1;
				if position in ('QB','TE','PK','Def') and pos_rank_e <=2 then output;
				if position in ('RB','WR') and pos_rank_e <=5 then output;
			end;
			
			if conference = 'WEST' then do;
				pos_rank_w + 1;
				if position in ('QB','TE','PK','Def') and pos_rank_w <=2 then output;
				if position in ('RB','WR') and pos_rank_w <=5 then output;
			end;
		run;
		
		proc sql;
		create table work.stage_&year as
		select	&year as year,
				name,
				player_id,
				position,
				conference,
				team_name,
				total_points,
				starts,
				first_team_BDL,
				MVP
		from work.probowl_stage
		order by conference, position, total_points desc;
		quit;
		
	%end;
	
		proc sql;
		create table stage.stg_awd_probowl as
		select *
		from work.stage_&start;
		quit;
	
	%do year=&start+1 %to &end %by 1;

		proc append base=stage.stg_awd_probowl data=work.stage_&year;
		run;
		
	%end;

%mend probowl;

%probowl(2009,2016);

Proc sql;
create table work.champs as
select	input(year,4.) as year,
		franchise_id
from BDL.hist_matchup_bridge
where week = 16 and playoffs = 'Y' and result = 'W';
quit;

proc sql;
create table work.players as
select	hp.year,
		p.name,
		p.player_id,
		p.position,
		f.team_name,
		sum(hp.score) as total_score,
		count(*) as starts
from bdl.hist_players hp
	left join bdl.dim_players p on (p.player_id = hp.player_id)
	inner join work.champs c on (c.year = hp.year and c.franchise_id = hp.franchise_id)
	left join bdl.hist_matchup_bridge mb on (input(mb.year,4.) = hp.year and mb.week = hp.week and hp.franchise_id = mb.franchise_id)
	left join bdl.dim_franchise f on (f.franchise_id = mb.franchise_id)
where hp.player_status = 'starter' and mb.playoffs = 'Y'
group by hp.year, p.name, p.player_id,p.position,f.team_name
order by hp.year, calculated total_score desc;
quit;

data stage.stg_awd_playoff_mvp;
	set work.players;
	by year;
	
	if first.year then output;

run;


%macro Rookies(start,end);

	%do year=&start %to &end %by 1;

		proc sql;
		create table work.pos_avg as
		select	p.position,
				mean(hp.score)*12 as avg
		from bdl.hist_players hp
			left join bdl.dim_players p on (p.player_id = hp.player_id)
		where hp.player_status = 'starter' and hp.week <=13 and hp.year = &year
		group by p.position;
		quit;

		proc sql;
		create table work.players_all as
		select	p.name,
				p.player_id,
				p.position,
				hp.franchise_id,
				sum(hp.score) as total_points,
				count(*) as starts,
				calculated total_points - pa.avg as pts_above_repl
		from bdl.hist_players hp
			left join bdl.dim_players p on (p.player_id = hp.player_id)
			left join work.pos_avg pa on (pa.position = p.position)
		where hp.player_status = 'starter' and hp.week <=13 and hp.year = &year and p.draft_year = &year
		group by p.name,p.position, pa.avg, hp.franchise_id, p.player_id
		order by p.name, calculated starts desc;
		quit;
		
		data work.conference;
			set work.players_all;
			by name;
			
			if first.name then output;
		run;
		
		proc sql;
		create table work.players as
		select	pa.name,
				pa.position,
				pa.player_id,
				IFC(c.franchise_id in (1,4,5,6,10),'EAST','WEST') as conference,
				f.team_name,
				pa.total_points,
				pa.starts,
				int(pa.pts_above_repl) as pts_above_repl
		from work.players_all pa
			left join work.conference c on (c.player_id = pa.player_id)
			left join bdl.dim_franchise f on (c.franchise_id = f.franchise_id)
		order by pa.position, pa.total_points desc;
		quit;
		
		proc sql noprint;
		select max(pts_above_repl)
				into: roy
		from work.players;
		quit;

		%put "ROY PTS ABOVE REPLACEMENT" | &roy;
		
		data work.rookie_stage;
			set work.players;
			by position;
			retain pos_rank_e pos_rank_w;
			
			if pts_above_repl ge &roy then do;
				ROY = 'Y';
			end;
			
			if first.position then output;
		run;
		
		proc sql;
		create table work.stage_&year as
		select	&year as year,
				player_id,
				name,
				position,
				team_name,
				total_points,
				starts,
				ROY
		from work.rookie_stage
		order by conference, position, total_points desc;
		quit;
		
	%end;
	
		proc sql;
		create table stage.stg_awd_Rookies as
		select *
		from work.stage_&start;
		quit;
	
	%do year=&start+1 %to &end %by 1;

		proc append base=stage.stg_awd_Rookies data=work.stage_&year;
		run;
		
	%end;

%mend rookies;

%Rookies(2009,2016);

proc datasets kill lib=work;
run;
