-- --------------------------------------------------------------------
-- Oracle APEX installation script.
--   Tested on APEX 24.1.0
-- --------------------------------------------------------------------

-- --------------------------------------------------------------------
-- Install APEX, image path includes APEX version.
--   REQUIRED ACTION:
--     Update IMAGE_PATH /i/24.1.0/ to fit your environment.
-- --------------------------------------------------------------------
@apexins SYSAUX SYSAUX TEMP /i/
-- @apexins SYSAUX SYSAUX TEMP /i/24.1.0/

-- --------------------------------------------------------------------
-- Load additional language resources.
--   REQUIRED ACTION:
--     Include or exclude languages resources.
-- --------------------------------------------------------------------
@load_trans JAPANESE

-- --------------------------------------------------------------------
-- Create APEX administration account.
--   REQUIRED ACTION:
--     Update p_username and p_password.
-- --------------------------------------------------------------------
begin
    apex_instance_admin.create_or_update_admin_user(
        p_username => 'ADMIN',
        p_email    => null,
        p_password => 'Welcome_1'
    );
    commit;
end;
/

-- --------------------------------------------------------------------
-- Set IMAGE_PREFIX.
--   REQUIRED ACTION:
--     Update p_value to CDN URL that match the installed APEX version.
-- --------------------------------------------------------------------
begin
    apex_instance_admin.set_parameter(
        p_parameter => 'IMAGE_PREFIX',
        p_value => 'https://static.oracle.com/cdn/apex/24.1.0/'
    );
    commit;
    end;
/

-- --------------------------------------------------------------------
-- Add Network ACL to APEX schema.
--   REQUIRED ACTION:
--     Update principal_name.
-- --------------------------------------------------------------------
begin
    dbms_network_acl_admin.append_host_ace(
        host => '*',
        ace => xs$ace_type(
            privilege_list => xs$name_list('connect'),
            principal_name => 'APEX_240100',
            principal_type => xs_acl.ptype_db
        )
     );
     commit;
end;
/

-- --------------------------------------------------------------------
-- Unlock APEX_PUBLIC_USER.
-- --------------------------------------------------------------------
alter user apex_public_user account unlock no authentication;

-- --------------------------------------------------------------------
exit;