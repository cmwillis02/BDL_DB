options mprint;
/*******************************************************/
/*               SETUP LIBNAMES                        */
/*******************************************************/

libname bdl postgres database=BDLCORE server="bdlpg.cquxuyvkuxqs.us-east-1.rds.amazonaws.com" port=5432 user=bdladmin  password="bdladmin123" schema="BDLCORE"; 
libname bdlref postgres database=BDLCORE server="bdlpg.cquxuyvkuxqs.us-east-1.rds.amazonaws.com" port=5432 user=bdladmin  password="bdladmin123" schema="REFERENCE";
Libname stage "/home/cwillis/BDL/data/stage";

/*******************************************************/
/*               AUTOCALL LIBRARY                      */
/*******************************************************/
option SASAUTOS=("/home/cwillis/BDL/macros/");
