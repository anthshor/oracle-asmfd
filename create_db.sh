#!/bin/bash

# define the global variables
export ORACLE_SID=fred
export PASSWORD=oracle12
export ASMPWD=Password1#
export VERSION="12.1.0.2"
export ORACLE_HOME=/u01/app/oracle/product/${VERSION}/dbhome_1

sudo -E -H -u oracle $ORACLE_HOME/bin/srvctl status database -d $ORACLE_SID > /dev/null
if [ $? -eq 0 ]; then
	echo "INFO: Database ${ORACLE_SID} exists, skipping database creation."
else
	echo "INFO: Creating database ${ORACLE_SID}..."
	sudo -E -H -u oracle /u01/app/oracle/product/${VERSION}/dbhome_1/bin/dbca -silent -createDatabase -templateName General_Purpose.dbc -gdbName $ORACLE_SID -sid $ORACLE_SID -sysPassword $PASSWORD \
	-systemPassword $PASSWORD -emConfiguration LOCAL -storageType ASM -diskGroupName DATA -recoveryGroupName FRA \
	-characterset WE8ISO8859P1 -obfuscatedPasswords false -sampleSchema false -asmSysPassword $ASMPWD
fi
