#!/bin/sh
################################################################################
# Install JDK
################################################################################
#
su -c "echo > /etc/dnf/vars/ociregion"
# ------------------------------------------------------------------------------
# uncomment for OpenJDK
# ------------------------------------------------------------------------------
echo "Install OpenJDK 21 for ORDS..."
su -c "dnf -y install java-21-openjdk-headless"
# ------------------------------------------------------------------------------
# uncomment for Oracle JDK
# ------------------------------------------------------------------------------
#echo "Install Oracle JDK 21 for ORDS..."
#curl -OL https://download.oracle.com/java/21/latest/jdk-21_linux-aarch64_bin.rpm
#su -c "dnf -y install jdk-21_linux-aarch64_bin.rpm"
#rm -f jdk-21_linux-aarch64_bin.rpm
# ------------------------------------------------------------------------------
# uncomment for GraalVM CE
# ------------------------------------------------------------------------------
#echo "Install GraalVM22 for GraphQL ..."
#su -c "dnf -y --repofrompath ol8_graalvm,https://yum.oracle.com/repo/OracleLinux/OL8/graalvm/community/aarch64 install graalvm22-ce-17-jdk graalvm22-ce-17-javascript"
#su -c "dnf -y --repofrompath ol8_graalvm,https://yum.oracle.com/repo/OracleLinux/OL8/graalvm/community/x86_64 install graalvm22-ce-17-jdk graalvm22-ce-17-javascript"
# ------------------------------------------------------------------------------
echo "Done."
