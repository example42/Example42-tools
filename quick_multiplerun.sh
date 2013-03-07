#!/bin/bash

echo 'Quick command to run multiple commands on multiple modules directories'
echo 'Do not run if you dont know what it does'
echo 'Edit the script directly to enable it, customize commands to run and modules list'

# Comment below to activate script
exit 1

# Define the modules list and assign it to the $modules variable
modules=$(cat /tmp/modules-list)

# Sample set of commands to run for each module
run_commands () {
  cp Example42-templates/standard42/.travis.yml $1/
  cp Example42-templates/standard42/.gemfile $1/
  sed "s/standard42/$1/" Example42-templates/standard42/.fixtures.yml > $1/.fixtures.yml
  cp Example42-templates/standard42/Rakefile $1/
  cp Example42-templates/standard42/spec/spec_helper.rb $1/spec/
  cd $1
  git add .travis.yml .gemfile .fixtures.yml Rakefile spec/spec_helper.rb
  git commit -m "Enabling Travis integration"
  git push git@github.com:example42/puppet-$1.git master
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
