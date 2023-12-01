#!/bin/bash

# Do not proceed when something fails in the script
set -e

# Allow to run alias inside script
shopt -s expand_aliases

alias run="sudo docker container run --rm -v ${PWD}/application-code/:/app -w /app node:16.18.0"
export VERSION=`run node -p "require('./package.json').version"`


deploy()
{
    HOST_IP=$1
    HOST_PASSWORD=$2
    DEPLOY_FOLDER=$3

echo "---------------------------------------> Deploying Application..."

#sshpass -p$HOST_PASSWORD ssh -o StrictHostKeyChecking=no pgwadm@$HOST_IP <<DEPLOY
#SSH Pass for Test Env
sudo sshpass -p 'D\9bvh>H)][=9-W' ssh -v -o StrictHostKeyChecking=no pmtoradm@$HOST_IP bash <<DEPLOY

curl -H "Authorization: Bearer $ACCESS_TOKEN" -LO "https://globe.jfrog.io/artifactory/payment-service/web-portal-fe/$BRANCH_NAME-$APP-v$VERSION.tar.gz"

echo "---------------------------------------> Unpacking $BRANCH_NAME-$APP-v$VERSION.tar.gz"
tar -xzf $BRANCH_NAME-$APP-v$VERSION.tar.gz
echo "checking directory ..."
ls -l

cp -R application-code/build/* $DEPLOY_FOLDER
ls -la $DEPLOY_FOLDER
chmod -R 755 $DEPLOY_FOLDER

echo "---------------------------------------> Performing cleanup..."
rm -rf $BRANCH_NAME-$APP-v$VERSION.tar.gz
rm -rf application-code*

echo "---------------------------------------> Cleanup done..."

echo "---------------------------------------> Done..."
exit
DEPLOY
}

#chmod -R 755 /appl/web-portal-api-r1/

if [[ $BRANCH_NAME == "develop" ]]
then
    echo "deployment to $BRANCH_NAME done ..."
    deploy "10.69.175.123" $PS_DEV_KEY  "/var/www/pgwcmsdev.globetel.com"

elif [[ $BRANCH_NAME == "feature-develop" ]]
then
    echo "deployment to $BRANCH_NAME done ..."
    deploy "10.69.175.123" $PS_DEV_KEY  "/var/www/pgwcmsdev.globetel.com"    

elif [[ $BRANCH_NAME == "testbed" ]]
then
    echo "deployment to $BRANCH_NAME done ..."
    deploy "10.69.175.123" $PS_STAGING_KEY "/var/www/pgwcmstest.globetel.com"

elif [[ $BRANCH_NAME == "feature-testbed" ]]
then
    echo "deployment to $BRANCH_NAME done ..."
    deploy "10.69.175.123" $PS_STAGING_KEY "/var/www/pgwcmstest.globetel.com"

elif [[ $BRANCH_NAME == "master" ]]
then
    deploy "10.69.101.26" $PS_PROD_WEB_FE_KEY "/var/www/pgwcms.globetel.com"
    echo "deployment to $BRANCH_NAME done ..."

elif [[ $BRANCH_NAME == "pre-prod" ]]
then
    echo "deployment to $BRANCH_NAME done ..."
    deploy "10.64.2.56" $PS_PREPRD_WEB_FE_KEY "/var/www/pgwcmspreprod.globetel.com"

elif [[ $BRANCH_NAME == "feature-preprod" ]]
then
    echo "deployment to $BRANCH_NAME done ..."
    deploy "10.64.2.56" $PS_PREPRD_WEB_FE_KEY "/var/www/pgwcmspreprod.globetel.com"

else

    echo "---------------------------------------> No environment to deploy..."
fi