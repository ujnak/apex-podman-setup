set define '^' verify off
prompt ...patch_37512460.sql
--------------------------------------------------------------------------------
--
--  Copyright (c) 2025, Oracle and/or its affiliates.
--
--    NAME
--      patch_37512460.sql
--
--    DESCRIPTION
--      Fixes the wwv_flow_report_layouts_oit trigger
--
--    MODIFIED   (MM/DD/YYYY)
--    mhoogend   01/23/2025 - Created
--

create or replace trigger wwv_flow_report_layouts_oit
instead of update or delete on wwv_flow_report_layouts_dev
for each row
declare
    l_is_file_based varchar2(1);
begin
    if updating then
        l_is_file_based :=
            case
                when :new.report_layout_type not in ( 'RTF_FILE', 'XSL_FILE', 'XSL_GENERIC' )
                then 'Y'
                else 'N'
            end;
        update wwv_flow_report_layouts
           set report_layout_name               = :new.report_layout_name,
               static_id                        = :new.static_id,
               file_content                     = case
                                                    when l_is_file_based = 'Y'
                                                    then :new.file_content
                                                  end,
               file_name                        = case
                                                    when l_is_file_based = 'Y'
                                                    then :new.file_name
                                                  end,
               mime_type                        = case
                                                    when l_is_file_based = 'Y'
                                                    then :new.mime_type
                                                  end,
               etag                             = case
                                                    when l_is_file_based = 'Y'
                                                    then case
                                                            when :old.etag = :new.etag
                                                            then null
                                                            else :new.etag
                                                         end
                                                  end,
               data_loop_name                   = case
                                                    when l_is_file_based = 'Y'
                                                    then :new.data_loop_name
                                                  end,
               page_template                    = case
                                                    when :new.report_layout_type in ( 'RTF_FILE', 'XSL_FILE' )
                                                    then wwv_flow_utilities.blob_to_clob( :new.file_content )
                                                    else :new.page_template
                                                  end,
               xslfo_column_heading_template    = :new.xslfo_column_heading_template,
               xslfo_column_template            = :new.xslfo_column_template,
               xslfo_column_template_width      = :new.xslfo_column_template_width,
               reference_id                     = :new.reference_id,
               version_scn                      = :new.version_scn,
               report_layout_comment            = :new.report_layout_comment
         where id                               = :old.id
           and flow_id                          = :old.flow_id
           and security_group_id                = wwv_flow_security.g_security_group_id;
    elsif deleting then
        delete from wwv_flow_report_layouts
         where id                               = :old.id
           and security_group_id                = wwv_flow_security.g_security_group_id;
    end if;

end;
/