# How to use this repository to create a local Oracle APEX environment using Podman

```bash
git clone https://github.com/ujnak/apex-podman-setup
cd apex-podman-setup
```

## Step 1: Create Pod (Oracle Database Free + ORDS)

```bash
sh config_apex.sh <SYS password> <APEX ADMIN password>
```

## Step 2: Create your first workspace in the APEX instance

```bash
sql sys/<SYS password>@localhost/freepdb1 as sysdba @create_workspace \
<workspace name> <admin account of the workspace> <admin password> <admin mail address>
```

## (Optional) Assign a workspace ID to the workspace

```bash
sql sys/<SYS password>@localhost/freepdb1 as sysdba @create_workspace_with_id \
<workspace name> <admin account of the workspace> <admin password> <admin mail address> <workspace id>
```

## Step 3: Apply PSR (Patch Set Release)

Set patch number in the script before execute.

```bash
sh apply_path.sh
```

## Additional Setup: OML4Py 2.1 Server and Client on apex-db (x86-64 only)

```bash
podman exec apex-db sh work/config_oml4py.sh
```

## Additional Setup: OML4R 2.0 Server on apex-db (x86-64 only)

```
podman exec apex-db sh work/config_oml4r.sh
```

## grant roles to APEX workspace schema

```
grant create mining model to <schema>
grant db_developer_role   to <schema>
grant pyqadmin            to <schema> -- OML4Py only
grant rqadmin             to <schema> -- OML4R  only
grant oml_developer       to <schema> -- ADB only?
```
