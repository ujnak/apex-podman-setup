set echo on

define SCHEMA = &1

-- create database user for apex parsing sdchema on Oracle Database Free
create user &SCHEMA default tablespace users temporary tablespace temp quota unlimited on users;

begin
-- grant required role for apex to the schema. 
for c1 in (
    select privilege from sys.dba_sys_privs
    where grantee = 'APEX_GRANTS_FOR_NEW_USERS_ROLE'
)
loop
    execute immediate 'grant ' || c1.privilege || ' to &SCHEMA';
end loop;
end;
/
exit;
