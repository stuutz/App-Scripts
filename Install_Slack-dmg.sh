#!/bin/bash


####################################################################################################
#
# CREATED BY
#
#   Brian Stutzman
#
# DESCRIPTION
#
#	This script installs the latest version of Slack.
#
#	File type: dmg
#
# VERSION
#
#	- 1.2
#
# CHANGE HISTORY
#
# 	- Created script - 6/11/21 (1.0)
# 	- Added support for Apple Silicon - 12/22/21 (1.1)
#	- Fixed the logged in user variable by removing python command (1.2) - 1/11/22
#
####################################################################################################


##########################################################################################
# Script variables (edit below)
##########################################################################################
AppName="Slack"    ## EDIT
dmgApp="/Volumes/$AppName/$AppName.app"    ## DON'T EDIT
dmgMountName="/Volumes/$AppName"    ## DON'T EDIT
dmgFilePath="/private/tmp/$AppName.dmg"    ## DON'T EDIT
localAppPath="/Applications/$AppName.app"    ## DON'T EDIT
user=$(echo "show State:/Users/ConsoleUser" | scutil | awk '/Name :/ && ! /loginwindow/ {print $3}')

# Identify chip architecture
arch=$(/usr/bin/arch)
if [ "$arch" == "arm64" ]; then
    echo "Apple Silicon Found"
    
	DownloadLink="https://slack.com/ssb/download-osx-silicon"    ## EDIT
          
elif [ "$arch" == "i386" ]; then
    
    echo "Intel Found"
    
    DownloadLink="https://slack.com/ssb/download-osx"	## EDIT
    
else
    
    echo "Unknown Architecture"
    
	DownloadLink="https://slack.com/ssb/download-osx-universal"	## EDIT
    
fi

##########################################################################################


##########################################################################################
# DO NOT EDIT ANYTHING BELOW
##########################################################################################


##########################################################################################
# Download/install app and change permissions
##########################################################################################
function DownloadApp () 
{
    
    # Download the latest version of the app
	curl -L -o "$dmgFilePath" "$DownloadLink"
    
    echo "Script result: Downloaded app"

	RemoveApp

}

##########################################################################################
# Remove the installed version of the app
##########################################################################################
function RemoveApp () 
{

    if [ -d "$localAppPath" ]; then
    
        # Kill the app process
		pkill -9 "$AppName"
    
    	sleep 3
    
        # Delete app
		rm -rf "$localAppPath"
        
		sleep 3
        
		echo "Script result: Deleted old app version"

	else

    	echo "Script result: App not found"
        
    fi
    
    CopyApp

}

##########################################################################################
# Copy app and change permissions
##########################################################################################
function CopyApp () 
{

	# Mount the dmg file
	hdiutil attach -nobrowse "$dmgFilePath"

    sleep 5

    # Copy new app to the applications folder
	sudo cp -R "$dmgApp" /Applications

    # Setting app permissions and owner
	chown -R root:wheel "$localAppPath"
	chmod -R 755 "$localAppPath"

    echo "Script result: Copied new app to Applications folder"

	CleanUp

}

##########################################################################################
# Remove files in the /private/tmp folder
##########################################################################################
function CleanUp () 
{

    # Un-mount/eject the dmg file
    diskutil eject "$dmgMountName"
    
    sleep 3

	# Delete dmg file
   	if [[ -e "$dmgFilePath" ]]; then

    	rm -rf "$dmgFilePath"
        
    fi
    
    defaults write /Users/$user/Library/Preferences/com.tinyspeck.slackmacgap SlackNoAutoUpdates -bool YES
    
	sudo chown $user:staff /Users/$user/Library/Preferences/com.tinyspeck.slackmacgap.plist
    
    echo "Script result: Cleanup completed"

}

##########################################################################################
# Main script
##########################################################################################

DownloadApp

exit 0
