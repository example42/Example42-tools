#!/bin/bash
work_dir=/tmp/

showhelp () {
cat << EOF

This script publishes a module on the Puppet forge. It uses Puppet Blacksmith https://github.com/maestrodev/puppet-blacksmith for this task.
Refer to online documentation to see how to use and configure it.

Example:
$0 [-m module_name] [-f true] [-b true]

EOF
}

force=false
bump=true
while [ $# -gt 0 ]; do
  case "$1" in
    -m)
      module=$2
      shift 2 ;;
    -f)
      force=$2
      shift 2 ;;
    -b)
      bump=$2
      shift 2 ;;   
  esac
done

if [ $module ] ; then
  cd $module
fi

if [ ! -f manifests/init.pp ] ; then
  echo "I don't find manifests/init.pp "
  echo "Run this script from a module directory or specify -m modulename"
  showhelp
  exit 1
fi

if [ $bump == 'true' ] ; then
  pwd
  rake spec
  rake lint
fi

if [ $force != 'true' ] ; then
  read -p "Do you want to continue and push the module to the Forge? (Y/n) " answer
  answer=${answer:-y}
  if [ $answer != 'y' ] ; then
    exit 1
  fi
fi

rake -f ../Example42-tools/Rakefile_blacksmith module:bump
rake -f ../Example42-tools/Rakefile_blacksmith  module:tag
cp Modulefile /tmp/Modulefile.tmp
grep -Ev 'example42/(monitor|firewall)' /tmp/Modulefile.tmp > Modulefile
rake -f ../Example42-tools/Rakefile_blacksmith  module:push
mv /tmp/Modulefile.tmp Modulefile
git commit -a -m "Release updated and published to the Forge"

