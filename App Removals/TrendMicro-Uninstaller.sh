#!/bin/bash

## Created by: Brian Stutzman
## Date: 2/23/18
#
# Application Install Notes:
#
# Trend Micro Uninstaller script
#
# Trend Micro Worry Free version 2.0.1287
#


## Set script variables
uninstallFile="/var/tmp/TrendMicro/tmsmuninstall.mpkg";
appPath="/Library/Application Support/TrendMicro/TmccMac/UIMgmt.app";

## Check to see if Trend Micro app is installed, if so uninstall
if [ -d "$appPath" ]; then
  echo "Trend Micro app found...uninstalling"
  ## Quit Trend Micro app
  osascript -e 'tell application "UIMgmt.app" to quit'
  osascript -e 'tell application "Trend Micro Security.app" to quit'
  ## Run uninstaller
  installer -pkg "$uninstallFile" -target /;
else
  echo "Trend Micro app not found...exiting script"
  exit 0
fi;

sleep 2

## Cleanup files
rm -R "$uninstallFile"


exit 0
