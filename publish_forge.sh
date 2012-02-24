#!/bin/bash
work_dir=/tmp/

showhelp () {
cat << EOF

This script publishes a module on the Puppet forge. You must provide the module name, the forge account and its password. You should have already created, on the Forge, a module, under your account, with the same name.

Example:
$0 -m module_name -u forge_user -p forge_password -n "release_notes"

EOF
}


while [ $# -gt 0 ]; do
  case "$1" in
    -m)
      module=$2
      shift 2 ;;
    -u)
      user=$2
      shift 2 ;;
    -p)
      password=$2
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
if [ ! $user ] ; then
  echo "Insert the PuppetForge user name"
  read user
fi

if [ ! $password ] ; then
  echo "Insert the PuppetForge password"
  read password
fi

if [ ! $notes ] ; then
  echo "Write some release notes, then enter return"
  read notes
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

saved_tgz=$work_dir/$module.tgz
tar --exclude-vcs -czvf $saved_tgz $module

curl -c $work_dir/cook -F "user_password=$password" -F "user_username=$user" -F "user_submit=Sign in" http://forge.puppetlabs.com/users/sign_in
curl -b  $work_dir/cook -F "release_file=@$saved_tgz" -F "release_version=$version" -F "release_notes=$notes" -F "release_submit=Add release" http://forge.puppetlabs.com/users/$user/modules/$module/releases/new
