set define '^' verify off
prompt ...patch_37751502.sql
--------------------------------------------------------------------------------
--
-- Copyright (c) 1999, 2025, Oracle and/or its affiliates.
--
-- NAME
--   patch_37751502.sql
--
-- DESCRIPTION
--  Fix for bug 37751502 - PLUGIN COMPONENT TYPES AT ATTRIBUTE LEVEL ARE NOT SET CORRECTLY
--
-- MODIFIED   (MM/DD/YYYY)
--   fsecara   05/05/2025 - Created
--
--------------------------------------------------------------------------------

--
-- Item comp type
--
update wwv_flow_step_items
    set use_cache_before_default = 'NO'
  where security_group_id = 10
    and flow_id           between 4000 and 4009
    and flow_step_id      >= 4415
    and flow_step_id      <  4415 + 1
    and id                >= 2029958216167737
    and id                <  2029958216167737 + 1
/

update wwv_flow_step_computations
    set compute_when      = ':P4415_PLUGIN_TYPE = ''ITEM TYPE''',
        compute_when_text = 'PLSQL',
        compute_when_type = 'EXPRESSION'
  where security_group_id = 10
    and flow_id           between 4000 and 4009
    and flow_step_id      >= 4415
    and flow_step_id      <  4415 + 1
    and id                >= 502499771942935715
    and id                <  502499771942935715 + 1
/

--
-- Process comp type
--
update wwv_flow_step_items
    set use_cache_before_default = 'NO'
  where security_group_id = 10
    and flow_id           between 4000 and 4009
    and flow_step_id      >= 4415
    and flow_step_id      <  4415 + 1
    and id                >= 502499517782935713
    and id                <  502499517782935713 + 1
/

update wwv_flow_step_computations
    set compute_when      = ':P4415_PLUGIN_TYPE = ''PROCESS TYPE''',
        compute_when_text = 'PLSQL',
        compute_when_type = 'EXPRESSION'
  where security_group_id = 10
    and flow_id           between 4000 and 4009
    and flow_step_id      >= 4415
    and flow_step_id      <  4415 + 1
    and id                >= 2029883003167736
    and id                <  2029883003167736 + 1
/
