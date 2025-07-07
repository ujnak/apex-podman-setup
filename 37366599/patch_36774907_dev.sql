set define '^' verify off
prompt ...patch_36774907_dev.sql
--------------------------------------------------------------------------------
--
--  Copyright (c) 2025, Oracle and/or its affiliates.
--
--    NAME
--      patch_36774907_dev.sql
--
--    DESCRIPTION
--      GENERATIVE AI: ADDITIONAL ATTRIBUTES OVERWRITTEN WITH DEFAULT VALUES
--
--    MODIFIED   (MM/DD/YYYY)
--    ralmuell    01/29/2025 - Created
--

update wwv_flow_steps
   set javascript_code = wwv_flow_string.join(wwv_flow_t_varchar2(
                         'function checkItemAndAddError(itemName, errorMessage, errorsArray) {',
                         '    if (apex.item(itemName).isEmpty()) {',
                         '        errorsArray.push({',
                         '            type: "error",',
                         '            location: ["page"],',
                         '            message: errorMessage,',
                         '            unsafe: false',
                         '        });',
                         '    }',
                         '}',
                         '',
                         'function isValidJSON() {',
                         '    let jsonAttributes = $v(''P9801_AI_ATTRIBUTES'');',
                         '',
                         '    if (jsonAttributes && jsonAttributes.trim() !== '''') {',
                         '        try {',
                         '            JSON.parse(jsonAttributes);',
                         '            return true;',
                         '        }',
                         '        catch (e) {',
                         '            return false;',
                         '        }',
                         '    }',
                         '    return true;',
                         '}',
                         '',
                         'function setAdditionalAttributes(itemName, aiProviderType, ociCompartmentID, ociModelID) {',
                         '    let jsonAttributes = $v(itemName);',
                         '    let jsonObject;',
                         '',
                         '    if (jsonAttributes && jsonAttributes.trim() !== '''') {',
                         '        try {',
                         '            jsonObject = JSON.parse(jsonAttributes);',
                         '        }',
                         '        catch (e) {',
                         '            apex.debug.error("Additional Attributes JSON parse error.");',
                         '            jsonObject = JSON.parse("{}");',
                         '        }',
                         '    }',
                         '',
                         '    switch (aiProviderType) {',
                         '        case ''OCI_GENAI'':',
                         '            jsonObject.compartmentId           = ociCompartmentID;',
                         '            jsonObject.servingMode             = {};',
                         '            jsonObject.servingMode.modelId     = ociModelID;',
                         '            jsonObject.servingMode.servingType = ''ON_DEMAND'';',
                         '        default:',
                         '    }',
                         '',
                         '    $s(itemName, JSON.stringify(jsonObject, null, 2));',
                         '}'))
 where security_group_id     = 10
   and flow_id               between 4000 and 4009
   and id                    >= 9801
   and id                    <  9801 + 1
/

-- In main the region default is calculated by wwv_flow_ai_dev.get_oci_region function
-- given the base URL
update wwv_flow_step_items
   set is_required           = 'N',
       item_default_type     = 'EXPRESSION',
       item_default_language = 'PLSQL',
       item_default          = 'substr(:P9801_BASE_URL, length(''https://inference.generativeai.'') + 1, length(:P9801_BASE_URL) - length(''https://inference.generativeai.'') - length(''.oci.oraclecloud.com''))'
 where security_group_id     = 10
   and flow_id               between 4000 and 4009
   and flow_step_id          >= 9801
   and flow_step_id          <  9801 + 1
   and id                    >= 3575163960259603
   and id                    <  3575163960259603 + 1
/

update wwv_flow_step_items
   set is_required           = 'N'
 where security_group_id     = 10
   and flow_id               between 4000 and 4009
   and flow_step_id          >= 9801
   and flow_step_id          <  9801 + 1
   and id                    >= 3575810718259610
   and id                    <  3575810718259610 + 1
/

