set echo on

define WKSPNAME  = &1
define ADMINNAME = &2
define ADMINPASS = &3
define ADMINMAIL = &4

-- create default parsing shema for worksapce apexdev.
create user wksp_&WKSPNAME default tablespace users temporary tablespace temp quota unlimited on users;

-- 
begin
    dbms_network_acl_admin.append_host_ace(
        host => '*',
        ace => xs$ace_type(
            privilege_list => xs$name_list('http'),
            principal_name => 'wksp_&WKSPNAME',
            principal_type => xs_acl.ptype_db
        )
    );
end;
/

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
    p_user_name                    => '&ADMINNAME',
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
