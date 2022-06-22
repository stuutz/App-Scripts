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
#	Installs macOS with the including features:
#	- Checks to see if connected to power
#   - Checks to see if there is enough free space to do the installation
#   - Downloads the installer if it doesn't already exist
#
# VERSION
#
#	- 1.2
#
# CHANGE HISTORY
#
# 	- Created script - 12/9/2020 (1.0)
# 	- Added cleanUp function to delete the macOS installer package from the DMG - 4/28/2021 (1.1)
# 	- Added a parameter for macOS version # - 11/5/2021 (1.2)
#
####################################################################################################


##################################################################
## script variables (edit as needed)
##################################################################

# Set name of macOS
macosName="$4"

# Set name of macOS installer
macosInstallerName="$5"

# ID of the app installer policy
appPolicyID="$6"

# macOS Version #
macOSVers="$7"

# Set full path to installer
macosInstallerPath="/Applications/$macosInstallerName"

# Set disk space required for the install (reference system requirements for macOS version)
requiredDiskSpaceSizeGB=35

# Set jamf Helper window binary
jamfHelper="/Library/Application Support/JAMF/bin/jamfHelper.app/Contents/MacOS/jamfHelper"

# Set default jamf Helper window icon
icon="/System/Library/CoreServices/Install in Progress.app/Contents/Resources/Installer.icns"

# Set error icon in jamf Helper window when errors are found
errorIcon="/System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/AlertStopIcon.icns"

# Set warning icon in jamf Helper window when warnings are found
warnIcon="/System/Library/PreferencePanes/EnergySaver.prefPane/Contents/Resources/EnergySaver.icns"

# Set jamf Helper window title bar text
title="Upgrade macOS"

# Amount of time (in seconds) to allow a user to connect to AC power before moving on
# If null or 0, then the user will not have the opportunity to connect to AC power
acPowerWaitTimer="90"

# Declare the sysRequirementErrors array
declare -a sysRequirementErrors=()


##################################################################
## script functions (system requirements) (do not edit)
##################################################################

function wait_for_ac_power ()
{
    
    # Loop for "acPowerWaitTimer" seconds until either AC Power is detected or the timer is up
    echo "Script result: Waiting for AC power..."
    
    while [[ "$acPowerWaitTimer" -gt "0" ]]; do
    
        if /usr/bin/pmset -g ps | /usr/bin/grep "AC Power" > /dev/null ; then
        
            echo "Script result: AC Power Detected"
            
            killjamfHelper
            
            return
            
        fi
        
        sleep 1
        
        ((acPowerWaitTimer--))
        
    done
    
    sysRequirementErrors+=("Is connected to AC power")
    
    echo "Script result: ERROR - No AC Power Detected"
    
    confirmRequirements

}


function validate_power_status ()
{

    # Check if device is on battery or ac power
    # If not, and our acPowerWaitTimer is above 1, allow user to connect to power for specified time period
    if /usr/bin/pmset -g ps | /usr/bin/grep "AC Power" > /dev/null ; then
    
        echo "Script result: AC Power Detected"
        
    else
    
        if [[ "$acPowerWaitTimer" -gt 0 ]]; then
        
            "$jamfHelper" -windowType "hud" -title "Waiting for AC Power Connection" -icon "$warnIcon" -description "Please connect your computer to power using an AC power adapter. This process will continue once AC power is detected." -timeout $acPowerWaitTimer -countdown -countdownPrompt "" -alignCountdown right -lockHUD &
            
            wait_for_ac_power "$!"
            
        else
        
            sysRequirementErrors+=("Is connected to AC power")
            
            echo "Script result: ERROR - No AC Power Detected"
            
        fi
        
    fi

}


function validate_free_space ()
{

    diskInfoPlist=$(/usr/sbin/diskutil info -plist /)
    
    freeSpace=$(
    /usr/libexec/PlistBuddy -c "Print :APFSContainerFree" /dev/stdin <<< "$diskInfoPlist" 2>/dev/null || /usr/libexec/PlistBuddy -c "Print :FreeSpace" /dev/stdin <<< "$diskInfoPlist" 2>/dev/null || /usr/libexec/PlistBuddy -c "Print :AvailableSpace" /dev/stdin <<< "$diskInfoPlist" 2>/dev/null
    )

    # The free space calculation also includes the installer, so it is excluded
    if [ -e "$macosInstallerPath" ]; then
    
        installerSizeBytes=$(/usr/bin/du -s "$macosInstallerPath" | /usr/bin/awk '{print $1}' | /usr/bin/xargs)
        
        freeSpace=$((freeSpace + installerSizeBytes))
        
    fi
    
	# Calculation to determine if there is enough freespace on the hard drive
    if [[ ${freeSpace%.*} -ge $(( requiredDiskSpaceSizeGB * 1000 * 1000 * 1000 )) ]]; then
    
        echo "Script result: Disk Check: OK - ${freeSpace%.*} Bytes Free Space Detected"
        
    else
    
        sysRequirementErrors+=("Has at least ${requiredDiskSpaceSizeGB}GB of Free Space")
        
        echo "Script result: Disk Check: ERROR - ${freeSpace%.*} Bytes Free Space Detected"
        
		confirmRequirements
        
    fi

}


##################################################################
## script functions (do not edit)
##################################################################

function validateInstaller ()
{

echo ""

# Look for macOS app already installed
if [ -d "$macosInstallerPath" ]; then

	installRequest

else 
    
    validateRequest
 
fi

}


