#!/bin/sh
#
# OML4R Server configuration script
# for Oracle Database Free 23ai container.
#
# HISTORY
# 2025/07/03 ynakakos created.
#
# Oracle® Machine Learning for R Installation and Administration Guide
# Release 2.0 for Oracle Database 23ai
# https://docs.oracle.com/en/database/oracle/machine-learning/oml4r/2.0.0-23ai/oread/index.html
#

######################################################################
# 3.2.1 Install Oracle R Distribution on Oracle Linux 8 Using Dnf
######################################################################

# check OML4R supporting packages medium for OML4R 2.0
if [ ! -f ~/work/oml/oml4r-supporting-linux-x86-64-2.0.zip ]; then
    echo "OML4R supporting packages medium not found."
    echo "Download from https://www.oracle.com/database/technologies/oml4r-downloads.html"
    exit 1
fi

# clear ociregion 
su -c "echo '' > /etc/dnf/vars/ociregion"
cat /etc/dnf/vars/ociregion

# install R-4.0.5
su -c "yum-config-manager --enable ol8_codeready_builder"
su -c "yum-config-manager --enable ol8_addons"
su -c "dnf -y install R-4.0.5 cairo-devel"

######################################################################
# 4.3 Install Oracle Machine Learning for R Server for Oracle Database 23ai
######################################################################

# ATTN: CDB excluded because it should work only on PDB.
cd $ORACLE_HOME/R/server
sqlplus / as sysdba <<EOF
@rqcfg.sql SYSAUX TEMP /opt/oracle/product/23ai/dbhomeFree /usr/lib64/R
alter session set container = FREEPDB1;
@rqcfg.sql SYSAUX TEMP /opt/oracle/product/23ai/dbhomeFree /usr/lib64/R
exit
EOF

######################################################################
# 6.4.1 Install the Supporting Packages on Linux
######################################################################

cd ~/work/oml
if [ ! -d supporting ]; then
unzip ~/work/oml/oml4r-supporting-linux-x86-64-2.0.zip
fi
chmod 755 /opt/oracle/product/23ai/dbhomeFree/bin/ORE
cd supporting
ORE CMD INSTALL *
su -c "R --vanilla CMD INSTALL *"

# OML4R configuration complete.
