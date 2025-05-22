#!/bin/sh
podman exec -i apex-db sh <<__EOF__
cd /opt/oracle/apex/37366599
cp -rf images ..
export NLS_LANG=American_America.AL32UTF8
sqlplus / as sysdba
alter session set container=freepdb1;
@catpatch.sql
exit
__EOF__
