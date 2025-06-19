set serveroutput on
set feedback     off
spool &2
declare
    l_exported_script clob;
begin
    l_exported_script := ords_export_admin.export_schema('&1');
    dbms_output.put_line(l_exported_script);
end;
/
exit;
