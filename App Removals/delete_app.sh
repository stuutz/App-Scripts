#!/bin/bash

####################################################################################################
#
# CREATED BY
#
#   Brian Stutzman
#
# DESCRIPTION
#
#  Type: SELF SERVICE POLICY
#
#	This script (built primarily in Apple Script) will allow the user to remove an application
#	without requiring admin rights.  Only apps in the /Applications folder can be removed.
#
#  Script Features:
#	- Prevent user from deleting any files outside the /Applications folder
#   	- Only ".app" files can be removed from the /Applications folder
#   	- Cannot delete any app that is native to macOS (ex: /System/Applications/Calculator.app)
#	- The user cannot delete specific apps required by the organization (ex: security apps)
#
# VERSION
#
#	- 1.2
#
# CHANGE HISTORY
#
# 	- Created script - 1/19/2022 (1.0)
# 	- Added a process kill command to quit chosen app if running - 1/25/2022 (1.1)
# 	- Fixed issue that prevented apps with a space in the filename to not delete - 5/25/2022 (1.2)
#
####################################################################################################


/usr/bin/osascript -e '
display dialog "Select the application to remove." buttons {"Cancel", "Continue"} default button "Cancel"

set strPath to POSIX file "/Applications/"
set chosenApp to choose file default location strPath
set appPath to POSIX path of chosenApp
set verPath to do shell script "echo " & appPath & " | cut -c 1-13"
set verSysPath to do shell script "echo " & appPath & " | cut -c 1-20"
set appPath to do shell script "echo " & appPath & " | sed 's/.$//'"
set appName to do shell script "echo " & appPath & " | cut -c 15-"
set appExt to do shell script "echo " & appPath & " | tail -c 5"
set appNameOnly to do shell script "echo " & appPath & " | cut -c 15- | sed 's/[.].*$//'"

----------------------------------------
-- cannot remove the following apps
----------------------------------------
set secApp1 to "GlobalProtect.app"
set secApp2 to "Netskope Client.app"
set secApp3 to "Remove Netskope Client.app"
set secApp4 to "QualysCloudAgent.app"
set secApp5 to "Falcon.app"
set secApp6 to "Safari.app"
set secApp7 to "NoMAD.app"
set secApp8 to "Self Service.app"

if appName = secApp1 or appName = secApp2 or appName = secApp3 or appName = secApp4 or appName = secApp5 or appName = secApp6 or appName = secApp7 or appName = secApp8 then
	
	display dialog "The selected application cannot be removed." buttons {"Close"}
	error number -128
	
end if

----------------------------------------
-- native macOS apps cannot be removed
----------------------------------------
set appSysLocation to "/System/Applications"
if appSysLocation = verSysPath then
	
	display dialog "The selected application is required by macOS." buttons {"Close"}
	error number -128
	
end if

----------------------------------------
-- only apps that reside in the Applications folder can be deleted
----------------------------------------
set appLocation to "/Applications"
if appLocation = verPath then
	
	-- only files with .app can be removed
	set appReq to ".app"
	if appExt = appReq then
		
		set appVersion to version of application named chosenApp
		
		-- show confirmation window
		tell application "Finder"
			display dialog "Remove the following application? 

Name:		" & (appName) & "
Version:		" & (appVersion) & "
Path:		" & (appPath) & "" buttons {"Cancel", "Yes"} default button "Cancel"
			
		end tell
		
		if button returned of result = "Yes" then
			
			-- command to quit and remove selected app
            tell application appNameOnly
				quit
			end tell
			do shell script "rm -rf " & quoted form of appPath
			
		end if
		
	else
		
        display dialog "The selected file is not an application." buttons {"Close"}
		error number -128
		
	end if
	
else
	
	display dialog "The selected file is not in the Applications folder." buttons {"Close"}
	error number -128
	
end if
'
