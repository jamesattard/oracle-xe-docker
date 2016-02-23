echo "Restore database"
pushd /u01/app/oracle/oradata/XE/
tar zxvf masterdata.tgz
popd

echo "Fixing permissions"

chown -R oracle:dba /u01/app/oracle/oradata/XE/
chown -R oracle:dba /archivelog/

echo "Fixing pfile"

sed -i 's/control.dbf/stbycf.ctl/g' /archivelog/initXE.ora

echo "Startup standby database from pfile"
sqlplus sys/oracle as sysdba << EOL
startup nomount pfile='/archivelog/initXE.ora';
alter database mount standby database;
EOL
