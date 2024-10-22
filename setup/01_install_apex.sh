#!/bin/sh

#################################################################################
# Connection configuration to the database.
# no change required when the password supplied with "-e ORACLE_PWD=password"
#################################################################################
# -------------------------------------------------------------------------------
# uncomment for bequeath connection. No database password required.
# -------------------------------------------------------------------------------
#export ORACLE_HOME=/opt/oracle/product/23ai/dbhomeFree
#export ORACLE_SID=FREE
#export LD_LIBRARY_PATH=$ORACLE_HOME/lib
#export JDK_JAVA_OPTIONS="-DuseOracleHome=true"
# -------------------------------------------------------------------------------
# uncomment if container is NOT created with -e ORACLE_PWD=password and not beq
# -------------------------------------------------------------------------------
#ORACLE_PWD=password

#################################################################################
# Configuration properties for Oracle APEX
#################################################################################
# APEX_VERSION and APEX_SCHEMA is deteced from apex_version.txt in apex-latest.zip
# APEX_VERSION=24.1.0
# APEX_SCHEMA=APEX_240100
# -------------------------------------------------------------------------------
# load japanese translation.
# -------------------------------------------------------------------------------
LOAD_TRANS="@load_trans JAPANESE"
# Admin settings
APEX_ADMIN_USER=ADMIN
# -------------------------------------------------------------------------------
# APEX Administrator Password.
# -------------------------------------------------------------------------------
APEX_ADMIN_PASSWORD=Welcome_1

#################################################################################
# Configuration properties for Oracle REST Data Services
#################################################################################
ORDS_CONF_DIR=/etc/ords/config
# unset ociregion for dnf repo that is avaialble only in Oracle Cloud.
su -c "echo > /etc/dnf/vars/ociregion"

#################################################################################
# Install JDK
################################################################################
# -------------------------------------------------------------------------------
# uncomment for OpenJDK
# -------------------------------------------------------------------------------
echo "Install OpenJDK 21 for ORDS..."
su -c "dnf -y install java-21-openjdk-headless"
# -------------------------------------------------------------------------------
# uncomment for Oracle JDK
# -------------------------------------------------------------------------------
#echo "Install Oracle JDK 21 for ORDS..."
#curl -OL https://download.oracle.com/java/21/latest/jdk-21_linux-aarch64_bin.rpm
#su -c "dnf -y install jdk-21_linux-aarch64_bin.rpm"
#rm -f jdk-21_linux-aarch64_bin.rpm
# -------------------------------------------------------------------------------
# uncomment for GraalVM CE
# -------------------------------------------------------------------------------
#echo "Install GraalVM22 for GraphQL ..."
#su -c "dnf -y --repofrompath ol8_graalvm,https://yum.oracle.com/repo/OracleLinux/OL8/graalvm/community/aarch64 install graalvm22-ce-17-jdk graalvm22-ce-17-javascript"
# -------------------------------------------------------------------------------
echo "Done."

#################################################################################
# Download APEX 
################################################################################
echo "Download APEX..."
curl -OL https://download.oracle.com/otn_software/apex/apex-latest.zip
su -c "unzip -d /opt/oracle/apex apex-latest.zip"
# -------------------------------------------------------------------------------
# detect apex version
# -------------------------------------------------------------------------------
apex_version_text=`cat /opt/oracle/apex/apex/images/apex_version.txt`
# before 24.1
#apex_version="${apex_version_text#Application Express Version:}"
# after  24.1
apex_version="${apex_version_text#Oracle APEX Version:}"
apex_version=`echo -n ${apex_version}` # trim
apex_major="${apex_version:0:2}"
apex_minor=${apex_version:3:1}
APEX_VERSION=${apex_major}.${apex_minor}.0
APEX_SCHEMA=APEX_${apex_major}0${apex_minor}00
echo "APEX VERSION detected: " ${APEX_VERSION} ${APEX_SCHEMA}
# -------------------------------------------------------------------------------
# move static resource under /opt/oracle/apex/${APEX_VERSION}
# -------------------------------------------------------------------------------
su -c "mv /opt/oracle/apex/apex /opt/oracle/apex/${APEX_VERSION}"
su -c "chown -R 54321:54321 /opt/oracle/apex"
rm -f apex-latest.zip
# -------------------------------------------------------------------------------
echo "Done."

#################################################################################
# Install APEX 
################################################################################
echo "Install APEX..."
export NLS_LANG=American_America.AL32UTF8
cd /opt/oracle/apex/${APEX_VERSION}
sqlplus / as sysdba <<EOF
alter session set container = freepdb1;
@apexins SYSAUX SYSAUX TEMP /i/
${LOAD_TRANS}
alter user apex_public_user account unlock no authentication;
begin
    apex_instance_admin.create_or_update_admin_user (
        p_username => '${APEX_ADMIN_USER}',
        p_email    => null,
        p_password => '${APEX_ADMIN_PASSWORD}' );
    commit;
end;
/
begin
    dbms_network_acl_admin.append_host_ace(
        host => '*',
        ace => xs\$ace_type(
            privilege_list => xs\$name_list('connect'),
            principal_name => '${APEX_SCHEMA}',
            principal_type => xs_acl.ptype_db
        )
     );
     commit;
end;
/
exit
EOF
# -------------------------------------------------------------------------------
echo "Done."

#################################################################################
# Install ORDS
################################################################################
echo "Install ORDS..."
su -c "dnf -y --repofrompath ol8_oracle_software,http://yum.oracle.com/repo/OracleLinux/OL8/oracle/software/aarch64 install ords"
echo "Done."

#################################################################################
# Configure ORDS
################################################################################
cd ${ORDS_CONF_DIR}
# -------------------------------------------------------------------------------
# uncommend for network connection.
# -------------------------------------------------------------------------------
ords --config ${ORDS_CONF_DIR} install \
--admin-user sys \
--db-hostname localhost --db-port 1521 --db-servicename freepdb1 \
--log-folder /tmp/logs --feature-sdw true <<EOF
${ORACLE_PWD}
EOF
# -------------------------------------------------------------------------------
# uncommend for bequeath connection.
# -------------------------------------------------------------------------------
#ords --config ${ORDS_CONF_DIR} install \
#--bequeath-connect \
#--db-hostname localhost --db-port 1521 --db-servicename freepdb1 \
#--log-folder /tmp/logs --feature-sdw true

# -------------------------------------------------------------------------------
# additonal configuration for ords
# -------------------------------------------------------------------------------
ords --config ${ORDS_CONF_DIR} config set db.invalidPoolTimeout 5s
ords --config ${ORDS_CONF_DIR} config set debug.printDebugToScreen true
ords --config ${ORDS_CONF_DIR} config set restEnabledSql.active true
ords --config ${ORDS_CONF_DIR} config set feature.sdw true
ords --config ${ORDS_CONF_DIR} config set jdbc.MaxLimit 30
ords --config ${ORDS_CONF_DIR} config set jdbc.InitialLimit 10
ords --config ${ORDS_CONF_DIR} config set standalone.http.port 8181
ords --config ${ORDS_CONF_DIR} config set standalone.static.context.path /i
ords --config ${ORDS_CONF_DIR} config set standalone.static.path /opt/oracle/apex/${APEX_VERSION}/images

# All setup has completed.
# now ready to start ORDS.

# end