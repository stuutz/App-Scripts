#!/bin/bash

####################################################################################################
#
# CREATED BY
#
#   Brian Stutzman
#
# DESCRIPTION
#
#	This script installs the latest version of Microsoft Teams.
#
#	File type: pkg
#
# VERSION
#
#	- 1.0
#
# CHANGE HISTORY
#
# 	- Created script - 5/20/2022 (1.0)
#
####################################################################################################


##########################################################################################
# Script variables (edit below)
##########################################################################################
AppName="Microsoft Teams"
DownloadLink="https://go.microsoft.com/fwlink/?linkid=869428"
pkgFilePath="/private/tmp/$AppName.pkg"
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
