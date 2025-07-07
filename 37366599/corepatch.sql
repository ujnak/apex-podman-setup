set define '^' verify off concat on
set concat .
set serveroutput on size unlimited

define PATCH_VERSION        = '6'
define PATCH_ID             = '37366599'
define PATCH_IMAGES_VERSION = '24.2.6'
define APPUN                = 'APEX_240200'
define PREFIX               = '^1'
-- Make sure we are not picking up APEX_SCHEMA value from the caller script
define APEX_SCHEMA          = ''

alter session set current_schema = SYS;

column   APEX_SCHEMA  new_val APEX_SCHEMA

select schema as APEX_SCHEMA
  from sys.dba_registry
 where comp_id = 'APEX'
   and schema  = '^APPUN.'
/

declare
    invalid_alter_priv exception;
    pragma exception_init(invalid_alter_priv,-02248);
begin
    execute immediate 'alter session set "_ORACLE_SCRIPT"=true';
exception
    when invalid_alter_priv then
    null;
end;
/

--==============================================================================
prompt ... Syncing with Post-Upgrade Job
--==============================================================================
declare
    l_lock_hdl    varchar2(128);
    l_lock_status number;
begin
    --
    -- We acquire a lock that the post-upgrade job also uses, to avoid
    -- collisions. Note that we do not explicitly release the lock later on.
    -- This automatically happens at the end of the DB session. If the same DB
    -- session needs to apply multiple patches (for example, on ADB), it should
    -- not fail due to the lock acquired by the first patch.
    --
    sys.dbms_lock.allocate_unique (
        lockname        => 'ORA$APEX_UPGRADE',
        lockhandle      => l_lock_hdl );
    l_lock_status := sys.dbms_lock.request (
        lockhandle        => l_lock_hdl,
        lockmode          => sys.dbms_lock.x_mode,
        timeout           => sys.dbms_lock.maxwait,
        release_on_commit => false );
    if l_lock_status not in (0, 4) then
        -- 0 - Success
        -- 4 - Already own lock specified by id or lockhandle
        raise_application_error (
            -20001,
            'Could not request ORA$APEX_UPGRADE: status '||l_lock_status );
    end if;
end;
/
--==============================================================================
prompt ... Disabling Jobs
--==============================================================================
declare
    l_jobs varchar2(32767);
begin
    --
    -- Fetch all enabled jobs
    --
    select ':'||
           listagg(job_name,':')
           within group (order by job_name)||
           ':'
      into l_jobs
      from sys.dba_scheduler_jobs
     where owner    =    '^APPUN'
       and enabled  =    'TRUE'
       and job_name like 'ORACLE_APEX_%'
     order by 1;
    --
    -- Store in COREPATCH_DISABLED_JOBS, or exit if the parameter already
    -- exists, which could be after re-running a failed patch.
    --
    begin
        insert into ^APPUN..wwv_flow_platform_prefs (
            id, name, value, security_group_id )
        values (
            -1, 'COREPATCH_DISABLED_JOBS', l_jobs, 10 );
        commit;
    exception when dup_val_on_index then
        return;
    end;
    --
    -- Disable
    --
    for i in ( select job_name,
                      state
                 from sys.dba_scheduler_jobs
                where owner   = '^APPUN'
                  and enabled = 'TRUE'
                  and instr (
                          l_jobs,
                          ':'||job_name||':' ) > 0
                order by 1 )
    loop
        sys.dbms_output.put_line('... disabling '||i.job_name);
        sys.dbms_scheduler.disable (
            name  => '^APPUN..'||i.job_name,
            force => true );
        if i.state = 'RUNNING' then
            sys.dbms_output.put_line('... stopping job');
            begin
                sys.dbms_scheduler.stop_job (
                    job_name => '^APPUN..'||i.job_name,
                    force    => false );
            exception when others then
                begin
                    sys.dbms_output.put_line('... stopping with force=>true');
                    sys.dbms_scheduler.stop_job (
                        job_name => '^APPUN..'||i.job_name,
                        force    => true );
                exception when others then null;
                end;
            end;
        end if;
    end loop;
end;
/
--==============================================================================
-- Install SYS objects
--==============================================================================

