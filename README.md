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
grant pyqadmin            to <schema> -- for OML4Py
grant rqadmin             to <schema> -- for OML4R
grant oml_developer       to <schema> -- for ADB
grant execute on ctx_ddl  to <schema> -- to support text analysis
```

## verify installaing 

# OML4Py Server

podman exec -it apex-db bash
. work/oml/oml4py.env
export PYTHONPATH=$ORACLE_HOME/oml4py/modules
python3
import oml
oml.connect(user='wksp_apexdev',password='password',port=1521,host='localhost',service_name='freepdb1')
oml.script.create("TEST", func='def func():return 1 + 1', overwrite=True)
res = oml.do_eval(func='TEST')
res
oml.script.drop("TEST")

# OML4R Server
export LD_LIBRARY_PATH=$ORACLE_HOME/lib:$LD_LIBRARY_PATH
ORE
library(ORE)
ore.connect("OMLUSER", password="パスワード", service_name="FREEPDB1", host="localhost", all=TRUE)

## Is the OML4R client connected to the OML4R server?
## The output of this function should be TRUE.
ore.is.connected()

## List the available database tables.
ore.ls()

## Push an R dataframe to a database table.
df <- data.frame(a="abc",
                b=1.456,
                c=TRUE,
                d=as.integer(1))
of <- ore.push(df)

## Run the self-contained example code in the help files associated with the following functions.
## The examples should not return any errors.
example("ore.odmAI")     ## Builds an OML4SQL attribute importance model.
example("ore.doEval")    ## Runs an embedded R execution function.

