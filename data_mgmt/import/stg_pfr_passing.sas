%macro pfr_passing(start,stop);

	%do i=&start %to &stop %by 1;
		
				proc import datafile="/home/cwillis/BDL/data/import_data/pfr/passing_&i..txt" out=work.import dbms=csv replace;
				delimiter=",";
				getnames=yes;
				guessingrows=32767;
				run;
			
				proc sql;
				create table work.stage as
				select	&i as year,
						scan(substr(','n,1,find(','n,'\')-1),1,' ') as first_name,
						scan(scan(substr(','n,1,find(','n,'\')-1),2,' '),1) as last_name,
						substr(','n,find(','n,'\')+1,length(','n)-find(','n,'\')) as id,
						ifc(find(','n,'+') > 0,'Y','') as all_pro,
						ifc(find(','n,'*') > 0,'Y','') as pro_bowl,
						tm,
						age,
						upcase(pos) as position,
						g as games,
						gs as games_started,
						cmp as completions,
						att as attempts,
						'cmp%'n as comp_pct,
						yds as yards,
						td,
						'TD%'n as td_pct,
						int,
						'int%'n as int_pct,
						lng,
						'AY/A'n as adj_yds_att,
						qbr,
						sk as sacked,
						var25 as sack_yds,
						'NY/A'n as net_yds_att,
						'ANY/A'n as adj_net_yds_att,
						'sk%'n as sack_pct
				from work.import;
				quit;
			
			
		%if &i = &start %then %do;
		
			proc sql;
			create table stage.stg_pfr_passing as
			select *
			from work.stage;
			quit;
		%end;	
		
		%else %do;
			
			proc append base=stage.stg_pfr_passing data=work.stage force;
			run;
		%end;
	%end;

%mend pfr_passing;

%pfr_passing(2006,2016);
proc sort data=stage.stg_pfr_passing noduprecs dupout=work.dups;
by year;
run;
