set define '^' verify off
prompt ...validate_apex
create or replace procedure validate_apex as
--------------------------------------------------------------------------------
--
-- Copyright (c) 2006, 2024, Oracle and/or its affiliates.
--
--    NAME
--      validate_apex.sql
--
--    SYNOPSIS
--      @validate_apex
--
--    DESCRIPTION
--      This procedure checks that the objects in the APEX application schema
--      are valid.
--
--    NOTES
--      Assumes the SYS user is connected.
--
--    MODIFIED   (MM/DD/YYYY)
--      jstraub   06/21/2006 - Created, borrowed almost exclusively from CTXSYS, thanks gkaminag
--
--------------------------------------------------------------------------------
    c_apex_schema        constant varchar2(30) := 'APEX_240200';
    l_reg_schema         varchar2(30);
    l_error_count        pls_integer := 0;
    c_key_apex_objects   constant sys.dbms_debug_vc2coll := sys.dbms_debug_vc2coll (
                                                                'WWV_FLOW_COLLECTIONS$',
                                                                'WWV_FLOW_COMPANIES',
                                                                'WWV_FLOW_FND_USER',
                                                                'WWV_FLOW_ITEMS',
                                                                'WWV_FLOW_LISTS',
                                                                'WWV_FLOW_MAIL_QUEUE',
                                                                'WWV_FLOW_PUSH_QUEUE',
                                                                'WWV_FLOW_MESSAGES$',
                                                                'WWV_FLOW_PAGE_PLUGS',
                                                                'WWV_FLOW_STEP_ITEMS',
                                                                'WWV_FLOW_STEP_PROCESSING',
                                                                'WWV_FLOW_STEP_VALIDATIONS',
                                                                'WWV_FLOW_STEPS',
                                                                'WWV_FLOW_SW_STMTS',
                                                                'WWV_FLOWS',
                                                                'WWV_FLOW_DML',
                                                                'WWV_FLOW_ITEM',
                                                                'WWV_FLOW_LANG',
                                                                'WWV_FLOW_LOG',
                                                                'WWV_FLOW_MAIL',
                                                                'WWV_FLOW_SVG',
                                                                'WWV_FLOW_SW_PARSER',
                                                                'WWV_FLOW_SW_UTIL',
                                                                'WWV_FLOW_UTILITIES',
                                                                'F',
                                                                'P',
                                                                'Z',
                                                                'V' );
    c_apex_post_job      constant varchar2(30)           := 'ORACLE_APEX_COPY_POST_METADATA';
    c_key_apex_jobs      constant sys.dbms_debug_vc2coll := sys.dbms_debug_vc2coll (
                                                                'ORACLE_APEX_DAILY_MAINTENANCE',
                                                                'ORACLE_APEX_MAIL_QUEUE',
                                                                'ORACLE_APEX_PURGE_SESSIONS',
                                                                'ORACLE_APEX_WS_NOTIFICATIONS' );
    c_key_file_objects   constant sys.dbms_debug_vc2coll := sys.dbms_debug_vc2coll (
                                                                'WWV_FLOW_FILE_OBJECTS$',
                                                                'WWV_BIU_FLOW_FILE_OBJECTS' );
    c_key_sys_objects    constant sys.dbms_debug_vc2coll := sys.dbms_debug_vc2coll (
                                                                'WWV_DBMS_SQL_'||c_apex_schema,
                                                                'WWV_FLOW_KEY',
                                                                'WWV_FLOW_VAL' );
    e_job_not_running    exception;
    pragma exception_init( e_job_not_running, -27366 );
    e_table_does_not_exist exception;
    pragma exception_init( e_table_does_not_exist, -942 );
    e_proc_does_not_exist  exception;
    pragma exception_init( e_proc_does_not_exist, -4042 );

    type t_vc_map                is table of varchar2(30) index by varchar2(30);
    l_job_enabled_yn             t_vc_map;

    l_is_runtime_only            boolean;
    l_is_dev                     boolean;

    l_privs_to_grant             sys.dbms_debug_vc2coll;
    c_grants_role                constant varchar2(30)  := 'APEX_GRANTS_FOR_NEW_USERS_ROLE';
    -- Needed for ORDS updates
    l_org_oracle_script_value    sys.v$parameter.value%type;

