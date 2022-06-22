#!/bin/bash

####################################################################################################
#
# CREATED BY
#
#   Brian Stutzman
#
# DESCRIPTION
#	This script will remove standalone conferencing applications and related files from the
#	computer. 
#
# VERSION
#
#	- 1.0
#
# CHANGE HISTORY
#
# 	- Created script - 5/28/20 (1.0)
#
####################################################################################################


##################################################################
# Script variables
##################################################################

user=$(/usr/bin/python -c 'from SystemConfiguration import SCDynamicStoreCopyConsoleUser; import sys; username = (SCDynamicStoreCopyConsoleUser(None, None, None) or [None])[0]; username = [username,""][username in [u"loginwindow", None, u""]]; sys.stdout.write(username + "\n");')
fullname=`finger | grep "$user" | sed -n 1p | awk '{print $2,$3}'`
computer=$(scutil --get ComputerName)
date=$(date +"%m-%d-%Y %H:%M:%S")


##################################################################
# Script functions
##################################################################

function gotomeeting ()
{
	if [ -d /Applications/GoToMeeting* ] || [ -d /Users/$user/Applications/GoToMeeting* ]; then
		
		echo "GoToMeeting: Installed"
		
		# Kill process
		pkill -9 "GoToMeeting"
		
		sleep 2
		
		# Remove Files
		rm -rf /Applications/GoToMeeting*
		rm -rf /Users/$user/Applications/GoToMeeting*
		rm -rf "/Users/$user/Library/Application Support/LogMeInInc"
		rm -rf "/Users/$user/Library/Application Support/GoToOpener"
		rm -rf "/Users/$user/Library/Caches/com.logmein"
		rm -rf "/Users/$user/Library/Preferences/com.logmein.G2MAIRUploader.plist"
		rm -rf "/Users/$user/Library/Preferences/com.logmein.G2MUpdate.plist"
		rm -rf "/Users/$user/Library/Preferences/com.logmein.GoToMeeting.plist"
		rm -rf "/Users/$user/Library/Preferences/com.logmein.mac.GoToOpener.plist"
		rm -rf "/Users/$user/Library/Preferences/ByHost/com.logmein.GoToMeeting.24B66719-C849-54B0-B609-62819F2598F7.plist"
		rm -rf "/Users/$user/Library/Logs/com.logmein.GoToMeeting"
		rm -rf "/Users/$user/Library/Logs/com.logmein.GoToOpener"
		rm -rf "/Users/$user/Library/LaunchAgents/com.logmein.GoToMeeting.G2MAIRUploader.plist"
		rm -rf "/Users/$user/Library/LaunchAgents/com.logmein.GoToMeeting.G2MUpdate.plist"
		rm -rf "/Users/$user/Library/Saved Application State/com.logmein.GoToMeeting.savedState"
		rm -rf "/private/var/folders/1l/d72x48456md1mp9kxhmgk4_46dmwbm/C/com.logmein.GoToMeeting"
		rm -rf "/private/var/folders/1l/d72x48456md1mp9kxhmgk4_46dmwbm/C/com.logmein.mac.GoToOpener"
		
	else
		
		echo "GoToMeeting: Not Installed"
		
	fi
}

function zoom ()
{
	if [ -d "/Applications/zoom.us.app" ] || [ -d "/Users/$user/Applications/zoom.us.app" ]; then
		
		echo "Zoom: Installed"
		
		# Kill process
		pkill -9 "zoom.us"
		
		sleep 2
		
		# Remove Files
		rm -rf "/Applications/zoom.us.app"
		rm -rf "/Users/$user/Applications/zoom.us.app"
		rm -rf "/Users/$user/.zoomus"
		rm -rf "/System/Library/Extensions/ZoomAudioDevice.kext"
		rm -rf "/Users/$user/Library/Application Support/zoom.us"
		rm -rf "/Users/$user/Library/Caches/us.zoom.xos"
		rm -rf "/Users/$user/Library/Logs/zoom.us"
		rm -rf "/Users/$user/Library/Logs/zoominstall.log"
		rm -rf "/Users/$user/Library/Logs/ZoomPhone"
		rm -rf "/Users/$user/Library/Preferences/us.zoom.xos.plist"
		rm -rf "/Users/$user/Library/Preferences/ZoomChat.plist"
		rm -rf "/Users/$user/Library/Saved Application State/us.zoom.xos.savedState"
		rm -rf "/Users/$user/Library/Cookies/us.zoom.xos.binarycookies"
		rm -rf "/private/var/folders/1l/d72x48456md1mp9kxhmgk4_46dmwbm/C/us.zoom.xos"
		rm -rf "/private/var/folders/1l/d72x48456md1mp9kxhmgk4_46dmwbm/C/us.zoom.ZoomUninstaller"
		
	else
		
		echo "Zoom: Not Installed"
		
	fi
}

