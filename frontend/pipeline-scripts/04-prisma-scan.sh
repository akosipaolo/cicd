#!/bin/bash

# Do not proceed when something fails in in the script
set -eu
sudo apt update
sudo apt install zip -y
export PRISMA_CONSOLE="https://asia-northeast1.cloud.twistlock.com/anz-3050922"
echo "Executing Prisma Script ..."
#shopt -s expand_aliases
#alias run="sudo docker container run --rm -v ${PWD}/application-code/:/app -w /app node:14.17"
export APP="ps-lambda"
#export VERSION=`run node -p "require('./package.json').version"`

#sudo zip ${APP}-v${VERSION}.zip application-code/*
#sudo chown ubuntu:1000 -R ${APP}-v${VERSION}.zip
#sudo chmod -R 722 ${APP}-v${VERSION}.zip

sudo zip ${APP}.zip application-code/*
sudo chown ubuntu:1000 -R ${APP}.zip
sudo chmod -R 722 ${APP}.zip

#sudo tar -czf $APP-v$VERSION.tar.gz application-code
#sudo chmod 777 $APP-v$VERSION.tar.gz

echo "APP: ${APP}"

#Download twistCLI plugin from Prisma Dashboard.
echo "---------- Installing TwistCLI ------------"
curl -k -u $PRISMA_USER:$PRISMA_PASS --output ./twistcli "${PRISMA_CONSOLE}/api/v1/util/twistcli"
chmod a+x ./twistcli
ls -la
echo "---------- Installation of TwistCLI : DONE ------------"

#Perform Prisma Scan.
echo "---------- Prisma Scan : Start ------------" 
./twistcli serverless scan --address $PRISMA_CONSOLE \
   -u $PRISMA_USER \
   -p $PRISMA_PASS \
   --details \
   --publish=TRUE \
   --include-js-dependencies ${APP}.zip
echo "---------- Prisma Scan : DONE ------------"