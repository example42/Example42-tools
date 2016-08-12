#!/bin/bash

echo 'Quick command to run multiple commands on multiple modules directories'
echo 'Do not run if you dont know what it does'
echo 'Edit the script directly to enable it, customize commands to run and modules list'

# Comment below to activate script
# exit 1

# Define the modules list and assign it to the $modules variable
modules=$(cat /tmp/modules-list)

# Sample set of commands to run for each module
run_commands () {
  cd $1
  cp -a ../auth/.github .
  git add .github
  git commit -m "Added github files"
  git push git@github.com:/example42/puppet-$1 master
  cd ..
}

run_rdoc2md () {
  cd $1
  sed 's/^==/##/;s/^=/#/' README.rdoc > README.md
  git rm README.rdoc
  git add README.md
  git commit -m "Automatic README conversion from rdoc to md"
  git push git@github.com:example42/puppet-$1.git master
  cd ..
}

# Sample set of command to run for git commit 
run_commit  () {
  cd $1
  # git commit -m 'Updates'
  # git push https://github.com/example42/puppet-$1 master
  cd ..
  
}

# Define what commands set to execute

for m in $modules ; do
  echo ; echo "Working on $m"
  run_commands $m
done 
