#!/bin/bash


####################################################################################################
#
# CREATED BY
#
#   Brian Stutzman
#
# DESCRIPTION
#
#	This script installs the latest version of Safari Technology Preview.
#
#	File type: dmg
#
# VERSION
#
#	- 1.1
#
# CHANGE HISTORY
#
# 	- Created script - 2/23/2022 (1.0)
# 	- Cleaned up script and remove un-needed parts - 3/8/2022 (1.1)
#
####################################################################################################


##########################################################################################
# Script variables (edit below)
##########################################################################################
AppName="Safari Technology Preview"    ## EDIT
dmgApp="/Volumes/$AppName/$AppName.pkg"    ## DON'T EDIT
dmgMountName="/Volumes/$AppName"    ## DON'T EDIT
dmgFilePath="/private/tmp/$AppName.dmg"    ## DON'T EDIT
localAppPath="/Applications/$AppName.app"    ## DON'T EDIT
pkgFilePath="/private/tmp/$AppName.pkg"    ## DON'T EDIT

macOSVer=$(sw_vers -productVersion | cut -c 1-2)
if [ $macOSVer = "12" ]; then

latestVersionMonterey=$(/usr/bin/curl -sL 'https://developer.apple.com/safari/download' | grep "Monterey" | awk '{print $4}' | cut -c 7-200 | sed 's/["].*$//')    ## EDIT

DownloadLink="$latestVersionMonterey"

fi

if [ $macOSVer = "11" ]; then
latestVersionBigSur=$(/usr/bin/curl -sL 'https://developer.apple.com/safari/download' | grep "Big Sur" | awk '{print $4}' | cut -c 7-200 | sed 's/["].*$//')    ## EDIT

DownloadLink="$latestVersionBigSur"
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
