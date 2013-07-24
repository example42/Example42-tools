#!/bin/bash

showhelp () {
cat << EOF

This script creates a new module based on an existing module or module template.
Run it from Example42 Puppet modules base dir.

Usage:
$0 -t standard42
Create a module (name will be prompted) based on the template in Example42-templates/standard42

$0 -m mysql
Create a module cloned from the existing module mysql

$0 -t package42 -n vim
Create a module called vim based on Example42-templates/minimal42

EOF
}

while [ $# -gt 0 ]; do
  case "$1" in
  -t)
    template=$2
    shift 2 ;;
  -m)
    module=$2
    shift 2 ;;
  -n)
    name=$2
    shift 2 ;;
  esac
done

showhelp

clone_from_template() {
  if [ ! -f Example42-templates/$template/manifests/init.pp ] ; then
    echo "I don't find Example42-templates/$template/manifests/init.pp "
    echo "Run this script from the base modules directory and specify a valid source module template"
    echo "Available Templates are in Example42-templates:"
    ls -1 Example42-templates/
    exit 1
  fi

  OLDMODULE=Example42-templates/$template
  OLDMODULESTRING=$template

  clone
}

clone_from_module() {
  if [ ! -f $module/manifests/init.pp ] ; then
    echo "I don't find $module/manifests/init.pp "
    echo "Run this script from the base modules directory and specify a valid source module"
    exit 1
  fi

  OLDMODULE=$module
  OLDMODULESTRING=$module

  clone
}

function clone() {
  echo
  if [ x$name == 'x' ] ; then
    echo -n "Enter the name of the new module to create:"
    read NEWMODULE
  else
    NEWMODULE=$name
  fi
  
  if [ -f $NEWMODULE/manifests/init.pp ] ; then
    echo "Module $NEWMODULE already exists."
    echo "Move or delete it if you want to recreate it. Quitting."
    exit 1
  fi
  
  echo "COPYING MODULE"
  mkdir $NEWMODULE
  rsync -av --exclude=".git" --exclude "spec/fixtures" $OLDMODULE/ $NEWMODULE
  
  
  echo "RENAMING FILES"
  for file in $( find . -name $NEWMODULE | grep $OLDMODULESTRING ) ; do 
    newfile=`echo $file | sed "s/$OLDMODULESTRING/$NEWMODULE/g"`
    echo "$file => $newfile" ;  mv $file $newfile && echo "Renamed $file to $newfile"
  done
  
  echo "---------------------------------------------------"
  echo "CHANGING FILE CONTENTS"
  for file in $( grep -R $OLDMODULESTRING $NEWMODULE | cut -d ":" -f 1 | uniq ) ; do 
    # Detect OS
    if [ -f /mach_kernel ] ; then
      sed -i "" -e "s/$OLDMODULESTRING/$NEWMODULE/g" $file && echo "Changed $file"
    else
      sed -i "s/$OLDMODULESTRING/$NEWMODULE/g" $file && echo "Changed $file"
    fi
  
  done
  
  echo "Module $NEWMODULE created"
  echo "Start to edit $NEWMODULE/manifests/params.pp to customize it"

}

if [ "x$module" == "x" ] ; then
  clone_from_template
else
  clone_from_module
fi