update wwv_flow_page_da_actions
   set attribute_01          = wwv_flow_string.join(wwv_flow_t_varchar2(
                               'declare',
                               '    l_json_attrs   sys.json_object_t;',
                               '    l_json         sys.json_object_t := sys.json_object_t;',
                               'begin',
                               '    :P9801_BASE_URL := wwv_flow_ai_dev.get_base_url(',
                               '        p_provider_type      => :P9801_AI_PROVIDER_TYPE,',
                               '        p_oci_region         => :P9801_OCI_REGION);',
                               '    ',
                               '    if :P9801_AI_ATTRIBUTES is null then',
                               '        l_json_attrs         := sys.json_object_t;',
                               '    else',
                               '        begin',
                               '            l_json_attrs     := sys.json_object_t.parse(:P9801_AI_ATTRIBUTES);',
                               '        exception',
                               '            when others then',
                               '                l_json_attrs := sys.json_object_t;',
                               '        end;',
                               '    end if;',
                               '    case :P9801_AI_PROVIDER_TYPE',
                               '        when wwv_flow_ai.c_provider_openai then',
                               '            null;',
                               '        when wwv_flow_ai.c_provider_cohere then',
                               '            null;',
                               '        when wwv_flow_ai.c_provider_ocigenai then',
                               '            l_json_attrs.put(''compartmentId'', :P9801_OCI_COMPARTMENT_ID);',
                               '            l_json.put(''modelId'', :P9801_OCI_MODEL_ID);',
                               '            l_json.put(''servingType'', ''ON_DEMAND'');',
                               '            l_json_attrs.put(''servingMode'', l_json);',
                               '        else',
                               '            null;',
                               '    end case;',
                               '    if l_json_attrs.get_size >= 1 then',
                               '        :P9801_AI_ATTRIBUTES := l_json_attrs.to_clob;',
                               '    end if;',
                               '',
                               '    if :P9801_AI_PROVIDER_TYPE != wwv_flow_ai.c_provider_ocigenai then',
                               '        :P9801_AI_MODEL_NAME := wwv_flow_ai_dev.get_default_model(',
                               '            p_provider_type => :P9801_AI_PROVIDER_TYPE);',
                               '    end if;',
                               'end;')),
       attribute_02          = 'P9801_AI_ATTRIBUTES, P9801_AI_PROVIDER_TYPE,P9801_OCI_REGION,P9801_OCI_COMPARTMENT_ID,P9801_OCI_MODEL_ID',
       attribute_03          = 'P9801_BASE_URL,P9801_AI_ATTRIBUTES',
       attribute_04          = 'N',
       attribute_05          = 'PLSQL'
 where security_group_id     = 10
   and flow_id               between 4000 and 4009
   and page_id               >= 9801
   and page_id               <  9801 + 1
   and id                    >= 1802616335232018
   and id                    <  1802616335232018 + 1
/

update wwv_flow_page_da_actions
   set execute_on_page_init  = 'N'
 where security_group_id     = 10
   and flow_id               between 4000 and 4009
   and page_id               >= 9801
   and page_id               <  9801 + 1
   and id                    >= 3576126271259613
   and id                    <  3576126271259613 + 1
/

update wwv_flow_page_da_actions
   set execute_on_page_init  = 'N',
       action                = 'NATIVE_JAVASCRIPT_CODE',
       attribute_01          = wwv_flow_string.join(wwv_flow_t_varchar2(
                               'setAdditionalAttributes(',
                               '    ''P9801_AI_ATTRIBUTES'', ',
                               '    $v(''P9801_AI_PROVIDER_TYPE''), ',
                               '    $v(''P9801_OCI_COMPARTMENT_ID''), ',
                               '    $v(''P9801_OCI_MODEL_ID''));'))
 where security_group_id     = 10
   and flow_id               between 4000 and 4009
   and page_id               >= 9801
   and page_id               <  9801 + 1
   and id                    >= 3576304905259615
   and id                    <  3576304905259615 + 1
/

