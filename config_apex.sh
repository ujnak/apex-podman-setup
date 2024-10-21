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

# replace Oracle APEX with latest archive.
rm -rf apex
curl -OL https://download.oracle.com/otn_software/apex/apex-latest.zip
unzip apex-latest.zip
cp install_apex_pod.sql apex/install_apex_pod.sql

password=`cat password.txt`

# prepare podman volumes
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
