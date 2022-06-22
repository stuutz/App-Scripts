#!/bin/bash

####################################################################################################
#
# CREATED BY
#
#   Brian Stutzman
#
# DESCRIPTION
#
#	This script installs the latest version of Cyberduck.
#
#	File type: pkg
#
# VERSION
#
#	- 1.0
#
# CHANGE HISTORY
#
# 	- Created script - 3/11/2022 (1.0)
#
####################################################################################################

##########################################################################################
# Script variables (edit below)
##########################################################################################
AppName="Cyberduck"    ## EDIT
latestVer=$4
pkgFilePath="/private/tmp/$AppName.pkg"    ## DON'T EDIT

# Identify chip architecture
arch=$(/usr/bin/arch)
if [ "$arch" == "arm64" ]; then
    
    echo "Apple Silicon Found"
    
	DownloadLink="https://update.cyberduck.io/Cyberduck-${latestVer}.pkg"    ## EDIT
          
elif [ "$arch" == "i386" ]; then
    
    echo "Intel Found"
    
    DownloadLink="https://update.cyberduck.io/Cyberduck-${latestVer}.pkg"    ## EDIT
    
else
    
    echo "Unknown Architecture"
    
	DownloadLink="https://update.cyberduck.io/Cyberduck-${latestVer}.pkg"    ## EDIT
    
fi

##########################################################################################

# DO NOT EDIT ANYTHING BELOW

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
