#!/bin/sh

####################################################################################################
#
# CREATED BY
#
#   Brian Stutzman (modified script for Policy/Self Service workflows) 
#
#	Paul Bowden (original script)
#	https://github.com/pbowden-msft/msupdatehelper/blob/master/MSUpdateTrigger.sh
#	Version 1.7
#
# DESCRIPTION
#
#	Type: POLICY or Self Service
#
#	Script uses Microsoft AutoUpdate commands to install Microsoft updates for patching policy and 
#	Self Service.
#
# VERSION
#
#	- 1.0
#
# CHANGE HISTORY
#
# 	- Created script - 2/7/2022 (1.0)
#
####################################################################################################


##################################################################
## script variables
##################################################################

# JAMF binary
jamfHelper="/Library/Application Support/JAMF/bin/jamfHelper.app/Contents/MacOS/jamfHelper"

# set jamfHelper window icon
if [ -f "/Library/Application Support/Microsoft/MAU2.0/Microsoft AutoUpdate.app/Contents/Resources/AppIcon.icns" ]; then
	cp -Rp "/Library/Application Support/Microsoft/MAU2.0/Microsoft AutoUpdate.app/Contents/Resources/AppIcon.icns" "/private/var/tmp"
	icon="/private/var/tmp/AppIcon.icns"
else
	cp -Rp "/Applications/Self Service.app/Contents/Resources/AppIcon.icns" "/private/var/tmp"
	icon="/private/var/tmp/AppIcon.icns"
fi

# Set workflow type
workFlowType=$4

# IT Admin constants for application path
PATH_WORD="/Applications/Microsoft Word.app"
PATH_EXCEL="/Applications/Microsoft Excel.app"
PATH_POWERPOINT="/Applications/Microsoft PowerPoint.app"
PATH_OUTLOOK="/Applications/Microsoft Outlook.app"
PATH_ONENOTE="/Applications/Microsoft OneNote.app"
PATH_REMOTEDESKTOP="/Applications/Microsoft Remote Desktop.app"
PATH_EDGE="/Applications/Microsoft Edge.app"
PATH_TEAMS="/Applications/Microsoft Teams.app"
PATH_ONEDRIVE="/Applications/OneDrive.app"

APPID_WORD="MSWD2019"
APPID_EXCEL="XCEL2019"
APPID_POWERPOINT="PPT32019"
APPID_OUTLOOK="OPIM2019"
APPID_ONENOTE="ONMC2019"
APPID_REMOTEDESKTOP="MSRD10"
APPID_EDGE="EDGE01"
APPID_TEAMS="TEAM01"
APPID_ONEDRIVE="ONDR18"

##################################################################
## script functions
##################################################################

# Function to check whether MAU 3.18 or later command-line updates are available
function CheckMAUInstall() {
	if [ ! -e "/Library/Application Support/Microsoft/MAU2.0/Microsoft AutoUpdate.app/Contents/MacOS/msupdate" ]; then
    	echo "Script result: ERROR: MAU 3.18 or later is required!"
    	exit 1
	fi
}

# Function to check whether we are allowed to send Apple Events to MAU
function CheckAppleEvents() {
	MAURESULT=$(${CMD_PREFIX}/Library/Application\ Support/Microsoft/MAU2.0/Microsoft\ AutoUpdate.app/Contents/MacOS/msupdate --config | /usr/bin/grep 'No result returned from Update Assistant')
	if [[ "$MAURESULT" = *"No result returned from Update Assistant"* ]]; then
    	echo "Script result: ERROR: Cannot send Apple Events to MAU. Check privacy settings"
    	exit 1
	fi
}

# Function to check whether MAU is up-to-date
function CheckMAUUpdate() {
	MAUUPDATE=$(${CMD_PREFIX}/Library/Application\ Support/Microsoft/MAU2.0/Microsoft\ AutoUpdate.app/Contents/MacOS/msupdate --list | /usr/bin/grep 'MSau04')
	if [[ "$MAUUPDATE" = *"MSau04"* ]]; then
    	echo "Script result: Updating MAU to latest version... $MAUUPDATE"
    	RESULT=$(${CMD_PREFIX}/Library/Application\ Support/Microsoft/MAU2.0/Microsoft\ AutoUpdate.app/Contents/MacOS/msupdate --install --apps MSau04)
    	sleep 120
	fi
}

