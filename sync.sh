#!/bin/bash

git pull origin master
git submodule sync
git sub module update
git submodule foreach git pull origin master