--
-- Compile wwv_dbms_sql.plb with original conditional compilation settings. Do
-- not do this in an application container, it would result in ORA-44201 during
-- sync.
--
col old_ccflags noprint new_val old_ccflags
col wwv_ccflags noprint new_val wwv_ccflags

-- select ( select sys.dbms_assert.enquote_literal(value)
--            from sys.v_$parameter
--           where name='plsql_ccflags' ) old_ccflags,
--        ( select sys.dbms_assert.enquote_literal (
--                     case
--                     when exists (select null
--                                    from sys.dba_registry
--                                   where comp_id = 'APEX' )
--                     then plsql_ccflags
--                     end )
--            from sys.dba_plsql_object_settings
--           where owner         = 'SYS'
--             and name          = 'WWV_DBMS_SQL_^APPUN'
--             and type          = 'PACKAGE BODY'
--             and origin_con_id = sys_context('USERENV','CON_ID') ) wwv_ccflags
--   from sys.dual
-- /
-- declare
--     l_stmt varchar2(4000);
-- begin
--     if ^wwv_ccflags is not null then
--         l_stmt := q'~alter session set plsql_ccflags=^wwv_ccflags~';
--         sys.dbms_output.put_line(l_stmt);
--         execute immediate l_stmt;
--     end if;
-- end;
-- /
--
-- @^PREFIX.wwv_dbms_sql.plb
--
-- declare
--     l_stmt varchar2(4000);
-- begin
--     if ^wwv_ccflags is not null then
--         l_stmt := q'~alter session set plsql_ccflags=^old_ccflags~';
--         sys.dbms_output.put_line(l_stmt);
--         execute immediate l_stmt;
--     end if;
-- end;
-- /

@^PREFIX.wwv_util_apex.plb
@^PREFIX.validate_apex.sql

alter session set current_schema = ^APPUN;

--==============================================================================
-- Views / other DDL
--==============================================================================
begin
    for i in ( select null
                 from dual
                where not exists ( select null
                                     from sys.dba_tab_privs
                                    where grantee    = '^APPUN'
                                      and owner      = 'SYS'
                                      and table_name = 'USER_OBJECTS' ))
    loop
        execute immediate 'grant select on sys.user_objects to ^APPUN';
    end loop;
end;
/

@^PREFIX.patch_37579661.sql
@^PREFIX.patch_37859249.sql

@^PREFIX.patch_37859062.sql
@^PREFIX.patch_37858190.sql

--==============================================================================
-- Specs/Bodies (1)
--==============================================================================


--==============================================================================
-- New Instance Parameter
--==============================================================================
declare
    l_cnt number;
begin
    select count(*) into l_cnt
      from wwv_flow_platform_prefs
     where name = 'IMAGE_PREFIX';

    if l_cnt = 0 and not wwv_flow_global.g_cloud then
        wwv_flow_platform.set_preference('IMAGE_PREFIX',wwv_flow_image_prefix.g_image_prefix);
    end if;
end;
/

--==============================================================================
-- Specs
--==============================================================================
@^PREFIX.flows_release.sql

--==============================================================================
-- Bodies for changed specs
--==============================================================================

