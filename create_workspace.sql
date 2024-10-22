set echo on

define WKSPNAME  = &1
define ADMINPASS = 'Welcome_1'
define ADMINMAIL = 'noreply@oracle.com'

-- create default parsing shema for worksapce apexdev.
create user wksp_&WKSPNAME default tablespace users temporary tablespace temp quota unlimited on users;

begin

for c1 in (
    select privilege from sys.dba_sys_privs
    where grantee = 'APEX_GRANTS_FOR_NEW_USERS_ROLE'
)
loop
    execute immediate 'grant ' || c1.privilege || ' to wksp_&WKSPNAME';
end loop;

apex_instance_admin.add_workspace(
    p_workspace => '&WKSPNAME',
    p_primary_schema => 'WKSP_&WKSPNAME'
);

apex_util.set_workspace('&WKSPNAME');

apex_util.create_user(
    p_user_name                    => '&WKSPNAME',
    p_web_password                 => '&ADMINPASS',
    p_developer_privs              => 'ADMIN:CREATE:DATA_LOADER:EDIT:HELP:MONITOR:SQL',
    p_email_address                => '&ADMINMAIL',
    p_default_schema               => 'WKSP_&WKSPNAME',
    p_change_password_on_first_use => 'N'
);
end;
/
commit;
exit;
