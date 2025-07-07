# Oracle APEX Product Version #  : 24.2.6
#
# Patch Set Exception : Bug 37366599 - PSE BUNDLE FOR APEX 24.2 (PSES ON TOP OF 24.2.x)
#
# Platform Patch for  : Generic - Platform independent
#
# DATE : Jun 06, 2025
#
# This document describes how you can install the Patch Set Exception on your Oracle APEX 24.2.x instance.
#
#
# (I) Requirements
# ----------------
# Before you install the patch, ensure that you meet the following requirement:
#
#    - You must be using Oracle APEX Product Version #  : 24.2.x
#
# If you do NOT meet this requirement, or are not certain that you meet
# the requirement, please log a Service Request and Oracle Support will make
# a determination about whether you should apply this patch.
#
#
# (II) Bugs Fixed by this patch
# -----------------------------
# ----- PATCH_VERSION: 1 -----
# 37355551 - APEX.ORACLECORP.COM: ON SSO LOGIN TO BUILDER, DO NOT SHOW CHANGE APEX USER PASSWORD PAGE
# 37403215 - VALIDATION ON LINK ATTRIBUTE IN EDIT MANAGE EXTENSION LINKS PAGE DOES NOT ALLOW RELATIVE PATHS
# 37377364 - TEXT MESSAGES > GRID EDIT ALWAYS THROWS ERROR DURING SAVE
# 37439882 - REGRESSION: ORA-922: MISSING OR INVALID OPTION IN SUPPORTING OBJ SCRIPT WITH );
# 37381826 - ERROR USING SELECT ONE WITH SHARED COMP LOV HAVING SAME RETURN/DISPLAY COL
# 37469753 - REGRESSION: UNABLE TO CREATE APP FROM SCRIPT CONTAINING CREATE TABLE STATEMENTS
# 37477049 - RICH TEXT EDITOR CANNOT RESIZE WHEN CONTENT SECURITY POLICY IS ENABLED
# 37474087 - FACETED SEARCH: WRONG WITDTH OF COMBOBOX IN ADD FILTER DIALOG IN UT
# 37481595 - APEX UNIVERSAL THEME SIDE NAVIGATION TREEVIEW TOGGLE ICON VISIBLE WHEN COLLAPSED
# 37480254 - GENERATIVE AI: SQL VIEWS ARE NOT CONSIDERED IN NL2SQL AI ASSISTANT
# 37477575 - POST-LOGOUT URL ATTRIBUTE DOES NOT SUPPORT AUTHENTICATION SUBSTITUTIONS
# 37459803 - INLINE CSS CONTENT SECURITY POLICY VIOLATION IN SMART FILTER CONTROLS
# ----- PATCH_VERSION: 2 -----
# 37484172 - APEX PATCHES SHOULD UPDATE EMAIL_IMAGES_URL IF USING CDN
# 37489550 - JSON SOURCES: DML ON ARRAY OF SCALAR VALUES THROWS ORA-40597 ERROR
# 37348464 - GENERATE DDL : CANNOT SAVE AS SCRIPT IF OBJECT TYPE IS SYNONYM
# 37502501 - REGRESSION: ORA-03048 IF CREATE VIEW STATEMENT CONTAINS COLUMN NAMED "TYPE"
# 37356737 - ACCESSIBLE ACTION/DIALOG LINKS BREAKS ACCESSIBLE HEADINGS ON SOME PAGES
# 37356338 - ACCESSIBILITY OF ACTION/DIALOG LINKS BREAKS ACCESSIBILITY OF QUICK PICK LINKS
# 37512460 - SAVING GENERIC COLUMNS REPORT LAYOUT SETS PAGE TEMPLATE TO NULL
# 37472949 - ORA-40597: JSON PATH EXPRESSION SYNTAX ERROR ('$.1') FOR GETPAGEDATA FOR ITEM TYPE PLUGINS
# 37376213 - BIND VAR DOES NOT EXIST + ROW NOT INSERTED UPDATING NESTED ARRAY IN JSON SOURCE
# 37382369 - INCREASE DEFAULT MAX TOKENS FOR OCI GENAI TO 4000
# 37503457 - REGRESSION: WORKFLOW PARAM PASSED AS STATIC VALUE EVALS TO NULL
# 37512596 - PAGINATION NOT WORKING PROPERLY IN "SIMPLE HTTP" RDS WHEN "HAS MORE ROWS ATTRIBUTE VALUE" IS NOT IN LOWER CASE
# 37519977 - RUNTIME ERROR USING BOSS POLYMORPHIC COMPOSITES (FLEX FIELDS)
# 37529125 - Fix for bug 37529125
# ----- PATCH_VERSION: 3 -----
# 37538056 - CREATE DUALITY VIEW SOURCE THROWS ORA-6503 ON DB 23.6
# 37514003 - NEW PADDING UTILITY CLASSES DON'T WORK
# 37564420 - ERROR WHILE DOWNLOADING PDF ON IR:ORA-01476: DIVISOR IS EQUAL TO ZERO
# 36774907 - GENERATIVE AI: ADDITIONAL ATTRIBUTES OVERWRITTEN WITH DEFAULT VALUES
# 37553867 - DML ON JSON SOURCES FAILS IF COLUMNS HAVE SQL EXPRESSIONS OR "SEQUENCE" IS USED AS DEFAULT
# 37541560 - APEX-EXT: APEX JOB ORACLE_APEX_PURGE_SESSIONS FAILED WITH ORA-01858
# 37549559 - CHAT CLIENT DIALOG HAS DOUBLE SCROLLBARS
# 37553042 - REGRESSION: ORA-6550 RAISED ON EDIT VECTOR PROVIDER PAGE
# 37563223 - DML ON "TABLE WITH JSON COLUMNS" JSON SOURCE RAISES ORA-3083 IF ONLY RELATIONAL COLUMNS ARE UPDATED
# 37473871 - ERR OPENING COPIED PAGE FROM DECOUPLED UT THEME APP IN NON-DECOUPLED THEME APP
# 37512743 - OPEN TELEMETRY SPANS CONTAIN UNSUBSTITUTED STRINGS UNEXPECTEDLY
# 37575481 - IMPORT SWAGGER 2.0 FILE AS REST CATALOG LEADS TO PARAMETER NAMES MISSING
# 37588311 - UNEXPECTED ERROR SAVING AUTOMATION WITH FUNCTION BODY RETURNING SQL
# 37590624 - BUILD OPTION UTILIZATION PAGE THROWING ORA-00903: INVALID TABLE NAME ERROR
# 37586431 - LIST DETAILS PAGE THROWING ORA-06502: PL/SQL: NUMERIC OR VALUE ERROR: CHARACTER STRING BUFFER TOO SMALL ERROR
# 37564624 - PE.SELECT PLACEHOLDER TEXT MESSAGE LISTED FOR CARDS REGIONS
# 37474511 - FACETED SEARCH: DATEPICKER INPUT IS NOT CLEARED CORRECTLY BECAUSE WRAPPEDELEMENT IS NOT SET
# 37512644 - REGRESSION: CLASSIC REPORT COLUMN WIDTH IGNORED AFTER DYNAMIC ACTION REFRESH
# 37568470 - REGRESSION: CLASSIC REPORT PERCENT GRAPH COLUMN BROKEN AFTER DYNAMIC ACTION REFRESH
# 37579661 - DAILY METRICS JOBS FAIL TO COLLECT INSTANCE METRICS ON 23AI DATABASES
# 37607202 - Fix for bug 37607202
# 37618011 - Fix for bug 37618011
# 37489539 - ADB-S: UNABLE TO SET PATH_PREFIX WORKSPACE PARAMETER
# 37250346 - APEX SENDS BACK CROSS ORIGIN HEADERS EVEN WITH HTTP_TRUSTED_ORIGINS
# 37365511 - FACETED SEARCH: ADD FILTER BUTTON DISABLED AFTER CLOSING DIALOGUE WITHOUT CLICKING APPLY
# 37623028 - Fix for bug 37623028
# 37634998 - DBMS_INSTANCE_ADMIN.DROP_CLOUD_CREDENTIAL THROWS ERROR "INSTANCE PARAMETER NOT FOUND" ON ADB
# ----- PATCH_VERSION: 4 -----
# 37651139 - IMPORT REPORT LAYOUT RAISES PLS-00123: PROGRAM TOO LARGE
# 37517405 - REGRESSION: ERROR OPENING MODAL PAGE W/ REDIRECT & SET VALUE RADIO GROUP
# 37365329 - FACETED SEARCH: DOUBLE ESCAPING WHEN RE-ADD VALUE TO SELECT ONE IN FILTER DIALOGS
# 37662593 - REGRESSION: CALENDAR EVENT LINKS CANNOT BE OPENED USING BROWSERS "OPEN IN NEW TAB" FUNCTION
# 37697085 - Fix for bug 37697085
# 37704247 - EDITING THEME FILES WHEN A THEME HAS APPLICATION SUBSCRIBERS RAISE NO DATA FOUND
# 37684930 - REGRESSION: WHEN UPDATING THEME TO LATEST VERSION CUSTOMIZED TEMPLATES ARE REMOVED
# 37693733 - REGRESSION: LIST MANAGER IS BROKEN WHEN USING IN OTHER LANGUAGES THEN ENGLISH
# 37740250 - ADB-S: DOCGEN CLOUD CREDENTIAL MISSING AFTER UPGRADE TO 24.2
# 37558869 - ORACLE_APEX_DICTIONARY_CACHE FAILS JOB FAILS IF ANY WORKSPACE NAME IS NUMBER
# ----- PATCH_VERSION: 5 -----
# 37794173 - JSON SOURCES: ORA-1008 THROWS WHEN INSERTING NEW CHILD INTO NESTED ARRAY OF SECOND OR DEEPER LEVEL
# 37794425 - PARENT COL NULL IN DATA PROFILE ARRAY COL FOR GRANDCHILD DUALITY VIEW COLLECTION
# 37787406 - ORA-20001 ERROR REPORTED IN APEX INSTALLATION LOG WHEN APEX 24.2
# 37740078 - Fix for bug 37740078
# 37810345 - Fix for bug 37810345
# 37756039 - ORACLE_APEX_DAILY_METRICS JOB FAILING RANDOMLY
# 37809911 - AN AUDIT RECORD IS NOT STORED DUE TO HANDLED EXCEPTION IN TRIGGER DURING WORKING COPY MERGE
# 37785000 - BAIL OUT OF JOBS ON LOGICAL STANDBY
# ----- NEW IN PATCH_VERSION: 6 -----
# 37751502 - PLUGIN COMPONENT TYPES AT ATTRIBUTE LEVEL ARE NOT SET CORRECTLY
# 37859249 - UNABLE TO CREATE OR DELETE DEFAULT INTERACTIVE REPORT SUBSCRIPTION DURING PHASE 2 OF APEX UPGRADE
# 37859062 - UNABLE TO SIGN IN TO APP BUILDER DURING PHASE 2 OF APEX UPGRADE
# 37858190 - DON'T LOG EVENTS FOR USER PREFERENCES
# 37967372 - GLOBAL INSTANCE PARAMETER FOR THEME ASSETS
# 37830514 - UNABLE TO LOG IN TO APEX WORKSPACE ON DBFIPS-ENABLED 23AI DB
# 37970639 - SUSPENDING WORKFLOWS MUST USE DBA_SCHEDULER_JOBS, RESUME SHOULD ABORT DANGLING JOB
# 37952347 - REGRESSION: REUSING TASK DETAILS PAGE NUMBER GIVES PAGE ALREADY EXISTS ERROR
# 37086304 - APEX.ORACLECORP.COM - WEB SERVICE ACTIVITY LOG PAGE TIMES OUT
# 38029863 - SOAP WEB SERVICE CALLS FAIL WITH LARGE ENVELOPES WHEN DEBUGGING IS ENABLED
# 38043213 - PATCH SET 24.2.5 ENABLES DEBUG AT WARN LEVEL FOR ALL JOBS
#
# (III) Patch Installation Instructions
# -------------------------------------
# To apply the patch:
#
#  1. Download the p37366599_242_GENERIC.zip patch set installation archive to a directory that is not the Oracle home directory or under the Oracle home directory.
#
#  2. Unzip and extract the installation files by double-clicking p37366599_242_GENERIC.zip in a Microsoft Windows based system, or entering the following command to unzip on a UNIX or Linux based system:
#
#   $ unzip p37366599_242_GENERIC.zip
#
#  3. Preventing Access to Oracle REST Data Services
#
#     It is important that no developers or end users access Oracle APEX while you are applying the patch. This section describes how to prevent access to Oracle APEX.
#
#     Stopping Oracle REST Data Services:
#
#        To learn more about stopping the Oracle REST Data Services server, see Oracle REST Data Services Installation and Configuration Guide:
#
#        https://docs.oracle.com/en/database/oracle/oracle-rest-data-services/index.html
#
#  4. Set your current directory to the "37366599" directory where you unzipped the p37366599_242_GENERIC.zip file.
#
#  5. Set the NLS_LANG environment variable, making sure that the character set is AL32UTF8. For example:
#
#     Bourne or Korn shell:
#
#       NLS_LANG=American_America.AL32UTF8
#       export NLS_LANG
#
#     C shell:
#
#       setenv NLS_LANG American_America.AL32UTF8
#
#     For Windows based systems:
#
#       set NLS_LANG=American_America.AL32UTF8
#
#  6. Connect to the database where Oracle APEX is installed as the SYS user and run catpatch.sql or catpatch_con.sql as in the following examples:
#
#     sql "sys/ as sysdba" @catpatch.sql        -- for non-CDB and for CDB where Oracle APEX is not installed in the root, and for PDB where APEX is not installed in the root
#     sql "sys/ as sysdba" @catpatch_con.sql    -- for CDB where Oracle APEX is installed in the root
#     sql "sys/ as sysdba" @catpatch_appcon.sql -- for installations where Oracle APEX is installed in an application container
#
#  7. Install the Patch Set Exception's changes in the images directory
#
#       Copy the images directory of the patch to the /images folder of the Oracle APEX installation directory images sub directory.
#
#       Assuming the p37366599_242_GENERIC.zip file was unzipped to c:\temp on Windows and /tmp on Linux
#
#       On a Windows system, run a command from a command prompt similar to the following example:
#
#           xcopy /E /I c:\temp\images ORACLE_APEX_HOME\apex\images
#
#       On UNIX or Linux based systems, run a command similar to the following example:
#
#           cp -rf /tmp/images ORACLE_APEX_HOME/apex
#
#       In the preceding syntax examples, ORACLE_APEX_HOME is the existing Oracle APEX installation location. For example, c:\oracle\apex_24.2 on Windows and /oracle/apex_24.2 on Linux.
#
#  8. Starting Oracle APEX
#
#    - Starting Oracle REST Data Services
#
#       To learn more about starting the Oracle REST Data Services server, see Oracle REST Data Services Installation and Configuration Guide:
#
#           https://docs.oracle.com/en/database/oracle/oracle-rest-data-services/index.html
#
#
# (IV) New APEX 24.2 Content Delivery Network (CDN)
# -------------------------------------------------
# APEX 24.2 static resources are available on a CDN, https://static.oracle.com/cdn/apex/24.2.6/.
#   - The CDN contains the production APEX 24.2.0 static resources and the updated static resources included in 24.2.1, 24.2.2, 24.2.3, 24.2.4, 24.2.5 and 24.2.6.
#
#    I. Instance using the APEX CDN
#
#       If your instance is currently using the APEX CDN, this patch automatically updates the CDN reference to the 24.2.6 version. No further action needed.
#
#   II. Instance not yet using the APEX CDN
#
#       If you wish to convert your instance to use the static resources from the 24.2.6 CDN, you will need to reset the APEX images prefix for your instance. This change can be performed on a live system.
#
#       To convert an instance to use the CDN:
#
#       - Set your current directory to the directory where the production APEX 24.2 zipfile was extracted. For example, c:\temp\apex_ on Windows and /tmp/apex_ on Linux.
#
#       - Navigate to the apex/utilities subdirectory of the production APEX 24.2 directory. For example, /tmp/apex_/apex/utilities
#
#       - Connect to the database where Oracle APEX is installed as SYS and run reset_image_prefix.sql, as in the following example:
#
#         sql "sys/ as sysdba" @reset_image_prefix.sql
#
#       - When prompted for the image prefix, enter the CDN path, as follows:
#
#         https://static.oracle.com/cdn/apex/24.2.6/
#
#  III. Use the APEX CDN in a single APEX application
#
#       If you wish to use the APEX CDN in a single APEX application:
#
#       - In App Builder, edit your application and click "Shared Components"
#
#       - Click "User Interface Attributes"
#
#       - Under Advanced, in the #APEX_FILES# Path enter as follows:
#
#         https://static.oracle.com/cdn/apex/24.2.6/
#
#       - Click "Apply Changes"
#
#
# (V) To confirm the patch has been applied
# -----------------------------------------
#
#    I. Review the Product Build number on your instance
#
#       - Log into your workspace.
#
#       - Review the Product Build number displayed in the lower right corner.
#
#         If your instance has been patched, the build number will be 24.2.x, where x is the PATCH_VERSION. For example, 24.2.6.
#         In your instance has not been patched, the build number will be 24.2.x.
#
#   II. Review the About dialog on your instance
#
#       - Log into your workspace.
#
#       - Click 'Help' > 'About'.
#
#       - Review the Details section:
#
#         'Patch Version' will display the version of the patch installed.
#         'Last Patch Time' will display the patch installation date and time.
#         These values will only be visible on a patched instance.
#
#  III. Start SQLcl and connect to the database where Oracle APEX is installed as SYS. For example:
#
#         - On Windows:
#
#                 SYSTEM_DRIVE:\> sql /nolog
#                 SQL> CONNECT SYS as SYSDBA
#                 Enter password:
#
#         - On UNIX and Linux:
#
#                 $ sql /nolog
#                 SQL> CONNECT SYS as SYSDBA
#                 Enter password:
#
#            Enter the following statement to verify the patch with patch_number 37366599 has been installed:
#
#                 select patch_version, installed_on
#                   from apex_patches
#                  where patch_number = 37366599
#                  order by installed_on;
#
#            Multiple rows will be returned if earlier versions of this patch have been installed.
#
#
# EOF README.txt