--==============================================================================
-- Other bodies
--==============================================================================
@^PREFIX.flowc.plb
@^PREFIX.gen_api_pkg.plb
@^PREFIX.provision.plb
@^PREFIX.reports3.plb
@^PREFIX.wwv_flow_ai.plb
@^PREFIX.wwv_flow_approval.plb
@^PREFIX.wwv_flow_authentication.plb
@^PREFIX.wwv_flow_automation.plb
@^PREFIX.wwv_flow_builder.plb
@^PREFIX.wwv_flow_cdn.plb
@^PREFIX.wwv_flow_debug.plb
@^PREFIX.wwv_flow_event_metrics_int.plb
@^PREFIX.wwv_flow_exec_doc_src.plb
@^PREFIX.wwv_flow_exec_web_src_boss.plb
@^PREFIX.wwv_flow_exec_web_src_http.plb
@^PREFIX.wwv_flow_imp_shared.plb
@^PREFIX.wwv_flow_instance_admin.plb
@^PREFIX.wwv_flow_ir.plb
@^PREFIX.wwv_flow_mail.plb
@^PREFIX.wwv_flow_maint.plb
@^PREFIX.wwv_flow_native_item.plb
@^PREFIX.wwv_flow_pdf.plb
@^PREFIX.wwv_flow_process_bg.plb
@^PREFIX.wwv_flow_pwa.plb
@^PREFIX.wwv_flow_security.plb
@^PREFIX.wwv_flow_session.plb
@^PREFIX.wwv_flow_session_state.plb
@^PREFIX.wwv_flow_sw_parser.plb
@^PREFIX.wwv_flow_upgrade.plb
@^PREFIX.wwv_flow_web_services_invoker.plb
@^PREFIX.wwv_flow_web_src_openapi.plb
@^PREFIX.wwv_flow_web_src_sync.plb
@^PREFIX.wwv_flow_wf_management.plb
@^PREFIX.wwv_flow_workflow.plb
@^PREFIX.wwv_meta_meta_data.plb
-- Please add files in alphabetic order and not at the end.

--==============================================================================
-- Metadata changes
--==============================================================================
@^PREFIX.patch_37967372.sql
@^PREFIX.patch_37830514.sql

--==============================================================================
-- Missing grants
--==============================================================================
@^PREFIX.patch_37970639.sql

--==============================================================================
-- Reinstall Universal Theme
--==============================================================================
set define '^'
@^PREFIX.patch_central_themes.sql "^PREFIX."

declare
    l_has_pub_router   number;
begin
    -- #36925895: in CDB instances APEX_PUBLIC_ROUTER won't exist
    select count(username)
      into l_has_pub_router
      -- into l_has_pub_router
      from sys.dba_users
     where username = 'APEX_PUBLIC_ROUTER';

    if l_has_pub_router = 1 then
        execute immediate 'grant inherit privileges on user APEX_PUBLIC_ROUTER to public';
    end if;
end;
/
--==============================================================================
-- Reinstall Universal Theme
--==============================================================================

--==============================================================================
-- Compilation of development package specifications and bodies. In certain CDB scenarios, development objects may exist
-- even if there are no 4xxx apps.
--==============================================================================
set define '^'
column thescript new_val script
set termout off
select case when f4000_cnt > 0 then 'devpatch.sql'
            when (select count(*)
                    from sys.dba_objects
                   where owner = '^APPUN.'
                     and object_name = 'WWV_FLOW_AUTHENTICATION_DEV'
                     and object_type = 'PACKAGE') > 0 then 'devpatch.sql'
            else 'null1.sql'
       end as thescript
  from (select count(*) as f4000_cnt from wwv_flows where id = 4000);
set termout on
@^PREFIX.^script "^PREFIX."
--==============================================================================
-- Set Revised Build Version in internal apps
--==============================================================================
set define '^' verify off
declare
    l_current_release varchar2(100) := wwv_flows_release;
begin
    -- Set build version to version in wwv_flows_release
    update wwv_flows
       set flow_version = '&PRODUCT_NAME. ' || l_current_release
     where security_group_id=10;

    --Only execute if APEX is in sys.dba_registry to support application containers
    if length('^APEX_SCHEMA.') > 0 then
        sys.dbms_registry.set_session_namespace (
            namespace   => 'DBTOOLS');
        sys.dbms_registry.loaded (
            comp_id      => 'APEX',
            comp_version => l_current_release );
    end if;

    commit;
end;
/

exec sys.dbms_session.modify_package_state(sys.dbms_session.reinitialize)
--==============================================================================
-- Reset Image Prefix to new CDN '^PATCH_IMAGES_VERSION.'
--==============================================================================
declare
    l_image_prefix     varchar2(4000) := lower(wwv_flow_image_prefix.g_image_prefix);
    l_email_images_url varchar2(4000) := wwv_flow_platform.get_preference (
                                             p_preference_name => 'EMAIL_IMAGES_URL' );
    l_new_cdn      varchar2(100) := 'https://static.oracle.com/cdn/apex/^PATCH_IMAGES_VERSION./';

    function has_cmo return boolean
    is
        l_has_cmo boolean := false;
    begin
        if wwv_flow_global.g_cloud then
            for c1 in (select null
                         from sys.dba_role_privs p,
                              sys.dba_users u
                        where p.grantee = u.username
                          and p.granted_role = 'ORDS_RUNTIME_ROLE'
                          and u.oracle_maintained = 'N'
                          and rownum = 1)
            loop
                l_has_cmo := true;
            end loop;
        end if;

        return l_has_cmo;
    end has_cmo;
