#!/bin/bash

showhelp () {
cat << EOF

This script creates a new module based on existing Example42 modules.
Run it from the directory that contains the "source" module (moduledir).

By default it uses the "foo" module as template.
Specify -t <source_module> to use a different template.
Example: $0 -t foo_webapp

EOF
}

template="foo"

while [ $# -gt 0 ]; do
  case "$1" in
  -t)
    template=$2
    shift 2 ;;
  esac
done

showhelp

if [ ! -f $template/manifests/init.pp ] ; then
  echo "I don't find $template/manifests/init.pp "
  echo "Run this script from the base modules directory and specify a valid source module template"
  exit 1
fi

OLDMODULE=$template
OLDMODULESTRING=$template
echo
echo "Source module template is $template "
echo -n "Enter the name of the new module based on $template: "
read NEWMODULE

if [ -f $NEWMODULE/manifests/init.pp ] ; then
  echo "Module $NEWMODULE already exists."
  echo "Move or delete it if you want to recreate it. Quitting."
  exit 1
fi

echo "COPYING MODULE"
mkdir $NEWMODULE
rsync -av --exclude=".git" $OLDMODULE/* $NEWMODULE/


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
