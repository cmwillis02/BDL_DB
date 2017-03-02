%macro m_player_scores(start,end,year);
%do week=&start %to &end %by 1;
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
	if program = 'player_scores' then do;
			call symputx('map',map_file);
			end;
run;
%put &map;
data _null_;
	call symputx('Url',CATX('.',"http://www&url_ref","myfantasyleague","com/&year/export?TYPE=playerScores&L=&id&W=&week&JSON=0"));
run;
%put &url;
filename  output URL "&Url";
filename  SXLEMAP "/home/cwillis/BDL/data/xml_maps/&map";
libname   output xmlv2 xmlmap=SXLEMAP access=READONLY;
DATA temp_&week; 
	SET output.playerscore;
		year="&year";
		week="&week";
run;
%end;
proc sql;
create table work.scores_&year as
select	playerscore_id as player_id,
		playerscore_score as score,
		playerscore_isavailable as status,
		year,
		week	
from work.temp_1
union all
select	playerscore_id as player_id,
		playerscore_score as score,
		playerscore_isavailable as status,
		year,
		week	
from work.temp_2
union all
select	playerscore_id as player_id,
		playerscore_score as score,
		playerscore_isavailable as status,
		year,
		week	
from work.temp_3
union all
select	playerscore_id as player_id,
		playerscore_score as score,
		playerscore_isavailable as status,
		year,
		week	
from work.temp_4
union all
select	playerscore_id as player_id,
		playerscore_score as score,
		playerscore_isavailable as status,
		year,
		week	
from work.temp_5
union all
select	playerscore_id as player_id,
		playerscore_score as score,
		playerscore_isavailable as status,
		year,
		week	
from work.temp_6
union all
select	playerscore_id as player_id,
		playerscore_score as score,
		playerscore_isavailable as status,
		year,
		week	
from work.temp_7
union all
select	playerscore_id as player_id,
		playerscore_score as score,
		playerscore_isavailable as status,
		year,
		week	
from work.temp_8
union all
select	playerscore_id as player_id,
		playerscore_score as score,
		playerscore_isavailable as status,
		year,
		week	
from work.temp_9
union all
select	playerscore_id as player_id,
		playerscore_score as score,
		playerscore_isavailable as status,
		year,
		week	
from work.temp_10
union all
select	playerscore_id as player_id,
		playerscore_score as score,
		playerscore_isavailable as status,
		year,
		week	
from work.temp_11
union all
select	playerscore_id as player_id,
		playerscore_score as score,
		playerscore_isavailable as status,
		year,
		week	
from work.temp_12
union all
select	playerscore_id as player_id,
		playerscore_score as score,
		playerscore_isavailable as status,
		year,
		week	
from work.temp_13
union all
select	playerscore_id as player_id,
		playerscore_score as score,
		playerscore_isavailable as status,
		year,
		week	
from work.temp_14
union all
select	playerscore_id as player_id,
		playerscore_score as score,
		playerscore_isavailable as status,
		year,
		week	
from work.temp_15
union all
select	playerscore_id as player_id,
		playerscore_score as score,
		playerscore_isavailable as status,
		year,
		week	
from work.temp_16
union all
select	playerscore_id as player_id,
		playerscore_score as score,
		playerscore_isavailable as status,
		year,
		week	
from work.temp_17;
quit;
%mend m_player_scores;
