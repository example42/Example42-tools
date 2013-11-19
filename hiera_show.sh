#!/bin/bash

HKEY=$1

if [ $2 ]
then 
  NODE=$2
else
  NODE='allnodes'
fi

if [ -d /var/opt/lib/pe-puppet/yaml/facts ]
then    
  FACTSDIR=/var/opt/lib/pe-puppet/yaml/facts
elif [ -d /var/lib/puppet/yaml/facts ]
then
  FACTSDIR=/var/lib/puppet/yaml/facts
else
  echo "Facts dir not found"
  exit 1
fi

showhelp () {
cat << EOF

This script shows the hiera value for a given key on a given or all nodes.
It is intended to be run on the puppetmaster where it exists a $FACTSDIR directory.
If no nodename is specified, it returns the content of the key for all the known nodes.

Usage:
$0 key [nodename]

EOF
}

if [ ! $1 ] ; then
    showhelp
    exit 1
fi

if [ "x$NODE" == 'xallnodes' ] 
then
  for file in $(ls $FACTSDIR) ; do
    filenode=${file%.yaml}
    echo -n "$filenode : " ; hiera $HKEY --yaml "${FACTSDIR}/${file}"
  done
else
  hiera $HKEY --yaml "${FACTSDIR}/${NODE}.yaml"
fi