--------------------------------------------------------------------------------
    procedure p (
        p_message in varchar2 )
    is
    begin
        sys.dbms_output.put_line (p_message);
    end p;
--------------------------------------------------------------------------------
    procedure error (
        p_message in varchar2 )
    is
    begin
        l_error_count := l_error_count + 1;
        if nvl(l_reg_schema,'x') = c_apex_schema then
            p('ORA-20001: '||p_message);
        else
            p('Current APEX schema is '||l_reg_schema||' and validate schema is '||c_apex_schema);
        end if;
    end error;
--------------------------------------------------------------------------------
    procedure log_action (
        p_message in varchar2 )
    is
    begin
        p('...('||to_char(sysdate,'HH24:MI:SS')||') '||p_message);
    end log_action;
--------------------------------------------------------------------------------
    function object_exists (
        p_schema in varchar2,
        p_type   in varchar2,
        p_name   in varchar2 )
        return boolean
    is
        l_count number;
    begin
        select count(*)
          into l_count
          from sys.dba_objects
         where owner       = p_schema
           and object_type = p_type
           and object_name = p_name;

        return l_count > 0;
    end object_exists;
--------------------------------------------------------------------------------
    function oracle_object_exists (
        p_schema in varchar2,
        p_type   in varchar2,
        p_name   in varchar2 )
        return boolean
    is
        l_count number;
    begin
        select count(*)
          into l_count
          from sys.dba_objects
         where owner             = p_schema
           and object_type       = p_type
           and object_name       = p_name
           and oracle_maintained = 'Y';

        return l_count > 0;
    end oracle_object_exists;
--------------------------------------------------------------------------------
    procedure check_key_objects_exist (
        p_schema  in varchar2,
        p_objects in sys.dbms_debug_vc2coll )
    is
    begin
        for i in ( select p.column_value object_name,
                          o.status
                     from table(p_objects) p,
                          sys.dba_objects  o
                    where p.column_value = o.object_name (+)
                      and ( o.status is null or o.owner = p_schema ) )
        loop
            if i.status is null then
                error('FAILED Existence check for '||p_schema||'.'||i.object_name);
            elsif i.status <> 'VALID' then
                error('FAILED status check for '||p_schema||'.'||i.object_name||': '||i.status);
            end if;
        end loop;
    end check_key_objects_exist;
--------------------------------------------------------------------------------
    procedure ddl (
        p_ddl in varchar2 )
    is
    begin
        log_action(p_ddl);
        execute immediate p_ddl;
    exception
        when   e_table_does_not_exist
            or e_proc_does_not_exist
        then
            null;
        when others then
            --
            -- during a database downgrade the object might not exist
            --
            log_action('DDL not successful');
    end ddl;
--------------------------------------------------------------------------------
-- For all elements in p_privileges that have not yet been granted to p_grantee,
-- do grant them.
--
-- The data in p_privileges is expected to look like this:
--
-- * 'PRIVILEGE,... on SCHEMA.OBJECT to #GRANTEE#' -- object grants
-- * 'SYSTEM PRIVILEGE to #GRANTEE#'               -- system grants
--
    procedure grant_missing_privileges (
        p_privileges in out nocopy sys.dbms_debug_vc2coll,
        p_grantee    in varchar2 )
    is
        l_missing sys.dbms_debug_vc2coll := p_privileges;
    begin
        for l_existing in ( select '% '||owner||'.'||table_name||' %' pattern
                              from sys.dba_tab_privs
                             where grantee = p_grantee
                             union
                            select privilege||' %'
                              from sys.dba_sys_privs
                             where grantee = p_grantee )
        loop
            <<inner>>
            for i in 1 .. l_missing.count loop
                if l_missing(i) like l_existing.pattern then
                    l_missing(i) := null;
                    exit inner;
                end if;
            end loop;
        end loop;

        for i in 1 .. l_missing.count loop
            if l_missing(i) is not null then
                ddl('grant '||
                    replace(l_missing(i), '#GRANTEE#', p_grantee));
            end if;
        end loop;
    end grant_missing_privileges;
