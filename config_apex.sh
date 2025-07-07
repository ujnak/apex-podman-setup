#!/bin/sh
# ############################################################################
# Script to configure Oracle APEX environment with podman.
# ############################################################################
# 
# Usage: config_apex.sh <DB SYS Password> <APEX ADMIN Password>
#
# - macOS Sonoma and Sequoia
# - podman 5.5.0
# - Oracle Databse 23ai Free Container Image. amd64 and arm64
#     container-registry.oracle.com/database/free:latest
# - Oracle ORDS Container Image. amd64 and arm64
#     container-registry.oracle.com/database/ords:latest
# - Oracle APEX latest zip
#     https://download.oracle.com/otn_software/apex/apex-latest.zip
# 
# Container and install images are subject to the following licenses:
#   Oracle Free Use Terms and Conditions
#   https://www.oracle.com/downloads/licenses/oracle-free-license.html
#   GraalVM Free Terms and Conditions (GFTC) including License for Early Adopter Versions
#   https://www.oracle.com/downloads/licenses/graal-free-license.html
#
# Change History:
# 2025/07/07: separate APEX installation.
# 2025/07/03: CI_DB_VERSION and CI_ORDS_VERSION to choose the version of container image.
# 2025/05/22: use sqlplus in db container to install apex insted of SQLcl.
# 2025/05/07: mapping port 8080 to 8181 by apex.yaml, remove config command of ords.
# 2025/05/07: remove JAVA_TOOL_OPTIONS="-XX:UseSVE=0", ORDS image includes this workaround.
# 2025/04/22: add JAVA_TOOL_OPTIONS="-XX:UseSVE=0" for workaround of graal issue #10458.
# 2025/04/21: Remove ORDS container explicitly after install and config.
# 2025/03/27: Change the ORDS installation password from here text to a file.
# 2025/03/27: Cleanup commands appended.
#
# PLEASE Modify: Language resource JAPANESE is installed
INSTALL_LANGUAGES="JAPANESE"

# prepare the container image for database free.
if [ -z "${CI_DB_VERSION}" ]; then
    export CI_DB_VERSION="latest"
fi
sh 01_pull_database_container_image.sh ${CI_DB_VERSION}|| exit 1

# prepare the container image for ords.
if [ -z "${CI_ORDS_VERSION}" ]; then
    export CI_ORDS_VERSION="latest"
fi
sh 02_pull_ords_container_image.sh ${CI_ORDS_VERSION} || exit 1

# #############################################################################
# Verify pre-requisits.
# #############################################################################
# Confirm podman volume oradata and ords_config are not exists.
for vol in oradata ords_config
do
  podman volume exists ${vol}
  if [ $? -eq 0 ]; then
    echo "volume ${vol} exists, exit";
    exit;
  fi
done

# #############################################################################
# Update database SYS password and APEX admin password 
# #############################################################################
# 1st argument is database SYS password. default is "oracle"
SYS_PASSWORD="oracle";
if [ $# -ge 1 ]; then
  SYS_PASSWORD=${1}
fi
# 2nd argument is APEX Admin password.
ADMIN_PASSWORD="Welcome_1";
if [ $# -ge 2 ]; then
  ADMIN_PASSWORD=${2}
fi

# #############################################################################
# Create Pod APEX with Oracle Database Free container and ORDS container.
# #############################################################################
# Prepare podman volumes
podman volume create oradata
podman volume create ords_config

# Create pod and containers.
envsubst < apex.yaml.template > apex.yaml
podman kube play apex.yaml
sleep 10
podman exec -i apex-db /home/oracle/setPassword.sh ${SYS_PASSWORD}

# #############################################################################
# Install Oracle APEX
# #############################################################################
#
sh 04_install_oracle_apex.sh apex-db ${ADMIN_PASSWORD} || exit 1

# #############################################################################
# Configure ORDS
# #############################################################################
#
sh 08_configure_ords.sh apex-ords ${SYS_PASSWORD} || exit 1

# #############################################################################
# Restart Pod APEX
# #############################################################################
#
podman pod stop apex
podman pod start apex

# end.
