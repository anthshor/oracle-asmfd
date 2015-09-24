#!/bin/bash

# Install Oracle Database software only

# define the global variables
export STAGE="/u01/stage"
export SOFTWARE="/u01/software"
export PASSWORD="Password1#"
export VERSION="12.1.0.2"

if [ -f /u01/app/oracle/product/${VERSION}/dbhome_1/root.sh ]; then
  echo "INFO: found oracle grid software installed"
else 
  echo "INFO: not found database software installed"
  if [ -f /u01/stage/database/runInstaller ]; then
    echo "INFO: Found Oracle software installer, will try to install"
    echo "INFO: This may take upto 25 minutes, press CTRL-C to cancel"
    for i in {1..5}; do echo . ; sleep 1; done
    echo "Installing database software..."
	sudo -E -H -u oracle $STAGE/database/runInstaller -silent -ignoreSysPrereqs -ignorePrereq -waitforcompletion \
	oracle.install.option=INSTALL_DB_SWONLY \
	ORACLE_HOSTNAME=whister.zoomer \
	UNIX_GROUP_NAME=oinstall \
	INVENTORY_LOCATION=/u01/app/oraInventory \
	SELECTED_LANGUAGES=en \
	ORACLE_HOME=/u01/app/oracle/product/${VERSION}/dbhome_1 \
	ORACLE_BASE=/u01/app/oracle \
	oracle.install.db.InstallEdition=EE \
	oracle.install.db.DBA_GROUP=dba \
	oracle.install.db.OPER_GROUP=oper \
	oracle.install.db.BACKUPDBA_GROUP=backupdba \
	oracle.install.db.DGDBA_GROUP=dgdba \
	oracle.install.db.KMDBA_GROUP=kmdba \
	oracle.install.db.isRACOneInstall=false \
	oracle.install.db.rac.serverpoolCardinality=0 \
	SECURITY_UPDATES_VIA_MYORACLESUPPORT=false \
	DECLINE_SECURITY_UPDATES=true
    if [ $? -eq 0 ]; then
      rm -rf $STAGE/grid
    fi
  fi
fi

