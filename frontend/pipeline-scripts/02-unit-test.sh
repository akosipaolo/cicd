#!/bin/bash

# Do not proceed when something fails in in the script
set -eu

# Allow alias to work on a bash script
shopt -s expand_aliases

alias run="sudo docker container run --rm -e CI=true -v ${PWD}/application-code/:/app -w /app node:lts"

echo "-------------------> Unit test ..."
run npm run test
sleep 3
echo "-------------------> Done..."