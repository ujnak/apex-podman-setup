Rem  Copyright (c) 2025, Oracle and/or its affiliates.
Rem
Rem    NAME
Rem      patch_central_themes.sql
Rem
Rem    DESCRIPTION
Rem      Install UT 24.2 into workspace 12
Rem
Rem    MODIFIED     (MM/DD/YYYY)
Rem    celara      02/07/2025 - Created

prompt
prompt ...Installing Universal Theme 24.2
prompt
set feedback off define '^' verify off
begin
    wwv_flow_application_install.set_workspace_id(12);
    wwv_flow_imp.set_security_group_id(12);
    wwv_flow_application_install.set_schema(wwv_flow.g_flow_schema_owner);
end;
/
@^PREFIX.f8842.242.sql

begin
    wwv_flow.g_import_in_progress := true;
    update wwv_flows
       set application_type = 'THEME'
     where security_group_id = 12
       and id = 8842.242;
    wwv_flow.g_import_in_progress := false;
    commit;
end;
/
--
--  Clear out application globals, so this avoids any downstream effect
begin
    wwv_flow_application_install.clear_all;
end;
/

set feedback on define '^' verify off
prompt
prompt ...done
