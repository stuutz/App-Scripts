#!/bin/bash


####################################################################################################
#
# CREATED BY
#
#   Brian Stutzman
#
# DESCRIPTION
#
#	This script installs the latest version of pgAdmin 4.
#
#	File type: dmg
#
# VERSION
#
#	- 1.0
#
# CHANGE HISTORY
#
# 	- Created script - 6/11/21 (1.0)
#
####################################################################################################


##########################################################################################
# Script variables (edit below)
##########################################################################################
AppName="pgAdmin 4"    ## EDIT
latestVersion=$(/usr/bin/curl -sL 'https://www.pgadmin.org/docs/pgadmin4/latest/index.html' | grep "documentation" | awk '{print $6}' | sed -n 1p)    ## EDIT
DownloadLink="https://ftp.postgresql.org/pub/pgadmin/pgadmin4/v${latestVersion}/macos/pgadmin4-${latestVersion}.dmg"    ## EDIT
dmgApp="/Volumes/$AppName/$AppName.app"    ## DON'T EDIT
dmgMountName="/Volumes/$AppName"    ## DON'T EDIT
dmgFilePath="/private/tmp/$AppName.dmg"    ## DON'T EDIT
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
	curl -L -o "$dmgFilePath" "$DownloadLink"
    
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

	# Mount the dmg file
	hdiutil attach -nobrowse "$dmgFilePath"

    sleep 5

    # Copy new app to the applications folder
	sudo cp -R "$dmgApp" /Applications

    # Setting app permissions and owner
	chown -R root:wheel "$localAppPath"
	chmod -R 755 "$localAppPath"

    echo "Script result: Copied new app to Applications folder"

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
    
    echo "Script result: Cleanup completed"

}

##########################################################################################
# Main script
##########################################################################################

DownloadApp

exit 0
