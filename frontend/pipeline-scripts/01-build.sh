#!/bin/bash

# Do not proceed when something fails in in the script
set -eu

# Allow alias to work on a bash script
shopt -s expand_aliases

alias run="sudo docker container run --rm -v ${PWD}/application-code/:/app -w /app node:16.18.0"
echo "-------------------> Initializing npm install ..."
run npm install -v

run node -v
run npm i react-scripts@2.1.8

# For debugging only
# echo ""
# cat $PRODUCTION_REACT_ENV
# /echo ""

echo "-------------------> Done ..."