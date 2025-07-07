set define '^' verify off
prompt ...patch_37588311_dev.sql
--------------------------------------------------------------------------------
--
--  Copyright (c) 2025, Oracle and/or its affiliates.
--
--    NAME
--      patch_37588311_dev.sql
--
--    DESCRIPTION
--      This script updates the "Automation Query" validation in app 4000, page 7021.
--
--    MODIFIED   (MM/DD/YYYY)
--    cczarski    02/13/2025
--
--------------------------------------------------------------------------------

update wwv_flow_step_validations
   set validation = wwv_flow_string.join(wwv_flow_t_varchar2(
                        '--',
                        '-- validate_query also validates that required items actually contain',
                        '-- a value (e.g. Table Name for Query Type = TABLE)',
                        '',
                        'return wwv_flow_exec_dev.validate_query(',
                        '           p_location               => :P7021_LOCATION,',
                        '           p_remote_server_id        => :P7021_REMOTE_SERVER_ID,',
                        '           p_web_src_module_id       => :P7021_WEB_SRC_MODULE_ID,',
                        '           p_array_column_id         => :P7021_WEB_SRC_ARRAY_COL_ID,',
                        '           p_document_source_id      => :P7021_DOCUMENT_SOURCE_ID,',
                        '           -- ',
                        '           p_table_owner             => :P7021_TABLE_OWNER,',
                        '           p_table_name              => case when :P7021_LOCAL_DATA_SOURCE_TYPE = ''GRAPH'' then :P7021_GRAPH_NAME else :P7021_TABLE_NAME end,',
                        '           p_where_clause            => :P7021_QUERY_WHERE,',
                        '           p_match_clause            => :P7021_PQL_MATCH_CLAUSE,',
                        '           p_columns_clause          => :P7021_PQL_COLUMNS_CLAUSE,',
                        '           p_order_by_clause         => :P7021_QUERY_ORDER_BY,',
                        '           p_sql_query               => :P7021_SQL,',
                        '           p_function_body_language  => :P7021_FUNCTION_BODY_LANGUAGE,',
                        '           p_function_body           => :P7021_SQL,',
                        '           p_optimizer_hint          => :P7021_OPTIMIZER_HINT,',
                        '           -- ',
                        '           p_post_processing_type    => :P7021_SOURCE_POST_PROCESSING,',
                        ' ',
                        '           p_query_type              => case when :P7021_LOCATION = ''REMOTE'' then :P7021_REMOTE_DATA_SOURCE_TYPE else :P7021_LOCAL_DATA_SOURCE_TYPE end );'))
 where security_group_id = 10
   and flow_id      between 4000 and 4009
    --
   and flow_step_id >= 7021
   and flow_step_id <  7021 + 1
    --
   and id           >= 987816604192252914
   and id           <  987816604192252914 + 1
/
