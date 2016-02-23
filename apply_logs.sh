sqlplus sys/oracle as sysdba << EOF
recover standby database;
AUTO
EOF
