%macro m_QC_Tables(type,no,message,record_identifier);
data work.detail (keep=record_id record_type check_no message) work.summary (keep=type no records date);
	set work.stage end=eof;
	retain total_count;

	if _n_ = 1 then total_count = 0;

	if error = 'Y' then do;
		record_id = &record_identifier;
		record_type = "&type";
		check_no=&no;
		message="&message";
		output work.detail;
		total_count+1;
	end;

	if eof then do;
		type="&type";
		no=&no;
		records=total_count;
		date="&sysdate"d;
		output work.summary;
	end;

run;
proc append base=stage.qc_detail data=work.detail force;
run;
proc append base=stage.qc_summary data=work.summary force;
run;
%mend m_QC_tables;
