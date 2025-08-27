#!/bin/sh
#
# Create Oracle Database Free Container.
podman run -d --name apexdb -p 1521:1521 -p 8181:8080 -p 8443:8443 -p 27017:27017 -v `pwd`/setup:/opt/oracle/scripts/setup -v `pwd`/startup:/opt/oracle/scripts/startup container-registry.oracle.com/database/free:latest
sleep 10

# Intall Oracle APEX in the container.
podman exec apexdb /opt/oracle/scripts/setup/01_install_apex.sh

# #############################################################################
# Update database SYS password and APEX admin password 
# #############################################################################
# 1st argument is database SYS password.
if [ $# -ge 1 ]; then
  SYSPWD=${1}
  podman exec apexdb ./setPassword.sh ${SYSPWD}
fi
# 2nd argument is APEX Admin password.
if [ $# -ge 2 ]; then
  APEXPWD=${2}
  sql sys/${SYSPWD}@localhost/freepdb1 as sysdba @config_apex_admin ${APEXPWD}
fi

podman restart apexdb

exit;
