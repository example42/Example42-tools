#!/bin/bash
work_dir=/tmp/

showhelp () {
cat << EOF

This script tags, checks and packages a module to be published on the Forge. You should have already created, on the Forge, a module, under your account, with the same name.

Example:
$0 -m module_name -v "version"

EOF
}


while [ $# -gt 0 ]; do
  case "$1" in
    -m)
      module=$2
      shift 2 ;;
    -t)
      tag=$2
      shift 2 ;;
    -n)
      notes=$2
      shift 2 ;;
    -v)
      version=$2
      shift 2 ;;
  esac
done

if [ ! $module ] ; then
  echo "Insert the module name"
  read module
fi

if [ ! -f $module/manifests/init.pp ] ; then
  echo "I don't find $module/manifests/init.pp "
  echo "Run this script from the base modules directory and specify a valid module name"
  showhelp
  exit 1
fi

version=$(grep version $module/Modulefile | cut -d "'" -f 2)

if [ ! $version ] ; then
  echo "Write the release version"
  read version
fi

cd $module
../Example42-tools/check-module.sh

echo
echo
cd ..
puppet module build $module

echo
echo
echo "Tagging module with version $version"
cd $module
git tag $version
