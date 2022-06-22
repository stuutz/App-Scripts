#!/bin/bash


## Set variable for current console user
user=`ls -l /dev/console | awk '{print $3}'`


## Close SfB app
    osascript -e 'tell application "Skype for Business" to quit'

sleep 3

########################################################################
## Do a completed uninstall of Skype for Business
########################################################################

echo "Removing SfB Application"
rm -rf /Applications/Skype\ for\ Business.app

echo "Removing Containers file"
rm -rf /Users/$user/Library/Containers/com.microsoft.SkypeForBusiness

echo "Removing Log file"
rm -rf /Users/$user/Library/Logs/LwaTracing

echo "Removing Saved Application State file"
rm -rf /Users/$user/Saved\ Application\ State/com.microsoft.SkypeForBusiness.savedState

echo "Removing Preference plist file"
rm -rf /Users/$user/Preferences/com.microsoft.SkypeForBusiness.plist

echo "Removing Skype Meeting plugin"
rm -rf /Library/Internet\ Plug-Ins/MeetingJoinPlugin.plugin

echo "Removing Application Scripts folder"
rm -rf /Users/$user/Library/Application\ Scripts/com.microsoft.SkypeForBusiness

echo "Removing SfB keychain entry"
security delete-generic-password -l "Skype for Business"

########################################################################

echo "Successfully removed all files."


exit 0
