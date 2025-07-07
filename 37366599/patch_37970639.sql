set define '^' verify off
prompt ...patch_37970639.sql
--------------------------------------------------------------------------------
--
--  Copyright (c) 2025, Oracle and/or its affiliates.
--
--    NAME
--      patch_37970639.sql
--
--    DESCRIPTION
--      Fix for 37970639 - WORKFLOW COMPONENT: SUSPENDING WORKFLOWS MUST USE 
--                         DBA_SCHEDULER_JOBS, RESUME SHOULD ABORT DANGLING JOBS 
--
--    MODIFIED   (MM/DD/YYYY)
--    ralmuell    05/23/2025 - Created
--
--------------------------------------------------------------------------------

begin
    execute immediate 'revoke select on sys.dba_scheduler_running_jobs from ^APPUN';
exception
    when others then
        null; -- defensive, if grant was already revoked earlier
end;
/