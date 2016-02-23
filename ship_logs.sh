# Switch archivelog
sqlplus sys/oracle as sysdba @switch_log.sql

# Sync with standby
rsync -rtv --ignore-existing /archivelog oracle@oraclexe_db_standby_1:/
