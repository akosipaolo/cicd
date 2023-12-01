#!/bin/bash

jq -version || sudo apt install jq zip -y

echo "files inside ${APPLICATION_DESTINATION_DIRECTORY}"
ls  

echo "zipping files..." 
zip -r "${APPLICATION_DESTINATION_DIRECTORY}.zip" ./${APPLICATION_DESTINATION_DIRECTORY} -x "*.git*"

echo "listing files..." 
ls -la

#echo "uploading zip file..." 
java -jar "./cast-aip-console-tools-cli/aip-console-tools-cli.jar" add -n ${CASTAIPCONSOLE_APPLICATION_NAME} --apikey="${CASTAIPCONSOLE_APIKEY}" -f "./${APPLICATION_DESTINATION_DIRECTORY}".zip --verbose=false -s ${CASTAIPCONSOLE_URL} --snapshot --no-clone

echo "Getting the Total Quality Index value"
var=$(curl --user "${CAST_API_USERNAME}:${CAST_API_PASSWORD}" --header "Content-Type: application/json" -H "Accept: application/json" --request GET "${CAST_TQI_URL}" | jq '.[] .applicationResults [] .result.grade')

echo "Total Quality Index value: $var"

if (( $(echo "$var >= ${CAST_TQI_BASELINE}" |bc -l) ))
then
    echo "Total Quality Index passed against baseline"
else
    echo "Total Quality Index falls below the baseline"
    exit 1
fi

echo "Done executing cast scan"