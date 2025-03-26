#!/bin/sh

$ORACLE_HOME/perl/bin/perl $ORACLE_HOME/rdbms/admin/catcon.pl -u sys/your-password -force_pdb_mode 'READ WRITE' -b dbms_cloud_install -d $ORACLE_HOME/rdbms/admin/ -l /tmp catclouduser.sql
$ORACLE_HOME/perl/bin/perl $ORACLE_HOME/rdbms/admin/catcon.pl -u sys/your-password -force_pdb_mode 'READ WRITE' -b dbms_cloud_install -d $ORACLE_HOME/rdbms/admin/ -l /tmp dbms_cloud_install.sql
exit
