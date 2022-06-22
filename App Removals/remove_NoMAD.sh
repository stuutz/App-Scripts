#!/bin/bash

user=$(echo "show State:/Users/ConsoleUser" | scutil | awk '/Name :/ && ! /loginwindow/ {print $3}')

if [ -d /Applications/NoMAD.app ]; then

	echo "NoMAD Found"

	launchctl unload /Library/LaunchAgents/com.trusourcelabs.NoMAD.plist 
	pkill -9 "NoMAD"
	killall "NoMAD"
	kdestroy

	sleep 3

	rm -rf /Applications/NoMAD.app
	rm -rf /Library/Scripts/ChangePassword.sh
	rm -rf /Users/$user/Library/LaunchAgents/com.trusourcelabs.NoMAD.plist
	rm -rf /Library/LaunchAgents/com.trusourcelabs.NoMAD.plist
	security delete-generic-password -l "NoMAD"

else

	echo "NoMAD not installed"

fi