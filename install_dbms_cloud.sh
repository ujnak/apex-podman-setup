#!/bin/sh
# install dbms_cloud package.
#
# run:
# podman exec -it apex-db bash < [this file]
# Ref: https://docs.oracle.com/en/database/oracle/oracle-database/23/sutil/dbms_cloud-family-packages.html
#
# Chage History:
#
$ORACLE_HOME/perl/bin/perl $ORACLE_HOME/rdbms/admin/catcon.pl -u sys/your-password -force_pdb_mode 'READ WRITE' -b dbms_cloud_install -d $ORACLE_HOME/rdbms/admin/ -l /tmp catclouduser.sql
$ORACLE_HOME/perl/bin/perl $ORACLE_HOME/rdbms/admin/catcon.pl -u sys/your-password -force_pdb_mode 'READ WRITE' -b dbms_cloud_install -d $ORACLE_HOME/rdbms/admin/ -l /tmp dbms_cloud_install.sql
exit
