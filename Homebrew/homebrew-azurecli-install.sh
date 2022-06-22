#!/bin/bash

####################################################################################################
#
# CREATED BY
#
#   Brian Stutzman
#
# DESCRIPTION
#
#	Script will install a brew formula.
#
# VERSION
#
#	- 1.1
#
# CHANGE HISTORY
#
# 	- Created script - 12/22/21 (1.0)
#	- Fixed the logged in user variable by removing python command (1.1) - 1/11/22
#
####################################################################################################


##################################################################
## Script variables (EDIT BELOW)
##################################################################

appName="Azure CLI"
appFormula="brew install azure-cli"

##################################################################
## (DO NOT EDIT)
##################################################################

jamfHelper="/Library/Application Support/JAMF/bin/jamfHelper.app/Contents/MacOS/jamfHelper"
icon="/System/Library/CoreServices/Problem Reporter.app/Contents/Resources/ProblemReporter.icns"
loggedInUser=$(echo "show State:/Users/ConsoleUser" | scutil | awk '/Name :/ && ! /loginwindow/ {print $3}')
userUID=$(id -u ${loggedInUser})
hbInstalled=$(/bin/launchctl asuser "$userUID" sudo -iu "$loggedInUser" which brew)

##################################################################
## Script functions (DO NOT EDIT)
##################################################################

function hbCheck ()
{
	if [ $hbInstalled ]; then
	
		echo "Homebrew installed"
        
		/bin/launchctl asuser "$userUID" sudo -iu "$loggedInUser" $appFormula --verbose
	
	else
	
		echo "Homebrew NOT installed"
        
        "$jamfHelper" -windowType hud -lockHUD -icon "$icon" -title "$appName" -description "Homebrew required before installing $appName." -button1 "Close" -defaultButton 0 -lockHUD

	fi
}

##################################################################
## main script
##################################################################

hbCheck

exit 0