set serveroutput on

define VERSION = &1

begin
    dbms_output.put_line(
        'IMAGE_PREFIX current: ' ||
        apex_instance_admin.get_parameter(p_parameter => 'IMAGE_PREFIX')
    );
    apex_instance_admin.set_parameter(
        p_parameter => 'IMAGE_PREFIX',
        p_value => 'https://static.oracle.com/cdn/apex/&VERSION/'
    );
    commit;
    dbms_output.put_line(
        'IMAGE_PREFIX after: ' ||
        apex_instance_admin.get_parameter(p_parameter => 'IMAGE_PREFIX')
    );
    end;
/
exit;
