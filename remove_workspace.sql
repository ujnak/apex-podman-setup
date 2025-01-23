set echo off
set serveroutput on

define WKSPNAME  = &1

begin
    apex_instance_admin.remove_workspace('&WKSPNAME');
exception
    when others then
        dbms_output.put_line(SQLERRM);
end;
/
begin
    execute immediate 'drop user wksp_&WKSPNAME cascade';
exception
    when others then
        dbms_output.put_line(SQLERRM);
end;
/
commit;
exit;
