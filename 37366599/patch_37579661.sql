set define '^' verify off
prompt ...patch_37579661.sql
--------------------------------------------------------------------------------
--
--  Copyright (c) 2025, Oracle and/or its affiliates.
--
--    NAME
--      patch_37579661.sql
--
--    DESCRIPTION
--      Increase the data type length for current_apex_version and current_db_version
--
--    MODIFIED   (MM/DD/YYYY)
--    andrdobr    02/19/2025 - Created
--
--------------------------------------------------------------------------------

alter table wwv_instance_aggr_metrics modify
(current_apex_version varchar2(255))
/

alter table wwv_instance_aggr_metrics modify
(current_db_version varchar2(1024))
/