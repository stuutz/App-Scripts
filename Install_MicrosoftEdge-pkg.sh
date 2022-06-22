#!/bin/bash


####################################################################################################
#
# CREATED BY
#
#   Brian Stutzman
#
# DESCRIPTION
#
#	This script installs the latest version of Microsoft Edge.
#
#	File type: pkg
#
# VERSION
#
#	- 1.1
#
# CHANGE HISTORY
#
# 	- Created script - 6/25/21 (1.0)
# 	- Added support for Apple Silicon - 12/14/21 (1.1)
#
####################################################################################################


##########################################################################################
# Script variables (edit below)
##########################################################################################
AppName="Microsoft Edge"    ## EDIT
#DownloadLink="https://go.microsoft.com/fwlink/?linkid=2093504"    ## EDIT
pkgFilePath="/private/tmp/$AppName.pkg"    ## DON'T EDIT

# Identify chip architecture
arch=$(/usr/bin/arch)
if [ "$arch" == "arm64" ]; then
    echo "Apple Silicon Found"
    
	DownloadLink="https://go.microsoft.com/fwlink/?linkid=2093504&platform=Mac&Consent=0&channel=Stable"    ## EDIT
          
elif [ "$arch" == "i386" ]; then
    
    echo "Intel Found"
    
    DownloadLink="https://go.microsoft.com/fwlink/?linkid=2069148&platform=Mac&Consent=0&channel=Stable"	## EDIT
    
else
    
    echo "Unknown Architecture"
    
	DownloadLink="https://go.microsoft.com/fwlink/?linkid=2069148&platform=Mac&Consent=0&channel=Stable"	## EDIT
    
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
