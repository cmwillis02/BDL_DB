%let year = 2016;
proc sql;
	delete from store.hist_players
	where year = "&year";
quit;
proc sql;
	delete from store.hist_matchup
	where year = "&year";
quit;


%m_import_results(&year,&year);
%let year = 2016;
proc sql;
create table work.Hist_Matchup_1 as
Select distinct	t1.weeklyresults_ordinal as week,
		t1.year,
		IFC(t1.matchup_regularseason = 1,'Y','N') as Regular_season,
		t2.franchise_id as Home_id,
		t2.franchise_score as Home_score,
		IFC(t2.franchise_result is null,'T',t2.franchise_result) as home_result,
		t3.franchise_id as Away_id,
		t3.franchise_score as Away_score,
		IFC(t3.franchise_result is null,'T',t3.franchise_result) as away_result,
		t2.franchise_starters as Home_starters,
		t2.franchise_optimal as home_optimal,
		t3.franchise_starters as away_starters,
		t3.franchise_optimal as away_optimal,
		IFC(t4.year is not null,'Y','N') as playoff
from work.matchup_&year t1
left join work.franchise_&year t2 on (t2.matchup_ordinal = t1.Matchup_ordinal AND t2.year = t1.year AND t2.franchise_ishome = 1)
left join work.franchise_&year t3 on (t3.matchup_ordinal = t1.Matchup_ordinal AND t3.year = t1.year AND t3.franchise_ishome = 0)
left join ref.playoff_matchups t4 on (put(t4.year,4.) = t1.year and t4.week=t1.weeklyresults_ordinal and t4.home_id = t2.franchise_id and t4.away_id = t3.franchise_id)
order by year, week;
quit;
proc sql;
create table work.hist_players_1 as
select Distinct	t1.year,
		t3.weeklyresults_ordinal as week,
		t2.franchise_id,
		t1.player_id,
		t1.player_status,
		t1.player_score,
		t1.player_shouldstart
from work.player_&year t1
	left join work.franchise_&year t2 on (t1.franchise_ordinal = t2.franchise_ordinal and t2.year = t1.year)
	left join work.matchup_&year t3 on (t3.matchup_ordinal = t2.matchup_ordinal and t3.year = t2.year)
	where (IFN(t1.year = '2011' AND t3.weeklyresults_ordinal = 7 and t1.player_id = 9299 and t2.franchise_id = 8,1,0)<>1)
order by t1.year, t3.weeklyresults_ordinal, t2.franchise_id
;quit;

/* Create Bye Week Data */
proc sql;
create table work.Hist_Matchup_bye as
Select distinct	t1.weeklyresults_ordinal as week,
		t1.year,
		'N' as Regular_season,
		t1.franchise1_id as Home_id,
		t1.franchise1_score as Home_score,
		'BYE' as home_result,
		. as Away_id,
		. as Away_score,
		'' as away_result,
		t1.franchise1_starters as Home_starters,
		t1.franchise1_optimal as home_optimal,
		'' as away_starters,
		'' as away_optimal,
		'N' AS playoff
from work.franchise1_&year t1
order by year, week;
quit;
proc sql;
create table work.hist_players_bye as
select distinct	t1.year,
		t2.weeklyresults_ordinal as week,
		t2.franchise1_id,
		t1.player1_id,
		t1.player1_status,
		t1.player1_score,
		t1.player1_shouldstart
from work.player1_&year t1
	left join work.franchise1_&year t2 on (t1.franchise1_ordinal = t2.franchise1_ordinal and t2.year = t1.year)
order by t1.year, t2.weeklyresults_ordinal, t2.franchise1_id;
quit;
/*Combine Bye week data and matchup data */
proc sql;
create table work.hist_matchup as
Select *
from work.hist_matchup_1
UNION ALL
select *
from work.hist_matchup_bye;
quit;
proc append base=store.hist_matchup data=work.hist_matchup force;
run;
proc sort data=store.hist_matchup;
by year week;
run;

proc sql;
create table work.player_stage as
select *
from work.hist_players_1
UNION ALL
select *
from work.hist_players_bye;
quit;

proc delete data= work.hist_matchup_1 work.hist_matchup_bye work.hist_players_1 work.hist_players_bye;
run;
proc delete data=work.franchise_&year work.franchise1_&year work.player_&year work.player1_&year work.matchup_&year;
run;

/**************************************/
/*     ADD NON ROSTERED PLAYERS       */
/**************************************/

%player_scores(1,17,2016);
proc delete data=
work.temp_1
work.temp_2
work.temp_3
work.temp_4
work.temp_5
work.temp_6
work.temp_7
work.temp_8
work.temp_9
work.temp_10
work.temp_11
work.temp_12
work.temp_13
work.temp_14
work.temp_15
work.temp_16
work.temp_17;
run;
/********************************************/
/*    FINAL RESULTS COMPILE                 */
/********************************************/



proc sql;
create table work.hist_players as
select	coalesce(t1.year,t2.year) as year,
		coalesce(t2.week,input(t1.week,2.)) as week,
		coalesce(t2.player_score, t1.score) as score,
		coalesce(t1.player_id, t2.player_id) as player_id,
		t2.franchise_id,
		t2.player_status,
		t2.player_shouldstart,
		case
			when t1.year is null and t2.year is not null then 'DNP'
			when t1.year is not null and t2.year is null then 'FA'
			else 'Rostered'
		end as status
from work.scores_2016 t1
Full join work.player_stage t2 on (input(t1.week,2.) = t2.week and t2.year = t1.year and t2.player_id = t1.player_id)
order by calculated year desc, calculated week, t2.franchise_id;
quit;

proc append base=store.hist_players data=work.hist_players force;
run;

proc delete data=work.player_stage work.player_stage2 work.scores work.hist_players work.scores_2016;
run;