begin
    if l_image_prefix like 'https://static.oracle.com/cdn/apex/%' and l_image_prefix <> l_new_cdn then
        wwv_flow_instance_admin.set_parameter(
            p_parameter => 'IMAGE_PREFIX',
            p_value     => l_new_cdn );
        --
        -- Bug 37484172 - Also set EMAIL_IMAGES_URL if currently using CDN
        --
        if l_email_images_url like 'https://static.oracle.com/cdn/apex/%'
            and l_email_images_url <> l_new_cdn then
            wwv_flow_instance_admin.set_parameter(
                p_parameter => 'EMAIL_IMAGES_URL',
                p_value     => l_new_cdn );
        end if;
    elsif wwv_flow_global.g_cloud and l_image_prefix like '/i/%/'
            and l_image_prefix <> '/i/^PATCH_IMAGES_VERSION./' and not has_cmo then
        wwv_flow_instance_admin.set_parameter(
            p_parameter => 'IMAGE_PREFIX',
            p_value     => '/i/^PATCH_IMAGES_VERSION./' );
    end if;

    update wwv_flows
       set flow_image_prefix = l_new_cdn
     where lower(flow_image_prefix) like 'https://static.oracle.com/cdn/apex/%'
       and lower(flow_image_prefix) <> l_new_cdn;

    commit;
end;
/
--==============================================================================
prompt ... Enabling Jobs
--==============================================================================
begin
    --
    -- Enable
    --
    for i in ( select j.job_name
                 from sys.dba_scheduler_jobs j,
                      ( select ( select value
                                   from ^APPUN..wwv_flow_platform_prefs
                                  where name = 'COREPATCH_DISABLED_JOBS'
                                    and id   = -1 ) disabled_jobs
                          from sys.dual )
                where owner = '^APPUN'
                  and instr (
                          disabled_jobs,
                          ':'||j.job_name||':' ) > 0
                order by 1 )
    loop
        sys.dbms_output.put_line('... enabling '||i.job_name);
        sys.dbms_scheduler.enable (
            name  => '^APPUN..'||i.job_name );
    end loop;
    --
    -- Delete helper parameter.
    --
    delete from ^APPUN..wwv_flow_platform_prefs
     where id   = -1
       and name = 'COREPATCH_DISABLED_JOBS';
    commit;
end;
/

--==============================================================================
-- Complete patch installation
--==============================================================================
set serveroutput on
prompt ...Validating APEX
begin
    --Only execute if APEX is in sys.dba_registry to support application containers
    if length('^APEX_SCHEMA.') > 0 then
        sys.validate_apex;
    end if;
end;
/

prompt ...Recompiling invalid public synonyms
declare
    procedure compile_synonym( p_synonym_name in varchar2 ) is
    begin
        execute immediate 'alter public synonym ' || sys.dbms_assert.enquote_name( p_synonym_name ) || ' compile';
    exception when others then
        sys.dbms_output.put_line( sqlerrm || ' when compiling public synonym ' || p_synonym_name );
    end;
begin
    for s in (
        select s.synonym_name
          from sys.dba_synonyms s, sys.dba_objects o
         where o.owner       = s.owner
           and o.object_name = s.synonym_name
            --
           and s.table_owner = '^APEX_SCHEMA'
           and o.status      = 'INVALID'
           and s.owner       = 'PUBLIC'
         order by s.synonym_name
    ) loop
        compile_synonym( p_synonym_name => s.synonym_name );
    end loop;
end;
/

set define '^' verify off
begin
    insert into wwv_flow_pses (patch_number, patch_version, images_version ) values ( ^PATCH_ID., '^PATCH_VERSION.', '^PATCH_IMAGES_VERSION.' );
    commit;
end;
/
