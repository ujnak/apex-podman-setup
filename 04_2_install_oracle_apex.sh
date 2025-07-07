#!/bin/sh
# ############################################################################
# Install APEX on the database container.
# ############################################################################
#
# Usage: install_oracle_apex.sh <Container Name>  <APEX ADMIN Password>
#
# Change History:
# 2025/07/05: Separated from config_apex.sh
# 
# ############################################################################
# Settings.
# ############################################################################
# Language resource.
INSTALL_LANGUAGES="JAPANESE"

# container to install oracle apex.
TARGET_CONTAINER=$1

# APEX admin password
ADMIN_PASSWORD=$2

# #############################################################################
# Find APEX version and schema of apex-latest.zip
# #############################################################################
# detect APEX version of apex-latest.zip
apex_version_text=`cat apex/images/apex_version.txt`
apex_version="${apex_version_text#Oracle APEX Version:}"
apex_version="${apex_version#"${apex_version%%[![:space:]]*}"}"
# apex_version=`echo -n ${apex_version}` # trim
apex_major="${apex_version:0:2}"
apex_minor=${apex_version:3:1}
APEX_VERSION=${apex_major}.${apex_minor}.0
APEX_SCHEMA=APEX_${apex_major}0${apex_minor}00
echo "APEX VERSION detected: " ${APEX_VERSION} ${APEX_SCHEMA}

# #############################################################################
# Install Oracle APEX
# #############################################################################
#
podman exec -i ${TARGET_CONTAINER} sh <<__EOF__
cd /home/oracle/work/apex
export NLS_LANG=American_America.AL32UTF8
sqlplus / as sysdba
alter session set container=FREEPDB1;
@apexins SYSAUX SYSAUX TEMP /i/
alter user apex_public_user account unlock no authentication;
begin
    apex_instance_admin.create_or_update_admin_user(
        p_username => 'ADMIN',
        p_email    => null,
        p_password => '${ADMIN_PASSWORD}'
    );
    commit;
end;
/
begin
    dbms_network_acl_admin.append_host_ace(
        host => '*',
        ace => xs\$ace_type(
            privilege_list => xs\$name_list('http','http_proxy'),
            principal_name => upper('${APEX_SCHEMA}'),
            principal_type => xs_acl.ptype_db
        )
    );
    commit;
end;
/
@load_trans ${INSTALL_LANGUAGES}
exit;
__EOF__

# #############################################################################
# End of APEX instalation.
# #############################################################################
