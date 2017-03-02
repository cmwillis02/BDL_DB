/************************************/
/*     IMPORT WEEKLY RESULTS        */
/************************************/

%m_import_results(2009,2016);
%m_compile(player);
%m_compile(player1);
%m_compile(franchise);
%m_compile(franchise1);
%m_compile(matchup);
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
		IFC(t4.year is not null,'Y','N') as playoffs
from work.matchup t1
left join work.franchise t2 on (t2.matchup_ordinal = t1.Matchup_ordinal AND t2.year = t1.year AND t2.franchise_ishome = 1)
left join work.franchise t3 on (t3.matchup_ordinal = t1.Matchup_ordinal AND t3.year = t1.year AND t3.franchise_ishome = 0)
left join bdlref.playoff_reference t4 on (t4.year = input(t1.year,4.) and t4.week=t1.weeklyresults_ordinal and t4.home_id = t2.franchise_id and t4.away_id = t3.franchise_id)
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
from work.player t1
	left join work.franchise t2 on (t1.franchise_ordinal = t2.franchise_ordinal and t2.year = t1.year)
	left join work.matchup t3 on (t3.matchup_ordinal = t2.matchup_ordinal and t3.year = t2.year)
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
from work.franchise1 t1
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
from work.player1 t1
	left join work.franchise1 t2 on (t1.franchise1_ordinal = t2.franchise1_ordinal and t2.year = t1.year)
order by t1.year, t2.weeklyresults_ordinal, t2.franchise1_id;
quit;
/*Combine Bye week data and matchup data */
proc sql;
create table stage.stg_hist_matchup as
Select *
from work.hist_matchup_1
UNION ALL
select *
from work.hist_matchup_bye;
quit;
proc sql;
create table work.player_stage as
select *
from work.hist_players_1
UNION ALL
select *
from work.hist_players_bye;
quit;

/**************************************/
/*     ADD NON ROSTERED PLAYERS       */
/**************************************/

%m_player_scores(1,17,2009);
%m_player_scores(1,17,2010);
%m_player_scores(1,17,2011);
%m_player_scores(1,17,2012);
%m_player_scores(1,17,2013);
%m_player_scores(1,17,2014);
%m_player_scores(1,17,2015);
%m_player_scores(1,17,2016);
%m_compile(scores);

/********************************************/
/*    FINAL RESULTS COMPILE                 */
/********************************************/
proc sql;
create table stage.stg_hist_players as
select	input(coalesce(t1.year,t2.year),4.) format=4. as year,
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
		end as roster_status
from work.scores t1
Full join work.player_stage t2 on (input(t1.week,2.) = t2.week and t2.year = t1.year and t2.player_id = t1.player_id)
where t1.player_id <> 9942
order by calculated year desc, calculated week, t2.franchise_id;
quit;
