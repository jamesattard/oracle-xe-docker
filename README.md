#Instructions to setup two oracle XE 11g instances setup as Master Standby replication configured on two Docker containers.


#Start containers
```sh
docker-compose up -d
docker-compose ps
```

#Connect to master
```sh
ssh root@localhost -p 49822
```

#Connect to slave (from master)
```sh
ssh root@oraclexe_db_standby_1
```

#Prerequisites
- Exchange SSH keys between master and standby
- Install rsync (apt-get install rsync) on both servers
- Amend STANDBY variable inside step_3_master_xferfiles.sh and ship_logs.sh to reflect name of your standby container

# SEMI-AUTOMATIC DEPLOYMENT:
## DEVELOPMENT PURPOSES ONLY!
###Docker Host
```sh
scp -P49522 step_1_master_prep.sh step_3_master_xferfiles.sh ship_logs.sh switch_log.sql root@localhost:/tmp
scp -P49622 step_2_standby_prep.sh step_4_standby_startup_standby.sh apply_logs.sh root@localhost:/tmp
```

###Master
```sh
ssh root@localhost -p 49522
cd /tmp
./step_1_master_prep.sh
```

###Slave
```sh
ssh root@localhost -p 49622
cd /tmp
./step_2_standby_prep.sh
```

###Master
```sh
ssh root@localhost -p 49522
cd /tmp
./step_3_master_xferfiles.sh
```

###Slave
```sh
ssh root@localhost -p 49622
cd /tmp
./step_4_standby_startup_standby.sh
```

###Master
```sh
ssh root@localhost -p 49522
su - oracle
cd /tmp
./ship_logs.sh
```

###Slave
```sh
ssh root@localhost -p 49622
su - oracle
cd /tmp
./apply_logs.sh
```

# MANUAL INSTRUCTIONS:

##Enable archivelog mode in master
```sh
sqlplus sys/oracle as sysdba
shutdown immediate;
startup mount;
alter database archivelog;
alter database open;
```

##Create archivelog location (master)
```sh
mkdir /archivelog
chown oracle:dba /archivelog/
sqlplus sys/oracle as sysdba
alter system set db_recovery_file_dest='/archivelog' scope=both;
```

##Take cold backup of Master database
```sh
shutdown immediate;
create pfile=‘/archivelog/initXE.ora’ from spfile;
pushd /u01/app/oracle/oradata/XE/ ; tar zcvf masterdata.tgz *.dbf; popd
```

##Create standby control file from Master database
```sh
alter database create standby controlfile as '/archivelog/stbycf.ctl';
```

##Prep standby server
```sh
mkdir /archivelog
chown oracle:dba /archivelog/
shutdown immediate;
pushd /u01/app/oracle/
mv oradata/ oradata_original
mkdir oradata; mkdir oradata/XE; chown -R oracle:dba oradata
popd
```

##Transfer files to standby server
```sh
scp /archivelog/masterdata.tgz root@oraclexe_db_standby_1:/u01/app/oracle/oradata/XE/
scp stbycf.ctl root@oraclexe_db_standby_1:/u01/app/oracle/oradata/XE/
scp initXE.ora root@oraclexe_db_standby_1:/archivelog/
```

##Last tidbits on standby server
```sh
chown -R oracle:dba /u01/app/oracle/oradata/XE/
chown -R oracle:dba /archivelog/
```
Amend pfile (/archivelog/initXE.ora/) to reflect standby controlfile (/u01/app/oracle/oradata/XE/stbycf.ctl)

##Startup standby database from pfile
```sh
startup nomount pfile='/archivelog/initXE.ora';
alter database mount standby database;
```

And we now have a standby database too!


##Ship logs (master)
```sh
./ship_logs.sh
```

##Apply logs (standby)
```sh
./apply_logs.sh
```

Check out the demo [movie](https://vimeo.com/156291617) to see this working in action.
