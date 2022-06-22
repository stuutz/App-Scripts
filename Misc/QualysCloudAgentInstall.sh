#!/bin/bash

qualysFile="/private/var/tmp/qualys-cloud-agent.x86_64.pkg";

installer -pkg "$qualysFile" -target /

if [[ -f /usr/local/qualys/cloud-agent/bin/qualys-cloud-agent.sh ]]; then
  /usr/local/qualys/cloud-agent/bin/qualys-cloud-agent.sh ActivationId=AID HERE CustomerId=CID HERE;
else
  /Applications/QualysCloudAgent.app/Contents/MacOS/qualys-cloud-agent.sh ActivationId=AID HERE CustomerId=CID HERE;
fi

rm "$qualysFile"

exit 0
