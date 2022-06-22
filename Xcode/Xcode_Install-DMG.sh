#!/bin/bash

####################################################################################################
#
# CREATED BY
#
#   Brian Stutzman
#
# DESCRIPTION
#
#	Type: SELF SERVICE
#
#	Allows the user to install Xcode from Self Service.
#
# VERSION
#
#	- 1.5
#
# CHANGE HISTORY
#
# 	- Created script - 4/9/2021 (1.0)
# 	- Added support for multiple installed Xcode versions - 9/24/2021 (1.1)
# 	- Included a macOS version varaible to ensure Xcode can be installed - 10/8/2021 (1.2)
# 	- Modified the script to make installing CLI tools optional - 10/11/2021 (1.3)
# 	- Fixed overwrite/keep section to ensure correct action was executed - 1/4/2022 (1.4)
#	- Fixed the logged in user variable by removing python command (1.5) - 1/11/2022
#
####################################################################################################


##################################################################
## script variables
##################################################################

# JAMF binary
jamfHelper="/Library/Application Support/JAMF/bin/jamfHelper.app/Contents/MacOS/jamfHelper"

# set jamfHelper window icon
icon="/private/var/tmp/Xcode.icns"

# Xcode Version to Install
xcodeVer=$4

# Download App (Policy ID)
downloadApp=$5

# CLI Tools Version to Install
CLIVersionToInstall=$6

# Install CLI Tools (Policy ID)
installCLI=$7

# Get logged in user account
user=$(echo "show State:/Users/ConsoleUser" | scutil | awk '/Name :/ && ! /loginwindow/ {print $3}')

# Xcode installation package location
xcodePackage="/private/var/tmp/Xcode-$xcodeVer.pkg"

##################################################################
## script functions
##################################################################

function macOSCheck ()
{

	echo ""
    
	osVer=$(sw_vers -productVersion | cut -c 1-5)
    problemIcon="/System/Library/CoreServices/Problem Reporter.app/Contents/Resources/ProblemReporter.icns"
    
    os=$(sw_vers -productVersion)
    echo "macOS Version: $os"
    
    if [ "$osVer" = "10.14" ]; then
    
    	macOSName="Mojave"
    
    fi
    
    if [ "$osVer" = "10.15" ]; then
    
    	macOSName="Catalina"
    
    fi
    
    if [ "$macOSName" = "Mojave" ] || [ "$macOSName" = "Catalina" ]; then
    
        echo "Xcode ($xcodeVer) cannot be installed on $os"
    
    	"$jamfHelper" -windowType "hud" -title "Xcode" -description "This version of Xcode ($xcodeVer) cannot be installed on macOS $macOSName ($osVer). 
        
Use Self Service to upgrade macOS to the latest version." -icon "$problemIcon" -button1 "CLOSE" -defaultButton 0 -lockHUD

    	exit 0
        
	fi
    
}

