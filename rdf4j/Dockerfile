#
# Dockerfile for RDF4J with Oracle Driver.
#
# Change History:
# 2025/11/13 ynakakos created.
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
# (2) apache-tomchat-9.0.x.zip, Apache Tomcat 9.0.x
#     Download from https://tomcat.apache.org/download-90.cgi
# (3) ojdbc8-full.tar.gz, Oracle JDBC Driver
#     Download from https://www.oracle.com/database/technologies/appdev/jdbc-downloads.html
# (4) eclipse-rdf4j-4.3.x-sdk.zip, https://rdf4j.org/download/
#     Downlaod from https://rdf4j.org/download/
# (5) httpcomponents-client-4.5.14-bin.zip, HttpClient 4.5
#     Download from https://hc.apache.org/downloads.cgi
# (6) httpcomponents-core-4.4.16-bin.zip, HttpCore 4.4
#     Download from https://archive.apache.org/dist/httpcomponents/httpcore/binary/
# (7) V1048830-01.zip, Graph Adaptor for Eclipse RDF4J 22.4.1
#     Download from https://www.oracle.com/database/graph/downloads.html
#
# HOW TO BUILD THIS IMAGE
# -----------------------
# Put all downloaded files in ./files directory.
# Run:
#      $ podman build -t oracle-rdf4j .
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
# (2) Expand Apache Tomcat 9.0.x in /opt/tomcat
#
ENV CATALINA_HOME=/opt/tomcat
COPY files/apache-tomcat-9.0.*.zip /tmp/
RUN set -eux; \
    set -- /tmp/apache-tomcat-9.0.*.zip; \
    [ "$#" -eq 1 ] || (echo "Expected 1 match, got $#" && exit 1); \
    TOMCAT_DIR="${1#/tmp/}"; TOMCAT_DIR="${TOMCAT_DIR%.zip}"; \
    echo "TOMCAT_DIR=${TOMCAT_DIR}" ; \
    unzip -q -d /opt /tmp/${TOMCAT_DIR}.zip ; \
    mv /opt/${TOMCAT_DIR} ${CATALINA_HOME} ; \
    chmod a+x ${CATALINA_HOME}/bin/catalina.sh

##################################################################################
# (3) Extract Oracle JDBC Driver and place them in /opt/tomcat/lib/
#
COPY files/ojdbc8-full.tar.gz /tmp/
RUN set -eux; \
    tar -xvzf /tmp/ojdbc8-full.tar.gz -C ${CATALINA_HOME}/lib/ ojdbc8.jar ; \
    tar -xvzf /tmp/ojdbc8-full.tar.gz -C ${CATALINA_HOME}/lib/ ucp.jar ;

##################################################################################
# (4) Extract Apache RDF4J and place them in /opt/tomcat/webapps/ and /opt/tomcat/lib
#
COPY files/eclipse-rdf4j-4.3.*-sdk.zip /tmp/
RUN set -eux; \
    set -- /tmp/eclipse-rdf4j-4.3.*-sdk.zip; \
    [ "$#" -eq 1 ] || (echo "Expected 1 match, got $#" && exit 1); \
    RDF4J_VER="${1#/tmp/eclipse-rdf4j-}"; RDF4J_VER="${RDF4J_VER%-sdk.zip}"; \
    echo "RDF4J_VER=${RDF4J_VER}" ; \
    unzip -j -d ${CATALINA_HOME}/webapps/ /tmp/eclipse-rdf4j-${RDF4J_VER}-sdk.zip \
        eclipse-rdf4j-${RDF4J_VER}/war/rdf4j-server.war \
        eclipse-rdf4j-${RDF4J_VER}/war/rdf4j-workbench.war ; \
    unzip -j -d ${CATALINA_HOME}/lib/ /tmp/eclipse-rdf4j-${RDF4J_VER}-sdk.zip \
        eclipse-rdf4j-${RDF4J_VER}/lib/httpclient-4.5.14.jar \
        eclipse-rdf4j-${RDF4J_VER}/lib/httpclient-cache-4.5.14.jar \
        eclipse-rdf4j-${RDF4J_VER}/lib/httpcore-4.4.16.jar \
        eclipse-rdf4j-${RDF4J_VER}/lib/jackson-annotations-2.13.5.jar \
        eclipse-rdf4j-${RDF4J_VER}/lib/jackson-core-2.13.5.jar \
        eclipse-rdf4j-${RDF4J_VER}/lib/jackson-databind-2.13.5.jar \
        eclipse-rdf4j-${RDF4J_VER}/lib/jsonld-java-0.13.4.jar \
        eclipse-rdf4j-${RDF4J_VER}/lib/rdf4j-rio-jsonld-4.3.16.jar \
        eclipse-rdf4j-${RDF4J_VER}/lib/rdf4j-rio-rdfjson-4.3.16.jar ;

