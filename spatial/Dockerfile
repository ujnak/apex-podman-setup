# Copyright (c) 2020, 2024 Oracle and/or its affiliates.
#
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.
#
# ORACLE DOCKERFILES PROJECT
# --------------------------
# This is the Dockerfile for Oracle JDK 17 on Oracle Linux 8
#
# REQUIRED FILES TO BUILD THIS IMAGE
# ----------------------------------
# (1) jdk-17.XX_linux-x64_bin.tar.gz or jdk-17.XX_linux-aarch64_bin.tar.gz
#     Download from https://www.oracle.com/java/technologies/downloads
#
# HOW TO BUILD THIS IMAGE
# -----------------------
# Put all downloaded files in the same directory as this Dockerfile
# Run:
#      $ docker build -t oracle/jdk:17 .
#
# This command is already scripted in build.sh so you can alternatively run
#      $ bash build.sh
#
# The builder image will be used to uncompress the tar.gz file with the Java Runtime.
#
#####################################################################################################
#
# NOTE for Oracle Spatial Studio:
#
# 1. Oracle Spatial Studio archive
#    https://www.oracle.com/database/technologies/spatial-studio/oracle-spatial-studio-downloads.html
#
# Place the downloaded V*-01.zip file under **files** directory.
# Make sure that there is only one file matching the pattern V*-01.zip.
#
# When V*-01.zip is extracted, it is expected to create a directory named Oracle_Spatial_Studio.
#
# 2. Oracle Java
#    https://www.oracle.com/java/technologies/downloads/#java17
#
# Place the jdk-17.*_linux-<arch>_bin.tar.gz file that matches your architecture under **files** directory.
# The file’s checksum varies depending on the JDK version.
# Currently, the checksum for version 17.0.16 is set in JAVA_SHA256.
# If you change the version from 17.0.16, you need to update JAVA_SHA256 accordingly.
#
# Oracle Spatial Studio did not work with JDK21.
#
# https://www.oracle.com/a/tech/docs/17-0-16-checksum.html
#
# HISTORY:
# 2025/08/01 ynakakos initial version.
#
#####################################################################################################

FROM oraclelinux:8 as builder

# LABEL maintainer="Aurelio Garcia-Ribeyro <aurelio.garciaribeyro@oracle.com>"

# Since the files are compressed as tar.gz first dnf install tar. gzip is already in oraclelinux:8
# FOR Spatial Studio - add unzip
RUN dnf install -y tar unzip

# FOR Spatial Studio - import Oracle Spatial Studio
COPY ./files/V*-01.zip /tmp/

# Default to UTF-8 file.encoding
ENV LANG en_US.UTF-8

# Environment variables for the builder image.
# Required to validate that you are using the correct file

ENV JAVA_HOME=/usr/java/jdk-17

##
COPY ./files/*.tar.gz /tmp/
SHELL ["/bin/bash", "-o", "pipefail", "-c"]
RUN set -eux; \
    ARCH="$(uname -m)" && \
    if [ "$ARCH" = "x86_64" ]; \
    then \
    mv "$(ls /tmp/jdk-17*_linux-x64_bin.tar.gz)" /tmp/jdk.tar.gz ; \
        JAVA_SHA256=f07da5571c693675a41603adbd6752e01f3defa272751b4fee582a7f29cacc75 ; \
    else \
    mv "$(ls /tmp/jdk-17*_linux-aarch64_bin.tar.gz)" /tmp/jdk.tar.gz ; \
        JAVA_SHA256=49c92d1b5a2607fbda0e5bbc3fa16c31ec8f50d264a7040c4a99e36233bb4b30 ; \
    fi && \
    echo "$JAVA_SHA256 */tmp/jdk.tar.gz" | sha256sum -c -; \
    mkdir -p "$JAVA_HOME"; \
    tar --extract --file /tmp/jdk.tar.gz --directory "$JAVA_HOME" --strip-components 1 ; \
    unzip -d /opt/oracle /tmp/V*-01.zip

# FOR Spatial Studio - add unzip to the last line of RUN

## Get a fresh version of Oracle Linux 8 for the final image
FROM oraclelinux:8

# Default to UTF-8 file.encoding
ENV LANG en_US.UTF-8
ENV JAVA_HOME=/usr/java/jdk-17
ENV PATH $JAVA_HOME/bin:$PATH

# If you need the Java Version you can read it from the release file with
# JAVA_VERSION=$(sed -n '/^JAVA_VERSION="/{s///;s/"//;p;}' "$JAVA_HOME"/release);

# Copy the uncompressed Java Runtime from the builder image
COPY --from=builder $JAVA_HOME $JAVA_HOME
# FOR Spatial Studio - copy Spatial Studio from builder
COPY --from=builder /opt/oracle/Oracle_Spatial_Studio /opt/oracle/Oracle_Spatial_Studio
COPY ./Start_Spatial_Studio.sh /opt/oracle/Oracle_Spatial_Studio/

RUN set -eux; \
# Ensure we get the latest OL 8 updates available at build time
    dnf -y update; \
# JDK assumes freetype is available
    dnf install -y \
        freetype fontconfig unzip which \
    ; \
    rm -rf /var/cache/dnf; \
    ln -sfT "$JAVA_HOME" /usr/java/default; \
    ln -sfT "$JAVA_HOME" /usr/java/latest; \
    for bin in "$JAVA_HOME/bin/"*; do \
        base="$(basename "$bin")"; \
        [ ! -e "/usr/bin/$base" ]; \
        alternatives --install "/usr/bin/$base" "$base" "$bin" 20000; \
    done;

# FOR Spatial Studio - start spatial studio
EXPOSE 8080 4040
WORKDIR /opt/oracle/Oracle_Spatial_Studio
CMD ["sh", "-c", "/opt/oracle/Oracle_Spatial_Studio/Start_Spatial_Studio.sh"]
#CMD ["jshell"]
