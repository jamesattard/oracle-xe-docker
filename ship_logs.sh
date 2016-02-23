# Switch archivelog
sqlplus sys/oracle as sysdba @switch_log.sql

STANDBY="oraclexedemo_db_standby_1"

# Sync with standby
rsync -rtv --ignore-existing /archivelog oracle@$STANDBY:/

