%let year=2017;
%m_import_type(&year,&year,rosters,rosters,cs_rosters);
proc sql;
create table stage.stg_cs_rosters as
select	franchise_id,
		player_id,
		status,
		contract_years
from work.cs_rosters&year;
quit;
