#!/bin/sh
# ############################################################################
# Create database container from Oracle Database 23ai Free container image
# ############################################################################
# 
# Usage: create_database_container.sh
#
# Change History:
# 2025/07/05: Separated from config_apex.sh
#

DB_CONTAINER=$1
CI_DB_VERSION=$2

# #############################################################################
# Create podman volume oradata 
# #############################################################################
#
podman volume exists oradata-${DB_CONTAINER}
if [ $? -eq 0 ]; then
  echo "volume oradata-${DB_CONTAINER} exists, exit";
  exit 1;
else
  podman volume create oradata-${DB_CONTAINER}
fi

# #############################################################################
# Create and Run the container
# #############################################################################
#
if [ ! -f ./.single-container ]; then
  podman run -d --name ${DB_CONTAINER} -p 1521:1521 -v `pwd`:/home/oracle/work container-registry.oracle.com/database/free:${CI_DB_VERSION}
else
  podman run -d --name ${DB_CONTAINER} -p 1521:1521 -p 8181:8080 -p 8443:8443 -p 27017:27017 -v `pwd`:/home/oracle/work container-registry.oracle.com/database/free:${CI_DB_VERSION}
fi

# #############################################################################
# End of database container creation.
# #############################################################################
