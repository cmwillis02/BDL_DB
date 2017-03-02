/****************************************************************************************/
/*			Compile BB_WAIVER DIMENSION                                                 */
/****************************************************************************************/
Proc SQL;
create table stage.stg_bb_detail as
select	input(t1.tranid,8.) as tranid,
		franchise as franchise_id,
		datepart(datetime) format=date9. as date,
		input(SCAN(t1.BB_waiver,1,'|'),8.) as acquired,
		input(SCAN(t1.BB_waiver,3,'|'),8.) as dropped,
		input(SCAN(t1.BB_waiver,2,'|'),3.) format 3. as bones
From work.transactions t1
where t1.type = 'BBID_WAIVER';
quit;
