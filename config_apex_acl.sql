-- --------------------------------------------------------------------
-- Add Network ACL to APEX schema.
-- --------------------------------------------------------------------
begin
    dbms_network_acl_admin.append_host_ace(
        host => '*',
        ace => xs$ace_type(
            privilege_list => xs$name_list('connect','http'),
            principal_name => '&1',
            principal_type => xs_acl.ptype_db
        )
    );
    commit;
end;
/
exit
