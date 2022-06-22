#!/bin/bash

####################################################################################################
#
# CREATED BY
#
#   Brian Stutzman
#
# DESCRIPTION
#
#	This script installs the latest version of Nitro PDF Pro.
#
#	File type: dmg
#
# VERSION
#
#	- 1.0
#
# CHANGE HISTORY
#
# 	- Created script - 5/16/22 (1.0)
#
####################################################################################################


##########################################################################################
# Script variables (edit below)
##########################################################################################
AppName="Nitro PDF Pro"
latestVersion=$(/usr/bin/curl -sL 'https://pdfpen.com/pdfpenpro/download_thanks' | grep "https://downloads.gonitro.com/macos/" | sed -n 1p | awk '{print $6}' | tr -d '"' | sed 's/href=//g' | awk 'BEGIN {FS="_"};{print $NF}' | tr -d 'dmg' | sed 's/.$//')
dmgApp="/Volumes/$AppName/$AppName.app"
dmgMountName="/Volumes/$AppName"
dmgFilePath="/private/tmp/$AppName.dmg"
localAppPath="/Applications/$AppName.app"

# Identify chip architecture
arch=$(/usr/bin/arch)
if [ "$arch" == "arm64" ]; then
    echo "Apple Silicon Found"
    
	DownloadLink="https://downloads.gonitro.com/macos/Nitro%20PDF%20Pro%20Retail_${latestVersion}.dmg"
          
elif [ "$arch" == "i386" ]; then
    
    echo "Intel Found"
    
    DownloadLink="https://downloads.gonitro.com/macos/Nitro%20PDF%20Pro%20Retail_${latestVersion}.dmg"
    
else
    
    echo "Unknown Architecture"
    
	DownloadLink="https://downloads.gonitro.com/macos/Nitro%20PDF%20Pro%20Retail_${latestVersion}.dmg"
    
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
