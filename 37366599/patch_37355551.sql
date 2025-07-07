set define '^' verify off
prompt ...patch_37355551.sql
--------------------------------------------------------------------------------
--
-- Copyright (c) 1999, 2024, Oracle and/or its affiliates.
--
-- NAME
--   patch_37355551.sql
--
-- DESCRIPTION
--   Remove BEFORE_HEADER branch from 4550:7 to 4550:20.
--
-- MODIFIED   (MM/DD/YYYY)
--   cneumuel  12/17/2024 - Created
--
--------------------------------------------------------------------------------

begin
    delete from wwv_flow_step_branches
     where security_group_id =       10
       and id                between 17445722481733542 and 17445722481733542.9999;
    --
    commit;
end;
/
