set define '^' verify off
prompt ...patch_37830514.sql
--------------------------------------------------------------------------------
--
--  Copyright (c) 2025, Oracle and/or its affiliates.
--
--    NAME
--      patch_37830514.sql
--
--    DESCRIPTION
--      Fix for Bug 37830514 - UNABLE TO LOG IN TO APEX WORKSPACE ON DBFIPS-ENABLED 23AI DB
--
--    MODIFIED   (MM/DD/YYYY)
--    ascheffe    05/23/2025 - Created
--
--------------------------------------------------------------------------------

--
-- for consistency of apps in workspace 10, we run this on both runtime and full development instances.
--
update wwv_flows
   set bookmark_checksum_function = 'SH512'
 where security_group_id = 10
   and bookmark_checksum_function  = 'SH1'
/
