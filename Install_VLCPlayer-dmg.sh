#!/bin/bash


####################################################################################################
#
# CREATED BY
#
#   Brian Stutzman
#
# DESCRIPTION
#
#	This script installs the latest version of VLC Player.
#
#	File type: dmg
#
# VERSION
#
#	- 1.1
#
# CHANGE HISTORY
#
# 	- Created script - 7/15/21 (1.0)
# 	- Added support for Apple Silicon - 12/22/21 (1.1)
#
####################################################################################################


##########################################################################################
# Script variables (edit below)
##########################################################################################
AppName="VLC"    ## EDIT
latestVersion=$(/usr/bin/curl -sL 'https://www.videolan.org/vlc/download-macosx.html' | grep "macOS" | awk '{print $1}' | sed 's/[<].*$//')
dmgApp="/Volumes/$AppName media player/$AppName.app"    ## DON'T EDIT
dmgMountName="/Volumes/$AppName media player"    ## DON'T EDIT
dmgFilePath="/private/tmp/$AppName.dmg"    ## DON'T EDIT
localAppPath="/Applications/$AppName.app"    ## DON'T EDIT

# Identify chip architecture
arch=$(/usr/bin/arch)
if [ "$arch" == "arm64" ]; then
    echo "Apple Silicon Found"
    
	DownloadLink="https://get.videolan.org/vlc/${latestVersion}/macosx/vlc-${latestVersion}-arm64.dmg"    ## EDIT
          
elif [ "$arch" == "i386" ]; then
    
    echo "Intel Found"
    
    DownloadLink="https://get.videolan.org/vlc/${latestVersion}/macosx/vlc-${latestVersion}-intel64.dmg"	## EDIT
    
else
    
    echo "Unknown Architecture"
    
	DownloadLink="https://get.videolan.org/vlc/${latestVersion}/macosx/vlc-${latestVersion}-universal.dmg"	## EDIT
    
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
    
    echo "Script result: Cleanup completed"

}

##########################################################################################
# Main script
##########################################################################################

DownloadApp

exit 0
