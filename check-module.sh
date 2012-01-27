#!/bin/bash
if [ ! -f manifests/init.pp ] ; then
    echo "I don't find manifests/init.pp "
    echo "Run this script from a module base directory"
    exit 1
fi

echo "############################"
echo "### Executing rake tasks ###"
echo "############################"
rake

echo "############################"
echo "### Executing puppet doc ###"
echo "############################"
for file in $( find . | grep "\.pp$" ) ; do
    echo "### $file"
    puppet doc $file
done

echo "############################"
echo "### Executing puppetlint ###"
echo "############################"
for file in $( find . | grep "\.pp$" ) ; do
    echo "### $file"
    puppet-lint $file
done

