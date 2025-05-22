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

```bash
cd apex
unzip pAPEXPATCH_VER.zip
podman exec -it apex-db sh
cd /opt/oracle/apex/PATCHNUMBER
cp -rf images ..
export NLS_LANG=American_America.AL32UTF8
sqlplus / as sysdba
alter session set container=FREEPDB1;
SQL> @catpatch
SQL> exit;
```
