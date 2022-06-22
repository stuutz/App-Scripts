#!/bin/bash


####################################################################################################
#
# CREATED BY
#
#   Brian Stutzman
#
# DESCRIPTION
#
#	This script installs the latest version of Wacom Tablet.
#
#	File type: dmg
#
# VERSION
#
#	- 1.0
#
# CHANGE HISTORY
#
# 	- Created script - 6/23/21 (1.0)
#
####################################################################################################


##########################################################################################
# Script variables (edit below)
##########################################################################################
AppName="WacomTablet"    ## EDIT
processName="Wacom*"    ## EDIT
latestVersion=$(/usr/bin/curl -sL 'https://www.wacom.com/en-us/support/product-support/drivers' | grep 'data-title="Driver' | sed -n '1p' | awk '{print $2}')    ## EDIT
DownloadLink="https://cdn.wacom.com/u/productsupport/drivers/mac/professional/WacomTablet_${latestVersion}.dmg"    ## EDIT
dmgApp="/Volumes/$AppName/Install Wacom Tablet.pkg"		## DON'T EDIT
dmgMountName="/Volumes/$AppName"    					## DON'T EDIT
dmgFilePath="/private/tmp/${AppName}.dmg"				## DON'T EDIT
pkgFilePath="/private/tmp/Install Wacom Tablet.pkg"		## DON'T EDIT
localAppPath="/Applications/Wacom Tablet"				## DON'T EDIT
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
    
    killProcess

}

##########################################################################################
# Remove the installed version of the app
##########################################################################################
function killProcess () 
{

    if [ -d "$localAppPath" ]; then
    
        # Kill the app process
		pkill -9 "$processName"
    
    	sleep 3

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

    # Copy new app to the /private/tmp folder
	sudo cp -R "$dmgApp" /private/tmp

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
