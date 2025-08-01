# Copyright (c) 2022, 2023 Oracle and/or its affiliates.
#
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.
#
# ORACLE DOCKERFILES PROJECT
# --------------------------
# This is the Dockerfile for Oracle JDK 21 on Oracle Linux 8
#
# REQUIRED FILES TO BUILD THIS IMAGE
# ----------------------------------
# This dockerfile will download a copy of JDK 21 from
#    https://download.oracle.com/java/21/latest/jdk-21_linux-<ARCH>_bin.tar.gz
#
# It will use either x64 or aarch64 depending on the target platform
#
# HOW TO BUILD THIS IMAGE
# -----------------------
# Run:
#      $ docker build -t oracle/jdk:21 .
#
# This command is already scripted in build.sh so you can alternatively run
#      $ bash build.sh
#
# The builder image will be used to uncompress the tar.gz file with the Java Runtime.
#
#####################################################################################################
#
# NOTE for Oracle Graph Server:
#
# 1. Oracle Graph Server archive
#    https://www.oracle.com/database/graph/downloads.html
#
# Place the downloaded oracle-graph-<version>-<arch>.rpm file under **files** directory.
# Make sure that there is only one file matching the pattern oracle-graph-*.rpm.
#
# HISTORY:
# 2025/08/01 ynakakos initial version.
#
#####################################################################################################

FROM oraclelinux:8 as builder

#LABEL maintainer="Aurelio Garcia-Ribeyro <aurelio.garciaribeyro@oracle.com>"

# Since the files are compressed as tar.gz first dnf install tar. gzip is already in oraclelinux:8
RUN set -eux; \
    dnf install -y tar;

# Default to UTF-8 file.encoding
ENV LANG en_US.UTF-8

# Environment variables for the builder image.
# Required to validate that you are using the correct file

ENV JAVA_URL=https://download.oracle.com/java/21/latest \
    JAVA_HOME=/usr/java/jdk-21

##
SHELL ["/bin/bash", "-o", "pipefail", "-c"]
RUN set -eux; \
    ARCH="$(uname -m)" && \
    # Java uses just x64 in the name of the tarball
    if [ "$ARCH" = "x86_64" ]; \
        then ARCH="x64"; \
    fi && \
    JAVA_PKG="$JAVA_URL"/jdk-21_linux-"${ARCH}"_bin.tar.gz ; \
    JAVA_SHA256=$(curl "$JAVA_PKG".sha256) ; \
    curl --output /tmp/jdk.tgz "$JAVA_PKG" && \
    echo "$JAVA_SHA256" */tmp/jdk.tgz | sha256sum -c; \
    mkdir -p "$JAVA_HOME"; \
    tar --extract --file /tmp/jdk.tgz --directory "$JAVA_HOME" --strip-components 1

## Get a fresh version of Oracle Linux 8 for the final image
FROM oraclelinux:8

# Default to UTF-8 file.encoding
ENV LANG en_US.UTF-8
ENV JAVA_HOME=/usr/java/jdk-21
ENV PATH $JAVA_HOME/bin:$PATH

# If you need the Java Version you can read it from the release file with
# JAVA_VERSION=$(sed -n '/^JAVA_VERSION="/{s///;s/"//;p;}' "$JAVA_HOME"/release);

# Copy the uncompressed Java Runtime from the builder image
COPY --from=builder $JAVA_HOME $JAVA_HOME
# For Oracle Graph
COPY ./files/oracle-graph-*.rpm /tmp/

RUN set -eux; \
# Ensure we get the latest OL 8 updates available at build time
    dnf -y update; \
# JDK assumes freetype is available
    dnf install -y \
#        freetype fontconfig \
        freetype fontconfig unzip numactl gcc libgfortran python3.11 python3.11-pip \
    ; \
# For Oracle Graph
    dnf install -y \
        /tmp/oracle-graph-*.rpm ; \
    rm -f /tmp/oracle-graph-*.rpm ; \
    alternatives --install /usr/bin/python3 python3 /usr/bin/python3.11 20000 ; \
    alternatives --install /usr/bin/pip3 pip3 /usr/bin/pip3.11 2000 ; \
    pip3 install oracle-graph-client ; \
# End
    rm -rf /var/cache/dnf; \
    ln -sfT "$JAVA_HOME" /usr/java/default; \
    ln -sfT "$JAVA_HOME" /usr/java/latest; \
    for bin in "$JAVA_HOME/bin/"*; do \
        base="$(basename "$bin")"; \
        [ ! -e "/usr/bin/$base" ]; \
        alternatives --install "/usr/bin/$base" "$base" "$bin" 20000; \
    done;

# For Oracle Graph
COPY ./server.conf /etc/oracle/graph/server.conf
COPY ./pgx.conf /etc/oracle/graph/pgx.conf

EXPOSE 7007
WORKDIR /opt/oracle/graph/bin
CMD ["sh", "/opt/oracle/graph/pgx/bin/start-server"]
