#!/bin/sh

########################################################################################
# Note :
# (1) Ensure credentials.xml has populated mobilefoundationUrl & mobilefoundationPassword
# (2) Ensure mobile foundation server (mobilefoundationUrl) is up and running
########################################################################################

if [ "$1" == "" ]
then
    echo "Enter the package name (refer AndroidManifest.xml)"
    exit 1
fi

mobilefoundationPassword=$(awk -F '[<>]' '/mobilefoundationPassword/{print $3}' $(pwd)/app/src/main/res/values/credentials.xml)
mobilefoundationUrl=$(awk -F '[<>]' '/mobilefoundationUrl/{print $3}' $(pwd)/app/src/main/res/values/credentials.xml)

OPERATION="Register Application"

registerJson1='{"applicationKey": {"packageName": "'
registerJson2='","version": "1.0","clientPlatform":"android"},"mandatoryScope":"appAuthenticity","securityCheckConfigurations": {"appAuthenticity":{"expirationSec": "1200"}}}'
registerJson=$registerJson1$1$registerJson2

HTTP_STATUS=$( curl -s -o /dev/null -w '%{http_code}' -X POST -u admin:$mobilefoundationPassword -H "Content-Type: application/json" -d "$registerJson" "$mobilefoundationUrl/mfpadmin/management-apis/2.0/runtimes/mfp/applications")

if [ "$HTTP_STATUS" == "200" ]
then
    echo "SUCCESS: $OPERATION"
else
  echo "FAILED: $OPERATION"
  echo $HTTP_STATUS
  exit 1
fi