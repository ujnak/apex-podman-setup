set define '^' verify off
prompt ...patch_37859062.sql
--------------------------------------------------------------------------------
--
--  Copyright (c) 2025, Oracle and/or its affiliates.
--
--    NAME
--      patch_37859062.sql
--
--    DESCRIPTION
--      Fixes the wwv_flow_fnd_user_t1 trigger
--
--    MODIFIED   (MM/DD/YYYY)
--    andrdobr   05/07/2025 - Created
--

create or replace trigger wwv_flow_fnd_user_t1
    before insert or update on wwv_flow_fnd_user
    for each row
declare
    procedure generate_hashed_password
    is
        l_today date := trunc(sysdate);
        l_found number;
    begin
        --
        -- hash the plain text password and clear legacy password columns
        --
        :new.web_password_version       := wwv_flow_crypto.get_current_password_version;
        :new.web_password2              := wwv_flow_crypto.hash_password (
                                               p_password          => :new.web_password,
                                               p_version           => :new.web_password_version,
                                               p_security_group_id => :new.security_group_id,
                                               p_user_name         => :new.user_name,
                                               p_user_id           => :new.user_id );
        :new.web_password               := null;
        :new.web_password_raw           := null;
        --
        -- save new password in history, but prevent duplicates
        --
        if updating then
            select count(1)
              into l_found
              from wwv_flow_password_history
             where security_group_id          = :new.security_group_id
               and user_id                    = :new.user_id
               and password                   = :new.web_password2
               and nvl(password_version, '*') = nvl(:new.web_password_version, '*')
               and created                    = l_today;
        else
            l_found := 0;
        end if;

        if l_found = 0 then
            insert into wwv_flow_password_history (
                id,
                user_id,
                password,
                password_version,
                created,
                security_group_id )
            values (
                wwv_flow_id.next_val,
                :new.user_id,
                :new.web_password2,
                :new.web_password_version,
                l_today,
                :new.security_group_id );
        end if;
    end generate_hashed_password;
begin
    if inserting then
        :new.user_id        := coalesce(:new.user_id, wwv_flow_id.next_val);
        :new.creation_date  := sysdate;
        :new.created_by     := coalesce(wwv_flow.g_user, user);
        :new.account_expiry := coalesce(:new.account_expiry, sysdate);
    end if;

    :new.start_date              := coalesce(:new.start_date, sysdate);
    :new.end_date                := coalesce(:new.end_date, :new.start_date + (365*20));
    :new.user_name               := wwv_flow_security.normalize_ws_user_name(:new.user_name);
    :new.allow_access_to_schemas := wwv_flow_security.normalize_ws_schema_name(:new.allow_access_to_schemas);
    :new.default_date_format     := trim(:new.default_date_format);
    :new.last_updated_by         := coalesce(wwv_flow.g_user, user);
    :new.last_update_date        := sysdate;
    :new.security_group_id       := coalesce(:new.security_group_id, wwv_flow_security.g_security_group_id, 0);
    --
    -- the insert/update APIs pass clear text passwords in the WEB_PASSWORD
    -- column. in this case, we apply the newest hashing algorithm and safe the
    -- hashed value instead of the clear text.
    --
    if :new.web_password is not null then
        generate_hashed_password;
        if updating then
            :new.account_expiry := sysdate;
        end if;
    end if;

    -- Check whether the user's email is valid
    if (inserting
        or nvl(:old.email_address, wwv_flow.LF) <> nvl(:new.email_address, wwv_flow.LF))
       and not wwv_flow_instance_admin.is_valid_provisioning_email( p_email => :new.email_address )
    then
        wwv_flow_error.raise_internal_error( p_error_code => 'APEX.PROVISION_REQUEST.INVALID_EMAIL' );
    end if;

    -- Monitor it on the wwv_flow_events1/2$ table
    if inserting then
        wwv_flow_event_metrics_int.add_event (
            p_event_type       => 'USER_CREATED',
            p_attribute_values => wwv_flow_t_varchar2 (
                                      wwv_flow_json.stringify(wwv_flow_security.find_company_name(
                                                                  p_security_group_id => :new.security_group_id)),
                                      wwv_flow_json.stringify(:new.user_name)));
    end if;
    --
    exception when wwv_flow_error.e_mutating_table then null;
end;
/