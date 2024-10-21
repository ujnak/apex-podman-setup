#!/bin/sh

#  preparetion steps to run this script.
#
# 1. Install SQLcl on the host machine. 
# 2. Downlod and expand latest Oracle APEX zip file.
#    % curl -OL https://download.oracle.com/otn_software/apex/apex-latest.zip
#    % unzip apex-latest.zip
# 3. Create apex.yaml in the current directory.
# 4. Create install_apex_pod.sql in apex directory.
# 5. Write database sys password in password.txt
#

# verify pre-requisit.
# Confirm SQLcl - sql is exists.
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

# Replace Oracle APEX with latest archive.
rm -rf apex META-INF
curl -OL https://download.oracle.com/otn_software/apex/apex-latest.zip
unzip apex-latest.zip > /dev/null

# detect apex version
apex_version_text=`cat apex/images/apex_version.txt`
apex_version="${apex_version_text#Oracle APEX Version:}"
apex_version="${apex_version#"${apex_version%%[![:space:]]*}"}"
# apex_version=`echo -n ${apex_version}` # trim
apex_major="${apex_version:0:2}"
apex_minor=${apex_version:3:1}
APEX_VERSION=${apex_major}.${apex_minor}.0
APEX_SCHEMA=APEX_${apex_major}0${apex_minor}00
echo "APEX VERSION detected: " ${APEX_VERSION} ${APEX_SCHEMA}

# Replace APEX_VERSION and APEX_SCHEMA
sed -e "s/#APEX_VERSION#/${APEX_VERSION}/" install_apex_pod.sql > install_apex_pod.sql.t
sed -e "s/#APEX_SCHEMA#/${APEX_SCHEMA}/" install_apex_pod.sql.t > apex/install_apex_pod.sql
#rm install_apex_pod.sql.t

# 

password=`cat password.txt`

# Prepare podman volumes
podman volume create oradata
podman volume create ords_config

# create pod and containers.
podman kube play apex.yaml
sleep 10
podman exec -i apex-db /home/oracle/setPassword.sh ${password}

# install apex
cd apex
sql sys/${password}@localhost/freepdb1 as sysdba <<EOF
@install_apex_pod
EOF

cd ..
# configure ORDS
podman stop apex-ords
podman run --pod apex --rm -i -v ords_config:/etc/ords/config container-registry.oracle.com/database/ords:latest install --admin-user sys --db-hostname localhost --db-port 1521 --db-servicename freepdb1 --log-folder /tmp/logs --feature-sdw true <<EOF
${password}
EOF

podman pod stop apex
podman pod start apex

# end.
