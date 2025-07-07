set define '^' verify off
set concat on
set concat .
prompt ...devpatch.sql

Rem  Copyright (c) 1999, 2024, Oracle and/or its affiliates.
Rem
Rem    NAME
Rem      devpatch.sql
Rem
Rem    DESCRIPTION
Rem      Oracle APEX patch for a full development installation.
Rem
Rem    MODIFIED   (MM/DD/YYYY)
Rem    hfarrell    10/13/2020 - Created

define APPUN    = 'APEX_240200'
define PREFIX = '^1'

alter session set current_schema = SYS;
--------------------------------------------------------------------------------
-- Grants
--------------------------------------------------------------------------------
grant select on sys.dba_external_tables to ^APPUN;

alter session set current_schema = ^APPUN;

---------------------------------------------------------------------------
-- Compilation of package specifications
-- @^PREFIX.foo.sql
---------------------------------------------------------------------------

---------------------------------------------------------------------------
-- Compilation of views
-- @^PREFIX.dev_views.sql
---------------------------------------------------------------------------

-------------------------------------------------------------------
-- Compilation of package bodies
-- @^PREFIX.wwv_flow_lov_dev.plb
-------------------------------------------------------------------
@^PREFIX.generate_ddl.plb
@^PREFIX.modules/auto_backup/wwv_flow_backup.plb
@^PREFIX.modules/issues/wwv_flow_issue_notify_int.plb
@^PREFIX.wwv_dictionary_cache_dev.plb
@^PREFIX.wwv_flow_ai_dev.plb
@^PREFIX.wwv_flow_authentication_dev.plb
@^PREFIX.wwv_flow_data_profile_dev.plb
@^PREFIX.wwv_flow_doc_src_dev.plb
@^PREFIX.wwv_flow_f4000_util.plb
@^PREFIX.wwv_flow_file_editor_dev.plb
@^PREFIX.wwv_flow_maint_dev.plb
@^PREFIX.wwv_flow_theme_manager.plb
@^PREFIX.wwv_flow_working_copy_dev.plb
@^PREFIX.wwv_sample_dataset.plb
-- Please add files in alphabetic order and not at the end.

--------------------------------------------------------------------------------
-- Grants and public synonyms
--------------------------------------------------------------------------------

-------------------------------------------------------------------
-- patch files
-- @^PREFIX.patch_123456.sql
-------------------------------------------------------------------
@^PREFIX.patch_37355551.sql
@^PREFIX.patch_37403215_dev.sql
@^PREFIX.patch_37377364.sql
@^PREFIX.patch_37512460_dev.sql
@^PREFIX.patch_36774907_dev.sql
@^PREFIX.patch_37553042_dev.sql
@^PREFIX.patch_37473871.sql
@^PREFIX.patch_37588311_dev.sql
@^PREFIX.patch_37809911_dev.sql
@^PREFIX.patch_37751502.sql
@^PREFIX.patch_37952347.sql
@^PREFIX.patch_37086304.sql


-- commit after dml changes to metadata
commit;
