#!/bin/bash

# Do not proceed when something fails in the script
set -e

# Allow to run alias inside script
shopt -s expand_aliases

echo "---------------------------------------> Uploading to Artifact Repository..."



alias run="sudo docker container run --rm -v ${PWD}/application-code/:/app -w /app node:16.18.0"
export VERSION=`run node -p "require('./package.json').version"`
echo "Application version is $VERSION ..."

echo "Injecting environment variables ..."
if [[ $BRANCH_NAME == "develop" ]]
then
	cat $DEVELOPMENT_REACT_ENV > $PWD/application-code/.env

elif [[ $BRANCH_NAME == "feature-develop" ]]
then
	cat $DEVELOPMENT_REACT_ENV > $PWD/application-code/.env	

elif [[ $BRANCH_NAME == "testbed" ]]
then 
	cat $STAGING_REACT_ENV  >  $PWD/application-code/.env

elif [[ $BRANCH_NAME == "feature-testbed" ]]
then 
	cat $TEST_REACT_ENV  >  $PWD/application-code/.env

elif [[ $BRANCH_NAME == "pre-prod" ]]
then 
	cat $PREPROD_REACT_ENV >  $PWD/application-code/.env

elif [[ $BRANCH_NAME == "master" ]]
then 
	cat $PROD_REACT_ENV >  $PWD/application-code/.env	

fi

echo "---------------------------------------> Run NPM build..."
run npm run build

# Push image to Artifactory
echo "---------------------------------------> Uploading build files..."
ls -al
#tar -zcvf $BRANCH_NAME-$APP-v$VERSION.tar.gz -C $PWD/application-code.
tar -zcvf $BRANCH_NAME-$APP-v$VERSION.tar.gz --exclude='.git' application-code
curl -X PUT -H "Authorization: Bearer $ACCESS_TOKEN" "https://globe.jfrog.io/artifactory/payment-service/web-portal-fe/$BRANCH_NAME-$APP-v$VERSION.tar.gz" -T $BRANCH_NAME-$APP-v$VERSION.tar.gz

echo "---------------------------------------> Upload build artifact done..."
echo "---------------------------------------> Removing gzip file..."
rm -rf $BRANCH_NAME-$APP-v$VERSION.tar.gz
echo "---------------------------------------> Done..."