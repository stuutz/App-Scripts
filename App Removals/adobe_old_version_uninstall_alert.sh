#!/bin/bash


####################################################################################################
#
# CREATED BY
#
#   Brian Stutzman
#
# DESCRIPTION
#
#	This will alert the user of an older version of Adobe app installed.  Notify the user to remove
#	and install a newer version.  If the app is not running it will remove the app silently.
#
# VERSION
#
#	- 1.1
#
# CHANGE HISTORY
#
# 	- Created script - 2/19/20 (1.0)
# 	- Rewrote the script using functions, removed the recon commands - 9/16/21 (1.1)
#
####################################################################################################


##########################################################################################
# Script variables
##########################################################################################

jamfHelper="/Library/Application Support/JAMF/bin/jamfHelper.app/Contents/MacOS/jamfHelper"
issueicon="/System/Library/CoreServices/Problem Reporter.app/Contents/Resources/ProblemReporter.icns"
trashicon="/System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/FullTrashIcon.icns"

type="$4"					# Window Type (hud, utility, fs)
title="$5"					# Window Title
appName="$6"				# App Name
winDesc="$7"				# Window Description
appPath="$8"				# App Path (ex: /Applications/Adobe Illustrator 2020/Adobe Illustrator.app)
processName="$9"			# App Process Name (ex: Adobe Illustrator)
iconPath="${10}"			# Icon Path (ex: /Applications/Adobe\ Illustrator\ 2020/Adobe\ Illustrator.app/Contents/Resources/ai_cc_appicon.icns)
uninstallPolicyID="${11}"	# Policy ID of the uninstaller

##########################################################################################
# Script functions
##########################################################################################

function checkStatus ()
{

	echo ""
        
	# Check to see if app is installed
	if [ -d "$appPath" ]; then

		echo "Script result: $appName installed"
        
        checkProcess

	else

		echo "Script result: $appName not installed"
    
    	exit 0

	fi

}

function checkProcess ()
{

	# Check to see if app is running
    if pgrep "$processName"; then
    
		echo "Script result: $processName is currently running!"
        
        removeAppRunning

	else
    
		echo "Script result: $processName is not running"
        
        removeAppSilent

	fi

}

function removeAppRunning ()
{

    # Display jamfHelper message
	userChoice=$("$jamfHelper" -windowType "$type" -title "$title" -description "An old version of $appName has been detected on your machine.  This version can no longer be installed due to security vulnerabilities. 

Please uninstall this app and use the Adobe Creative Cloud app to install the latest version." -icon "$iconPath" -button1 "UNINSTALL" -defaultButton 0 -lockHUD)

	# Uninstall button is pressed
	if [ "$userChoice" == "0" ]; then

		echo "Script result: Attempting to uninstall $appName"

    	# Display jamfHelper message
    	"$jamfHelper" -windowType "$type" -description "All versions of $processName will be closed.  
    
SAVE ALL CURRENT WORK." -icon "$iconPath" -button1 "CONTINUE" -lockHUD

   		# Caffinate the update process
    	caffeinate -d -i -m -u &
    	caffeinatepid=$!

    	# Display jamfHelper message
    	"$jamfHelper" -windowType "$type" -description "Attempting to uninstall:
    
$appName" -icon "$iconPath" -lockHUD > /dev/null 2>&1 &

		# Kill the app process
		pkill -9 "$processName"

		sleep 3

		echo "Script result: Executing Policy ID $uninstallPolicyID"

		# Run uninstall policy id
		/usr/local/bin/jamf policy -id "$uninstallPolicyID"
     
   		sleep 5
    
    	# Kill jamfhelper
    	killall jamfHelper > /dev/null 2>&1

    	# Kill the caffinate process
    	kill "$caffeinatepid"
        
        verifyRemoval

	fi
}

function verifyRemoval ()
{

	if [ -d "$appPath" ]; then

		echo "Script result: $appName failed to uninstall"

    	# Display jamfHelper message
		"$jamfHelper" -windowType "$type" -title "Uninstall Failed" -description "The attempt to uninstall $appName failed.  
    
Please contact the Service Desk for assistance." \
    -icon "$issueicon" -button1 "CLOSE" -defaultButton 0 -lockHUD
    
    	# JAMF inventory update
		/usr/local/bin/jamf recon

		exit 1

	else

		echo "Script result: $appName has been removed"
    
    	# Display jamfHelper message
    	"$jamfHelper" -windowType "$type" -description "Successfully uninstalled:

$appName" -icon "$trashicon" -button1 "CLOSE" -defaultButton 0 -lockHUD

		# JAMF inventory update
		/usr/local/bin/jamf recon

	fi

}

function removeAppSilent ()
{
       
	if [ -d "$appPath" ]; then
        
		echo "Script result: Attempting to remove silently"
        
		# Run uninstall policy id
		/usr/local/bin/jamf policy -id "$uninstallPolicyID"
        
        verifyRemovalSilent

	fi

}

function verifyRemovalSilent ()
{

	if [ -d "$appPath" ]; then

		echo "Script result: $appName failed to uninstall"
        
        # JAMF inventory update
		/usr/local/bin/jamf recon

		exit 1

	else

		echo "Script result: $appName has been removed"
        
        # JAMF inventory update
		/usr/local/bin/jamf recon

	fi

}

##########################################################################################
# main script
##########################################################################################

checkStatus
