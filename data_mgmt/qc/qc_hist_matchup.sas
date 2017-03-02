proc sql;
create table work.stage as
select	t1.year,
		t1.week,
		t1.home_id,
		ifc(t1.home_id >10 or t1.home_id <1,'Y','N') as error
from stage.stg_hist_matchup t1;
quit;

%m_QC_Tables(hist_matchup,8,Incorrect Franchise_id,home_id);

proc sql;
create table work.stage as
select	t1.year,
		t1.week,
		t1.away_id,
		ifc(t1.away_id >10 or t1.away_id <1,'Y','N') as error
from stage.stg_hist_matchup t1
where t1.regular_season = 'Y' or t1.playoffs = 'Y';
quit;

%m_QC_Tables(hist_matchup,9,Incorrect Franchise_id,away_id);

proc sql;
create table work.stage as
select	t1.year,
		t1.week,
		catx('-',t1.year,t1.week) as year_week,
		count(*) as count,
		ifc(calculated count <> 5,'Y','N') as error
from stage.stg_hist_matchup t1
where t1.regular_season = 'Y'
group by t1.year,t1.week;
quit;

%m_QC_Tables(hist_matchup,10,Weekly Matchups <> 5,year_week);

proc sql;
create table work.stage as
select	t1.year,
		count(*) as count,
		ifc(calculated count <> 5,'Y','N') as error
from stage.stg_hist_matchup t1
where t1.playoffs = 'Y'
group by t1.year;
quit;

%m_QC_Tables(hist_matchup,11,Playoff Matchups <> 5,year_week);

