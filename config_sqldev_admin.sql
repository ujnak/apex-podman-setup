set serveroutput on
begin
  for r in (select * from dba_role_privs)
  loop
    if r.grantee <> 'SYS' and r.grantee in ('ADMIN','PDBADMIN') then
      ords_admin.enable_schema(
        p_enabled => true,
        p_schema => r.grantee,
        p_url_mapping_type => 'BASE_PATH',
        p_url_mapping_pattern => lower(r.grantee),
        p_auto_rest_auth => true
      );
      dbms_output.put_line('Schema ' || r.grantee || ' is allowed to connect to SQL Developer Web.');
    end if;
  end loop;
  commit;
end;
/
