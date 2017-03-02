%let type=BB_Waiver;
%let no=1;
proc sql;
create table work.stage as
select *
from stage.stg_bb_detail
order by tranid;
quit;
data stage.qc_detail (keep=record_id record_type check_no message) stage.qc_summary (keep=type no records date);
	set work.stage end=eof;
	by tranid;
	retain total_count;
	format	message $100.
			record_type $50.
			type $50.;
		if _n_ =1 then do;
			total_count=0;
		end;	

		if first.tranid then do;
			count=0;
		end;

		count+1;

		if last.tranid and count>1 then do;
			record_id=tranid;
			record_type="&type";
			check_no=&no;
			message="More than 1 record";
			output stage.qc_detail;
			total_count +1;	
		end;

		if eof then do;
			type="&type";
			no=&no;
			records=total_count;
			date="&sysdate"d;
			output stage.qc_summary;
		end;
run;
/****************CHECK 2 *************/

proc sql;
create table work.stage as
select	t1.date,
		t1.tranid,
		t1.franchise_id,	
		t1.acquired,
		t1.dropped,
		t2.player_id as player_added,
		t3.player_id as player_dropped,
		case
			when t2.player_id is null then 'Y'
			when t1.dropped <> 0 and t3.player_id is null then 'Y'
			else 'N'
		end as error
from stage.stg_bb_detail t1
left join stage.stg_dim_players t2 on (t2.player_id = t1.acquired)
left join stage.stg_dim_players t3 on (t3.player_id = t1.dropped)
where calculated error = 'Y'
order by t1.date;
quit;

%m_QC_Tables(BB_Waiver,2,Missing Record in dim_players,tranid);


/****************CHECK 2 *************/
proc sql;
create table work.stage as
select t1.*,
		ifc(t1.franchise_id >10 or t1.franchise_id <1,'Y','N') as error
from stage.stg_bb_detail t1;
quit;

%m_QC_Tables(BB_Waiver,3,Incorrect franchise id, tranid);









