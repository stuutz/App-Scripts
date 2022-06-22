#!/bin/sh


####################################################################################################
#
# CREATED BY
#
#   Brian Stutzman
#
# DESCRIPTION
#
# 	Type: SELF SERVICE
#
#	Deletes all GlobalProtect entries from the Login and System keychains. Keeping these files when
#	GlobalProtect installs prompts the user for their password.  Deleting these items surpresses
#	this window.
#
# VERSION
#
#	- 1.4
#
# CHANGE HISTORY
#
# 	- Created script - 6/3/20 (1.0)
#	- Added a function with if statement - 8/21/20 (1.1)
#	- Delete new login item "com.paloaltonetworks.gplogin.loginkc" and added reboot - 1/11/21 (1.2)
#	- Added reboot function - 1/12/21 (1.3)
#	- Fixed the logged in user variable by removing python command (1.4) - 1/11/2022
#
####################################################################################################


##################################################################
# Script variables
##################################################################

# Get logged in user
user=$(echo "show State:/Users/ConsoleUser" | scutil | awk '/Name :/ && ! /loginwindow/ {print $3}')
userUID=$(id -u ${user})
jamfHelper="/Library/Application Support/JAMF/bin/jamfHelper.app/Contents/MacOS/jamfHelper"
icon="/System/Library/CoreServices/Problem Reporter.app/Contents/Resources/ProblemReporter.icns"


##################################################################
# Script functions
##################################################################

function removeGPKC ()
{

if [ -d "/Applications/GlobalProtect.app" ] || [ -d "/Users/$user/Applications/GlobalProtect.app" ]; then

	echo "GlobalProtect: Installed"

	# System Keychain
	security delete-generic-password -s "GlobalProtectService" /Library/Keychains/System.keychain
	security delete-generic-password -s "GlobalProtect" /Library/Keychains/System.keychain
	security delete-generic-password -s "com.paloaltonetworks.gplogin.loginkc" /Library/Keychains/System.keychain

	# User Login Keychain
	/bin/launchctl asuser "$userUID" sudo -iu "$user" security delete-generic-password -s "GlobalProtectService" "/Users/$user/Library/Keychains/login.keychain-db"
	/bin/launchctl asuser "$userUID" sudo -iu "$user" security delete-generic-password -s "GlobalProtect" "/Users/$user/Library/Keychains/login.keychain-db"
	/bin/launchctl asuser "$userUID" sudo -iu "$user" security delete-generic-password -s "com.paloaltonetworks.gplogin.loginkc" "/Users/$user/Library/Keychains/login.keychain-db"

	reboot

else

	echo "GlobalProtect: Not Installed"
    
    exit 1
    
fi

}

function reboot ()
{

# jamfHelper window
userChoice=$("$jamfHelper" -windowType "hud" -heading "Reboot Required" -description "Are you ready to reboot?" -icon "$icon" -button1 "CANCEL" -button2 "REBOOT" -defaultButton 0 -lockHUD)

# REBOOT button was pressed
if [ "$userChoice" == "2" ]; then

	echo "Script result: Rebooting machine"
		
	# Reboot
	shutdown -r now &
    
    exit 0
			
	# CANCEL button was pressed
	elif [ "$userChoice" == "0" ]; then

		echo "Script result: User Canceled"

		exit 0

fi

}


##################################################################
# main script
##################################################################

removeGPKC


exit 0
