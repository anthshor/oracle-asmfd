#!/bin/bash

# define the global variables
export PASSWORD="Password1#"
export VERSION="12.1.0.2"


# Proxy
[ -f /proxy/.proxy.env ] && source /proxy/.proxy.env

if [ -f /u01/app/oracle/product/${VERSION}/dbhome_1/root.sh.run ]; then
  echo "INFO: /u01/app/oracle/product/${VERSION}/dbhome_1/root.sh already run"
else
  /u01/app/oracle/product/${VERSION}/dbhome_1/root.sh
  touch /u01/app/oracle/product/${VERSION}/dbhome_1/root.sh.run
fi

