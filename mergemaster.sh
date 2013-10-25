#/bin/bash
git checkout master
git pull
grep "version '2" Modulefile
if [ "x$?" == "x0" ] ; then
  git checkout 2.x
  git merge master
  git push --set-upstream origin 2.x
else
  grep "version" Modulefile
  echo "Nothing to do"
  git checkout 2.x
fi
