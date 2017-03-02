/***  QC Main  ***/
%let root=/home/cwillis/BDL/data_mgmt/qc;

%include "&root/qc_bb_waivers.sas";
%include "&root/qc_cs_rosters.sas";
%include "&root/qc_dim_player_teams.sas";
%include "&root/qc_dim_players.sas";
%include "&root/qc_hist_matchup.sas";
%include "&root/qc_hist_players.sas";
%include "&root/qc_trans_trades.sas";
%include "&root/qc_trans_waivers.sas";

proc datasets kill lib=work;
run;
