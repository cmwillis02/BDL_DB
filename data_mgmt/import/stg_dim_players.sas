%macro players(start,end);
%do year=&start %to &end %by 1;
data _null_;
	set bdlref.url;
	if year = &year then do;
		call symputx('url_ref',url);
		call symputx('id',league_id);
		end;
run;
%put &url_ref;
%put &id;
data _null_;
	set bdlref.xml_map;
		if program = "players" then do;
			call symputx('map',map_file);
			end;
run;
%put &map;
data _null_;
	call symputx('Url',CATX('.',"http://www&url_ref","myfantasyleague","com/&year/export?TYPE=players&DETAILS=1&L=&id&W=YTD&JSON=0"));
run;
%put &url;
filename  output URL "&url";
filename  SXLEMAP "/home/cwillis/BDL/data/xml_maps/&map";
libname   output xmlv2 xmlmap=SXLEMAP access=READONLY;
DATA players&year; 
	SET output.players;
	year=&year;
run;
%end;
%mend players;
%players(2009,2016);
proc sql;
create table work.stage as
select * from work.players2009
union all
select * from work.players2010
union all
select * from work.players2011
union all
select * from work.players2012
union all
select * from work.players2013
union all
select * from work.players2014
union all
select * from work.players2015
union all
select * from work.players2016
order by id;
quit;
data stage.stg_dim_player_teams;
	set work.stage;
	KEEP player_id position team year;
	player_id = id;
	if position in ('QB','RB','WR','TE','PK') then output;
run;
data work.stage_players (drop=id);
	set work.stage (drop= year team);
	by id;
	if position = 'XX' then do;
	position = 'WR';
	end;
	player_id = id;
	if upcase(position) in ('QB','RB','WR','TE','PK','DEF') then output;
run;

data stage.stg_dim_players;
	set work.stage_players;
	by player_id;

	if first.player_id then output;

run;





