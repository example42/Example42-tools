#!/bin/bash

collection=$(basename `pwd`)
case "$collection" in
  puppet-modules-nextgen) suggestedbranch='2.x' ;;
  puppet-modules-stdmod) suggestedbranch='3.x' ;;
  puppet-modules) suggestedbranch='master' ;;
  *) suggestedbranch='master' ;;
esac

branch=${1:-$suggestedbranch}
echo "Using branch: $branch"

git pull origin master
git submodule sync
git submodule init
git submodule update

if [ "x$branch" == "xmaster" ] ; then
  git submodule foreach git checkout $branch
  git submodule foreach git pull
else
  Example42-tools/example42_do.sh git checkout $branch
  Example42-tools/example42_do.sh git pull origin $branch
fi

if [ "x$branch" == "x2.x" ] ; then
  Example42-tools/example42_do.sh ../Example42-tools/mergemaster.sh
fi

