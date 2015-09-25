# Oracle asmfd
Oracle Grid install with ASM using asmfd

```
time vagrant up

real 20m8.224s
user 0m10.440s
sys 0m6.942s
```

```
[grid@whister ~]$ asmcmd lsdsk
Path
AFD:ASMDISK1
AFD:ASMDISK2
```

Added Oracle Database (ref: vagrantup.log)

```
time vagrant up

real	34m11.237s
user	0m12.404s
sys	0m8.127s
```

Check Database:

```
$ vagrant ssh
[vagrant@whister ~]$ su - oracle
Password: 
[oracle@whister ~]$ . oraenv
ORACLE_SID = [oracle] ? fred
The Oracle base has been set to /u01/app/oracle
[oracle@whister ~]$ sqlplus / as sysdba

SQL*Plus: Release 12.1.0.2.0 Production on Fri Sep 25 22:13:59 2015

Copyright (c) 1982, 2014, Oracle.  All rights reserved.


Connected to:
Oracle Database 12c Enterprise Edition Release 12.1.0.2.0 - 64bit Production
With the Partitioning, Automatic Storage Management, OLAP, Advanced Analytics
and Real Application Testing options

SQL> select name, open_mode from v$database;

NAME	  OPEN_MODE
--------- --------------------
FRED	  READ WRITE

SQL> select name from v$datafile;

NAME
--------------------------------------------------------------------------------
+DATA/FRED/DATAFILE/system.258.891381267
+DATA/FRED/DATAFILE/sysaux.257.891381213
+DATA/FRED/DATAFILE/undotbs1.260.891381317
+DATA/FRED/DATAFILE/users.259.891381313
```


