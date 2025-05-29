#!/bin/sh
# enable MultiLingual Engine
# sqlplus sys@localhost/pdb as sysdba
# usage: @enable_mle <workspace_schema>

grant execute on javascript to &1;
grant execute dynamic mle to &1;
grant create mle to &1;
exit;
