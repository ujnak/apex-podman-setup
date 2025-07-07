Rem  Copyright (c) 1999, 2024, Oracle and/or its affiliates.
Rem
Rem    NAME
Rem      catpatch_con.sql
Rem
Rem    DESCRIPTION
Rem      This script installs Oracle APEX patch in a multitenant container database.
Rem
Rem    NOTES
Rem      Assumes the SYS user is connected. Must be run locally to the database and the
Rem      ORACLE_HOME environment variable must be set.
Rem
Rem    REQUIREMENTS
Rem      - Oracle Database 12.1.0.1 or later
set define '^' verify off

define PREFIX   = '@'

timing start "Complete Patch"


whenever sqlerror exit

column :xe_home new_value OH_HOME NOPRINT
variable xe_home varchar2(255)

set serveroutput on
begin
    -- get oracle_home
    sys.dbms_system.get_env('ORACLE_HOME',:xe_home);
    if length(:xe_home) = 0 then
        sys.dbms_output.put_line(lpad('-',80,'-'));
        raise_application_error (
            -20001,
            'Oracle Home environment variable not set' );
    end if;
end;
/

Rem Check that release is 24.2.% and installed version not newer
declare
    c_expected_release constant varchar2(100) := '24.2.%';
    c_patch_version    constant number        := 2426;
    l_current_release  varchar2(100) := '<unknown>';
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

whenever sqlerror continue

set termout off
select :xe_home from sys.dual;
set termout on

prompt Performing installation in multitenant container database in the background.
prompt The installation progress is spooled into *catpatch_con*.log files.
prompt
prompt Please wait...
prompt

host ^OH_HOME/perl/bin/perl -I ^OH_HOME/rdbms/admin ^OH_HOME/rdbms/admin/catcon.pl -b catpatch_con corepatch.sql --p^PREFIX

timing stop

prompt
prompt Installation completed. Log files for each container can be found in:
prompt
prompt catpatch_con*.log
prompt
prompt You can quickly scan for ORA errors or compilation errors by using a utility
prompt like grep:
prompt
prompt grep ORA- *.log
prompt grep PLS- *.log
prompt