--------------------------------------------------------------------------------
    function is_runtime (
        p_schema  in varchar2 ) return boolean
    is
        l_is_dev_env number;
    begin
        execute immediate 'select 1 ' ||
                          'from ' || sys.dbms_assert.enquote_name( p_schema ) || '.wwv_flows ' ||
                          'where id = 4000'
                     into l_is_dev_env;
        return false;
    exception
        when NO_DATA_FOUND then
            return true;
    end is_runtime;
--------------------------------------------------------------------------------
    procedure disable_job( p_job_name in varchar2 )
    is
        l_enabled_job_cnt number;
    begin
        select count(1)
          into l_enabled_job_cnt
          from sys.dba_scheduler_jobs
         where owner     = c_apex_schema
           and job_name  = p_job_name
           and state    != 'DISABLED';

        if l_enabled_job_cnt > 0 then
            l_job_enabled_yn( p_job_name ) := 'Y';

            sys.dbms_scheduler.disable(
                name  => c_apex_schema || '.' || p_job_name,
                force => true );

            begin
                sys.dbms_scheduler.stop_job(
                    job_name => c_apex_schema || '.' || p_job_name,
                    force    => true );
            exception
                when e_job_not_running then
                    null;
            end;
        end if;
    end disable_job;
--------------------------------------------------------------------------------
    procedure enable_job( p_job_name in varchar2 )
    is
    begin
        if l_job_enabled_yn.exists( p_job_name ) then
            sys.dbms_scheduler.enable( name => c_apex_schema|| '.' || p_job_name );
        end if;
    end enable_job;