update wwv_flow_page_da_actions
   set execute_on_page_init  = 'N',
       action                = 'NATIVE_JAVASCRIPT_CODE',
       attribute_01          = wwv_flow_string.join(wwv_flow_t_varchar2(
                               'setAdditionalAttributes(',
                               '    ''P9801_AI_ATTRIBUTES'', ',
                               '    $v(''P9801_AI_PROVIDER_TYPE''), ',
                               '    $v(''P9801_OCI_COMPARTMENT_ID''), ',
                               '    $v(''P9801_OCI_MODEL_ID''));'))
 where security_group_id     = 10
   and flow_id               between 4000 and 4009
   and page_id               >= 9801
   and page_id               <  9801 + 1
   and id                    >= 3576508433259617
   and id                    <  3576508433259617 + 1
/

--
update wwv_flow_page_da_actions
   set action                = 'NATIVE_CLOSE_REGION',
       action_sequence       = 30,
       event_result          = 'TRUE'
 where security_group_id     = 10
   and flow_id               between 4000 and 4009
   and page_id               >= 9801
   and page_id               <  9801 + 1
   and id                    >= 4374426286092313
   and id                    <  4374426286092313 + 1
/

update wwv_flow_step_processing
   set process_sql_clob = wwv_flow_string.join(wwv_flow_t_varchar2(
                          'declare',
                          '    l_oci_attributes   sys.json_object_t;',
                          '    l_oci_serving_mode sys.json_object_t;',
                          'begin',
                          '    if :P9801_AI_PROVIDER_TYPE = ''OCI_GENAI'' then',
                          '        :P9801_OCI_CREDENTIAL_ID := :P9801_CREDENTIAL_ID;',
                          '        begin',
                          '            l_oci_attributes := sys.json_object_t.parse(:P9801_AI_ATTRIBUTES);',
                          '            if l_oci_attributes is not null then',
                          '             :P9801_OCI_COMPARTMENT_ID := l_oci_attributes.get_string(''compartmentId'');',
                          '                l_oci_serving_mode        := l_oci_attributes.get_object(''servingMode'');',
                          '                if l_oci_serving_mode is not null then',
                          '                    :P9801_OCI_MODEL_ID   := l_oci_serving_mode.get_string(''modelId'');',
                          '                end if;',
                          '            end if; ',
                          '            :P9801_OCI_REGION := substr(:P9801_BASE_URL, length(''https://inference.generativeai.'') + 1, length(:P9801_BASE_URL) - length(''https://inference.generativeai.'') - length(''.oci.oraclecloud.com''));',
                          '        exception',
                          '            when others then',
                          '                -- Set model to default model and leave compartment empty',
                          '                :P9801_OCI_MODEL_ID := wwv_flow_ai_dev.get_default_model(',
                          '                    p_provider_type => :P9801_AI_PROVIDER_TYPE);',
                          '        end;',
                          '    else',
                          '         :P9801_APIKEY_CREDENTIAL_ID := :P9801_CREDENTIAL_ID;',
                          '    end if;',
                          'end;',
                          ''))
 where security_group_id     = 10
   and flow_id               between 4000 and 4009
   and flow_step_id          >= 9801
   and flow_step_id          <  9801 + 1
   and id                    >= 2384839101262621
   and id                    <  2384839101262621 + 1
/

