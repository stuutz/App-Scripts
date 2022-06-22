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
#	- 1.2
#
# CHANGE HISTORY
#
# 	- Created script - 2/22/21 (1.0)
#	- Fixed installation error, added verbose option for more detailed script results - 2/23/21 (1.1)
#	- Updated the logged in user variable (1.2) - 1/11/22
#
####################################################################################################


##################################################################
## Script variables (EDIT BELOW)
##################################################################

appName="SwiftLint"
appFormula="brew install swiftlint"

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