#!/bin/sh

podman run -d --name apexdb -e ORACLE_PWD=oracle -p 1521:1521 -p 8181:8181 -p 8443:8443 -v `pwd`/setup:/opt/oracle/scripts/setup -v `pwd`/startup:/opt/oracle/scripts/startup container-registry.oracle.com/database/free:latest
sleep 10
podman exec apexdb /opt/oracle/scripts/setup/01_install_apex.sh
podman restart apexdb
