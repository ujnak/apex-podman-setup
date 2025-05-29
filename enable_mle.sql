#!/bin/sh
# enable MultiLingual Engine

WORKSPACE_SCHEMA=${1}

grant execute on javascript to ${WORKSPACE_SCHEMA};
grant execute dynamic mle to ${WORKSPACE_SCHEMA};
grant create mle to ${WORKSPACE_SCHEMA};
