set define '^' verify off concat on
set concat .

spool catpatch.log

define PATCH_ID = '37366599'
define PREFIX   = '@'
timing start "Complete Patch ^PATCH_ID."

prompt
prompt . ORACLE
prompt .
prompt . Oracle APEX 24.2.%
prompt . Patch Set Exception ^PATCH_ID.
prompt ........................................

whenever sqlerror exit sql.sqlcode rollback

Rem Load current APEX version and schema from DBA_REGISTRY
column   APEX_VERSION new_val APEX_VERSION
column   APEX_SCHEMA  new_val APEX_SCHEMA

select version APEX_VERSION,
       schema  APEX_SCHEMA
  from sys.dba_registry
 where comp_id = 'APEX'
/

Rem Check that release is 24.2.% and installed version not newer
declare
    c_expected_release constant varchar2(100) := '24.2.%';
    c_patch_version    constant number        := 2426;
    l_current_release  varchar2(100)          := nvl('^APEX_VERSION','<unknown>');
begin
    for c1 in ( select version
                  from sys.dba_registry
                 where comp_id = 'APEX' )
    loop
        l_current_release := c1.version;
    end loop;

    if l_current_release not like c_expected_release then
        raise_application_error( -20001, 'You can only use this script to patch release ' || c_expected_release ||
                                         '. This instance appears to be ' || l_current_release || '.' );
    elsif to_number(replace(l_current_release,'.',null)) > c_patch_version then
        raise_application_error( -20001, 'This instance appears to be ' || l_current_release || 
                                         ' which is later than this patch.' );
    end if;
end;
/

@^PREFIX.corepatch.sql "^PREFIX."

timing stop
spool off

whenever sqlerror exit success
set termout off
begin
    if nvl( sys_context('USERENV', 'ACTION'), 'xx' ) != 'patching' then
        raise_application_error( -20001, 'Stop further processing. This error can be ignored.' );
    end if;
    sys.dbms_session.reset_package();
end;
/
whenever sqlerror exit sql.sqlcode rollback
set termout on
