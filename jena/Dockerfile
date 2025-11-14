#
# Dockerfile for Apache Jena with Oracle Driver.
#
# Change History:
# 2025/11/14 ynakakos created.
#
# This is based on the Dockerfile.ol8 published in the following GitHub repository.
# https://github.com/oracle/docker-images/tree/main/OracleJava/11
# Copyright (c) 2019, 2024 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.
#
# REQUIRED FILES TO BUILD THIS IMAGE
# ----------------------------------
#
# (1) jdk-11.XX_linux-x64_bin.tar.gz or jdk-11.XX_linux-aarch64_bin.tar.gz
#     Download from https://www.oracle.com/java/technologies/downloads/#java11
# (2) V1052173-01.zip, Support for Apache Jena and Fuseki 3.12.0, 21.1.8
#     Download from https://www.oracle.com/database/graph/downloads.html
#
# HOW TO BUILD THIS IMAGE
# -----------------------
# Put all downloaded files in ./files directory.
# Run:
#      $ podman build -t oracle-jena .
#
FROM oraclelinux:8 as builder

# Since the files are compressed as tar.gz and zip first dnf install tar and unzip.
# gzip is already in oraclelinux:8
RUN dnf install -y tar unzip

# Default to UTF-8 file.encoding
ENV LANG en_US.UTF-8

##################################################################################
# (1) Expand JDK 11 in /usr/java/jdk-11
# 
ENV JAVA_HOME=/usr/java/jdk-11
COPY files/jdk-11.*.tar.gz /tmp/
RUN set -eux; \
    ARCH="$(uname -m)" && \
    if [ "$ARCH" = "x86_64" ]; \
    then \
    mv "$(ls /tmp/jdk-11*_linux-x64_bin.tar.gz)" /tmp/jdk.tar.gz ; \
    else \
    mv "$(ls /tmp/jdk-11*_linux-aarch64_bin.tar.gz)" /tmp/jdk.tar.gz ; \
    fi && \
    mkdir -p "$JAVA_HOME"; \
    tar --extract --file /tmp/jdk.tar.gz --directory "$JAVA_HOME" --strip-components 1

##################################################################################
# (2) Expand V1052173-01.zip in /opt/oracle-jena
#
COPY files/V1052173-01.zip /tmp/
RUN unzip -q -d /opt/oracle-jena /tmp/V1052173-01.zip

## Get a fresh version of Oracle Linux 8 for the final image
FROM oraclelinux:8

# Default to UTF-8 file.encoding
ENV LANG en_US.UTF-8

ENV JAVA_HOME=/usr/java/jdk-11
ENV ORACLE_JENA_HOME=/opt/oracle-jena

ENV PATH $ORACLE_JENA_HOME/bin:$JAVA_HOME/bin:$PATH

# Copy Java and Apache Jena from the builder image
COPY --from=builder $JAVA_HOME $JAVA_HOME
COPY --from=builder $ORACLE_JENA_HOME $ORACLE_JENA_HOME

RUN set -eux; \
    dnf -y update; \
    dnf install -y \
# JDK assumes freetype is available
        freetype fontconfig \
        tar unzip \
    ; \
    rm -rf /var/cache/dnf; \
    ln -sfT "$JAVA_HOME" /usr/java/default; \
    ln -sfT "$JAVA_HOME" /usr/java/latest; \
    for bin in "$JAVA_HOME/bin/"*; do \
        base="$(basename "$bin")"; \
        [ ! -e "/usr/bin/$base" ]; \
        alternatives --install "/usr/bin/$base" "$base" "$bin" 20000; \
    done; \
# -Xshare:dump will create a CDS archive to improve startup in subsequent runs
    java -Xshare:dump;

# For integrating the Oracle driver into RDF4J. 
COPY config-oracle.ttl /opt/oracle-jena/fuseki/run/config.ttl
COPY shiro.ini         /opt/oracle-jena/fuseki/run/shiro.ini 

# Expose Fuseki port
EXPOSE 3030

WORKDIR ${ORACLE_JENA_HOME}/fuseki
CMD ["sh","fuseki-server"]
# CMD ["sh"]
