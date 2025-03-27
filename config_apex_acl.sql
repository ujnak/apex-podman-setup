-- --------------------------------------------------------------------
-- Add Network ACL to APEX schema.
--
-- Change History;
-- 2025-03-27: add http_proxy to privilege_list
-- 2025-03-27: always upper case for principal_name
-- --------------------------------------------------------------------
begin
    dbms_network_acl_admin.append_host_ace(
        host => '*',
        ace => xs$ace_type(
            privilege_list => xs$name_list('http','http_proxy'),
            principal_name => upper('&1'),
            principal_type => xs_acl.ptype_db
        )
    );
    commit;
end;
/
exit
