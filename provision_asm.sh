#!/bin/bash

# define the global variables
export STAGE="/u01/stage"
export SOFTWARE="/u01/software"
export PASSWORD="Password1#"
export VERSION="12.1.0.2"


# Proxy
[ -f /proxy/.proxy.env ] && source /proxy/.proxy.env

# Start NTP daemon
service ntpd status || service ntpd start
chkconfig ntpd on

for disk in /dev/sd[b-z]; do
  [ -b $disk ] && chown grid:asmadmin $disk
done

/u01/app/oraInventory/orainstRoot.sh
if [ -f /u01/app/${VERSION}/grid/root.sh.run ]; then
  echo "INFO: /u01/app/${VERSION}/grid/root.sh already run"
else
  /u01/app/${VERSION}/grid/root.sh
  touch /u01/app/${VERSION}/grid/root.sh.run
fi

export ORACLE_HOME=/u01/app/12.1.0.2/grid

# Configuring Grid for standalone
$ORACLE_HOME/bin/crsctl config has 2>/dev/null
if [ $? -ne 0 ]; then
  echo "Configuring Grid"
  /u01/app/12.1.0.2/grid/perl/bin/perl -I/u01/app/12.1.0.2/grid/perl/lib -I/u01/app/12.1.0.2/grid/crs/install /u01/app/12.1.0.2/grid/crs/install/roothas.pl
else
  echo "Grid already configured, skipping..."
fi

# Run asmca
# Create DATA and FRA
# asmca -h

export ORACLE_SID=+ASM

sudo -E -H -u grid $ORACLE_HOME/bin/asmcmd lsdg DATA
if [ $? -ne 0 ]; then
  echo "Configuring ASM and creating DATA disk group..."
  sudo -E -H -u grid /u01/app/12.1.0.2/grid/bin/asmca -silent -configureASM -sysAsmPassword oracle12 -asmsnmpPassword oracle12 -diskGroupName DATA \
  -disk '/dev/sdb' -redundancy EXTERNAL
else
  echo "DATA disk already created, skipping..."
fi
  
#this need to be run onces, what can be used to know if this was run?  
# AU size is the disk extent size in Mb - leave default
sudo -E -H -u grid $ORACLE_HOME/bin/asmcmd lsdg FRA
if [ $? -ne 0 ]; then
  echo "Creating ASM FRA disk..."
  sudo -E -H -u grid /u01/app/12.1.0.2/grid/bin/asmca -silent -createDiskGroup -diskGroupName FRA -disk '/dev/sdc' -redundancy EXTERNAL 
else
  echo "FRA disk already created, skipping..."
fi

# Configure disks to use ASMFD
# https://docs.oracle.com/database/121/OSTMG/GUID-06B3337C-07A3-4B3F-B6CD-04F2916C11F6.htm
if [ `sudo -E -H -u grid $ORACLE_HOME/bin/asmcmd lsdsk | grep 'AFD:' | wc  -l` -eq 0 ]; then
  echo "Migrating to asmfd"
  sudo -E -H -u grid $ORACLE_HOME/bin/srvctl stop asm -f
  sudo -E -H -u grid $ORACLE_HOME/bin/srvctl stop asm -f
  $ORACLE_HOME/bin/crsctl stop has
  $ORACLE_HOME/bin/asmcmd afd_configure
  $ORACLE_HOME/bin/asmcmd afd_state
  $ORACLE_HOME/bin/crsctl start has
  sudo -E -H -u grid $ORACLE_HOME/bin/srvctl stop diskgroup -diskgroup data -f
  sudo -E -H -u grid $ORACLE_HOME/bin/srvctl stop diskgroup -diskgroup fra -f
  sudo -E -H -u grid $ORACLE_HOME/bin/asmcmd afd_label ASMDISK1 /dev/sdb --migrate
  sudo -E -H -u grid $ORACLE_HOME/bin/asmcmd afd_label ASMDISK2 /dev/sdc --migrate
  sudo -E -H -u grid $ORACLE_HOME/bin/asmcmd afd_scan
  sudo -E -H -u grid $ORACLE_HOME/bin/srvctl start diskgroup -diskgroup data
  sudo -E -H -u grid $ORACLE_HOME/bin/srvctl start diskgroup -diskgroup fra
  sudo -E -H -u grid $ORACLE_HOME/bin/asmcmd lsdg
  sudo -E -H -u grid $ORACLE_HOME/bin/asmcmd lsdsk
else
  echo "Already migrated to asmfd, skipping..."
fi

# ./runInstaller for db software
# Saved responsefile in /vagrant for command line scripting

# dbca to create db

# netca required?
