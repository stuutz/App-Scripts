#!/bin/bash

####################################################################################################
#
# CREATED BY
#
#   Brian Stutzman
#
# DESCRIPTION
#
#	This script installs the latest version of MySQLWorkbench.
#
#	File type: dmg
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
AppName="MySQLWorkbench"
latestVersion=$(/usr/bin/curl -sL 'https://dev.mysql.com/downloads/workbench' | grep "<h1>" | awk '{print $3}')
dmgApp="/Volumes/MySQL Workbench community-${latestVersion}/$AppName.app"
dmgMountName="/Volumes/MySQL Workbench community-${latestVersion}"
dmgFilePath="/private/tmp/$AppName.dmg"
localAppPath="/Applications/$AppName.app"

# Identify chip architecture
arch=$(/usr/bin/arch)
if [ "$arch" == "arm64" ]; then
    echo "Apple Silicon Found"
    
	DownloadLink="https://cdn.mysql.com//Downloads/MySQLGUITools/mysql-workbench-community-${latestVersion}-macos-x86_64.dmg"
          
elif [ "$arch" == "i386" ]; then
    
    echo "Intel Found"
    
    DownloadLink="https://cdn.mysql.com//Downloads/MySQLGUITools/mysql-workbench-community-${latestVersion}-macos-x86_64.dmg"
    
else
    
    echo "Unknown Architecture"
    
	DownloadLink="https://cdn.mysql.com//Downloads/MySQLGUITools/mysql-workbench-community-${latestVersion}-macos-x86_64.dmg"
    
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