# Function to check whether its safe to close Excel because it has no open unsaved documents
function OppCloseExcel() {
	APPSTATE=$(${CMD_PREFIX}/usr/bin/pgrep "Microsoft Excel")
	if [ ! "$APPSTATE" == "" ]; then
		DIRTYDOCS=$(${CMD_PREFIX}/usr/bin/defaults read com.microsoft.Excel NumTotalBookDirty)
		if [ "$DIRTYDOCS" == "0" ]; then
			echo "Script result: Closing Excel as no unsaved documents are open"
			$(${CMD_PREFIX}/usr/bin/pkill -HUP "Microsoft Excel")
		fi
	fi
}

# Function to determine the logged-in state of the Mac
function DetermineLoginState() {
	# The following line is is taken from: https://erikberglund.github.io/2018/Get-the-currently-logged-in-user,-in-Bash/
	CONSOLE="$(/usr/sbin/scutil <<< "show State:/Users/ConsoleUser" | /usr/bin/awk '/Name :/ && ! /loginwindow/ { print $3 }')"
	if [ "$CONSOLE" == "" ]; then
		echo "Script result: No user currently logged in to console - using fall-back account"
        CONSOLE=$(/usr/bin/last -1 -t ttys000 | /usr/bin/awk '{print $1}')
        echo "Script result: Using account $CONSOLE for update"
		userID=$(/usr/bin/id -u "$CONSOLE")
		CMD_PREFIX="/bin/launchctl asuser $userID "
	else
    	echo "Script result: User $CONSOLE is logged in"
    	userID=$(/usr/bin/id -u "$CONSOLE")
		CMD_PREFIX="/bin/launchctl asuser $userID "
	fi
}

# Function to register an application with MAU
function RegisterApp() {
   	$(${CMD_PREFIX}/usr/bin/defaults write com.microsoft.autoupdate2 Applications -dict-add "$1" "{ 'Application ID' = '$2'; LCID = 1033 ; }")
}

# Function to flush any existing MAU sessions
function FlushDaemon() {
	$(${CMD_PREFIX}/usr/bin/defaults write com.microsoft.autoupdate.fba ForceDisableMerp -bool TRUE)
	$(${CMD_PREFIX}/usr/bin/pkill -HUP "Microsoft Update Assistant")
}

# Function to call 'msupdate' and update the target applications
function PerformUpdate() {
	${CMD_PREFIX}/Library/Application\ Support/Microsoft/MAU2.0/Microsoft\ AutoUpdate.app/Contents/MacOS/msupdate --install --apps $1 --wait 600 2>/dev/null
}

