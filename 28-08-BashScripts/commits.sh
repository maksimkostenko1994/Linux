#!/bin/bash

for run in {1..10}
do
  # shellcheck disable=SC2006
  now=`date`
  git add .
  git commit -m "commit $run"
  git push --set-upstream origin 28-08-BashScripts
  echo "Commit number $run. Made - $now"
done

# my comment
