--
create user &1 identified by &2 default tablespace users temporary tablespace temp;
alter user &1 quota unlimited on users;

-- allow user to create machine learning model.
grant create mining model to &1;
-- DB_DEVELOPER_ROLE is available on db23ai.
grant db_developer_role to &1;
-- CTX_DDL for Text processing
grant execute on ctxsys.ctx_ddl to &1;
-- grant OML4Py admin role, ignore if OML4Py is not configured.
begin execute immediate 'grant pyqadmin to &1';
exception when others then null; end;
/
-- grant OML4R admin role, ignore if OML4R is not configured.
begin execute immediate 'grant rqadmin to &1';
exception when others then null; end;
/
-- OML_DEVELOPER is available only on ADB
begin execute immediate 'grant oml_developer to &1';
exception when others then null; end;
/

exit;
