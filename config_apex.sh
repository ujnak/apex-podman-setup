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
echo DB container image is ${CI_DB_VERSION}.
# pull container image
podman pull container-registry.oracle.com/database/free:${CI_DB_VERSION}
if [ $? -ne 0 ]; then
    echo failed to pull the container image of the database, exit.
    exit 1
fi

# prepare the container image for ords.
if [ -z "${CI_ORDS_VERSION}" ]; then
    export CI_ORDS_VERSION="latest"
fi
echo ORDS container image is ${CI_DB_VERSION}.
podman pull container-registry.oracle.com/database/ords:${CI_ORDS_VERSION}
if [ $? -ne 0 ]; then
    echo failed to pull the container image of the ords, exit.
    exit 1
fi

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
# Replace Oracle APEX by the latest archive.
# #############################################################################
# skip if directory apex exists.
if [ ! -d ./apex ]; then
rm -rf apex META-INF
curl -OL https://download.oracle.com/otn_software/apex/apex-latest.zip
unzip apex-latest.zip > /dev/null
fi

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
# Prepare podman volumes
podman volume create oradata
podman volume create ords_config

# Create pod and containers.
echo "May take some time if Oracle Database Free or ORDS container image is not latest."
# only current directory should be substituted.
envsubst < apex.yaml.template > apex.yaml
podman kube play apex.yaml
sleep 10
podman exec -i apex-db /home/oracle/setPassword.sh ${SYS_PASSWORD}

# #############################################################################
# Install Oracle APEX
# #############################################################################
#
podman exec -i apex-db sh <<__EOF__
cd /opt/oracle/apex
export NLS_LANG=American_America.AL32UTF8
sqlplus / as sysdba
alter session set container=FREEPDB1;
@apexins SYSAUX SYSAUX TEMP /i/
alter user apex_public_user account unlock no authentication;
begin
    apex_instance_admin.create_or_update_admin_user(
        p_username => 'ADMIN',
        p_email    => null,
        p_password => '${ADMIN_PASSWORD}'
    );
    commit;
end;
/
begin
    dbms_network_acl_admin.append_host_ace(
        host => '*',
        ace => xs\$ace_type(
            privilege_list => xs\$name_list('http','http_proxy'),
            principal_name => upper('${APEX_SCHEMA}'),
            principal_type => xs_acl.ptype_db
        )
    );
    commit;
end;
/
@load_trans ${INSTALL_LANGUAGES}
exit;
__EOF__

# #############################################################################
# Configure ORDS
# #############################################################################
#
podman exec -i apex-ords sh <<__EOF__
echo ${SYS_PASSWORD} | ords --config /etc/ords/config install --admin-user sys --db-hostname localhost --db-port 1521 --db-servicename freepdb1 --log-folder /tmp/logs --feature-sdw true --password-stdin
ords --config /etc/ords/config config set standalone.static.path /opt/oracle/apex/images
__EOF__

# #############################################################################
# Restart Pod APEX
# #############################################################################
#
podman pod stop apex
podman pod start apex

# end.
