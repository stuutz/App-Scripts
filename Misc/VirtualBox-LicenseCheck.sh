#!/bin/bash

####################################################################################################
#
# CREATED BY
#
#   Brian Stutzman
#
# DESCRIPTION
#
#   This script will check if Oracle VirtualBox app is installed as well as any Extension Packs.
#
# SCRIPT TYPE 
#
#	POLICY
#
# SCRIPT VERSION
#
#	1.1
#
# CHANGE HISTORY
#
# - Created (1.0) - 4/8/20
# - Fixed the logged in user variable by removing python command (1.1) - 1/11/22
#
####################################################################################################


##################################################################
# Script Variables
##################################################################

userNAME=$(echo "show State:/Users/ConsoleUser" | scutil | awk '/Name :/ && ! /loginwindow/ {print $3}')
computerNAME=$(scutil --get ComputerName)
dateFORMAT=$(date +"%m-%d-%Y %H:%M:%S")
osVersion=$(sw_vers -productVersion)
adminAccts=$(dscl . -read /Groups/admin GroupMembership | sed 's/root//g; s/GroupMembership://g' | awk '{print $1,$2,$3,$4,$5,$6,$7,$8,$9,$10}')
fullName=$(finger | grep "$userNAME" | sed -n 1p | awk '{print $2,$3}')
en0IP=$(ipconfig getifaddr en0)
en1IP=$(ipconfig getifaddr en1)
en3IP=$(ipconfig getifaddr en3)
en5IP=$(ipconfig getifaddr en5)
en8IP=$(ipconfig getifaddr en8)

##################################################################
# main script
##################################################################

echo "==============Computer Information==============="
echo "Date: $dateFORMAT"
echo "Name: $fullName ($userNAME)"
echo "Computer Name: $computerNAME"
echo "macOS: $osVersion"
echo "Administrators: $adminAccts"
echo "en0 IP: $en0IP"
echo "en1 IP: $en1IP"
echo "en3 IP: $en3IP"
echo "en5 IP: $en5IP"
echo "en8 IP: $en8IP"
echo ""
echo ""

appDate=$(date -r /Applications/VirtualBox.app "+%m-%d-%Y %H:%M:%S")
app=$(ls /Applications | grep -c "VirtualBox.app")
if [ $app = "0" ]; then
	appStatus="No"
else
	appStatus="Yes"
fi

echo "==============Application Information==============="
echo "VirtualBox Installed: $appStatus"
echo "Installed/Modified Date: $appDate"
echo ""
echo ""

vblic=$(VBoxManage list extpacks)

echo "==============List Extension Packs==============="
echo "$vblic"
echo ""
echo ""

extpack=$(ls /Applications/VirtualBox.app/Contents/MacOS/ExtensionPacks/Oracle_VM_VirtualBox_Extension_Pack | grep -c "ExtPack-license.html")

if [ $extpack = "0" ]; then
	epcheck="ExtPack-license.html - File Not Found"
else
	epcheck="ExtPack-license.html - File Found"
fi

echo "===========License File Check============"
echo "$epcheck"

exit 0