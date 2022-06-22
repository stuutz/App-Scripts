#!/bin/bash


####################################################################################################
#
# CREATED BY
#
#   Brian Stutzman
#
# DESCRIPTION
#
#	This script installs the latest version of BlueJeans.
#
#	File type: dmg
#
# VERSION
#
#	- 1.1
#
# CHANGE HISTORY
#
# 	- Created script - 11/16/21 (1.0)
# 	- Added support for Apple Silicon - 12/13/21 (1.1)
#
####################################################################################################


##########################################################################################
#															 Intel App (dmg) - main script
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

    # Open the installer application
    open "/Volumes/BlueJeans Installer/BlueJeansInstaller.app/Contents/MacOS/BlueJeansInstaller"
    
    echo "Script result: Opened application installer"
    
    sleep 15

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
    
	pkill -9 "Terminal"
    		
	pkill -9 "$AppName"
    
    echo "Script result: Cleanup completed"

}




##########################################################################################
#														 Apple Silicon (pkg) - main script
##########################################################################################




##########################################################################################
# Download/install app and change permissions
##########################################################################################
function DownloadAppAS () 
{

    # Download the latest version of the app
    curl -L "$DownloadLink" > "$pkgFilePath"

    echo "Script result: Downloaded app"

    InstallPKGAS

}


##########################################################################################
# Copy app and change permissions
##########################################################################################
function InstallPKGAS () 
{
    
    # Install the PKG file
    installer -pkg "$pkgFilePath" -target /
    
    echo "Script result: Installed PKG to the Applications folder"

	CleanUpAS
    
}

##########################################################################################
# Remove files in the /private/tmp folder
##########################################################################################
function CleanUpAS () 
{

	# Delete pkg file
   	if [ -e "$pkgFilePath" ]; then

    	rm -rf "$pkgFilePath"

    fi
    
    echo "Script result: Cleanup completed"

}


##########################################################################################
# main script
##########################################################################################

# Identify chip architecture
arch=$(/usr/bin/arch)
if [ "$arch" == "arm64" ]; then
    echo "Apple Silicon Found"
    
	AppName="BlueJeans"    ## EDIT
	latestVersionShort=$(/usr/bin/curl -sL 'https://www.bluejeans.com/downloads' | grep "dmg" | sed -n 1p | awk '{print $2}' | tr -d '"' | awk 'BEGIN {FS="https://swdl.bluejeans.com/desktop-app/mac/"};{print $NF}' | awk '{sub(/\/.*/,""); print}')    ## EDIT
	latestVersionLong=$(/usr/bin/curl -sL '/usr/bin/curl -sL '/usr/bin/curl -sL 'https://www.bluejeans.com/downloads' | grep "dmg" | sed -n 1p | awk '{print $2}' | tr -d '"' | awk 'BEGIN {FS="https://swdl.bluejeans.com/desktop-app/mac/"};{print $NF}' | awk '{sub(/B.*/,""); print}' | sed 's/.$//' | awk 'BEGIN {FS="/"};{print $NF}')    ## EDIT
    DownloadLink="https://swdl.bluejeans.com/desktop-app/mac/$latestVersionShort/$latestVersionLong/${AppName}AdminInstaller(arm64).pkg"    ## EDIT
	pkgFilePath="/private/tmp/$AppName.pkg"    ## DON'T EDIT
    
	DownloadAppAS

elif [ "$arch" == "i386" ]; then
    
    echo "Intel Found"
    
	AppName="BlueJeans"    ## EDIT
	latestVersionShort=$(/usr/bin/curl -sL 'https://www.bluejeans.com/downloads' | grep "dmg" | sed -n 1p | awk '{print $2}' | tr -d '"' | awk 'BEGIN {FS="https://swdl.bluejeans.com/desktop-app/mac/"};{print $NF}' | awk '{sub(/\/.*/,""); print}')    ## EDIT
	latestVersionLong=$(/usr/bin/curl -sL '/usr/bin/curl -sL '/usr/bin/curl -sL 'https://www.bluejeans.com/downloads' | grep "dmg" | sed -n 1p | awk '{print $2}' | tr -d '"' | awk 'BEGIN {FS="https://swdl.bluejeans.com/desktop-app/mac/"};{print $NF}' | awk '{sub(/B.*/,""); print}' | sed 's/.$//' | awk 'BEGIN {FS="/"};{print $NF}')    ## EDIT
	DownloadLink="https://swdl.bluejeans.com/desktop-app/mac/$latestVersionShort/$latestVersionLong/${AppName}Installer(x86_64).dmg"    ## EDIT
	dmgApp="/Volumes/$AppName Installer/${AppName}Installer.app"    ## DON'T EDIT
	dmgMountName="/Volumes/$AppName Installer"    ## DON'T EDIT
	dmgFilePath="/private/tmp/$AppName.dmg"    ## DON'T EDIT
	localAppPath="/Applications/$AppName.app"    ## DON'T EDIT

    DownloadApp
    
else
    
    echo "Unknown Architecture"
    
	AppName="BlueJeans"    ## EDIT
	latestVersionShort=$(/usr/bin/curl -sL 'https://www.bluejeans.com/downloads' | grep "dmg" | sed -n 1p | awk '{print $2}' | tr -d '"' | awk 'BEGIN {FS="https://swdl.bluejeans.com/desktop-app/mac/"};{print $NF}' | awk '{sub(/\/.*/,""); print}')    ## EDIT
	latestVersionLong=$(/usr/bin/curl -sL '/usr/bin/curl -sL '/usr/bin/curl -sL 'https://www.bluejeans.com/downloads' | grep "dmg" | sed -n 1p | awk '{print $2}' | tr -d '"' | awk 'BEGIN {FS="https://swdl.bluejeans.com/desktop-app/mac/"};{print $NF}' | awk '{sub(/B.*/,""); print}' | sed 's/.$//' | awk 'BEGIN {FS="/"};{print $NF}')    ## EDIT
	DownloadLink="https://swdl.bluejeans.com/desktop-app/mac/$latestVersionShort/$latestVersionLong/${AppName}Installer(x86_64).dmg"    ## EDIT
	dmgApp="/Volumes/$AppName Installer/${AppName}Installer.app"    ## DON'T EDIT
	dmgMountName="/Volumes/$AppName Installer"    ## DON'T EDIT
	dmgFilePath="/private/tmp/$AppName.dmg"    ## DON'T EDIT
	localAppPath="/Applications/$AppName.app"    ## DON'T EDIT

    DownloadApp
    
fi


exit 0
