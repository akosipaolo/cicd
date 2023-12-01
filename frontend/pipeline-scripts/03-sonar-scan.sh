#!/bin/bash

# Do not proceed when something fails in in the script
set -eu

# Allow alias to work on a bash script
shopt -s expand_aliases

echo "-------------------> Starting sonar scan on application-code..."

alias run="sudo docker container run --rm -v ${PWD}/application-code/:/app -w /app node:lts"
echo "-------------------> Running sonar scan ..."

export VERSION=`run node -p "require('./package.json').version"`


sudo docker run \
    --rm \
    -e SONAR_HOST_URL="https://devops.globe.com.ph/sonar" \
    -e SONAR_LOGIN=$SONAR_LOGIN \
    -v ${PWD}/application-code/:/app \
    -w /app \
    sonarsource/sonar-scanner-cli \
    -D sonar.projectVersion=$VERSION \
    -D sonar.projectKey=$SONAR_PROJECT_KEY \
    -D sonar.projectName=$SONAR_PROJECT_KEY \
    -D sonar.inclusions=src/**/* \
    -D sonar.qualitygate.wait=false \
    -D sonar.qualitygate.timeout=300

sleep 3

echo "-------------------> Sonarscan Done ..."
