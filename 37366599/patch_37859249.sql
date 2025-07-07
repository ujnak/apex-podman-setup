set define '^' verify off
prompt ...patch_37859249.sql
--------------------------------------------------------------------------------
--
--  Copyright (c) 2025, Oracle and/or its affiliates.
--
--    NAME
--      patch_37859249.sql
--
--    DESCRIPTION
--      Fix for 37859249 - UNABLE TO CREATE OR DELETE DEFAULT INTERACTIVE REPORT SUBSCRIPTION DURING PHASE 2 OF APEX UPGRADE
--
--    MODIFIED   (MM/DD/YYYY)
--    cczarski    05/07/2025 - Created
--------------------------------------------------------------------------------

prompt ...trigger wwv_flow_worksheet_notify_t1

create or replace trigger wwv_flow_worksheet_notify_t1
    before insert or update on wwv_flow_worksheet_notify
    for each row
begin
    if inserting and :new.id is null then
        :new.id := wwv_flow_id.next_val;
    end if;
    if inserting then
        --
        -- Mark the session as associated with the subscription.
        --
        if :new.session_id is not null then
            wwv_flow_session.on_subscription_created (
                p_id => :new.session_id );
        end if;
    end if;

    if not wwv_flow.g_import_in_progress then
        if inserting then
            :new.created_on := sysdate;
            :new.created_by := nvl(wwv_flow.g_user,user);
            :new.updated_on := sysdate;
            :new.updated_by := nvl(wwv_flow.g_user,user);
        elsif updating then
            :new.updated_on := sysdate;
            :new.updated_by := nvl(wwv_flow.g_user,user);
        end if;
    end if;

    --
    -- set owner
    --
    if :new.owner is null then
        :new.owner := :new.created_by;
    end if;

    --
    -- vpd
    --
    if :new.security_group_id is null then
       :new.security_group_id := wwv_flow.get_sgid;
    end if;

    --
    -- for a subscription we don't cascade to the parent.
    --
    -- * unlike all the other report activites, adding a subscription does not change the
    --   report; no new filters, different views, highlights or anything else. The report
    --   stays as it is. So, changing "last updated" is not even appropriate.
    --
    -- * subscriptions to public reports would finally trigger an UPDATE to the WWV_FLOW_WORKSHEETS
    --   table, which renders such subscription changes impossible during phase 2 of an APEX upgrade.
    --   (bug 37859249).
    --
end;
/
