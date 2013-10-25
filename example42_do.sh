#!/bin/bash

# Do things on example42 only modules
if [ -f example42only_list.txt ] ; then 
  echo "Found example42only_list.txt"
else
  echo "example42only_list.txt not found. Exiting."
  exit 1
fi

COMMAND=${*:-"echo Provide a command to execute on all the modules in example42only_list.txt"}
MODULELIST=$(cat example42only_list.txt)

for a in $MODULELIST; do
  echo
  echo $a
  cd $a
  $COMMAND
  cd ..
done
