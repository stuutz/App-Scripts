#!/bin/sh

####################################################################################################
#
# CREATED BY
#
#   Brian Stutzman
#
# DESCRIPTION
#
#	Type: POLICY
#
#	Script assists with the installation of Adobe Acrobat update. 
#
# VERSION
#
#	- 1.0
#
# CHANGE HISTORY
#
# 	- Created script - 3/3/2022 (1.0)
#
####################################################################################################


##################################################################
## script variables
##################################################################

appPolicyID="$4"
appLatestVers="$5"
jamfHelper="/Library/Application Support/JAMF/bin/jamfHelper.app/Contents/MacOS/jamfHelper"
appPath="/Applications/Adobe Acrobat DC/Adobe Acrobat.app"
icon="$appPath/Contents/Resources/ACP_App.icns"
appInstalledVers=$(/usr/bin/defaults read /Applications/Adobe\ Acrobat\ DC/Adobe\ Acrobat.app/Contents/Info.plist CFBundleShortVersionString)

##################################################################
## script functions
##################################################################

function appStatus () 
{
    if [ -d "$appPath" ]; then
    
		echo "Script result: Acrobat found"
        

        "$jamfHelper" -windowType "hud" -title "Adobe Acrobat Update" -description "Mandatory Acrobat Update

Installed:  $appInstalledVers
       New:  $appLatestVers

Close Adobe apps and install?" -icon "$icon" -button1 "YES" -defaultButton 0 -lockHUD
		
		echo "Script result: Installing Acrobat update"

		# Kill the app process
		pkill -9 "Adobe*"
		pkill -9 "Creative Cloud"

		# caffinate the update process
		caffeinate -d -i -m -u &
		caffeinatepid=$!

		# display jamfHelper message
		"$jamfHelper" -windowType "hud" -title "Adobe Acrobat Update" -description "Updates are downloading & installing.  Please keep all Adobe apps closed.

Window will close when finished." -icon "$icon" -lockHUD > /dev/null 2>&1 &

		jamf policy -id $appPolicyID
            
		disableUpdates
            
		killjamfHelper

	else

		echo "Script result: Acrobat NOT found"
        
        exit 0
        
    fi
}

function killjamfHelper ()
{
	# kill jamfhelper
	killall jamfHelper > /dev/null 2>&1
	
	# kill the caffinate process
	kill "$caffeinatepid"
}

function disableUpdates ()
{
	
    if [ -d "$appPath/Contents/Plugins/Updater.acroplugin.old" ]; then
    
    	echo "Script result: Updater plugin already disabled"
    
    else
    
    	mv "$appPath/Contents/Plugins/Updater.acroplugin" "$appPath/Contents/Plugins/Updater.acroplugin.old"

		echo "Script result: Disabled updater plugin"

	fi
}

##################################################################
## main script
##################################################################
echo ""
echo "Script result: Started - $(/bin/date)"
appStatus
echo "Script result: Finished - $(/bin/date)"

exit 0