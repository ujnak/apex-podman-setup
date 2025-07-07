#!/bin/sh
################################################################################
# Install ORDS
################################################################################
echo "Install ORDS..."
su -c "dnf -y --repofrompath ol8_oracle_software,http://yum.oracle.com/repo/OracleLinux/OL8/oracle/software/aarch64 install ords"
#su -c "dnf -y --repofrompath ol8_oracle_software,http://yum.oracle.com/repo/OracleLinux/OL8/oracle/software/x86_64 install ords"
echo "Done."

################################################################################
# Configure ORDS
################################################################################
ORDS_CONF_DIR=/etc/ords/config
cd ${ORDS_CONF_DIR}
# ------------------------------------------------------------------------------
# uncommend for network connection.
# ------------------------------------------------------------------------------
#ords --config ${ORDS_CONF_DIR} install \
#--admin-user sys \
#--db-hostname localhost --db-port 1521 --db-servicename freepdb1 \
#--log-folder /tmp/logs --feature-sdw true <<EOF
#${ORACLE_PWD}
#EOF
# ------------------------------------------------------------------------------
# uncommend for bequeath connection.
# ------------------------------------------------------------------------------
ords --config ${ORDS_CONF_DIR} install \
--bequeath-connect \
--db-hostname localhost --db-port 1521 --db-servicename freepdb1 \
--log-folder /tmp/logs --feature-sdw true

# ------------------------------------------------------------------------------
# additonal configuration for ords
# ------------------------------------------------------------------------------
unset JDK_JAVA_OPTIONS
ords --config ${ORDS_CONF_DIR} config set db.invalidPoolTimeout 5s
ords --config ${ORDS_CONF_DIR} config set debug.printDebugToScreen true
ords --config ${ORDS_CONF_DIR} config set restEnabledSql.active true
ords --config ${ORDS_CONF_DIR} config set feature.sdw true
ords --config ${ORDS_CONF_DIR} config set jdbc.MaxLimit 30
ords --config ${ORDS_CONF_DIR} config set jdbc.InitialLimit 10
ords --config ${ORDS_CONF_DIR} config set standalone.http.port 8181
ords --config ${ORDS_CONF_DIR} config set standalone.static.context.path /i
ords --config ${ORDS_CONF_DIR} config set standalone.static.path /home/oracle/work/apex/images

# All setup has completed.
# now ready to start ORDS.

# end