function skype ()
{
	if [ -d "/Applications/Skype.app" ] || [ -d "/Users/$user/Applications/Skype.app" ]; then
		
		echo "Skype: Installed"
		
		# Kill process
		pkill -9 "Skype"
		
		sleep 2
		
		# Remove Files
		rm -rf "/Applications/Skype.app"
		rm -rf "/Users/$user/Applications/Skype.app"
		rm -rf "/Users/$user/Library/Application Support/Skype"
		rm -rf "/Users/$user/Library/Application Support/Microsoft/Skype for Desktop"
		rm -rf "/Users/$user/Library/Preferences/com.skype.skype.plist"
		rm -rf "/Users/$user/Library/Preferences/ByHost/com.skype.skype.ShipIt.24B66719-C849-54B0-B609-62819F2598F7.plist"
		rm -rf "/Users/$user/Library/Caches/com.skype.skype.ShipIt"
		rm -rf "/Users/$user/Library/Caches/com.skype.skype"
		rm -rf "/Users/$user/Library/Logs/Skype"
		rm -rf "/Users/$user/Library/Saved Application State/com.skype.skype.savedState"
		rm -rf "/private/var/folders/1l/d72x48456md1mp9kxhmgk4_46dmwbm/C/com.skype.skype"
		rm -rf "/private/var/folders/1l/d72x48456md1mp9kxhmgk4_46dmwbm/T/Skype Helper (Renderer)"
		rm -rf "/private/var/folders/1l/d72x48456md1mp9kxhmgk4_46dmwbm/T/skype-preview Crashes"
		
	else
		
		echo "Skype: Not Installed"
		
	fi
}

