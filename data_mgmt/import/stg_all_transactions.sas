%macro transactions(start,stop);
%do year=&start %to &stop %by 1;
%let type=transactions;
data _null_;
	set bdlref.url;
	if year = &year then do;
		call symputx('url_ref',url);
		call symputx('id',league_id);
		end;
run;
data _null_;
	set bdlref.xml_map;
		if program = "&type" then do;
			call symputx('map',map_file);
			end;
run;
%put &map;
data _null_;
	call symputx('Url',CATX('.',"http://www&url_ref","myfantasyleague","com/&year/export?TYPE=&type&L=&id&W=YTD&JSON=0"));
run;
%put &url;
filename  output URL "&url";
filename  SXLEMAP "/home/cwillis/BDL/data/xml_maps/&map";
libname   output xmlv2 xmlmap=SXLEMAP access=READONLY;

DATA transactions_&year; 
	SET output.&type;
	format datetime datetime20.;
	year="&year";
	tranid=CAT(&year,id);
	datetime=INTNX('DTYEAR',timestamp,10,"S");
	If type ne 'SUBMIT_LINEUP' AND type ne 'SUBMIT_LINEUP_FAILED' then output;	
run;
%end;
%mend transactions;
%transactions(2009,2016);
%m_compile(transactions);