function confirmRequirements ()
{

# If there are errors, inform user and exit
if [[ "${#sysRequirementErrors[@]}" -ge 1 ]]; then
    
    "$jamfHelper" -windowType "hud" -title "$title" -icon "$errorIcon" -heading "Upgrade Requirements Not Met" -description "Unable to prepare your computer for $macosName. Please ensure your computer meets the following requirements:

$( /usr/bin/printf '\t• %s\n' "${sysRequirementErrors[@]}" )

If you continue to experience this issue, please contact the Solution Desk." -iconSize 100 -button1 "CLOSE" -lockHUD

    exit 1
    
fi

}


function validateRequest ()
{

# jamfHelper window
userChoice=$("$jamfHelper" -windowType "hud" -title "$title" -description "Download macOS $macosName ($macOSVers)?" -icon "$icon" -button1 "CANCEL" -button2 "YES" -defaultButton 0 -lockHUD)

# YES button was pressed
if [ "$userChoice" == "2" ]; then

	echo "Script result: Downloading $macosName installer file"

	downloadInstaller

   	# CANCEL button was pressed
	elif [ "$userChoice" == "0" ]; then

		echo "Script result: User Canceled (validateRequest)"

fi

}


function continueInstall ()
{

if [ -d "$macosInstallerPath" ]; then

    installerIcon="/Applications/$macosInstallerName/Contents/Resources/InstallAssistant.icns"
	installerOSVER=$(defaults read "/Applications/$macosInstallerName/Contents/Info.plist" DTPlatformVersion)
    
    validate_power_status

	validate_free_space
    
	echo "Script result: Installing $macosName ($installerOSVER)"
        
	jamfHelperPID=""
        
	# display jamfHelper message
	"$jamfHelper" -windowType "hud" -title "$title" -description "Computer will reboot shortly to begin the upgrade." -icon "$installerIcon" -lockHUD &

	jamfHelperPID=$!

	"/Applications/$macosInstallerName/Contents/Resources/startosinstall" --agreetolicense --forcequitapps --nointeraction --pidtosignal $jamfHelperPID &
    
    cleanUp

	QuitSelfService
        
	exit 0

else
	
	# jamfHelper window
	"$jamfHelper" -windowType "hud" -title "Error!" -description "Failed to download $macosName ($macOSVers) installer." -icon "$icon" -button1 "CLOSE" -defaultButton 0 -lockHUD

	echo "Script result: Failed to download $macosName ($macOSVers) installer."

	exit 1

fi

}


function downloadInstaller ()
{

# Install using software update
#softwareupdate --fetch-full-installer &

# Install using JAMF policy
jamf policy -id $appPolicyID &

# caffinate the update process
caffeinate -d -i -m -u &
caffeinatepid=$!

# display jamfHelper message
"$jamfHelper" -windowType "hud" -title "$title" -description "Downloading $macosName ($macOSVers) installer

This will take a few minutes..." -icon "$icon" -lockHUD > /dev/null 2>&1 &

while [ ! -d "$macosInstallerPath" ];
		
	do
			
		sleep 2
			
		echo "Script result: searching for macOS installer..."

	done
	
    sleep 60
    
	echo "Script result: BREAK LOOP, found macOS installer file"
    
    killjamfHelper
    
	continueInstall
        
}


function installRequest ()
{

if [ -d "$macosInstallerPath" ]; then

    installerIcon="/Applications/$macosInstallerName/Contents/Resources/InstallAssistant.icns"
    installerOSVER=$(defaults read "/Applications/$macosInstallerName/Contents/Info.plist" DTPlatformVersion)

	# jamfHelper window
	userChoice=$("$jamfHelper" -windowType "hud" -title "$title" -description "Found macOS $macosName ($installerOSVER) installer.
    
Ready to install?" -icon "$installerIcon" -button1 "CANCEL" -button2 "YES" -defaultButton 0 -lockHUD)

	# YES button was pressed
	if [ "$userChoice" == "2" ]; then
    
		validate_power_status
    
    	validate_free_space

		echo "Script result: Installing $macosName ($installerOSVER)"
        
        jamfHelperPID=""
        
        # display jamfHelper message
		"$jamfHelper" -windowType "hud" -title "$title" -description "Computer will reboot shortly to begin the upgrade." -icon "$icon" -lockHUD &

		jamfHelperPID=$!

		"/Applications/$macosInstallerName/Contents/Resources/startosinstall" --agreetolicense --forcequitapps --nointeraction --pidtosignal $jamfHelperPID &
        
        cleanUp

		QuitSelfService
        
        exit 0

   		# CANCEL button was pressed
		elif [ "$userChoice" == "0" ]; then

			echo "Script result: User Canceled (installRequest)"

	fi

else
	
	# jamfHelper window
	"$jamfHelper" -windowType "hud" -title "Error!" -description "Failed to download $macosName ($macOSVers) installer." -icon "$icon" -button1 "CLOSE" -defaultButton 0 -lockHUD

	echo "Script result: Failed to download $macosName ($macOSVers) installer."

	exit 1

fi

}


function killjamfHelper ()
{

	# kill jamfhelper
	killall jamfHelper > /dev/null 2>&1

	# kill the caffinate process
	kill "$caffeinatepid"

}


function QuitSelfService ()
{

	pkill -9 "Self Service"

}


function cleanUp ()
{

	rm -R /private/var/tmp/macOS-*.pkg

}


##################################################################
## main script (do not edit)
##################################################################

validateInstaller

exit 0