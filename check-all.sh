#!/bin/bash
if [ $1 ] ; then
  path=$1
else
  path='.'
fi

echo "# CHECKING MANIFESTS
for manifest in `find $path -name '*.pp'` ; do
  puppet parser validate $manifest && echo "${manifest} Syntax OK" || echo "${manifest} Syntax ERROR!"
done

#echo "# CHECKING TEMPLATES
#for template in `find $path -name '*.erb'` ; do
#  erb -x -T - $template && echo "${template} Syntax OK" || echo "${template} Syntax ERROR!"
#done
