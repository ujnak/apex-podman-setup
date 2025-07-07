#!/bin/sh
# ############################################################################
# Create ORDS container
# ############################################################################
# 
# Usage: create_ORDS_container.sh <DB SYS Password> <Container Name> <Version>
#
# Change History:
# 2025/07/05: Separated from config_apex.sh
#

SYS_PASSWORD=$1
ORDS_CONTAINER=$2
CI_ORDS_VERSION=$3

# #############################################################################
# Create podman volume ords_config
# #############################################################################
#
podman volume exists ords_config-${ORDS_CONTAINER}
if [ $? -eq 0 ]; then
  echo "volume ords_config-${ORDS_CONTAINER} exists, exit";
  exit 1;
else
  podman volume create ords_config-${ORDS_CONTAINER}
fi

# #############################################################################
# Create ORDS container.
# #############################################################################

podman run -d --name ${ORDS_CONTAINER} -p 8181:8080 -p 8443:8443 -p 27017:27017 -v `pwd`/apex:/opt/oracle/apex -v ords_config:/etc/ords/config -e DBHOST=host.containers.internal -e DBPORT=1521 -e DBSERVICENAME=FREEPDB1 -e ORACLE_PWD=${SYS_PASSWORD} container-registry.oracle.com/database/ords:${CI_ORDS_VERSION}

# #############################################################################
# End of script.
# #############################################################################
