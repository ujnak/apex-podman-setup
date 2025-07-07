set define '^' verify off
prompt ...patch_37809911.sql
--------------------------------------------------------------------------------
--
--  Copyright (c) 2025, Oracle and/or its affiliates.
--
--    NAME
--      patch_37809911.sql
--
--    DESCRIPTION
--      Fix for 37809911 - AN AUDIT RECORD IS NOT STORED DUE TO HANDLED EXCEPTION IN TRIGGER DURING WORKING COPY MERGE
--
--    MODIFIED   (MM/DD/YYYY)
--    fsecara     4/17/2025 - Created
--------------------------------------------------------------------------------

prompt ...trigger wwv_flow_step_items_t2

create or replace trigger wwv_flow_step_items_t2
    before delete on wwv_flow_step_items
    for each row
begin
    --
    -- cascade delete flow and step computations referencing item
    --
    if nvl(wwv_flow_imp.g_mode,'x') != 'REPLACE' then
        begin
            delete wwv_flow_computations
             where upper(computation_item) = upper(:old.name)
               and flow_id                 = :old.flow_id
               and security_group_id       = :old.security_group_id;
            delete wwv_flow_step_computations
             where upper(computation_item) = upper(:old.name)
               and flow_id                 = :old.flow_id
               and security_group_id       = :old.security_group_id;
        exception when others then null;
        end;
    end if;
    --
    -- cascade update to page
    --
    begin
        wwv_flow_audit.g_cascade := true;
        update wwv_flow_steps
           set last_updated_on = sysdate,
               last_updated_by = wwv_flow.g_user
         where flow_id           = :old.flow_id
           and id                = :old.flow_step_id
           and security_group_id = :new.security_group_id;
        wwv_flow_audit.g_cascade := false;
    exception
        when others then
            wwv_flow_audit.g_cascade := false;
    end;
end;
/
