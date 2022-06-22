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
#	- 1.0
#
# CHANGE HISTORY
#
# 	- Created script - 2/22/21 (1.0)
#
####################################################################################################


##################################################################
## Script variables (EDIT BELOW)
##################################################################

appName="Terraform"
appFormula="brew tap hashicorp/tap"


##################################################################
## (DO NOT EDIT)
##################################################################

jamfHelper="/Library/Application Support/JAMF/bin/jamfHelper.app/Contents/MacOS/jamfHelper"
icon="/System/Library/CoreServices/Problem Reporter.app/Contents/Resources/ProblemReporter.icns"
loggedInUser=$(stat -f%Su /dev/console)
userUID=$(id -u ${loggedInUser})
hbInstalled=$(/bin/launchctl asuser "$userUID" sudo -iu "$loggedInUser" which brew)
installApp=$(/bin/launchctl asuser "$userUID" sudo -iu "$loggedInUser" $appFormula)


##################################################################
## Script functions (DO NOT EDIT)
##################################################################

function hbCheck ()
{
	if [ $hbInstalled ]; then
	
		echo "Homebrew installed"
        
		$installApp
	
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