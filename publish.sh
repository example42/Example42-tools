#!/bin/bash
work_dir=/tmp/puppet-publish
echo_title () {
  echo
  echo
  echo "###########################################"
  echo "$1"
  echo
}

showhelp () {
cat << EOF

This script tags and publishes a module:
- On the Puppet forge, with Maestrodev's Puppet Blacksmith https://github.com/maestrodev/puppet-blacksmith
- On GitHub using local credentials

By default tests are done and a new tag is created
Example:
$0 [-m module_name] [-f|--force] [-nf|--no-force] [-b|--bump] [-nb|--no-bump] [-t|--tag] [-nt|--no-tag] [-fx|--fix] [-nofx|--no-fix] [-c|--check] [-nc|--no-check]

EOF
}

force=false
bump=true
tag=true
fix=true
check=true
forge=true
github=true

while [ $# -gt 0 ]; do
  case "$1" in
    -m)
      module=$2
      shift 2 ;;
    -f|--force)
      force=true
      shift ;;
    -nf|--no-force)
      force=false
      shift ;;
    -b|--bump)
      bump=true
      shift ;;
    -nb|--no-bump)
      bump=false
      shift ;;
    -t|--tag)
      tag=true
      shift ;;
    -nt|--no-tag)
      tag=false
      shift ;;
    -fx|--fix)
      fix=true
      shift ;;
    -nfx|--no-fix)
      fix=false
      shift ;;
    -c|--check)
      check=true
      shift ;;
    -nc|--no-check)
      check=false
      shift ;;
  esac
done

if [ $module ] ; then
  cd $module
fi

if [ ! -f manifests/init.pp ] ; then
  echo_title "SOMETHING WRONG"
  echo "I don't find manifests/init.pp "
  echo "Run this script from a module directory or specify -m modulename"
  showhelp
  exit 1
fi

if [ $check == 'true' ] ; then
  pwd
  rake -f ../Example42-tools/Rakefile_blacksmith module:clean
  rake spec_clean

  echo_title "LINT TESTS"
  rake lint
  echo_title "SPEC TESTS"
  rake spec
fi

if [ $force != 'true' ] ; then
  echo_title "PROCEED? "
  read -p "Do you want to continue with tagging and publishing? (Y/n) " answer
  answer=${answer:-y}
  if [ $answer != 'y' ] ; then
    echo "OK, try later!"
    exit 1
  fi
fi

if [ $bump == 'true' ] ; then
  echo_title "VERSION BUMP"
  rake -f ../Example42-tools/Rakefile_blacksmith module:bump || exit 1
fi

if [ $tag == 'true' ] ; then
  echo_title "MODULE TAG"
  rake -f ../Example42-tools/Rakefile_blacksmith module:tag || exit 1
  git commit -a -m "Release tagged and published to the Forge"
fi

if [ $forge == 'true' ] ; then
  echo_title "PUBLISH TO THE FORGE"
  if [ $fix == 'true' ] ; then
    [ -d $work_dir ] || mkdir -p $work_dir
    cp Modulefile $work_dir/Modulefile.tmp
    grep -Ev 'example42/(monitor|firewall)' $work_dir/Modulefile.tmp > Modulefile
  fi

  rake -f ../Example42-tools/Rakefile_blacksmith module:push || exit 1

  if [ $fix == 'true' ] ; then
    mv $work_dir/Modulefile.tmp Modulefile
  fi
fi

if [ $github == 'true' ] ; then
  echo_title "PUBLISH TO GITHUB"
  git push -u origin master --tags
fi
