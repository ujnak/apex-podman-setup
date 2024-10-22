set echo on

define WKSPNAME  = &1

begin
    apex_instance_admin.remove_workspace('&WKSPNAME');
    execute immediate 'drop user wksp_&WKSPNAME cascade';
end;
/
commit;
exit;
