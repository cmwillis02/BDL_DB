%macro pfr_rushing(start,stop);

	%do i=&start %to &stop %by 1;

		proc import datafile="/home/cwillis/BDL/data/import_data/pfr/rushing_&i..txt" out=work.import dbms=csv replace;
		delimiter=",";
		getnames=no;
		guessingrows=32767;
		run;
		
		data work.import2;
			set work.import;
			
			if _n_ not in (1,2) then output;
		
		run;

		proc sql;
		create table work.stage as
		select	&i as year,
				scan(substr(var2,1,find(var2,'\')-1),1,' ') format=$30. as first_name,
				scan(scan(substr(var2,1,find(var2,'\')-1),2,' '),1) format=$30. as last_name,
				substr(var2,find(var2,'\')+1,length(var2)-find(var2,'\')) format=$30. as id,
				ifc(find(var2,'+') > 0,'Y','') as all_pro,
				ifc(find(var2,'*') > 0,'Y','') as pro_bowl,
				var3 as team,
				var4 as age,
				upcase(ifc(var5 contains '/',scan(var5,1,'/'),var5)) as position,
				input(var6,10.) as games_played,
				input(var7,10.) as games_started,
				input(var8,10.) as attempts,
				input(var9,10.) as yards,
				input(var10,10.) as TD,
				input(var11,10.) as long,
				input(var12,10.) as yards_att,
				input(var13,10.) as yards_game,
				input(var14,10.) as attempts_game,
				input(var15,10.) as targets,
				input(var16,10.) as receptions,
				input(var17,10.) as rec_yards,
				input(var18,10.) as yards_rec,
				input(var19,10.) as rec_td,
				input(var20,10.) as rec_long,
				input(var21,10.) as rec_game,
				input(var22,10.) as rec_y_game,
				input(var23,10.) as catch_pct,
				input(var24,10.) as y_scrm,
				input(var25,10.) as tot_TD,
				input(var26,10.) as fumbles
		from work.import2;
		quit;

%if &i = &start %then %do;
		
			proc sql;
			create table stage.stg_pfr_rushing as
			select *
			from work.stage;
			quit;
		%end;	
		
		%else %do;
			
			proc append base=stage.stg_pfr_rushing data=work.stage force;
			run;
		%end;
	%end;

%mend pfr_rushing;

%pfr_rushing(2006,2016);

proc sort data=stage.stg_pfr_rushing noduprecs dupout=work.dups;
by year;
run;
