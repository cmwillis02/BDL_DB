%macro m_export(output,filename);
proc export data=work.&output outfile="/folders/myfolders/cwillis/Data/Export/&filename"
dbms=xlsx
replace;
quit;
%mend m_export;
