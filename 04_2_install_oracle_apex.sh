#!/bin/sh
# ############################################################################
# Install APEX on the database container.
# ############################################################################
#
# Usage: install_oracle_apex.sh <Container Name>  <APEX ADMIN Password>
#
# Change History:
# 2025/07/10: use APEX_APPLICATION.g_flow_schema_owner
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
            principal_name => APEX_APPLICATION.g_flow_schema_owner,
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
