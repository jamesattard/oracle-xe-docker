echo "Transferring backup and conf files to standby server"
STANDBY="oraclexedemo_db_standby_1"
scp /archivelog/masterdata.tgz root@$STANDBY:/u01/app/oracle/oradata/XE/
scp /archivelog/stbycf.ctl root@$STANDBY:/u01/app/oracle/oradata/XE/
scp /archivelog/initXE.ora root@$STANDBY:/archivelog/
