echo "Installing Files"
apt-get install rsync -y

echo "Fixing permissions on standby srver"
mkdir /archivelog
chown oracle:dba /archivelog/
sqlplus sys/oracle as sysdba << EOL
shutdown immediate;
EOL

echo "Removing old database"
pushd /u01/app/oracle/
mv oradata/ oradata_original
mkdir oradata; mkdir oradata/XE; chown -R oracle:dba oradata
popd

echo "Authorizing SSH key from master"

mkdir /root/.ssh
cat >/root/.ssh/authorized_keys <<EOL
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDAAeLaWCfl7epVvkfKV04uT6WiqqIZTp5sZhCe5w10D92Z7dkvz+O6A4CVMnvas/dA/m7ha7FaKLExqx69hPzGiJJ04ztUqMGgExoPnX7kMAy1ccBPqM8bkHF3bJOOUJcrH3UCeO7dudOLrdFY3b4At7fdPqbHeXwzwlpiMLRdHfuEON8CCanVRy7+BKc1LyB6jeVMe75B9QMuWtwcHgUpAyPUpFSJkvnkswEKENEBvoeDY/R/N5NkfQX22W8CwbdDprLJUfkf0qQSkSbfNk0c5OSYeJaa3ldeI9u4Q8Xvg0FMid1YwTCS77kMpcpPFwjj2u76zEBCt2YKnjk0Xum3 oracle@ada530e07737
EOL

mkdir /u01/app/oracle/.ssh
cat >/u01/app/oracle/.ssh/authorized_keys <<EOL
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDAAeLaWCfl7epVvkfKV04uT6WiqqIZTp5sZhCe5w10D92Z7dkvz+O6A4CVMnvas/dA/m7ha7FaKLExqx69hPzGiJJ04ztUqMGgExoPnX7kMAy1ccBPqM8bkHF3bJOOUJcrH3UCeO7dudOLrdFY3b4At7fdPqbHeXwzwlpiMLRdHfuEON8CCanVRy7+BKc1LyB6jeVMe75B9QMuWtwcHgUpAyPUpFSJkvnkswEKENEBvoeDY/R/N5NkfQX22W8CwbdDprLJUfkf0qQSkSbfNk0c5OSYeJaa3ldeI9u4Q8Xvg0FMid1YwTCS77kMpcpPFwjj2u76zEBCt2YKnjk0Xum3 oracle@ada530e07737
EOL

chown -R oracle:dba /u01/app/oracle/.ssh
chmod 700 /u01/app/oracle/.ssh
chmod 600 /u01/app/oracle/.ssh/authorized_keys

chmod 700 /root/.ssh
chmod 600 /root/.ssh/authorized_keys
