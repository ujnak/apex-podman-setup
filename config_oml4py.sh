#!/bin/sh
#
# OML4Py Server and Client configuration script
# for Oracle Database Free 23ai container.
#
# HISTORY
# 2025/07/03 ynakakos changed to work on the database for APEX.
# 2025/05/29 ynakakos created.
#
# Oracle Machine Learning for Python User's Guide
# Release 2.1 for Oracle Database 23ai
# https://docs.oracle.com/en/database/oracle/machine-learning/oml4py/2-23ai/mlpug/
#

################################################################################
# 4. Install OML4Py for On-Premises Databases
################################################################################

# check OML4Py client 2.1 media 
if [ ! -f ~/work/oml/V1048628-01.zip ]; then
    echo "OML4Py client media not found."
    echo "Download from https://www.oracle.com/database/technologies/oml4py-downloads.html"
    exit 1
fi

################################################################################
# 4.2 Build and Install Python for Linux for On-Premises Databases
################################################################################
# https://docs.oracle.com/en/database/oracle/machine-learning/oml4py/2-23ai/mlpug/build-and-install-python-linux-premises-databases.html

# 4.2-1
# To avoid downloading Python-3.12.6.tgz each time,
# Python-3.12.6.tgz will be downloaded in advance
if [ ! -f ~/work/oml/Python-3.12.6.tgz ]; then
    echo "Python-3.12.6.tgz not found."
    echo "Download https://www.python.org/ftp/python/3.12.6/Python-3.12.6.tgz"
    exit 1
fi

# clear ociregion 
su -c "echo '' > /etc/dnf/vars/ociregion"
cat /etc/dnf/vars/ociregion

# 4.2-3
# Install required os packages + wget and gcc
su -c "dnf -y install perl-Env libffi-devel openssl openssl-devel tk-devel xz-devel zlib-devel bzip2-devel readline-devel libuuid-devel ncurses-devel wget gcc"

# 4.2-2
# Create a directory and extract the contents to the directory
mkdir -p $HOME/python
tar -xvzf ~/work/oml/Python-3.12.6.tgz --strip-components=1 -C $HOME/python

# 4.2-4
# Configure, build and install Python 3.12.6
cd $HOME/python
./configure --enable-shared --prefix=$HOME/python
make clean; make
make altinstall

# 4.2-5
# Set environment variable 
export PYTHONHOME=$HOME/python
export PATH=$PYTHONHOME/bin:$PATH
export LD_LIBRARY_PATH=$PYTHONHOME/lib:$LD_LIBRARY_PATH

# 4.2-6
# Create a symbolic link
cd $HOME/python/bin
ln -s python3.12 python3

# Upgrade pip
cd ~
python3 -m pip install --upgrade pip

################################################################################
# 4.3 Install the Required Supporting Packages for Linux for On-Premises Databases
################################################################################
# https://docs.oracle.com/en/database/oracle/machine-learning/oml4py/2-23ai/mlpug/install-required-supporting-packages-linux-premises-databases.html

# Installing required packages on OML4Py client machine
pip3.12 install -r ~/work/requirements.txt

# Installing required packages on OML4Py server machine
pip3.12 install -r ~/work/requirements2.txt --target=$ORACLE_HOME/oml4py/modules

################################################################################
# 4.4 Install OML4Py Server for On-Premises Oracle Database
################################################################################
# https://docs.oracle.com/en/database/oracle/machine-learning/oml4py/2-23ai/mlpug/install-oml4py-server-premises-database.html

# 4.4.1
# Set environment variables
export ORACLE_HOME=/opt/oracle/product/23ai/dbhomeFree
export PYTHONHOME=$ORACLE_HOME/python
export PATH=$PYTHONHOME/bin:$ORACLE_HOME/bin:$PATH
export LD_LIBRARY_PATH=$PYTHONHOME/lib:$ORACLE_HOME/lib:$LD_LIBRARY_PATH

# Configure OML4Py Server, both on CDB and PDB
# ATTN: CDB excluded because it should work only on PDB.
cd $ORACLE_HOME/oml4py/server
sqlplus / as sysdba <<EOF
-- @pyqcfg.sql SYSAUX TEMP /opt/oracle/product/23ai/dbhomeFree/python
alter session set container=FREEPDB1;
@pyqcfg.sql SYSAUX TEMP /opt/oracle/product/23ai/dbhomeFree/python
exit
EOF

################################################################################
# 4.5.1.2 Install OML4Py Client for Linux for On-Premises Databases
################################################################################
# https://docs.oracle.com/en/database/oracle/machine-learning/oml4py/2-23ai/mlpug/install-oml4py-client-linux-premises-databases.html

cd ~
unzip ~/work/oml/V1048628-01.zip
export PYTHONHOME=$HOME/python
export PATH=$PYTHONHOME/bin:$PATH
export LD_LIBRARY_PATH=$PYTHONHOME/lib:$LD_LIBRARY_PATH
unset PYTHONPATH
pip3 install client/oml-2.1-cp312-cp312-linux_x86_64.whl
perl -Iclient client/client.pl -y

# OML4Py configuration complete.
