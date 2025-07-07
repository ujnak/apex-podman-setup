set define '^' verify off
prompt ...patch_37967372.sql
--------------------------------------------------------------------------------
--
--  Copyright (c) 2025, Oracle and/or its affiliates.
--
--    NAME
--      patch_37967372.sql
--
--    DESCRIPTION
--      Fix for 37967372 - GLOBAL INSTANCE PARAMETER FOR THEME ASSETS
--
--    MODIFIED   (MM/DD/YYYY)
--    stuarwil    05/19/2025 - Created
--
--------------------------------------------------------------------------------

declare
    l_cnt number;
begin
    select count(*) into l_cnt
      from wwv_flow_platform_prefs
     where name = 'DEFAULT_THEME_FILES';

    if l_cnt = 0 then
        wwv_flow_platform.set_preference('DEFAULT_THEME_FILES','https://static.oracle.com/cdn/');
    end if;
end;
/
