#!/bin/bash

git pull origin master
git submodule sync
git submodule update
git submodule foreach git pull origin master
