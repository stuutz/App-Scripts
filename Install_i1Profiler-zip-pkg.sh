#!/bin/bash

####################################################################################################
#
# CREATED BY
#
#   Brian Stutzman
#
# DESCRIPTION
#
#	This script installs the latest version of i1Profiler.
#
#	File type: zip-pkg
#
# VERSION
#
#	- 1.0
#
# CHANGE HISTORY
#
# 	- Created script - 3/14/2022 (1.0)
#
####################################################################################################


##########################################################################################
# Script variables (edit below)
##########################################################################################
intelVer="$4"
armVer="$5"
AppName="i1Profiler"
zipFilePath="/private/tmp/$AppName.zip"
pkgFilePath="/private/tmp/$AppName.pkg"
localAppPath="/Applications/$AppName/$AppName.app"

# Identify chip architecture
arch=$(/usr/bin/arch)
if [ "$arch" == "arm64" ]; then
    
    echo "Apple Silicon Found"
    
	DownloadLink="https://downloads.xrite.com/downloads/software/$AppName/${armVer}/Mac/$AppName.zip"
          
elif [ "$arch" == "i386" ]; then
    
    echo "Intel Found"
    
    DownloadLink="https://downloads.xrite.com/downloads/software/$AppName/${intelVer}/Mac/$AppName.zip"
    
else
    
    echo "Unknown Architecture"
    
    DownloadLink="https://downloads.xrite.com/downloads/software/$AppName/${intelVer}/Mac/$AppName.zip"
    
fi

##########################################################################################


##########################################################################################
# Download/install app
##########################################################################################
function DownloadApp () 
{
    
    # Download the latest version of the app
    curl -L "$DownloadLink" > "$zipFilePath"
     
    echo "Script result: Downloaded app"
     
	# Change to /tmp directory
    cd /private/tmp/
    
    # Unzipping file
    unzip "$zipFilePath" >/dev/null 2>&1
    
    echo "Script result: Unzipped file"

	CopyApp

}

##########################################################################################
# Copy app
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

    sleep 3

	# Install the PKG file
    installer -pkg "$pkgFilePath" -target /
    
	echo "Script result: Installed PKG to the Applications folder"

	CleanUp

}

##########################################################################################
# Remove files in the /tmp folder
##########################################################################################
function CleanUp () 
{

	# Delete zip file
   	if [ -e "$zipFilePath" ]; then

    	rm -rf "$zipFilePath"
        
		echo "Script result: deleted zip file"

    fi

    # Delete pkg file
    if [ -e "$pkgFilePath" ]; then

		rm -rf "$pkgFilePath"
        
		echo "Script result: deleted pkg file"

	fi
    
    echo "Script result: Cleanup completed"

}

##########################################################################################
# Main script
##########################################################################################

DownloadApp

exit 0
