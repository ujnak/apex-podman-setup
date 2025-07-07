set define '^' verify off
prompt ...patch_37403215.sql
--------------------------------------------------------------------------------
--
--  Copyright (c) 2025, Oracle and/or its affiliates.
--
--    NAME
--      patch_37403215.sql
--
--    DESCRIPTION
--      Revoves validation on URL entry fields for Extention Links.
--
--    MODIFIED   (MM/DD/YYYY)
--    crokitta    20/12/2024 - Created
--

delete from wwv_flow_step_validations
 where security_group_id = 10
   and flow_id           = 4350
   and flow_step_id >= 110
   and flow_step_id < 110 + 1
   and id >= 1647860943649821
   and id < 1647860943649821 + 1
/

delete from wwv_flow_step_validations
 where security_group_id = 10
   and flow_id           = 4350
   and flow_step_id >= 112
   and flow_step_id < 112 + 1
   and id >= 1647753461649820
   and id < 1647753461649820 + 1
/