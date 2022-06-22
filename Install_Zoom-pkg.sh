#!/bin/bash


####################################################################################################
#
# CREATED BY
#
#   Brian Stutzman
#
# DESCRIPTION
#
#	This script installs the latest version of Zoom.
#
#	File type: pkg
#
# VERSION
#
#	- 1.1
#
# CHANGE HISTORY
#
# 	- Created script - 11/9/21 (1.0)
# 	- Added support for Apple Silicon - 12/22/21 (1.1)
#
####################################################################################################


##########################################################################################
# Script variables (edit below)
##########################################################################################
AppName="Zoom"    ## EDIT
DownloadLink="https://zoom.us/client/latest/$AppName.pkg"    ## EDIT
pkgFilePath="/private/tmp/$AppName.pkg"    ## DON'T EDIT

# Identify chip architecture
arch=$(/usr/bin/arch)
if [ "$arch" == "arm64" ]; then
    echo "Apple Silicon Found"
    
	DownloadLink="https://zoom.us/client/latest/$AppName.pkg?archType=arm64"    ## EDIT
          
elif [ "$arch" == "i386" ]; then
    
    echo "Intel Found"
    
    DownloadLink="https://zoom.us/client/latest/$AppName.pkg"	## EDIT
    
else
    
    echo "Unknown Architecture"
    
	DownloadLink="https://zoom.us/client/latest/$AppName.pkg"	## EDIT
    
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
