Rem  Copyright (c) 1999, 2024, Oracle and/or its affiliates.
Rem
Rem    NAME
Rem      catpatch_appcon.sql
Rem
Rem    DESCRIPTION
Rem      This script installs Oracle APEX patch in an application container database.
Rem
Rem    NOTES
Rem      Assumes the SYS user is connected. Must be run locally to the database and the
Rem      ORACLE_HOME environment variable must be set.
Rem
Rem    REQUIREMENTS
Rem      - Oracle Database 12.1.0.1 or later
set define '^' verify off

set concat .

spool catpatch_appcon.log

define PATCH_ID = ''
define PREFIX   = '@'

timing start "Complete Patch ^PATCH_ID."

prompt
prompt . ORACLE
prompt .
prompt . Oracle APEX 24.2.x
prompt . Patch Set Exception ^PATCH_ID.
prompt ........................................

whenever sqlerror exit sql.sqlcode rollback

Rem Check that release is 24.2
--
-- Applications in an application container cannot be listed in the registry. They have
-- their own "registry" and APEX starts at 24.2. Each subsequent patch is really considered
-- and upgrade in the application container infrastructure, and each time a patch is applied
-- the APEX application is incremented by 1. It should not be expected that applying a patch
-- to an application container would result in the same application version number as the
-- version in the database component registry. To determine the patch level in an application
-- container, wwv_flow_pses can be queried.
declare
    c_expected_release constant varchar2(100) := '24.2';
    l_current_release  varchar2(100) := '<unknown>';
begin
    for c1 in ( select substr(app_version,1,4) app_version
                  from sys.dba_applications
                 where app_name = 'APEX' )
    loop
        l_current_release := c1.app_version;
    end loop;

    if l_current_release not like c_expected_release then
        raise_application_error( -20001, 'You can only use this script to patch release ' || c_expected_release ||
                                         '. This instance appears to be ' || l_current_release || '.' );
    end if;
end;
/

column appver new_val appver
column begver new_val begver
set termout off
select substr(app_version,1,4)||'.'||to_char(nvl(substr(app_version,6,1),0)+1) appver from dba_applications where app_name = 'APEX';
select app_version begver from dba_applications where app_name = 'APEX';
set termout on

alter pluggable database application apex begin upgrade '^begver' to '^appver';

@^PREFIX.corepatch.sql "^PREFIX."

alter pluggable database application apex end upgrade to '^appver';

begin
    sys.dbms_utility.compile_schema( 'APEX_240200', false );
    sys.dbms_utility.compile_schema( 'FLOWS_FILES', false );
end;
/

timing stop
spool off

