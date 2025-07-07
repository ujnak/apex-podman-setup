set define '^' verify off
prompt ...patch_37952347.sql
--------------------------------------------------------------------------------
--
--  Copyright (c) 2025, Oracle and/or its affiliates.
--
--    NAME
--      patch_37952347.sql
--
--    DESCRIPTION
--      REGRESSION: REUSING TASK DETAILS PAGE NUMBER GIVES PAGE ALREADY EXISTS ERROR
--
--    MODIFIED   (MM/DD/YYYY)
--    mderouic   05/27/2025 - Created
--

  update wwv_flow_step_validations
     set validation_condition      = 'CREATE_TASK_DETAILS_PAGE',
         validation_condition_type = 'REQUEST_EQUALS_CONDITION'
   where security_group_id = 10
     and flow_id between 4000 and 4009
     and flow_step_id >= 9502
     and flow_step_id <  9502 + 1
     and id      >= 238464660669582701
     and id      <  238464660669582701 + 1
/