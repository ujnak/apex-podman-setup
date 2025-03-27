#!/bin/sh
# install dbms_cloud package.
#
# Ref: https://docs.oracle.com/en/database/oracle/oracle-database/23/sutil/dbms_cloud-family-packages.html
#
# Chage History:
# 2025-03-27: run select statement to verify both on CDB and PDB.
#
# 1st argment is sys password
SYSCRED="";
if [ $# -ge 1 ]; then
  SYSCRED=${1}
fi
if [ -z "${SYSCRED}" ]; then
  echo "please provide sys passord."
  exit 1;
fi

# Oracle Home inside the 23ai free container.
ORACLE_HOME=/opt/oracle/product/23ai/dbhomeFree

# Creates the schema C##CLOUD$SERVICE with the necessary privileges. 
podman exec apex-db $ORACLE_HOME/perl/bin/perl $ORACLE_HOME/rdbms/admin/catcon.pl -u sys/${SYSCRED} -force_pdb_mode 'READ WRITE' -b dbms_cloud_install -d $ORACLE_HOME/rdbms/admin/ -l /tmp catclouduser.sql
# Installs the DBMS_CLOUD packages in schema C##CLOUD$SERVICE.
podman exec apex-db $ORACLE_HOME/perl/bin/perl $ORACLE_HOME/rdbms/admin/catcon.pl -u sys/${SYSCRED} -force_pdb_mode 'READ WRITE' -b dbms_cloud_install -d $ORACLE_HOME/rdbms/admin/ -l /tmp dbms_cloud_install.sql

sql sys/${SYSCRED}@localhost/free as sysdba <<EOF
select con_id, owner, object_name, status, sharing, oracle_maintained from cdb_objects where object_name like 'DBMS_CLOUD%';
EOF

sql sys/${SYSCRED}@localhost/freepdb1 as sysdba <<EOF
select owner, object_name, status, sharing, oracle_maintained from dba_objects where object_name like 'DBMS_CLOUD%';
EOF

exit
