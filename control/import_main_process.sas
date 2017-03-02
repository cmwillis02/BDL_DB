/*               BDL MAIN PROCESS              */

/*Config*/
%include "/home/cwillis/BDL/control/config.sas";

/*Stage Jobs*/
%let root=/home/cwillis/BDL/data_mgmt/import;

%include "&root/stg_rosters.sas";
%include "&root/stg_league_standings.sas";
%include "&root/stg_dim_players.sas";
%include "&root/stg_all_transactions.sas";
%include "&root/stg_trans_trades.sas";
%include "&root/stg_trans_bb_waivers.sas";
%include "&root/stg_trans_ir.sas";
%include "&root/stg_trans_waivers.sas";
%include "&root/stg_matchup_bridge.sas";

proc datasets kill lib=work;
run;



