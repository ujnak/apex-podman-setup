#!/bin/sh
# ############################################################################
# Create ORDS container
# ############################################################################
# 
# Usage: create_ORDS_container.sh <DB SYS Password> <Container Name>
#
# Change History:
# 2025/07/05: Separated from config_apex.sh
#

# #############################################################################
# Evaluate arguments.
# #############################################################################
# 1st argument is database sys password.
SYS_PASSWORD="oracle";
if [ $# -ge 1 ]; then
  SYS_PASSWORD=${1}
fi
# 2nd arg is ords container name, default is apex-ords
ORDS_CONTAINER="apex-ords";
if [ $# -ge 2 ]; then
  ORDS_CONTAINER=${2}
fi

# #############################################################################
# prepare the container image for Oracle REST Data Services.
# #############################################################################
#
if [ -z "${CI_ORDS_VERSION}" ]; then
    export CI_ORDS_VERSION="latest"
fi

# pull container image
podman pull container-registry.oracle.com/database/ords:${CI_ORDS_VERSION}
if [ $? -ne 0 ]; then
    echo failed to pull the container image of the ords, exit.
    exit 1
fi

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

