#!/bin/sh
# ############################################################################
# Script to configure Oracle APEX environment with podman.
# ############################################################################
# 
# Usage: config_apex.sh <DB SYS Password> <APEX ADMIN Password>
#
# - macOS Sonoma and Sequoia
# - podman 5.2.4
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
# PLEASE Modify: Language resource JAPANESE is installed
INSTALL_LANGUAGES="JAPANESE"

# #############################################################################
# Verify pre-requisits.
# #############################################################################
# Confirm podman is available.
which podman
if [ $? -ne 0 ]; then
  echo "podman is not installed or not accesible, exit";
  exit;
fi

# Confirm SQLcl - sql is available.
which sql
if [ $? -ne 0 ]; then
  echo "SQLcl is not installed or not accessible, exit";
  exit;
fi

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
# 1st argument is database SYS password.
if [ $# -ge 1 ]; then
  echo ${1} > password.txt
fi
# 2nd argument is APEX Admin password.
ADMIN_PASSWORD="Welcome_1";
if [ $# -ge 2 ]; then
  ADMIN_PASSWORD=${2}
fi

# #############################################################################
# Replace Oracle APEX by the latest archive.
# #############################################################################
#
rm -rf apex META-INF
curl -OL https://download.oracle.com/otn_software/apex/apex-latest.zip
unzip apex-latest.zip > /dev/null

# #############################################################################
# Find APEX version and schema of apex-latest.zip
# #############################################################################
# detect APEX version of apex-latest.zip
apex_version_text=`cat apex/images/apex_version.txt`
apex_version="${apex_version_text#Oracle APEX Version:}"
apex_version="${apex_version#"${apex_version%%[![:space:]]*}"}"
# apex_version=`echo -n ${apex_version}` # trim
apex_major="${apex_version:0:2}"
apex_minor=${apex_version:3:1}
APEX_VERSION=${apex_major}.${apex_minor}.0
APEX_SCHEMA=APEX_${apex_major}0${apex_minor}00
echo "APEX VERSION detected: " ${APEX_VERSION} ${APEX_SCHEMA}

# #############################################################################
# Create Pod APEX with Oracle Database Free container and ORDS container.
# #############################################################################
#
password=`cat password.txt`

# Prepare podman volumes
podman volume create oradata
podman volume create ords_config

# Create pod and containers.
podman kube play apex.yaml
sleep 10
podman exec -i apex-db /home/oracle/setPassword.sh ${password}

# #############################################################################
# Install Oracle APEX
# #############################################################################
#
cp config_apex_*.sql apex
cd apex
sql sys/${password}@localhost/freepdb1 as sysdba <<EOF
@apexins SYSAUX SYSAUX TEMP /i/
alter user apex_public_user account unlock no authentication;
exit
EOF

# setup admin account, image path and network acl
sql sys/${password}@localhost/freepdb1 as sysdba @config_apex_admin ${ADMIN_PASSWORD}
sql sys/${password}@localhost/freepdb1 as sysdba @config_apex_cdn ${APEX_VERSION}
sql sys/${password}@localhost/freepdb1 as sysdba @config_apex_acl ${APEX_SCHEMA}

# load language resources if specified
if [ ! -z "${INSTALL_LANGUAGES}" ]; then
sql sys/${password}@localhost/freepdb1 as sysdba <<EOF
@load_trans ${INSTALL_LANGUAGES}
exit
EOF
fi

cd ..

# #############################################################################
# Configure ORDS
# #############################################################################
#
podman stop apex-ords
podman run --pod apex --rm -i -v ords_config:/etc/ords/config \
container-registry.oracle.com/database/ords:latest install \
--admin-user sys --db-hostname localhost --db-port 1521 --db-servicename freepdb1 \
--log-folder /tmp/logs --feature-sdw true <<EOF
${password}
EOF

podman run --pod apex --rm -v ords_config:/etc/ords/config \
container-registry.oracle.com/database/ords:latest \
config set standalone.http.port 8181

# #############################################################################
# Restart Pod APEX
# #############################################################################
#
podman pod stop apex
podman pod start apex

# end.
