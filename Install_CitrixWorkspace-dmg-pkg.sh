#!/bin/bash

####################################################################################################
#
# CREATED BY
#
#   Brian Stutzman
#
# DESCRIPTION
#
#	This script installs the latest version of Citrix Workspace.
#
#	File type: dmg
#
# VERSION
#
#	- 1.0
#
# CHANGE HISTORY
#
# 	- Created script - 3/10/2022 (1.0)
#
####################################################################################################


##########################################################################################
# Script variables (edit below)
##########################################################################################
AppName="Citrix Workspace"    ## EDIT
getLink=$(curl -s -L https://www.citrix.com/downloads/workspace-app/mac/workspace-app-for-mac-latest.html#ctx-dl-eula-external | grep "dmg" | awk '{print $8}' | sed 's/.$//' | sed -n 2p | sed 's/rel="//g')    ## EDIT
protocol="https:"
dmgApp="/Volumes/$AppName/Install $AppName.pkg"    ## DON'T EDIT
dmgMountName="/Volumes/$AppName"    ## DON'T EDIT
dmgFilePath="/private/tmp/$AppName.dmg"    ## DON'T EDIT
localAppPath="/Applications/$AppName.app"    ## DON'T EDIT
pkgFilePath="/private/tmp/Install $AppName.pkg"    ## DON'T EDIT

# Identify chip architecture
arch=$(/usr/bin/arch)
if [ "$arch" == "arm64" ]; then
    echo "Apple Silicon Found"
    
	DownloadLink="${protocol}${getLink}"    ## EDIT
          
elif [ "$arch" == "i386" ]; then
    
    echo "Intel Found"
    
    DownloadLink="${protocol}${getLink}"	## EDIT
    
else
    
    echo "Unknown Architecture"
    
	DownloadLink="${protocol}${getLink}"	## EDIT
    
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

	CopyApp

}

##########################################################################################
# Copy app and change permissions
##########################################################################################
function CopyApp () 
{

	if [ -d "$localAppPath" ]; then
    
		echo "Script result: App found"
    
        # Kill the app process
		pkill -9 "$AppName"

	else

    	echo "Script result: App not found"
        
    fi

	# Mount the dmg file
	hdiutil attach -nobrowse "$dmgFilePath"

    sleep 5

    # Copy PKG to the tmp folder
	sudo cp -R "$dmgApp" /private/tmp
    
	echo "Script result: Copied PKG to tmp folder"
 
    sleep 3

	# Install the PKG file
    installer -pkg "$pkgFilePath" -target /
    
	echo "Script result: Installed PKG to the Applications folder"

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
    
	# Delete pkg file
   	if [[ -e "$pkgFilePath" ]]; then

    	rm -rf "$pkgFilePath"
        
    fi
    
    echo "Script result: Cleanup completed"

}

##########################################################################################
# Main script
##########################################################################################

DownloadApp

exit 0
