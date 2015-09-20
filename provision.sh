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
# NB /etc/resolv.conf - server can't find logitech: NXDOMAIN (skipped prereqs) - fix later
if [ ! -f /u01/app/${VERSION}/grid/root.sh ]; then
  echo "Installing Grid software..."
  sudo -E -H -u grid /u01/stage/grid/runInstaller -silent -ignoreSysPrereqs  -ignorePrereq -waitforcompletion  \
  oracle.install.asm.SYSASMPassword=oracle12 oracle.install.asm.monitorPassword=oracle12 \
  ORACLE_HOSTNAME=logitech.sprite.zero \
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


  /u01/app/oraInventory/orainstRoot.sh
  /u01/app/${VERSION}/grid/root.sh

# Configuring Grid for standalone
/u01/app/12.1.0.2/grid/perl/bin/perl -I/u01/app/12.1.0.2/grid/perl/lib -I/u01/app/12.1.0.2/grid/crs/install /u01/app/12.1.0.2/grid/crs/install/roothas.pl

else
  echo "Skipping Grid Installation."
fi

pushd /dev
  chown grid:dba sdb
  chown grid:dba sdc
popd

# Run asmca
# Create DATA and FRA
# Need command line for scripting
# https://docs.oracle.com/database/121/OSTMG/GUID-877EB0F8-E9CA-4C97-965C-AACBB256B12D.htm#OSTMG94309

sudo -E -H -u grid /u01/app/12.1.0.2/grid/bin/asmcmd lsdg
if [ $? ne 0 ]; then
  echo "Configuring ASM..."
  asmca -silent -configureASM -diskList '/dev/sdb, /dev/sdc' –sysAsmPassword oracle11 -asmsnmpPassword oracle11
# AU size is the disk extent size in Mb
  echo "Creating ASM DATA disk..."
  asmca -silent -createDiskGroup -diskGroupName DATA -disk '/dev/sdb' -redundancy EXTERNAL -au_size 4 -compatible.asm '11.2.0.0.0'\
   -compatible.rdbms '11.2.0.0.0' -compatible.advm '11.2.0.0.0'

  echo "Creating ASM FRA disk..."
  asmca -silent -createDiskGroup -diskGroupName FRA -disk '/dev/sdc' -redundancy EXTERNAL -au_size 4 -compatible.asm '11.2.0.0.0'\
   -compatible.rdbms '11.2.0.0.0' -compatible.advm '11.2.0.0.0'
else
  echo "Skipping ASMCA."
fi


# Configure disks to use ASMFD
# https://docs.oracle.com/database/121/OSTMG/GUID-06B3337C-07A3-4B3F-B6CD-04F2916C11F6.htm

# ./runInstaller for db software
# Saved responsefile in /vagrant for command line scripting

# dbca to create db

# netca required?
