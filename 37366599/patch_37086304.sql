set define '^' verify off
prompt ...patch_37086304.sql
--------------------------------------------------------------------------------
--
-- Copyright (c) 1999, 2025, Oracle and/or its affiliates.
--
--    NAME
--      patch_37086304.sql
--
--    DESCRIPTION
--      Enable Lazy Loading for Web Service Activity Log report
--
--    MODIFIED   (MM/DD/YYYY)
--    andrdobr   05/28/2025 - Created
--
--------------------------------------------------------------------------------

update wwv_flow_worksheets
    set lazy_loading = 'Y'
  where security_group_id = 10
    and flow_id           between 4050 and 4059
    and page_id           >= 101
    and page_id           <  101 + 1
    and id                >= 812399756925979420
    and id                <  812399756925979420 + 1
/