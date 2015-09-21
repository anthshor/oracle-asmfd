#!/bin/bash

# define the global variables
export STAGE="/u01/stage"
export SOFTWARE="/u01/software"
export PASSWORD="Password1#"
export VERSION="12.1.0.2"


# Proxy
[ -f /proxy/.proxy.env ] && source /proxy/.proxy.env

# Start NTP daemon
service ntpd status && service ntpd restart || service ntpd start
chkconfig ntpd on

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
  fi
fi

for disk in /dev/sd[b-z]; do
  [ -b $disk ] && chown grid:asmadmin $disk
done

/u01/app/oraInventory/orainstRoot.sh
/u01/app/${VERSION}/grid/root.sh

# Configuring Grid for standalone
/u01/app/12.1.0.2/grid/perl/bin/perl -I/u01/app/12.1.0.2/grid/perl/lib -I/u01/app/12.1.0.2/grid/crs/install /u01/app/12.1.0.2/grid/crs/install/roothas.pl

# Run asmca
# Create DATA and FRA
# asmca -h

export ORACLE_HOME=/u01/app/12.1.0.2/grid

echo "Configuring ASM and creating DATA disk group..."
sudo -E -H -u grid /u01/app/12.1.0.2/grid/bin/asmca -silent -configureASM -sysAsmPassword oracle12 -asmsnmpPassword oracle12 -diskGroupName DATA \
-disk '/dev/sdb' -redundancy EXTERNAL
  
# AU size is the disk extent size in Mb - leave default
echo "Creating ASM FRA disk..."
sudo -E -H -u grid /u01/app/12.1.0.2/grid/bin/asmca -silent -createDiskGroup -diskGroupName FRA -disk '/dev/sdc' -redundancy EXTERNAL 


# Configure disks to use ASMFD
# https://docs.oracle.com/database/121/OSTMG/GUID-06B3337C-07A3-4B3F-B6CD-04F2916C11F6.htm
export ORACLE_SID=+ASM
export PATH=$PATH:$ORACLE_HOME/bin
sudo -E -H -u grid $ORACLE_HOME/bin/srvctl stop asm -f
sudo -E -H -u grid $ORACLE_HOME/bin/srvctl stop asm -f
crsctl stop has
asmcmd afd_configure
asmcmd afd_state
crsctl start has
sudo -E -H -u grid $ORACLE_HOME/bin/srvctl stop diskgroup -diskgroup data -f
sudo -E -H -u grid $ORACLE_HOME/bin/srvctl stop diskgroup -diskgroup fra -f
sudo -E -H -u grid $ORACLE_HOME/bin/asmcmd afd_label ASMDISK1 /dev/sdb --migrate
sudo -E -H -u grid $ORACLE_HOME/bin/asmcmd afd_label ASMDISK2 /dev/sdc --migrate
sudo -E -H -u grid $ORACLE_HOME/bin/asmcmd afd_scan
sudo -E -H -u grid $ORACLE_HOME/bin/srvctl start diskgroup -diskgroup data
sudo -E -H -u grid $ORACLE_HOME/bin/srvctl start diskgroup -diskgroup fra
sudo -E -H -u grid $ORACLE_HOME/bin/asmcmd lsdg
sudo -E -H -u grid $ORACLE_HOME/bin/asmcmd lsdsk


# ./runInstaller for db software
# Saved responsefile in /vagrant for command line scripting

# dbca to create db

# netca required?
