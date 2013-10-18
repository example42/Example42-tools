#!/bin/bash

collection=$(basename `pwd`)
case "$collection" in
  puppet-modules-nextgen) $suggestedbranch='2.x' ;;
  puppet-modules-stdmod) $suggestedbranch='3.x' ;;
  puppet-modules) $suggestedbranch='master' ;;
  *) $suggestedbranch='master' ;;
esac

branch={$1:-$suggestedbranch}

git pull origin master
git submodule sync
git submodule init
git submodule update
git submodule foreach git checkout $branch
git submodule foreach git pull origin $branch