##################################################################################
# (5) Extract httpclient-osgi-*.jar from httpcomponents-client-*-bin.zip
#
COPY files/httpcomponents-client-4.5.*-bin.zip /tmp/
RUN set -eux; \
    set -- /tmp/httpcomponents-client-4.5.*-bin.zip; \
    [ "$#" -eq 1 ] || (echo "Expected 1 match, got $#" && exit 1); \
    HC_VER="${1#/tmp/httpcomponents-client-}"; HC_VER="${HC_VER%-bin.zip}"; \
    echo "HC_VER=${HC_VER}" ; \
    unzip -j -d ${CATALINA_HOME}/lib/ /tmp/httpcomponents-client-${HC_VER}-bin.zip \
        lib/httpclient-osgi-${HC_VER}.jar ;

##################################################################################
# (6) Extract httpcore-osgi-*.jar from httpcomponents-core-*-bin.zip
#
COPY files/httpcomponents-core-4.4.*-bin.zip /tmp/
RUN set -eux; \
    set -- /tmp/httpcomponents-core-4.4.*-bin.zip; \
    [ "$#" -eq 1 ] || (echo "Expected 1 match, got $#" && exit 1); \
    HC_VER="${1#/tmp/httpcomponents-core-}"; HC_VER="${HC_VER%-bin.zip}"; \
    echo "HC_VER=${HC_VER}" ; \
    unzip -j -d ${CATALINA_HOME}/lib/ /tmp/httpcomponents-core-${HC_VER}-bin.zip \
        lib/httpcore-osgi-${HC_VER}.jar ;

##################################################################################
# (7) Expand V1048830-01.zip in /opt/oracle
#
COPY files/V1048830-01.zip /tmp/
RUN unzip -q -d /opt/oracle /tmp/V1048830-01.zip

## Get a fresh version of Oracle Linux 8 for the final image
FROM oraclelinux:8

# Default to UTF-8 file.encoding
ENV LANG en_US.UTF-8

ENV JAVA_HOME=/usr/java/jdk-11
ENV CATALINA_HOME=/opt/tomcat
ENV ORACLE_HOME=/opt/oracle

ENV PATH $ORACLE_HOME/bin:$JAVA_HOME/bin:$PATH

# Copy Java, Tomcat and Oracle from the builder image
COPY --from=builder $JAVA_HOME     $JAVA_HOME
COPY --from=builder $CATALINA_HOME $CATALINA_HOME
COPY --from=builder $ORACLE_HOME   $ORACLE_HOME

RUN set -eux; \
    dnf -y update; \
    dnf install -y \
# JDK assumes freetype is available
        freetype fontconfig \
        tar unzip wget sudo \
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

# setup user/group for Oracle
RUN groupadd -g 54321 oinstall && \
    useradd -u 54321 -g 54321 -m -s /bin/bash oracle && \

    chown -R oracle:oinstall /home/oracle
# Configure sudo without password for oracle user
RUN echo 'oracle ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers.d/oracle && \
    chmod 0440 /etc/sudoers.d/oracle

# For integrating the Oracle driver into RDF4J. 
COPY create.xsl             /tmp/
COPY create-oracle.xsl      /tmp/ 
COPY context.xml            /tmp/
COPY tomcat-users.xml       /tmp/
COPY setup-oracle-driver.sh /tmp/ 

# Chagen ownership of Apache Tomcat and Eclipse RDF4J
RUN chown -R oracle:oinstall $CATALINA_HOME
RUN chown -R oracle:oinstall $ORACLE_HOME

# Expose Tomcat port
EXPOSE 8080

# start tomcat
WORKDIR $CATALINA_HOME
USER oracle
CMD ["/opt/tomcat/bin/catalina.sh","run"]
# CMD ["sh"]