--------------------------------------------------------------------------------
begin
    sys.dbms_registry.set_session_namespace (
        namespace   => 'DBTOOLS');
    l_reg_schema := sys.dbms_registry.schema('APEX');
    log_action('Starting validate_apex for '||c_apex_schema);
    if nvl(l_reg_schema,'x') <> c_apex_schema then
        log_action('DBMS registry schema for APEX is "'||l_reg_schema||'"');
    end if;

    l_is_runtime_only := is_runtime( c_apex_schema );
    l_is_dev := not l_is_runtime_only;
    --
    -- Missing direct grants to the APEX schema.
    --
    log_action('Checking missing privileges for ' || c_apex_schema);

    l_privs_to_grant := sys.dbms_debug_vc2coll (
        -- SYS objects
        'EXECUTE                on SYS.DBMS_XS_NSATTR            to #GRANTEE#',
        'EXECUTE                on SYS.DBMS_XS_NSATTRLIST        to #GRANTEE#',
        'EXECUTE                on SYS.DBMS_STATS_INTERNAL       to #GRANTEE#',
        'EXECUTE                on SYS.XS$NAME_LIST              to #GRANTEE#',
        'SELECT                 on SYS.DBA_XS_DYNAMIC_ROLES      to #GRANTEE#',
        'SELECT                 on SYS.V_$XS_SESSION_ROLES       to #GRANTEE#',
        'EXECUTE                on SYS.DBMS_CRYPTO_INTERNAL      to #GRANTEE#',
        'EXECUTE                on SYS.DBMS_CRYPTO               to #GRANTEE#',
        'EXECUTE                on SYS.GETLONG                   to #GRANTEE#',
        'EXECUTE                on SYS.UTL_CALL_STACK            to #GRANTEE#',
        'EXECUTE                on SYS.JSON_ARRAY_T              to #GRANTEE#',
        'EXECUTE                on SYS.JSON_ELEMENT_T            to #GRANTEE#',
        'EXECUTE                on SYS.JSON_KEY_LIST             to #GRANTEE#',
        'EXECUTE                on SYS.JSON_OBJECT_T             to #GRANTEE#',
        'EXECUTE                on SYS.JSON_DATAGUIDE            to #GRANTEE#',
        'SELECT                 on SYS.DBA_TAB_IDENTITY_COLS     to #GRANTEE#',
        'SELECT                 on SYS.DBA_SCHEDULER_JOBS        to #GRANTEE#',
        'SELECT                 on SYS.NLS_DATABASE_PARAMETERS   to #GRANTEE#',
        'EXECUTE                on MDSYS.SDO_GEOMETRY            to #GRANTEE#',
        'EXECUTE                on MDSYS.SDO_ELEM_INFO_ARRAY     to #GRANTEE#',
        'EXECUTE                on MDSYS.SDO_ORDINATE_ARRAY      to #GRANTEE#',
        'EXECUTE                on MDSYS.SDO_POINT_TYPE          to #GRANTEE#',
        'EXECUTE                on MDSYS.SDO_DIM_ARRAY           to #GRANTEE#',
        'EXECUTE                on MDSYS.SDO_DIM_ELEMENT         to #GRANTEE#',
        'EXECUTE                on MDSYS.MDERR                   to #GRANTEE#',
        'EXECUTE                on MDSYS.SDO_META                to #GRANTEE#',
        'EXECUTE                on MDSYS.SDO_GEOM                to #GRANTEE#',
        'EXECUTE                on MDSYS.SDO_UTIL                to #GRANTEE#',
        'EXECUTE                on MDSYS.SDO_GCDR                to #GRANTEE#',
        'EXECUTE                on MDSYS.SDO_CS                  to #GRANTEE#',
        'SELECT                 on MDSYS.USER_SDO_INDEX_INFO     to #GRANTEE#',
        'SELECT, INSERT, DELETE on MDSYS.SDO_GEOM_METADATA_TABLE to #GRANTEE#',
        -- System privileges
        'INHERIT ANY PRIVILEGES to #GRANTEE#' );
    if l_is_dev then
        l_privs_to_grant := l_privs_to_grant multiset union sys.dbms_debug_vc2coll (
            'EXECUTE            on SYS.DBMS_METADATA             to #GRANTEE#',
            'EXECUTE            on SYS.DIANA                     to #GRANTEE#',
            'EXECUTE            on SYS.DIUTIL                    to #GRANTEE#',
            'EXECUTE            on SYS.KU$_DDL                   to #GRANTEE#',
            'EXECUTE            on SYS.KU$_DDLS                  to #GRANTEE#',
            'SELECT             on MDSYS.CS_SRS                  to #GRANTEE#' );
    end if;

    if object_exists (
        p_schema => 'SYS',
        p_type   => 'PACKAGE',
        p_name   => 'DBMS_CRYPTO_STATS_INT' )
    then
        l_privs_to_grant := l_privs_to_grant multiset union sys.dbms_debug_vc2coll (
            'EXECUTE            on SYS.DBMS_CRYPTO_STATS_INT     to #GRANTEE#' );
    end if;
    if sys.dbms_db_version.version >= 21 then
        l_privs_to_grant := l_privs_to_grant multiset union sys.dbms_debug_vc2coll (
            -- SYS objects
            'EXECUTE            on SYS.DBMS_MLE                  to #GRANTEE#',
            'EXECUTE            on SYS.JAVASCRIPT                to #GRANTEE# with grant option',
            -- System privileges
            'EXECUTE DYNAMIC MLE to #GRANTEE# with admin option' );
    end if;
    if sys.dbms_db_version.version >= 23 then
        l_privs_to_grant := l_privs_to_grant multiset union sys.dbms_debug_vc2coll (
            'CREATE MLE                                          to #GRANTEE# with admin option',
            'CREATE PROPERTY GRAPH                               to #GRANTEE# with admin option' );
        if l_is_dev then
            l_privs_to_grant := l_privs_to_grant multiset union sys.dbms_debug_vc2coll (
                'READ           on SYS.DBA_MLE_ENVS              to #GRANTEE#',
                'READ           on SYS.DBA_MLE_MODULES           to #GRANTEE#',
                'READ           on SYS.DBA_MLE_ENV_IMPORTS       to #GRANTEE#',
                'READ           on SYS.DBA_PROPERTY_GRAPHS       to #GRANTEE#',
                'READ           on SYS.DBA_MINING_MODELS         to #GRANTEE#' );
        end if;
    end if;
    if object_exists (
        p_schema => 'SYS',
        p_type   => 'FUNCTION',
        p_name   => 'RESOLVE_SYNONYM' )
    then
        l_privs_to_grant := l_privs_to_grant multiset union sys.dbms_debug_vc2coll (
            'EXECUTE            on SYS.RESOLVE_SYNONYM           to #GRANTEE#' );
    end if;
    grant_missing_privileges (
        p_privileges => l_privs_to_grant,
        p_grantee    => c_apex_schema );

    --
    -- Report any grants that are still missing and that we can determine via
    -- static dependencies.
    --
    for c1 in ( with privs as (
                    select --+materialize
                           owner,
                           table_name
                      from sys.dba_tab_privs
                     where grantee = c_apex_schema )
                select d.owner,
                       d.referenced_owner,
                       d.referenced_name,
                       d.referenced_type
                  from ( select distinct d.owner,
                                         d.referenced_owner,
                                         d.referenced_name,
                                         d.referenced_type
                           from sys.dba_dependencies d
                          where d.owner            = c_apex_schema
                            and d.referenced_owner not in (d.owner, 'PUBLIC')
                            and d.referenced_name  not in ( 'STANDARD',
                                                            'DBMS_STANDARD',
                                                            'PLITBLM',
                                                            'DUAL' )
                            and not (    d.referenced_owner = 'XDB'
                                     and d.referenced_name  like 'X$%' )
                            and not (    d.referenced_owner = 'SYS'
                                     and d.referenced_name  = 'XMLSEQUENCETYPE' )) d
                 where not exists ( select null
                                      from privs
                                     where d.referenced_owner = privs.owner
                                       and d.referenced_name  = privs.table_name )
                 order by 1,2,3 )
    loop
        error('MISSING GRANT: grant '||
            case when c1.referenced_type in ('TABLE', 'VIEW') then 'select' else 'execute' end||
            ' on "'||c1.referenced_owner||'"."'||c1.referenced_name||
            '" to '||c_apex_schema);
    end loop;
    --
    -- Check missing privs in the role holding privs which will be granted to
    -- new users.
    --
    log_action('Checking missing privileges for ' || c_grants_role);

    l_privs_to_grant := sys.dbms_debug_vc2coll();

    if sys.dbms_db_version.version >= 21 then
        l_privs_to_grant := l_privs_to_grant multiset union sys.dbms_debug_vc2coll (
            'EXECUTE on SYS.JAVASCRIPT to #GRANTEE#',
            'EXECUTE DYNAMIC MLE       to #GRANTEE#' );
    end if;
    if sys.dbms_db_version.version >= 23 then
        l_privs_to_grant := l_privs_to_grant multiset union sys.dbms_debug_vc2coll (
            'CREATE MLE                to #GRANTEE#',
            'CREATE PROPERTY GRAPH     to #GRANTEE#' );
    end if;
    grant_missing_privileges (
        p_privileges => l_privs_to_grant,
        p_grantee    => c_grants_role );
    --
    -- check missing privs on DBMS_CLOUD
    --
    --
    -- find the owner and the actial name of the DBMS_CLOUD package
    --
    -- on ATP/ADW (currently):       C##CLOUD$SERVICE
    -- on premises (when available): SYS
    --
    declare
        l_dbms_cloud_owner   sys.dba_synonyms.table_owner%type;
        l_dbms_cloud_name    sys.dba_synonyms.table_name%type;
    begin
        --
        -- 1. Find the actual package name and owner for the DBMS_CLOUD public synonym
        --
        select table_owner,
               table_name
          into l_dbms_cloud_owner,
               l_dbms_cloud_name
          from sys.dba_synonyms
         where synonym_name = 'DBMS_CLOUD'
           and owner        = 'PUBLIC'
           and rownum       = 1;

        --
        -- 2. does that package actually exist, and is it Oracle-Maintained?
        --
        if oracle_object_exists (
            p_schema => l_dbms_cloud_owner,
            p_type   => 'PACKAGE',
            p_name   => l_dbms_cloud_name )
        then
            for l_priv in ( --
                            -- check whether a grant on the package which the DBMS_CLOUD synonym points to,
                            -- already exists or not.
                            --
                            select 'DBMS_CLOUD' as missing
                              from sys.dual
                             where not exists( select 1
                                                 from sys.dba_tab_privs
                                                where grantee      = c_apex_schema
                                                  and owner        = l_dbms_cloud_owner
                                                  and table_name   = l_dbms_cloud_name )
                             union all
                                --
                                -- We only need to execute the GRANT INHERIT PRIVILEGES if DBMS_CLOUD
                                -- is not owned by SYS.
                                --
                            select 'INHERIT' as missing
                              from sys.dual
                             where l_dbms_cloud_owner != 'SYS'
                               and not exists( select 1
                                                 from sys.dba_tab_privs
                                                where privilege    = 'INHERIT PRIVILEGES'
                                                  and grantee      = l_dbms_cloud_owner
                                                  and table_name   = c_apex_schema ) )
            loop
                if l_priv.missing = 'DBMS_CLOUD' then
                    ddl(    'grant execute on '
                         || sys.dbms_assert.enquote_name( l_dbms_cloud_owner )
                         || '.'
                         || sys.dbms_assert.enquote_name( l_dbms_cloud_name )
                         || ' to '
                         || c_apex_schema );

                elsif l_priv.missing = 'INHERIT' then
                    ddl(    'grant inherit privileges on user '
                         || c_apex_schema
                         || ' to '
                         || sys.dbms_assert.enquote_name( l_dbms_cloud_owner ) );
                end if;
            end loop;
        end if;
    exception
        when no_data_found then
            --
            -- if there is no DBMS_CLOUD public synonym, do nothing.
            --
            null;
    end;
    --
    -- stop and disable the background execution coordinator job
    --
    disable_job( p_job_name => 'ORACLE_APEX_BG_PROCESSES' );
    --
    -- detect database environment (version and available features)
    --
    log_action('Re-generating '||c_apex_schema||'.wwv_flow_db_version');

    -- on a runtime environment, the APEX_XXXXXX schema does not have the CREATE PROCEDURE privilege. However,
    -- in order to run wwv_flow_db_env_detection.generate_wwv_flow_db_version correctly, this privilege is needed.
    -- So we temporarily grant the privilege here and revoke it after we're finished with wwv_flow_db_env_detection.
    --
    if l_is_runtime_only then
        log_action('temporarily grant CREATE PROCEDURE to '||c_apex_schema);
        execute immediate 'grant create procedure to '||c_apex_schema;
    end if;
    --
    -- now detect db version and capabilities; wwv_flow_db_version might be replaced ...
    --
    begin
        execute immediate 'begin ' ||
                          c_apex_schema||'.wwv_flow_db_env_detection.generate_wwv_flow_db_version;' ||
                          'end;';
    exception when others then
        error(sqlerrm);
    end;
    --
    -- revoke the create procedure privilege again, when runtime only
    --
    if l_is_runtime_only then
        log_action('revoke CREATE PROCEDURE from '||c_apex_schema);
        execute immediate 'revoke create procedure from '||c_apex_schema;
    end if;
    --
    -- recompile any invalid objects in schemas that we use
    --
    for l_schema in ( select owner, count(*)
                        from sys.dba_objects
                       where owner in ( c_apex_schema, 'FLOWS_FILES', 'SYS' )
                         and ( owner <> 'SYS' or object_name member of c_key_sys_objects )
                         and status <> 'VALID'
                       group by owner
                       order by case owner
                                when 'SYS'         then 1
                                when 'FLOWS_FILES' then 2
                                else 3
                                end )
    loop
        if l_schema.owner <> 'SYS' then
            log_action('Recompiling '||l_schema.owner||' ... with dbms_utility.compile_schema');
            sys.dbms_utility.compile_schema (
                schema         => l_schema.owner,
                compile_all    => false,
                reuse_settings => true );
        else
            --
            -- dbms_utility.compile_schema can not compile SYS, that raises
            -- ORA-20001: Cannot recompile SYS objects
            --
            for i in ( select object_type, object_name
                         from sys.dba_objects
                        where owner = l_schema.owner
                          and status <> 'VALID'
                          and object_name member of c_key_sys_objects
                        order by 1 )
            loop
                ddl (
                    'alter package sys.'||sys.dbms_assert.enquote_name(i.object_name)||
                    ' compile'||
                    case when i.object_type='PACKAGE BODY' then ' body' end||
                    ' reuse settings');
            end loop;
        end if;
        --
        -- check for objects that are still invalid
        --
        log_action('Checking for objects that are still invalid');
        for c1 in ( select object_name, object_type, status
                      from sys.dba_objects
                     where owner           = l_schema.owner
                       and ( owner <> 'SYS' or object_name member of c_key_sys_objects )
                       and object_type not in ( 'SYNONYM' )
                       and object_type not like 'LOB%'
                       and status <> 'VALID'
                     order by case object_type
                              when 'PACKAGE'      then 1
                              when 'PACKAGE BODY' then 3
                              when 'TYPE BODY'    then 3
                              else 2
                              end,
                              object_name )
        loop
            -- check if downgrade
            if nvl(l_reg_schema,'x') = c_apex_schema then -- registry matches, not a downgrade
                error('COMPILE FAILURE: '||c1.object_type||' '||l_schema.owner||'.'||c1.object_name);
                for l_err in ( select line, position, text
                                 from dba_errors
                                where owner = l_schema.owner
                                  and name  = c1.object_name
                                  and type  = c1.object_type
                                order by line, position )
                loop
                    p('...'||rpad(l_err.line||'/'||l_err.position, 8)||' '||l_err.text);
                end loop;
            else -- there are invalid objects but they exist in the schema downgraded from
                if l_schema.owner = c_apex_schema
                    and c1.object_name in ('APEX$_WS_ROWS_T1')
                then
                    ddl('drop '||
                        sys.dbms_assert.noop(c1.object_type)||' '||
                        sys.dbms_assert.enquote_name(c_apex_schema)||'.'||
                            sys.dbms_assert.enquote_name(c1.object_name));
                end if;
            end if;
        end loop;
    end loop;
    --
    -- Drop view sys.wwv_flow_cu_constraints if it is not used anymore. If we
    -- always drop it, we break downgrades to 23.2 and older.
    --
    log_action('Checking for sys.wwv_flow_cu_constraints');
    for i in ( select ( select owner
                          from sys.dba_dependencies d
                         where d.referenced_owner  = 'SYS'
                           and d.referenced_type   = 'VIEW'
                           and d.referenced_name   = 'WWV_FLOW_CU_CONSTRAINTS'
                           and rownum = 1 ) owner
                 from sys.dba_objects o
                where o.owner = 'SYS'
                  and o.object_type = 'VIEW'
                  and o.object_name = 'WWV_FLOW_CU_CONSTRAINTS'
                  and rownum        = 1 )
    loop
        if i.owner is not null then
            p(  '... sys.wwv_flow_cu_constraints is still referenced by '||
                i.owner );
        else
            ddl('drop view sys.wwv_flow_cu_constraints');
        end if;
    end loop;
    --
    -- recompile invalid public synonyms that reference APEX
    --
    log_action('Checking invalid public synonyms');
    for s in ( select s.synonym_name
                 from sys.dba_synonyms s, sys.dba_objects o
                where o.owner       = s.owner
                  and o.object_name = s.synonym_name
                   --
                  and s.table_owner = c_apex_schema
                  and o.status      = 'INVALID'
                  and s.owner       = 'PUBLIC'
                order by s.synonym_name )
    loop
        ddl('alter public synonym '||
            sys.dbms_assert.enquote_name(s.synonym_name)||
            ' compile');
    end loop;
    --
    -- Check for the existence of key objects. On upgrades, the post upgrade job
    -- creates the other jobs, so we only verify the existence of APEX jobs when
    -- there is no upgrade job.
    --
    log_action('Key object existence check');

    check_key_objects_exist (
        p_schema  => c_apex_schema,
        p_objects => c_key_apex_objects );
    if not object_exists (
               p_schema => c_apex_schema,
               p_type   => 'JOB',
               p_name   => c_apex_post_job )
    then
        check_key_objects_exist (
            p_schema  => c_apex_schema,
            p_objects => c_key_apex_jobs );
    end if;
    check_key_objects_exist (
        p_schema  => 'FLOWS_FILES',
        p_objects => c_key_file_objects );
    check_key_objects_exist (
        p_schema  => 'SYS',
        p_objects => c_key_sys_objects );

    --
    -- #8460: In order to REST enable APEX_PUBLIC_ROUTER ORDS requires that _oracle_script="true"
    -- Note: Not valide for APP_CONTAINER installs (ok since this function should not be called for APP_CONTAINER installs)
    -- Preserve existing state (if applicable)
    log_action('Post-ORDS updates');
    begin
        select lower(p.value)
        into l_org_oracle_script_value
        from sys.v$parameter p
        where lower(p.name) = '_oracle_script';
    exception
        when no_data_found then
            null; -- not defined yet
    end;

    if l_org_oracle_script_value is null or l_org_oracle_script_value != 'true' then
        execute immediate 'alter session set "_ORACLE_SCRIPT"=true';
    end if;

    log_action(lower('Calling wwv_util_' || c_apex_schema || '.post_ords_upgrade'));
    begin
        execute immediate 'begin ' ||
                            'sys.wwv_util_' || c_apex_schema || '.post_ords_upgrade;' ||
                          'end;';
    exception when others then
        error(sqlerrm);
    end;

    -- Reset to false if it was not true before
    if l_org_oracle_script_value is null or l_org_oracle_script_value != 'true' then
        execute immediate 'alter session set "_ORACLE_SCRIPT"=false';
    end if;


    --
    -- enable the background execution coordinator job
    --
    enable_job( p_job_name => 'ORACLE_APEX_BG_PROCESSES' );
    --
    -- write summary and set registry status
    --
    if l_error_count > 0 then
        log_action('Setting DBMS registry for APEX to INVALID');
        sys.dbms_registry.invalid('APEX');
    else
        log_action('Setting DBMS Registry for APEX to valid');
        sys.dbms_registry.valid('APEX');
    end if;
    --
    log_action('Exiting validate_apex');
    sys.dbms_registry.set_session_namespace (
        namespace   => 'SERVER');
exception when others then
    sys.dbms_registry.invalid('APEX');
    sys.dbms_registry.set_session_namespace (
        namespace   => 'SERVER');
    error('Error in validate_apex: '||sqlerrm);
    p(sys.dbms_utility.format_error_backtrace);
end validate_apex;
/
show errors
