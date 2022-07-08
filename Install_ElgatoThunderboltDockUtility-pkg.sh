#!/bin/bash

####################################################################################################
#
# CREATED BY
#
#   Brian Stutzman
#
# DESCRIPTION
#
#	This script installs the latest version of Elgato Thunderbolt Dock Utility.
#
#	File type: pkg
#
# VERSION
#
#	- 1.0
#
# CHANGE HISTORY
#
# 	- Created script - 6/29/2022 (1.0)
#
####################################################################################################


##########################################################################################
# Script variables (edit below)
##########################################################################################
AppName="Elgato Thunderbolt Dock Utility"
pkgFilePath="/private/tmp/$AppName.pkg"

# Identify chip architecture
arch=$(/usr/bin/arch)
if [ "$arch" == "arm64" ]; then
    echo "Apple Silicon Found"
    
	DownloadLink="https://update.elgato.com/mac/thunderbolt-dock-update/download.php?_ga=2.106912906.863021383.1656523352-41934229.1656523352"
          
elif [ "$arch" == "i386" ]; then
    
    echo "Intel Found"
    
	DownloadLink="https://update.elgato.com/mac/thunderbolt-dock-update/download.php?_ga=2.106912906.863021383.1656523352-41934229.1656523352"
    
else
    
    echo "Unknown Architecture"
    
	DownloadLink="https://update.elgato.com/mac/thunderbolt-dock-update/download.php?_ga=2.106912906.863021383.1656523352-41934229.1656523352"
    
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
    curl -L "$DownloadLink" > "$pkgFilePath"

    echo "Script result: Downloaded app"

    InstallPKG

}

##########################################################################################
# Copy app and change permissions
##########################################################################################
function InstallPKG () 
{
    
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

	# Delete pkg file
   	if [ -e "$pkgFilePath" ]; then

    	rm -rf "$pkgFilePath"

    fi
    
    echo "Script result: Cleanup completed"

}

##########################################################################################
# Main script
##########################################################################################

DownloadApp

exit 0
