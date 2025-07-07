#!/bin/sh
# #############################################################################
# Configure ORDS
# #############################################################################
#
TARGET_CONTAINER=$1
SYS_PASSWORD=$2

podman exec -i ${TARGET_CONTAINER} sh <<__EOF__
echo ${SYS_PASSWORD} | ords --config /etc/ords/config install --admin-user sys --db-hostname localhost --db-port 1521 --db-servicename freepdb1 --log-folder /tmp/logs --feature-sdw true --password-stdin
ords --config /etc/ords/config config set standalone.static.path /opt/oracle/apex/images
__EOF__
