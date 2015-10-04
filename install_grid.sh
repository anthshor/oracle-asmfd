#!/bin/bash

# define the global variables
export STAGE="/u01/stage"
export SOFTWARE="/u01/software"
export PASSWORD="Password1#"
export VERSION="12.1.0.2"

# Installing Grid Infrastructure Using a Software-Only Installation
# NB /etc/resolv.conf - server can't find <domain>: NXDOMAIN (skipped prereqs) - fix later
if [ -f /u01/app/${VERSION}/grid/root.sh ]; then
  echo "OK: found oracle grid software installed"
else
  echo "WARN: not found oracle grid software installed"
  if [ -f /u01/stage/grid/runInstaller ]; then
    echo "OK: found oracle grid software installer, will try to install"
    echo "NOTE: This may take upto 25 minutes, press CTRL-C to cancel"
    for i in {1..5}; do echo . ; sleep 1; done
    echo "Installing Grid software..."
    sudo -E -H -u grid /u01/stage/grid/runInstaller -silent -ignoreSysPrereqs  -ignorePrereq -waitforcompletion  \
    oracle.install.asm.SYSASMPassword=oracle12 oracle.install.asm.monitorPassword=oracle12 \
    ORACLE_HOSTNAME=$HOSTNAME \
    INVENTORY_LOCATION=/u01/app/oraInventory \
    SELECTED_LANGUAGES=en \
    oracle.install.option=CRS_SWONLY \
    ORACLE_BASE=/u01/app/grid \
    ORACLE_HOME=/u01/app/12.1.0.2/grid \
    oracle.install.asm.OSDBA=asmdba \
    oracle.install.asm.OSOPER=asmoper \
    oracle.install.asm.OSASM=asmadmin \
    oracle.install.crs.config.ClusterType=STANDARD \
    oracle.install.crs.config.gpnp.configureGNS=false \
    oracle.install.crs.config.sharedFileSystemStorage.votingDiskRedundancy=NORMAL \
    oracle.install.crs.config.sharedFileSystemStorage.ocrRedundancy=NORMAL \
    oracle.install.crs.config.useIPMI=false \
    oracle.install.crs.config.ignoreDownNodes=false \
    oracle.install.config.managementOption=NONE 
    if [ $? -eq 0 ]; then
      /u01/app/oraInventory/orainstRoot.sh
      rm -rf $STAGE/grid
    fi
  fi
fi


