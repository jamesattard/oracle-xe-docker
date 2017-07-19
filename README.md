# 1. Introduction
These are all the instructions needed to setup two oracle XE 11g instances setup as Master Standby replication configured on two Docker containers.


# 2. Docker Quick Refresher
## 2.1 Start containers
```sh
docker-compose up -d
docker-compose ps
```

## 2.2 Connect to master
```sh
ssh root@localhost -p 49822
```

## 2.3 Connect to slave (from master)
```sh
ssh root@oraclexe_db_standby_1
```

# 3. Prerequisites
- Exchange SSH keys between master and standby
- Install rsync (apt-get install rsync) on both servers
- Amend STANDBY variable inside step_3_master_xferfiles.sh and ship_logs.sh to reflect name of your standby container

# 4. Deployment
## 4.1 Semi-Automatic Process

### 4.1.1 Docker Host
```sh
scp -P49522 step_1_master_prep.sh step_3_master_xferfiles.sh ship_logs.sh switch_log.sql root@localhost:/tmp
scp -P49622 step_2_standby_prep.sh step_4_standby_startup_standby.sh apply_logs.sh root@localhost:/tmp
```

### 4.1.2 Master
```sh
ssh root@localhost -p 49522
cd /tmp
./step_1_master_prep.sh
```

### 4.1.3 Slave
```sh
ssh root@localhost -p 49622
cd /tmp
./step_2_standby_prep.sh
```

### 4.1.4 Master
```sh
ssh root@localhost -p 49522
cd /tmp
./step_3_master_xferfiles.sh
```

### 4.1.5 Slave
```sh
ssh root@localhost -p 49622
cd /tmp
./step_4_standby_startup_standby.sh
```

### 4.1.6 Master
```sh
ssh root@localhost -p 49522
su - oracle
cd /tmp
./ship_logs.sh
```

### 4.1.7 Slave
```sh
ssh root@localhost -p 49622
su - oracle
cd /tmp
./apply_logs.sh
```

## 4.2 MANUAL INSTRUCTIONS:

### 4.2.1 Enable archivelog mode in master
```sh
sqlplus sys/oracle as sysdba
shutdown immediate;
startup mount;
alter database archivelog;
alter database open;
```

### 4.2.2 Create archivelog location (master)
```sh
mkdir /archivelog
chown oracle:dba /archivelog/
sqlplus sys/oracle as sysdba
alter system set db_recovery_file_dest='/archivelog' scope=both;
```

### 4.2.3 Take cold backup of Master database
```sh
shutdown immediate;
create pfile=‘/archivelog/initXE.ora’ from spfile;
pushd /u01/app/oracle/oradata/XE/ ; tar zcvf masterdata.tgz *.dbf; popd
```

### 4.2.4 Create standby control file from Master database
```sh
alter database create standby controlfile as '/archivelog/stbycf.ctl';
```

### 4.2.5 Prep standby server
```sh
mkdir /archivelog
chown oracle:dba /archivelog/
shutdown immediate;
pushd /u01/app/oracle/
mv oradata/ oradata_original
mkdir oradata; mkdir oradata/XE; chown -R oracle:dba oradata
popd
```

### 4.2.6 Transfer files to standby server
```sh
scp /archivelog/masterdata.tgz root@oraclexe_db_standby_1:/u01/app/oracle/oradata/XE/
scp stbycf.ctl root@oraclexe_db_standby_1:/u01/app/oracle/oradata/XE/
scp initXE.ora root@oraclexe_db_standby_1:/archivelog/
```

### 4.2.7 Last tidbits on standby server
```sh
chown -R oracle:dba /u01/app/oracle/oradata/XE/
chown -R oracle:dba /archivelog/
```
Amend pfile (/archivelog/initXE.ora/) to reflect standby controlfile (/u01/app/oracle/oradata/XE/stbycf.ctl)

### 4.2.8 Startup standby database from pfile
```sh
startup nomount pfile='/archivelog/initXE.ora';
alter database mount standby database;
```

And we now have a standby database too!

### 4.2.9 Ship logs (master)
```sh
./ship_logs.sh
```

### 4.2.10 Apply logs (standby)
```sh
./apply_logs.sh
```

Check out the demo [movie](https://vimeo.com/156291617) to see this working in action.
