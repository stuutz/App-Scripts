#!/bin/bash

####################################################################################################
#
# CREATED BY
#
#   Brian Stutzman
#
# DESCRIPTION
#
#	This script installs the latest version of ON1 Resize.
#
#	File type: dmg
#
# VERSION
#
#	- 1.0
#
# CHANGE HISTORY
#
# 	- Created script - 7/1/2022 (1.0)
#
####################################################################################################


##########################################################################################
# Script variables (edit below)
##########################################################################################
AppName="ON1 Resize 10"
processName="ON1 Resize"
dmgApp="/Volumes/$AppName/$AppName.pkg"
dmgMountName="/Volumes/$AppName"
dmgFilePath="/private/tmp/$AppName.dmg"
localAppPath="/Applications/ON1 Resize 10/ON1 Resize 10.app"
pkgFilePath="/private/tmp/$AppName.pkg"
zipFilePath="/Applications/$AppName/onapp.zip"
DownloadLink="https://ononesoft.cachefly.net/resize10/mac/ON1_Resize_10.5.2.dmg"

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
		pkill -9 "$processName"

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

	# Change to /Application directory
    cd /Applications/ON1\ Resize\ 10/
    
    # Unzipping app
    unzip "$zipFilePath" >/dev/null 2>&1
    
    # Setting app permissions
	chown -R root:wheel "$localAppPath"
	chmod -R 755 "$localAppPath"
   	cd ~
    
    echo "Script result: Downloaded app"

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
    
    # Delete zip file
   	if [[ -e "$zipFilePath" ]]; then

    	rm -rf "$zipFilePath"
        
    fi
    
    echo "Script result: Cleanup completed"

}

##########################################################################################
# Main script
##########################################################################################

DownloadApp

exit 0
