%macro pfr_receiving(start,stop);

	%do i=&start %to &stop %by 1;

		proc import datafile="/home/cwillis/BDL/data/import_data/pfr/receiving_&i..txt" out=work.import dbms=csv replace;
		delimiter=",";
		getnames=yes;
		guessingrows=32767;
		run;
		

		proc sql;
		create table work.stage as
		select	&i as year,
				scan(substr(','n,1,find(','n,'\')-1),1,' ') format=$30. as first_name,
				scan(scan(substr(','n,1,find(','n,'\')-1),2,' '),1) format=$30. as last_name,
				substr(','n,find(','n,'\')+1,length(','n)-find(','n,'\')) format=$30. as id,
				ifc(find(','n,'+') > 0,'Y','') as all_pro,
				ifc(find(','n,'*') > 0,'Y','') as pro_bowl,
				upcase(ifc(pos contains '/',scan(pos,1,'/'),pos)) as position,
				age,
				tm as team,
				g as games,
				gs as games_started,
				tgt as targets,
				rec as receptions,
				'ctch%'n as catch_pct,
				yds as yards,
				'Y/R'n as yards_rec,
				td,
				lng as long,
				'r/g'n as rec_game,
				'y/g'n as yds_game,
				fmb as fumbles
		from work.import;
		quit;

%if &i = &start %then %do;
		
			proc sql;
			create table stage.stg_pfr_receiving as
			select *
			from work.stage;
			quit;
		%end;	
		
		%else %do;
			
			proc append base=stage.stg_pfr_receiving data=work.stage force;
			run;
		%end;
	%end;

%mend pfr_receiving;

%pfr_receiving(2006,2016);

proc sort data=stage.stg_pfr_receiving noduprecs dupout=work.dups;
by year;
run;
