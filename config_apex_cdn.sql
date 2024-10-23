-- --------------------------------------------------------------------
-- Set CDN path for IMAGE_PREFIX.
-- --------------------------------------------------------------------
begin
    apex_instance_admin.set_parameter(
        p_parameter => 'IMAGE_PREFIX',
        p_value => 'https://static.oracle.com/cdn/apex/&1/'
    );
    commit;
end;
/
exit
