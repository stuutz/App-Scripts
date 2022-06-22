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
# 	- Created script (1.0) - 11/23/2021
#	- Updated the logged in user variable (1.1) - 1/11/2022
#
####################################################################################################


##################################################################
## Script variables (EDIT BELOW)
##################################################################

appName="http-server"
appFormula="brew install http-server"

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