function xcodeCheck ()
{

	if [ -d "/Applications/Xcode.app" ]; then
    
		echo "Script result: Xcode already installed"
        
        installedXcodeVer=$(defaults read "/Applications/Xcode.app/Contents/version.plist" CFBundleShortVersionString)
    
    	# jamfHelper window
		userChoice=$("$jamfHelper" -windowType "hud" -title "Xcode" -description "Choose the type of install:
        
Click OVERWRITE to install Xcode ($xcodeVer) and overwrite the currently installed Xcode ($installedXcodeVer) app.  This option is for users who only use one version of Xcode.
        
Click KEEP to install Xcode ($xcodeVer) and keep the older version installed (old version will be renamed).  This option is for users that want to have multiple Xcode versions installed." -icon "$icon" -button1 "KEEP" -button2 "OVERWRITE" -defaultButton 0 -lockHUD)

		# OVERWRITE button was pressed
		if [ "$userChoice" == "2" ]; then

			echo "Script result: User clicked OVERWRITE Xcode app"
            
			renamed="no"

		# KEEP button was pressed
        elif [ "$userChoice" == "0" ]; then

			echo "Script result: User clicked KEEP Xcode app"
            
			pkill -9 "Xcode"
            
            mv "/Applications/Xcode.app" "/Applications/Xcode-$installedXcodeVer.app"
            
			echo "Script result: Renamed existing version to Xcode-$installedXcodeVer.app"
            
            renamed="yes"

        fi
        
        xcodeInstalled

	else

		echo "Script result: Xcode NOT installed"
        
		xcodeNotInstalled

	fi

}

function xcodeInstalled ()
{

	if [ "$renamed" = "yes" ]; then
	
		renamedXcodeVer=$(defaults read "/Applications/Xcode-$installedXcodeVer.app/Contents/version.plist" CFBundleShortVersionString)
            
		# jamfHelper window
		userChoice=$("$jamfHelper" -windowType "hud" -title "Xcode" -description "Renamed app to Xcode-$renamedXcodeVer

Proceed with installing Xcode ($xcodeVer)?" -icon "$icon" -button1 "CANCEL" -button2 "YES" -defaultButton 0 -lockHUD)
         
    else
    
		# jamfHelper window
		userChoice=$("$jamfHelper" -windowType "hud" -title "Xcode" -description "Proceed with installing Xcode ($xcodeVer)?" -icon "$icon" -button1 "CANCEL" -button2 "YES" -defaultButton 0 -lockHUD)

    fi

	# YES button was pressed
	if [ "$userChoice" == "2" ]; then

		echo "Script result: User clicked YES, start installation"
		
		pkill -9 "Xcode"
		
		downloadXcode
		
		installXcodeScript
		
		installCLITools

		# CANCEL button was pressed
		elif [ "$userChoice" == "0" ]; then

			echo "Script result: User clicked CANCEL, exiting script"
            
			# revert Xcode file name change
			if [ "$renamed" = "yes" ]; then
                
				mv "/Applications/Xcode-$renamedXcodeVer.app" "/Applications/Xcode.app"
                
				echo "Script result: Reverted Xcode file name change"
                    
			fi

			# remove icon
			if [ -f "$icon" ]; then

				rm -R $icon

				echo "Script result: Icon removed"

			else

			echo "Script result: Icon not found"

		fi

		exit 0

	fi

}

function xcodeNotInstalled ()
{

	# jamfHelper window
	userChoice=$("$jamfHelper" -windowType "hud" -title "Xcode" -description "Xcode not installed. 

Proceed with installation?" -icon "$icon" -button1 "CANCEL" -button2 "YES" -defaultButton 0 -lockHUD)
		
	# YES button was pressed
	if [ "$userChoice" == "2" ]; then

		echo "Script result: User clicked YES, start installation"

		downloadXcode
	
		installXcodeScript
	
		installCLITools
	
	# CANCEL button was pressed
	elif [ "$userChoice" == "0" ]; then

		echo "Script result: User clicked CANCEL, exit script"

		# remove icon
		if [ -f "$icon" ]; then

			rm -R $icon

			echo "Script result: Icon removed"

		else

			echo "Script result: Icon not found"

		fi

		exit 0

	fi

}

function downloadXcode ()
{
	
	echo "Script result: Downloading Xcode $xcodeVer"
	
	# caffinate the update process
	caffeinate -d -i -m -u &
	caffeinatepid=$!
	
	# display jamfHelper message
	"$jamfHelper" -windowType "hud" -title "Xcode" -description "Downloading Xcode Version: $xcodeVer" -icon "$icon" -lockHUD > /dev/null 2>&1 &
	
	# JAMF policy to download app
	/usr/local/bin/jamf policy -id $downloadApp &
	
	while [ ! -f $xcodePackage ] ;
	do
		sleep 2
	done
	
}

function installXcodeScript ()
{

	killjamfHelper
	
	echo "Script result: Installing Xcode $xcodeVer"

	# caffinate the update process
	caffeinate -d -i -m -u &
	caffeinatepid=$!

	# display jamfHelper message
	"$jamfHelper" -windowType "hud" -title "Xcode" -description "Installing Xcode $xcodeVer

This process may take awhile." -icon "$icon" -lockHUD > /dev/null 2>&1 &

	# install Xcode package
	installer -pkg $xcodePackage -target /

}

function installCLITools ()
{
	
	killjamfHelper

	checkCLITools=$(pkgutil --pkg-info=com.apple.pkg.CLTools_Executables)
    
    if [ "$checkCLITools" ]; then
    
    	# Get Command Line Tools (CLI) version
    	installedCLIVers=$(pkgutil --pkg-info=com.apple.pkg.CLTools_Executables | grep "version" | awk '{print $2}')
        
        echo "Installed CLI Tools Version: $installedCLIVers"
        
    else
    
        installedCLIVers="Not Installed"
        
		echo "CLI Tools $installedCLIVers"
    
    fi

    # jamfHelper window
	userChoice=$("$jamfHelper" -windowType "hud" -title "Xcode" -description "Do you want to install Command Line Tools (CLI)?
    
Version to install: $CLIVersionToInstall
Currently Installed: $installedCLIVers" -icon "$icon" -button1 "NO" -button2 "YES" -defaultButton 0 -lockHUD)

	# YES button was pressed
	if [ "$userChoice" == "2" ]; then

		echo "Script result: User clicked YES, start CLI tools installation"
	
		# caffinate the update process
		caffeinate -d -i -m -u &
		caffeinatepid=$!
	
		# display jamfHelper message
		"$jamfHelper" -windowType "hud" -title "Xcode" -description "Installing Command Line Tools" -icon "$icon" -lockHUD > /dev/null 2>&1 &
	
		# JAMF policy to install package
		/usr/local/bin/jamf policy -id $installCLI

	# NO button was pressed
	elif [ "$userChoice" == "0" ]; then

		echo "Script result: User clicked NO, procced to finalize"

	fi

}

function setupXcode ()
{
	
	killjamfHelper
	
	echo "Script result: Apply Xcode Settings"
	
	# caffinate the update process
	caffeinate -d -i -m -u &
	caffeinatepid=$!
	
	# display jamfHelper message
	"$jamfHelper" -windowType "hud" -title "Xcode" -description "Finalizing Xcode Installation" -icon "$icon" -lockHUD > /dev/null 2>&1 &
	
	# automate accepting the Xcode license
	/Applications/Xcode.app/Contents/Developer/usr/bin/xcodebuild -license accept
	
	echo "Script result: Accepted Xcode License"
	
	# installs the Additional Components
	/Applications/Xcode.app/Contents/Developer/usr/bin/xcodebuild -runFirstLaunch
	
	echo "Script result: Install Additional Components"
	
	# change the security authorization policies for developer systems
	/usr/sbin/DevToolsSecurity -enable
	
	echo "Script result: Enable Dev Tools Security"
	
	# add user to _developer group
	/usr/sbin/dseditgroup -o edit -a $user -t user _developer
	
	echo "Script result: Add User to _developer Group"
	
	#while [ ! -f $xcodePackage ] ;
	#do
		#sleep 2
	#done
	
	jamfRecon
	
}

function jamfRecon ()
{

	# run inventory update
	/usr/local/bin/jamf recon

}

function finalize ()
{

	recheckXcodeVer=$(defaults read "/Applications/Xcode.app/Contents/version.plist" CFBundleShortVersionString)

	if [ "$xcodeVer" = "$recheckXcodeVer" ]; then

		setupXcode
		
		killjamfHelper
		
		echo "Script result: Installation SUCCESSFUL"

		"$jamfHelper" -windowType "hud" -title "Xcode" -description "Xcode ($xcodeVer) has been installed." -icon "$icon" -button1 "CLOSE" -defaultButton 0 -lockHUD
		
	else
    
		killjamfHelper

		echo "Script result: Installation FAILED"

		"$jamfHelper" -windowType "hud" -title "Xcode" -description "Xcode ($xcodeVer) failed to install.  Please try again." -icon "$icon" -button1 "CLOSE" -defaultButton 0 -lockHUD

	fi

	cleanUp
      
}

function killjamfHelper ()
{

	# kill jamfhelper
	killall jamfHelper > /dev/null 2>&1

	# kill the caffinate process
	kill "$caffeinatepid"

}

function cleanUp ()
{

	# remove icon
	if [ -f "$icon" ]; then

		rm -R $icon

		echo "Script result: Icon removed"

	else

		echo "Script result: Icon not found"

	fi
	
	if [ -f "$xcodePackage" ]; then
		
		rm -R $xcodePackage
		
		echo "Script result: Xcode Package removed"
		
	else
		
		echo "Script result: Xcode Package not found"
		
	fi

}


##################################################################
## main script
##################################################################

macOSCheck

xcodeCheck

finalize

exit 0
