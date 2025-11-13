#!/bin/sh

cd $HOME
# Install Oracle Driver for RDF4J
cp /opt/oracle/jar/* /opt/tomcat/webapps/rdf4j-server/WEB-INF/lib/
cp /opt/oracle/jar/* /opt/tomcat/webapps/rdf4j-workbench/WEB-INF/lib/
cp create-oracle.xsl /opt/tomcat/webapps/rdf4j-workbench/transformations/create-oracle.xsl
cp create.xsl        /opt/tomcat/webapps/rdf4j-workbench/transformations/create.xsl
# Should update <<username>>, <<pwd>> and <<host:port/servicename>> in context.xml
cp context.xml       /opt/tomcat/conf/context.xml
# Should update <must-be-changed> for admin password in tomcat-users.xml
cp tomcat-users.xml  /opt/tomcat/conf/tomcat-users.xml
# Allow access from anywhere
sed -i 's|127\.0\.0\.0/8,::1/128|0.0.0.0/0,::/0|g' /opt/tomcat/webapps/manager/META-INF/context.xml
sed -i 's|127\.0\.0\.0/8,::1/128|0.0.0.0/0,::/0|g' /opt/tomcat/webapps/docs/META-INF/context.xml
sed -i 's|127\.0\.0\.0/8,::1/128|0.0.0.0/0,::/0|g' /opt/tomcat/webapps/examples/META-INF/context.xml
sed -i 's|127\.0\.0\.0/8,::1/128|0.0.0.0/0,::/0|g' /opt/tomcat/webapps/host-manager/META-INF/context.xml
