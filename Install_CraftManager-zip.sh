#!/bin/bash


####################################################################################################
#
# CREATED BY
#
#   Brian Stutzman
#
# DESCRIPTION
#
#	This script installs the latest version of Craft Manager.
#
#	File type: zip
#
# VERSION
#
#	- 1.0
#
# CHANGE HISTORY
#
# 	- Created script - 9/13/21 (1.0)
#
####################################################################################################


##########################################################################################
# Script variables (edit below)
##########################################################################################
AppName="CraftManager"    ## EDIT
DownloadLink="https://s3.amazonaws.com/www-assets.invisionapp.com/labs/craft/manager/CraftManager.zip"    ## EDIT
zipFilePath="/private/tmp/$AppName.zip"    ## DON'T EDIT
tmpAppPath="/private/tmp/$AppName.app"    ## DON'T EDIT
localAppPath="/Applications/$AppName.app"    ## DON'T EDIT
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
# Main script
##########################################################################################

DownloadApp

exit 0
