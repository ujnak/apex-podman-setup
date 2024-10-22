-- --------------------------------------------------------------------
-- Create APEX administration account.
-- --------------------------------------------------------------------
begin
    apex_instance_admin.create_or_update_admin_user(
        p_username => 'ADMIN',
        p_email    => null,
        p_password => '&1'
    );
    commit;
end;
/

-- --------------------------------------------------------------------
-- Set CDN path for IMAGE_PREFIX.
-- --------------------------------------------------------------------
begin
    apex_instance_admin.set_parameter(
        p_parameter => 'IMAGE_PREFIX',
        p_value => 'https://static.oracle.com/cdn/apex/&2/'
    );
    commit;
end;
/

-- --------------------------------------------------------------------
-- Add Network ACL to APEX schema.
-- --------------------------------------------------------------------
begin
    dbms_network_acl_admin.append_host_ace(
        host => '*',
        ace => xs$ace_type(
            privilege_list => xs$name_list('connect'),
            principal_name => '&3',
            principal_type => xs_acl.ptype_db
        )
    );
    commit;
end;
/
exit