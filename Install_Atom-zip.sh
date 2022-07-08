#!/bin/bash

####################################################################################################
#
# CREATED BY
#
#   Brian Stutzman
#
# DESCRIPTION
#
#	This script installs the latest version of Atom.
#
#	File type: zip
#
# VERSION
#
#	- 1.1
#
# CHANGE HISTORY
#
# 	- Created script - 6/8/21 (1.0)
# 	- Added function for Command Line Tools installation - 6/29/2022 (1.1)
#
####################################################################################################


##########################################################################################
# Script variables (edit below)
##########################################################################################
AppName="Atom"
DownloadLink="https://atom.io/download/mac"
zipFilePath="/private/tmp/$AppName.zip"
tmpAppPath="/private/tmp/$AppName.app"
localAppPath="/Applications/$AppName.app"
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
    curl -L "$DownloadLink" > "$zipFilePath"
      
	# Change to /tmp directory
    cd /private/tmp/
    
    # Unzipping app
    unzip "$zipFilePath" >/dev/null 2>&1
    
    # Setting app permissions
	chown -R root:wheel "$tmpAppPath"
	chmod -R 755 "$tmpAppPath"
   	cd ~
    
    echo "Script result: Downloaded app"

	RemoveApp

}

##########################################################################################
# Remove the installed version of the app
##########################################################################################
function RemoveApp () 
{

    if [ -d "$localAppPath" ]; then
    
        # Kill the app process
		pkill -9 "$AppName"
    
    	sleep 3
    
        # Delete app
		rm -rf "$localAppPath"
        
		sleep 3
        
		echo "Script result: Deleted old app version"

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
    	
	# Copy new app to the applications folder
	sudo cp -R "$tmpAppPath" /Applications
    
    echo "Script result: Copied new app to Applications folder"

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

    fi

    # Delete /private/tmp app file
    if [ -d "$tmpAppPath" ]; then

		rm -rf "$tmpAppPath"

	fi
    
    echo "Script result: Cleanup completed"

}

##########################################################################################
# Have the xcode command line tools been installed?
##########################################################################################
function CLIToolsCheck () 
{

check=$( pkgutil --pkgs | grep -c "CLTools_Executables" )

	if [[ "$check" != 1 ]]; then

		echo "Installing Command Line Tools"
    
    	# Command Line Tools package install
    	/usr/local/bin/jamf policy -id 1245

	fi

}

##########################################################################################
# Main script
##########################################################################################

CLIToolsCheck

DownloadApp

exit 0
