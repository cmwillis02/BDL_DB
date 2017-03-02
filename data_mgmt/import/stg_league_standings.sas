%m_import_type(&year,&year,leagueStandings,leagueStandings, cs_leaguestandings);
proc sql;
create table stage.stg_cs_standings as
select	t1.franchise_id,
		t1.wins,
		t1.losses,
		t1.ties,
		200-t1.bb_spent as bones,
		t1.points_for
from work.cs_leaguestandings&year t1;
quit;
