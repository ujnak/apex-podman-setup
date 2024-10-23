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
exit
