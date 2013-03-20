#!/bin/bash

git pull origin master
git submodule sync
git submodule init
git submodule update
git submodule foreach git checkout master
git submodule foreach git pull origin master
