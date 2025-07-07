set define '^' verify off
prompt ...patch_37377364.sql
--------------------------------------------------------------------------------
--
-- Copyright (c) 1999, 2024, Oracle and/or its affiliates.
--
-- NAME
--   patch_37377364.sql
--
-- DESCRIPTION
--   Remove BEFORE_HEADER branch from 4550:7 to 4550:20.
--
-- MODIFIED   (MM/DD/YYYY)
--   sravva    12/18/2024 - Created
--
--------------------------------------------------------------------------------

begin
    update wwv_flow_step_processing
       set attribute_05 = 'N',
           attribute_06 = 'N'
     where security_group_id = 10
       and flow_id           between 4000 and 4009
       and flow_step_id      >= 888
       and flow_step_id      <  888 + 1
       and id                >= 4643948008749483
       and id                <  4643948008749483 + 1;
    --
    commit;
end;
/
