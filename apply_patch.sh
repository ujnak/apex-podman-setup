#!/bin/sh
podman exec -i apex-db sh <<__EOF__
cd ~/work/patches/37366599
cp -rf images ../../apex/ 
export NLS_LANG=American_America.AL32UTF8
sqlplus / as sysdba
alter session set container=freepdb1;
@catpatch.sql
exit
__EOF__
