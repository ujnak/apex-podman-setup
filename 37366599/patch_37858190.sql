set define '^' verify off
prompt ...patch_37858190.sql
--------------------------------------------------------------------------------
--
--  Copyright (c) 2025, Oracle and/or its affiliates.
--
--    NAME
--      patch_37858190.sql
--
--    DESCRIPTION
--      Fixes the wwv_flow_preferences_t1 trigger
--      Drops the wwv_flow_preferences_t2 trigger
--
--    MODIFIED   (MM/DD/YYYY)
--    andrdobr   05/13/2025 - Created
--

prompt ...trigger wwv_flow_preferences_t1

create or replace trigger wwv_flow_preferences_t1
    before insert or update on wwv_flow_preferences$
    for each row
begin
    if inserting then
        if :new.id is null then
            :new.id := wwv_flow_id.next_val;
        end if;
    end if;
    --
    -- vpd
    --
    if :new.security_group_id is null then
       :new.security_group_id := wwv_flow_security.g_security_group_id;
    end if;
    --
    exception when wwv_flow_error.e_mutating_table then null;
end;
/

begin
    for i in ( select trigger_name,
                      owner
                 from sys.dba_triggers
                where owner        = 'APEX_240200'
                  and trigger_name = 'WWV_FLOW_PREFERENCES_T2' )
    loop
        execute immediate 'drop trigger ' || i.owner || '.' || i.trigger_name;
    end loop;
end;
/