function skypefb ()
{
	if [ -d "/Applications/Skype for Business.app" ] || [ -d "/Users/$user/Applications/Skype for Business.app" ]; then
		
		echo "Skype for Business: Installed"
		
		# Kill process
		pkill -9 "Skype for Business"
		
		sleep 2
		
		# Remove Files
		rm -rf "/Applications/Skype for Business.app"
		rm -rf "/Users/$user/Applications/Skype for Business.app"
		rm -rf "/Library/Internet Plug-Ins/MeetingJoinPlugin.plugin"
		defaults delete com.microsoft.SkypeForBusiness || true
		rm -rf "/Users/$user/Library/Containers/com.microsoft.SkypeForBusiness"
		rm -rf "/Users/$user/Library/Logs/DiagnosticReports/Skype for Business_*"
		rm -rf "/Users/$user/Library/Saved Application State/com.microsoft.SkypeForBusiness.savedState"
		rm -rf "/Users/$user/Library/Preferences/com.microsoft.SkypeForBusiness.plist"
		rm -rf "/Users/$user/Library/Application Support/CrashReporter/Skype for Business_*"
		rm -rf "/Users/$user/Library/Application Support/com.apple.sharedfilelist/com.apple.LSSharedFileList.ApplicationRecentDocuments/com.microsoft.skypeforbusiness*"
		rm -rf "/Users/$user/Library/Logs/LwaTracing"
		rm -rf "/Users/$user/Library/Cookies/com.microsoft.SkypeForBusiness*"
		rm -rf "/private/var/db/receipts/com.microsoft.SkypeForBusiness*"
		rmdir "/Users/$user/Library/Application Scripts/com.microsoft.SkypeForBusiness"
		rm -rf "/private/var/db/receipts/com.microsoft.SkypeForBusiness.bom"
		rm -rf "/private/var/db/receipts/com.microsoft.SkypeForBusiness.plist"
		rm -rf "/private/var/folders/1l/d72x48456md1mp9kxhmgk4_46dmwbm/C/com.microsoft.SkypeForBusiness"
		rm -rf "/private/var/folders/1l/d72x48456md1mp9kxhmgk4_46dmwbm/T/com.microsoft.SkypeForBusiness"
		find -f /private/var/db/BootCaches/* -name "app.com.microsoft.SkypeForBusiness*" -exec sudo rm -rf {} +
		security delete-generic-password -l "Skype for Business"
		
	else
		
		echo "Skype for Business: Not Installed"
		
	fi
}

function ciscowebexmeetings ()
{
	if [ -d "/Applications/Cisco Webex Meetings.app" ] || [ -d "/Users/$user/Applications/Cisco Webex Meetings.app" ]; then
		
		echo "Cisco Webex Meetings: Installed"
		
		# Kill process
		pkill -9 "Cisco Webex Meetings"
		
		sleep 2
		
		# Remove Files
		rm -rf "/Applications/Cisco Webex Meetings.app"
		rm -rf "/Users/$user/Applications/Cisco Webex Meetings.app"
		rm -rf "/Users/$user/Library/Caches/com.cisco.webex.Cisco-WebEx-Start"
		rm -rf "/Users/$user/Library/Caches/com.cisco.webex.webexmta"
		rm -rf "/Users/$user/Library/Group Containers/group.com.cisco.webex.meetings"
		rm -rf "/private/var/folders/1l/d72x48456md1mp9kxhmgk4_46dmwbm/C/com.cisco.webex.Cisco-WebEx-Start.CWSSafariExtension"
		rm -rf "/private/var/folders/1l/d72x48456md1mp9kxhmgk4_46dmwbm/C/com.cisco.webexmeetingsapp"
		rm -rf "/private/var/folders/1l/d72x48456md1mp9kxhmgk4_46dmwbm/C/com.webex.meetingmanager"
		rm -rf "/Users/$user/Library/Application Support/WebEx Folder"
		rm -rf "/Users/$user/Library/Application Support/Cisco/WebEx Meetings"
		rm -rf "/Users/$user/Library/Internet Plug-Ins/WebEx64.plugin"
		rm -rf "/Users/$user/Library/Preferences/com.cisco.webex.casl_info.plist"
		rm -rf "/Users/$user/Library/Preferences/com.cisco.webex.Cisco-WebEx-Start.plist"
		rm -rf "/Users/$user/Library/Preferences/com.cisco.webexmeetingsapp.plist"
		rm -rf "/Users/$user/Library/Preferences/com.webex.eventcenter.plist"
		rm -rf "/Users/$user/Library/Preferences/com.webex.meetingmanager.plist"
		rm -rf "/Users/$user/Library/Preferences/webex.com*"
		rm -rf "/Users/$user/Library/Saved Application State/com.cisco.webexmeetingsapp.savedState"
		rm -rf "/Users/$user/Library/Logs/webexmta"
		rm -rf "/Users/$user/Library/Application Scripts/com.cisco.webex.Cisco-WebEx-Start.CWSSafariExtension"
		rm -rf .Webex
		
	else
		
		echo "Cisco Webex Meetings: Not Installed"
		
	fi
}

function bluejeans ()
{
	if [ -d "/Applications/BlueJeans.app" ] || [ -d "/Users/$user/Applications/BlueJeans.app" ]; then
		
		echo "BlueJeans: Installed"
		
		# Kill process
		pkill -9 "BlueJeans*"
		launchctl remove com.bluejeansnet.BlueJeansHelper
		launchctl remove com.bluejeansnet.BlueJeansMenu
		
		sleep 2
		
		# Remove Files
		rm -rf "/Applications/BlueJeans.app"
		rm -rf "/Users/$user/Applications/BlueJeans.app"
		rm -rf "/Users/$user/Library/Application Support/Blue Jeans"
		rm -rf "/Users/$user/Library/Application Support/com.bluejeansnet.Blue"
		rm -rf "/Users/$user/Library/Caches/com.bluejeansnet.Blue"
		rm -rf "/Users/$user/Library/LaunchAgents/com.bluejeansnet.BlueJeansMenu.plist"
		rm -rf "/Users/$user/Library/Logs/BlueJeans"
		rm -rf "/Users/$user/Library/Preferences/com.bluejeansnet.Blue.plist"
		rm -rf "/private/var/folders/1l/d72x48456md1mp9kxhmgk4_46dmwbm/C/com.bluejeansnet.Blue"
		rm -rf "/private/var/folders/1l/d72x48456md1mp9kxhmgk4_46dmwbm/C/com.bluejeansnet.BlueMenulet"
		
	else
		
		echo "BlueJeans: Not Installed"
		
	fi
}

##################################################################
# Main script
##################################################################
echo ""
echo "*******************************************************"
echo "User: $fullname"
echo "Computer: $computer"
echo "Date: $date"
echo "*******************************************************"
echo "STARTING FILE REMOVALS"
echo "*******************************************************"
gotomeeting
zoom
skype
skypefb
ciscowebexmeetings
bluejeans
echo "*******************************************************"
echo "COMPLETED FILE REMOVALS"
echo "*******************************************************"


exit 0

