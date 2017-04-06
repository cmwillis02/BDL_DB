proc sql;
create table work.stage as
select	substr(scan(p.name,2,','),2) as first,
		scan(p.name,1,',') as last,
		p.player_id,
		pf.id,
		pf.first_name,
		pf.last_name,
		sum(hp.score) as score
from bdl.dim_players p
full join bdl.pfr_reference pf on (pf.first_name=substr(scan(p.name,2,','),2) and pf.last_name=scan(p.name,1,','))
left join bdl.hist_players hp on (hp.player_id = p.player_id)
where p.position in ('QB','RB','WR','TE')
group by first, last, p.player_id,pf.id, first_name, last_name;
quit;
proc sort data=work.stage nodupkey dupout=work.dups;
by player_id;
run;


data work.matched work.missing;
	set work.stage;

	if first ne '' and first_name ne '' then output work.matched;
	if first_name = '' or first_name = '' then output work.missing;

run;
	
