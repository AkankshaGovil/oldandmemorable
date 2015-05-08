#!/bin/sh

if [ $# -lt 2 ] ; then
   echo -e "Usage ./importcert.sh <certificate with path if not in current dir> <alias>\n"
   exit 1
fi

CERTFILE=$1
ALIAS=$2

JRE_HOME=/opt/nxtn/jdk
export JRE_HOME
$JRE_HOME/bin/keytool -keystore $JRE_HOME/lib/security/cacerts  -delete -v -alias $ALIAS -storepass changeit >/dev/null 2>&1 
$JRE_HOME/bin/keytool -keystore $JRE_HOME/lib/security/cacerts -alias $ALIAS -import -v -noprompt -trustcacerts -file $CERTFILE -storepass changeit >/dev/null 2>&1