update wwv_flow_step_processing
   set process_sql_clob = wwv_flow_string.join(wwv_flow_t_varchar2(
                          'declare',
                          '    l_json_attrs   sys.json_object_t;',
                          '    l_json         sys.json_object_t := sys.json_object_t;',
                          '    l_clob         clob;',
                          '    l_clob_attrs   clob;',
                          'begin',
                          '    :P9801_BASE_URL := wwv_flow_ai_dev.get_base_url(',
                          '        p_provider_type      => :P9801_AI_PROVIDER_TYPE,',
                          '        p_oci_region         => :P9801_OCI_REGION);',
                          '    ',
                          '    if :P9801_AI_ATTRIBUTES is null then',
                          '        l_json_attrs         := sys.json_object_t;',
                          '    else',
                          '        begin',
                          '            l_json_attrs     := sys.json_object_t.parse(:P9801_AI_ATTRIBUTES);',
                          '        exception',
                          '            when others then',
                          '                l_json_attrs := sys.json_object_t;',
                          '        end;',
                          '    end if;',
                          '    case :P9801_AI_PROVIDER_TYPE',
                          '        when wwv_flow_ai.c_provider_openai then',
                          '            null;',
                          '        when wwv_flow_ai.c_provider_cohere then',
                          '            null;',
                          '        when wwv_flow_ai.c_provider_ocigenai then',
                          '            l_json_attrs.put(''compartmentId'', :P9801_OCI_COMPARTMENT_ID);',
                          '            l_json.put(''modelId'', :P9801_OCI_MODEL_ID);',
                          '            l_json.put(''servingType'', ''ON_DEMAND'');',
                          '            l_json_attrs.put(''servingMode'', l_json);',
                          '        else',
                          '            null;',
                          '    end case;',
                          '    if l_json_attrs.get_size >= 1 then',
                          '        l_clob_attrs := l_json_attrs.to_clob;',
                          '        select json_serialize(to_clob(l_clob_attrs) returning clob pretty)',
                          '          into l_clob',
                          '          from sys.dual;',
                          '        :P9801_AI_ATTRIBUTES := l_clob;',
                          '    end if;',
                          'end;'))
 where security_group_id     = 10
   and flow_id               between 4000 and 4009
   and flow_step_id          >= 9801
   and flow_step_id          <  9801 + 1
   and id                    >= 4374907795092318
   and id                    <  4374907795092318 + 1
/

declare
   l_offset                  number;
   l_flow_id                 number;
   l_dummy                   number;
begin
   wwv_flow_security.g_security_group_id := 10;
   wwv_flow_imp.g_id_offset := 0;

   -- Iterate over all installed builders
   for l_flow in (
      select id
        from wwv_flows
       where id                between 4000 and 4009
         and security_group_id = 10) loop

      l_flow_id := l_flow.id;

      -- No offset for 4000
      l_offset := case l_flow_id when 4000 then 0 else (l_flow_id / 10000) end;

      begin
         select 1
           into l_dummy
           from wwv_flow_page_da_actions
          where security_group_id =  10
            and flow_id           =  l_flow_id
            and page_id           =  9801 + l_offset
            and id                =  2759843671191302 + l_offset
            and rownum            <= 1;
      exception
         when no_data_found then
            wwv_flow_imp_page.create_page_da_action(
               p_id=>wwv_flow_imp.id(2759843671191302 + l_offset)
               ,p_flow_id=>wwv_flow_imp.id(l_flow_id)
               ,p_page_id=>wwv_flow_imp.id(9801 + l_offset)
               ,p_event_id=>wwv_flow_imp.id(4374347245092312 + l_offset)
               ,p_event_result=>'TRUE'
               ,p_action_sequence=>10
               ,p_execute_on_page_init=>'N'
               ,p_name=>'Alert if invalid JSON'
               ,p_action=>'NATIVE_ALERT'
               ,p_attribute_01=>'&"APP_TEXT$PE.INVALID".'
               ,p_client_condition_type=>'JAVASCRIPT_EXPRESSION'
               ,p_client_condition_expression=>' ! isValidJSON()');
      end;

      begin
         select 1
           into l_dummy
           from wwv_flow_page_da_actions
          where security_group_id =  10
            and flow_id           =  l_flow_id
            and page_id           =  9801 + l_offset
            and id                =  2759972222191303 + l_offset
            and rownum            <= 1;
      exception
         when no_data_found then
            wwv_flow_imp_page.create_page_da_action(
               p_id=>wwv_flow_imp.id(2759972222191303 + l_offset)
               ,p_flow_id=>wwv_flow_imp.id(l_flow_id)
               ,p_page_id=>wwv_flow_imp.id(9801 + l_offset)
               ,p_event_id=>wwv_flow_imp.id(4374347245092312 + l_offset)
               ,p_event_result=>'TRUE'
               ,p_action_sequence=>20
               ,p_execute_on_page_init=>'N'
               ,p_name=>'Cancel Event'
               ,p_action=>'NATIVE_CANCEL_EVENT'
               ,p_client_condition_type=>'JAVASCRIPT_EXPRESSION'
               ,p_client_condition_expression=>'! isValidJSON()');
      end;

   end loop;
end;
/
