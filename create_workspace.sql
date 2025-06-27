set echo on

define WKSPNAME  = &1
define ADMINNAME = &2
define ADMINPASS = &3
define ADMINMAIL = &4

-- create default parsing shema for worksapce.
@create_schema WKSP_&WKSPNAME

-- create apex workspace.
begin
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
