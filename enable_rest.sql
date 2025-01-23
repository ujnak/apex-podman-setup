set echo on

define WKSPNAME  = &1

--- add roles
grant connect,resource to WKSP_&WKSPNAME;

-- enable REST service.
begin
    ords_admin.enable_schema(
        p_enabled => true
        ,p_schema => 'WKSP_&WKSPNAME'
        ,p_url_mapping_type => 'BASE_PATH'
        ,p_url_mapping_pattern => lower('&WKSPNAME')
        ,p_auto_rest_auth => true
     );
     commit;
end;
/
exit;