# Function to get all available updates
function GetUpdates ()
{
	# data file location
	msupdateFile="/Users/Shared/msupdate_info.txt"
	
	# create text file to output data to
	touch $msupdateFile
	
	# change permissions on text file
	chmod -R 777 $msupdateFile
    
    # dump all available updates to txt file
	${CMD_PREFIX}/Library/Application\ Support/Microsoft/MAU2.0/Microsoft\ AutoUpdate.app/Contents/MacOS/msupdate --list > $msupdateFile
    
    if grep -q "No updates available" $msupdateFile; then
		
		echo "Script result: No updates available"
        
        if [ "$workFlowType" = "Self Service" ]; then
        
        	"$jamfHelper" -windowType "hud" -title "Microsoft Updates" -description "No updates available." -icon "$icon" -button1 "CLOSE" -defaultButton 0 -lockHUD
		
		fi
		
        CleanUp
        
        exit 0
		
	fi

	# self service workflow
	if [ "$workFlowType" = "Self Service" ]; then
        
    	UpdateList=$(cat $msupdateFile | awk 'NR >= 6 && NR <= 20 {print $2, $3, $4, $5}' | sed 's/^/- /')
		
		userChoice=$("$jamfHelper" -windowType "hud" -title "Microsoft Updates" -description "Microsoft updates ready to install:

$UpdateList" -icon "$icon" -button1 "CANCEL" -button2 "YES" -defaultButton 0 -lockHUD)
	
		# YES button was pressed
		if [ "$userChoice" == "2" ]; then
		
			echo "Script result: Installing Microsoft updates"

        	pkill -9 "Microsoft*"
           	pkill -9 "OneDrive"
			pkill -9 "Teams"

			# caffinate the update process
			caffeinate -d -i -m -u &
			caffeinatepid=$!

			# display jamfHelper message
			"$jamfHelper" -windowType "hud" -title "Microsoft Updates" -description "Updates are being downloaded and installed.  Please keep all Microsoft apps closed until updates have completed.

While updates are being performed you can access all Microsoft apps online by going to:

https://www.office.com


This window will close when updates have completed." -icon "$icon" -lockHUD > /dev/null 2>&1 &

			PerformUpdate "$APPID_WORD $APPID_EXCEL $APPID_POWERPOINT $APPID_OUTLOOK $APPID_ONENOTE $APPID_REMOTEDESKTOP $APPID_EDGE $APPID_TEAMS $APPID_ONEDRIVE"

			UpdateCheck

			# CANCEL button was pressed
			elif [ "$userChoice" == "0" ]; then
		
				echo "Script result: User canceled"
		
				CleanUp
		
				exit 0
		
			fi

	else
        
        # policy workflow
		UpdateList=$(cat $msupdateFile | awk 'NR >= 6 && NR <= 20 {print $2, $3, $4, $5}' | sed 's/^/- /')
		
		userChoice=$("$jamfHelper" -windowType "hud" -title "Microsoft Updates" -description "Mandatory updates ready to install:

$UpdateList" -icon "$icon" -button1 "INSTALL" -defaultButton 0 -lockHUD)
	
		# INSTALL button was pressed
		if [ "$userChoice" == "0" ]; then
		
			echo "Script result: Installing Microsoft updates"

        	pkill -9 "Microsoft*"
			pkill -9 "OneDrive"
			pkill -9 "Teams"

			# caffinate the update process
			caffeinate -d -i -m -u &
			caffeinatepid=$!

			# display jamfHelper message
			"$jamfHelper" -windowType "hud" -title "Microsoft Updates" -description "Updates are being downloaded and installed.  Please keep all Microsoft apps closed until updates have completed.

While updates are being performed you can access all Microsoft apps online by going to:

https://login.microsoftonline.com


This window will close when updates have completed." -icon "$icon" -lockHUD > /dev/null 2>&1 &

			PerformUpdate "$APPID_WORD $APPID_EXCEL $APPID_POWERPOINT $APPID_OUTLOOK $APPID_ONENOTE $APPID_REMOTEDESKTOP $APPID_EDGE $APPID_TEAMS $APPID_ONEDRIVE"

			UpdateCheck
                
		fi
        
	fi
}

# Re-check MAU for remaining updates
function UpdateCheck () 
{
	# re-check for updates
	${CMD_PREFIX}/Library/Application\ Support/Microsoft/MAU2.0/Microsoft\ AutoUpdate.app/Contents/MacOS/msupdate --list > $msupdateFile
  
	if grep -q "No updates available" $msupdateFile; then
		
		killjamfHelper
		
		echo "Script result: Updates completed"
		
		"$jamfHelper" -windowType "hud" -title "Microsoft Updates" -description "Microsoft updates have completed." -icon "$icon" -button1 "CLOSE" -defaultButton 0 -lockHUD
		
		CleanUp
		
	else
		
		echo "Script result: Run updates one more time"
		
		PerformUpdate "$APPID_WORD $APPID_EXCEL $APPID_POWERPOINT $APPID_OUTLOOK $APPID_ONENOTE $APPID_REMOTEDESKTOP $APPID_EDGE $APPID_TEAMS $APPID_ONEDRIVE"

		killjamfHelper
		
		CleanUp
		
	fi
}

function killjamfHelper ()
{
	# kill jamfhelper
	killall jamfHelper > /dev/null 2>&1
	
	# kill the caffinate process
	kill "$caffeinatepid"
}

# delete update text file
function CleanUp () 
{
	# remove update list txt file
	if [ -f "$msupdateFile" ]; then
    
    	rm -rf $msupdateFile
    
    	echo "Script result: txt file removed"
    
    else
    
		echo "Script result: txt file not found"
    
    fi
	
	# remove icon
	if [ -f "$icon" ]; then
		
		rm -R $icon
		
		echo "Script result: icon removed"
		
	else
		
		echo "Script result: icon not found"
		
	fi
    
    echo "Script result: Finished - $(/bin/date)"
}

##################################################################
## main script
##################################################################
echo ""
echo "Script result: Started - $(/bin/date)"
DetermineLoginState
CheckMAUInstall
FlushDaemon
CheckAppleEvents
CheckMAUUpdate
FlushDaemon
RegisterApp "$PATH_WORD" "$APPID_WORD"
RegisterApp "$PATH_EXCEL" "$APPID_EXCEL"
RegisterApp "$PATH_POWERPOINT" "$APPID_POWERPOINT"
RegisterApp "$PATH_OUTLOOK" "$APPID_OUTLOOK"
RegisterApp "$PATH_ONENOTE" "$APPID_ONENOTE"
RegisterApp "$PATH_REMOTEDESKTOP" "$APPID_REMOTEDESKTOP"
RegisterApp "$PATH_EDGE $APPID_EDGE"
RegisterApp "$PATH_TEAMS $APPID_TEAMS"
RegisterApp "$PATH_ONEDRIVE $APPID_ONEDRIVE"
OppCloseExcel
GetUpdates

exit 0