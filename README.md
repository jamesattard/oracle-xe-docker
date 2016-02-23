#Instructions to setup two oracle XE 11g instances setup as Master Standby replication configured on two Docker containers.

#Start containers
docker-compose up -d
docker-compose ps

#Connect to master
````bash
ssh root@localhost -p 49822
```

#Connect to slave (from master)
````bash
ssh root@oraclexe_db_standby_1
```

#Prerequisites
- Exchange SSH keys between master and standby
- Install rsync (apt-get install rsync) on both servers


##Enable archivelog mode in master
````bash
sqlplus sys/oracle as sysdba
shutdown immediate;
startup mount;
alter database archivelog;
alter database open;
```

##Create archivelog location (master)
````bash
mkdir /archivelog
chown oracle:dba /archivelog/
sqlplus sys/oracle as sysdba
alter system set db_recovery_file_dest='/archivelog' scope=both;
```

##Take cold backup of Master database
````bash
shutdown immediate;
create pfile=‘/archivelog/initXE.ora’ from spfile;
pushd /u01/app/oracle/oradata/XE/ ; tar zcvf masterdata.tgz *.dbf; popd
```

##Create standby control file from Master database
````bash
alter database create standby controlfile as '/archivelog/stbycf.ctl';
```

##Prep standby server
````bash
mkdir /archivelog
chown oracle:dba /archivelog/
shutdown immediate;
pushd /u01/app/oracle/
mv oradata/ oradata_original
mkdir oradata; mkdir oradata/XE; chown -R oracle:dba oradata
popd
```

##Transfer files to standby server
````bash
scp /archivelog/masterdata.tgz root@oraclexe_db_standby_1:/u01/app/oracle/oradata/XE/
scp stbycf.ctl root@oraclexe_db_standby_1:/u01/app/oracle/oradata/XE/
scp initXE.ora root@oraclexe_db_standby_1:/archivelog/
```

##Last tidbits on standby server
````bash
chown -R oracle:dba /u01/app/oracle/oradata/XE/
chown -R oracle:dba /archivelog/
```
Amend pfile (/archivelog/initXE.ora/) to reflect standby controlfile (/u01/app/oracle/oradata/XE/stbycf.ctl)

##Startup standby database from pfile
````bash
startup nomount pfile='/archivelog/initXE.ora';
alter database mount standby database;
```

And we now have a standby database too!


##Ship logs (master)
````bash
./ship_logs.sh
```

##Apply logs (standby)
````bash
./apply_logs.sh
```

Check out the demo movie https://vimeo.com/156291617 to see this working in action.
