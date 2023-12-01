#!/bin/bash


# Do not proceed when something fails in in the script
set -e


echo "Post Deployment scripts here..."

if [[ $BRANCH_NAME == "testbed" ]]
then
  echo "Perform Functional Test..."
  python $PWD/pipeline-scripts/functional-test.py
  echo '------------------------- END OF Functional Test ---------------------------------------' 
  sleep 3
  echo "Performing Non Functional Test..."
  echo "Done..."
  sleep 3
  echo "Perform UAT..."
  echo "Done..."
elif [[ $BRANCH_NAME == "feature" ]]
then
  echo "Perform Performance Test..."
  echo "Done..."
fi

sleep 3


echo "Done..."