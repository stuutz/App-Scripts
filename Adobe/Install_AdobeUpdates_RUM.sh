#!/bin/bash

####################################################################################################
#
# CREATED BY
#
#   Brian Stutzman
#
# DESCRIPTION
#
#	Type: POLICY 
#   - This can be ran against all computers or scoped to a specific JAMF group.
# 	- Create second policy to handle install (/usr/local/bin/RemoteUpdateManager --action=install)
#
#	Features:
#   - Inform the user which Adobe apps have updates
#   - The user can choose to install now or wait until the count down timer expires
#   - All Adobe apps will quit during the install process
#   - Download and install all available Adobe updates
#   - When finished the prompts will go away
#   - If there are no updates available it will not impact the user
#   - The script will fail (exit 1) if no user is signed in
#
# VERSION
#
#   - 1.0
#
# CHANGE HISTORY
#
#   - Created script - 3/25/2022 (1.0)
#
####################################################################################################

##################################################################
## Script variables
##################################################################
startDate=$(date | awk '{print $1,$2,$3,$6,$4,$5}')
user=$(echo "show State:/Users/ConsoleUser" | scutil | awk '/Name :/ && ! /loginwindow/ {print $3}')
hostName=$(hostname)
rum=/usr/local/bin/RemoteUpdateManager
rumlog=/var/tmp/RUMupdate.log
rumlogMOD=/var/tmp/RUMupdateMOD.log
jamfHelper="/Library/Application Support/JAMF/bin/jamfHelper.app/Contents/MacOS/jamfHelper"
icon="/Applications/Utilities/Adobe Creative Cloud/ACC/Creative Cloud.app/Contents/Resources/CreativeCloudApp.icns"
# Measured in seconds (3600=60mins)
timer=7200
# Timer Alignment = (left, right, center)
timerpos=right

##################################################################
## Script functions
##################################################################

# User login verification (fail script if no user is signed in)
function GetLoginUser ()
{

	if [ "$user" == "" ]; then
		
		echo "Script result: No user logged in"
		
		# This will cause the policy to fail
		exit 1
		
	else
		
		echo "Script result: $user logged in on $hostName"
		
	fi
	
}

# Close Adobe apps
function CloseApps ()
{
	
# Non-year specific apps

if [ -d  "/Applications/Adobe Creative Cloud" ]; then
	echo "Script result: Found Adobe Creative Cloud, killing process"
	pkill -9 "Creative Cloud"
fi

if [ -d  "/Applications/Adobe Acrobat DC" ]; then
	echo "Script result: Found Adobe Acrobat DC, killing process"
	pkill -9 "AdobeAcrobat"
fi

if [ -d  "/Applications/Adobe Lightroom Classic" ]; then
	echo "Script result: Found Adobe Lightroom Classic, killing process"
	pkill -9 "Adobe Lightroom Classic"
fi

if [ -d  "/Applications/Adobe Lightroom CC" ]; then
	echo "Script result: Found Adobe Lightroom CC, killing process"
	pkill -9 "Adobe Lightroom"
fi

if [ -d  "/Applications/Adobe XD" ]; then
	echo "Script result: Found Adobe XD, killing process"
	pkill -9 "Adobe XD"
fi

if [ -d  "/Applications/Adobe Premiere Rush 2.0" ]; then
	echo "Script result: Found Adobe Premiere Rush 2.0, killing process"
	pkill -9 "Adobe Premiere Rush"
fi

if [ -d  "/Applications/Adobe Dimension" ]; then
	echo "Script result: Found Adobe Dimension, killing process"
	pkill -9 "Adobe Dimension"
fi

# 2022 Version Apps

if [ -d  "/Applications/Adobe After Effects 2022" ]; then
	echo "Script result: Found Adobe After Effects 2022, killing process"
	pkill -9 "After Effects"
fi

if [ -d  "/Applications/Adobe Illustrator 2022" ]; then
	echo "Script result: Found Adobe Illustrator 2022, killing process"
	pkill -9 "Adobe Illustrator"
fi

if [ -d  "/Applications/Adobe InDesign 2022" ]; then
	echo "Script result: Found Adobe InDesign 2022, killing process"
	pkill -9 "Adobe InDesign 2022"
fi

if [ -d  "/Applications/Adobe Media Encoder 2022" ]; then
	echo "Script result: Found Adobe Media Encoder 2022, killing process"
	pkill -9 "Adobe Media Encoder 2022"
fi

if [ -d  "/Applications/Adobe Photoshop 2022" ]; then
	echo "Script result: Found Adobe Photoshop 2022, killing process"
	pkill -9 "Adobe Photoshop 2022"
fi

if [ -d  "/Applications/Adobe Premiere Pro 2022" ]; then
	echo "Script result: Found Adobe Premiere Pro 2022, killing process"
	pkill -9 "Adobe Premiere Pro 2022"
fi

if [ -d  "/Applications/Adobe Bridge 2022" ]; then
	echo "Script result: Found Adobe Bridge 2022, killing process"
	pkill -9 "Adobe Bridge 2022"
fi

if [ -d  "/Applications/Adobe Audition 2022" ]; then
	echo "Script result: Found Adobe Audition 2022, killing process"
	pkill -9 "Adobe Audition 2022"
fi

if [ -d  "/Applications/Adobe Character Animator 2022" ]; then
	echo "Script result: Found Adobe Character Animator 2022, killing process"
	pkill -9 "Character Animator"
fi

if [ -d  "/Applications/Adobe InCopy 2022" ]; then
	echo "Script result: Found Adobe InCopy 2022, killing process"
	pkill -9 "Adobe InCopy 2022"
fi

if [ -d  "/Applications/Adobe Animate 2022" ]; then
	echo "Script result: Found Adobe Animate 2022, killing process"
	pkill -9 "Adobe Animate 2022"
fi

# 2021 Versions

if [ -d  "/Applications/Adobe After Effects 2021" ]; then
	echo "Script result: Found Adobe After Effects 2021, killing process"
	pkill -9 "After Effects"
fi

if [ -d  "/Applications/Adobe Illustrator 2021" ]; then
	echo "Script result: Found Adobe Illustrator 2021, killing process"
	pkill -9 "Adobe Illustrator"
fi

if [ -d  "/Applications/Adobe InDesign 2021" ]; then
	echo "Script result: Found Adobe InDesign 2021, killing process"
	pkill -9 "Adobe InDesign 2021"
fi

if [ -d  "/Applications/Adobe Media Encoder 2021" ]; then
	echo "Script result: Found Adobe Media Encoder 2021, killing process"
	pkill -9 "Adobe Media Encoder 2021"
fi

if [ -d  "/Applications/Adobe Photoshop 2021" ]; then
	echo "Script result: Found Adobe Photoshop 2021, killing process"
	pkill -9 "Adobe Photoshop 2021"
fi

if [ -d  "/Applications/Adobe Premiere Pro 2021" ]; then
	echo "Script result: Found Adobe Premiere Pro 2021, killing process"
	pkill -9 "Adobe Premiere Pro 2021"
fi

if [ -d  "/Applications/Adobe Bridge 2021" ]; then
	echo "Script result: Found Adobe Bridge 2021, killing process"
	pkill -9 "Adobe Bridge 2021"
fi

if [ -d  "/Applications/Adobe Audition 2021" ]; then
	echo "Script result: Found Adobe Audition 2021, killing process"
	pkill -9 "Adobe Audition 2021"
fi

if [ -d  "/Applications/Adobe Character Animator 2021" ]; then
	echo "Script result: Found Adobe Character Animator 2021, killing process"
	pkill -9 "Character Animator"
fi

if [ -d  "/Applications/Adobe InCopy 2021" ]; then
	echo "Script result: Found Adobe InCopy 2021, killing process"
	pkill -9 "Adobe InCopy 2021"
fi

if [ -d  "/Applications/Adobe Animate 2021" ]; then
	echo "Script result: Found Adobe Animate 2021, killing process"
	pkill -9 "Adobe Animate 2021"
fi

if [ -d  "/Applications/Adobe Dreamweaver 2021" ]; then
	echo "Script result: Found Adobe Dreamweaver 2021, killing process"
	pkill -9 "Dreamweaver"
fi
	
}

# Recheck RUM
function reRUM ()
{
    
	# Delete RUM log
	rm -rf $rumlog
	
	# Create RUMupdate.log, change file permissions and output RUM contents
	touch $rumlog
	chmod -R 777 $rumlog
	$rum --action=list > $rumlog
	
    echo ""	
    echo "======================================"
	echo "RE-CHECK RUM -- START"
	echo "======================================"
	echo ""
	
    printLog=$(cat $rumlog)
    echo "$printLog"
    
	endDate=$(date | awk '{print $1,$2,$3,$6,$4,$5}')
    
	echo ""	
    echo "======================================"
	echo "RE-CHECK RUM -- END"
    echo "$endDate"
	echo "======================================"
	echo ""
    
    killjamfHelper

}

function killjamfHelper ()
{
	# kill jamfhelper
	killall jamfHelper > /dev/null 2>&1
	
	# kill the caffinate process
	kill "$caffeinatepid"
}

# Clean up files
function CleanUp ()
{

	# Delete RUM log
	rm -rf $rumlog

	# Exit script
	exit 0
	
}

##################################################################
## Main script
##################################################################
echo ""

echo "======================================"
echo "RUM -- START" 
echo "$startDate"
echo "======================================"
echo ""

# Script will 'exit 1' (fail) if user not logged in
GetLoginUser

# Create RUMupdate.log
touch $rumlog

# Change file permissions
chmod -R 777 $rumlog

# Output RUM contents to file
$rum --action=list > $rumlog

# Remove lines from log file
grep -v "RemoteUpdateManager" $rumlog > $rumlogMOD && mv $rumlogMOD $rumlog
awk 'BEGIN {FS="("};{print $NF}' $rumlog > $rumlogMOD && mv $rumlogMOD $rumlog

# Get the number of updates available from RUMupdate.log
updateCount=$(grep -c ")" $rumlog)

if [ "$updateCount" = "0" ] ; then

	echo "Script result: No Updates Found"
    
	endDate=$(date | awk '{print $1,$2,$3,$6,$4,$5}')
    
	echo ""	
    echo "======================================"
	echo "RUM -- END"
    echo "$endDate"
	echo "======================================"
	echo ""
	
	CleanUp
	
else
	
	# Clean up the jamfHelper window to show what updates are available
	secho=`sed 's/Following Updates are applicable on the system :/Mandatory Adobe updates are ready to install:/g' $rumlog \
		| sed '/RemoteUpdateManager exiting with Return Code (0)/d' \
		| sed '1d' \
		| sed '2d' \
		| sed '/RemoteUpdateManager version is/d' \
		| sed '/No new updates are available for Acrobat/d' \
		| sed '/Reader/d' \
		| sed '/Starting the RemoteUpdateManager.../d' \
		| sed '/*/d' \
		| sed '/AdobeAcrobatDC/d' \
		| sed 's/ACR/• Adobe Camera Raw -/g' \
		| sed 's/COMP/• Adobe Comp CC -/g' \
		| sed 's/AEFT/• After Effects -/g' \
		| sed 's/AME/• Media Encoder -/g' \
		| sed 's/AUDT/• Audition -/g' \
		| sed 's/FLPR/• Animate -/g' \
		| sed 's/ILST/• Illustrator -/g' \
		| sed 's/MUSE/• Muse -/g' \
		| sed 's/PHSP/• Photoshop -/g' \
		| sed 's/PRLD/• Prelude -/g' \
		| sed 's/SPRK/• XD -/g' \
		| sed 's/KBRG/• Bridge -/g' \
		| sed 's/AICY/• InCopy -/g' \
		| sed 's/ANMLBETA/• Character Animator Beta -/g' \
		| sed 's/DRWV/• Dreamweaver -/g' \
		| sed 's/IDSN/• InDesign -/g' \
		| sed 's/PPRO/• Premiere Pro -/g' \
		| sed 's/LTRM/• Lightroom Classic -/g' \
		| sed 's/CHAR/• Character Animator -/g' \
		| sed 's/LIBS/• Creative Cloud Libraries -/g' \
		| sed 's/CCXP/• CCXProcess -/g' \
		| sed 's/COSY/• CoreSync -/g' \
		| sed 's/ACAI/• Adobe Content Authenticity Initiative -/g' \
		| sed 's/ESHR/• Dimension -/g' \
		| sed 's/LRCC/• Lightroom CC -/g' \
		| sed 's/RUSH/• Premiere Rush -/g' \
		| sed 's/FUSE/• Fuse -/g' \
		| sed 's/\//(/g' \
		| sed 's/(/\ /g' \
		| sed 's/)/\ /g' \
		| sed 's/osx10-64//g' \
		| sed 's/osx10//g' \
		| sed 's/macarm64//g' \
		| sed 's/ macuniversal //g'`
	
	"$jamfHelper" -windowType hud -lockHUD -title "Found ($updateCount) Adobe Updates" -description "$secho

Adobe apps will be closed.  Please SAVE your work.

Updates will start automatically in:" -button1 "Install Now" -defaultButton 0 -icon "$icon" -lockHUD -timeout $timer -countdown -countdownPrompt "" -alignCountdown $timerpos

	CloseApps

	echo "$secho"
	
	# caffinate the update process
	caffeinate -d -i -m -u &
	caffeinatepid=$!
    
	"$jamfHelper" -windowType "hud" -title "Installing ($updateCount) Adobe Updates" -description "DO NOT open Adobe apps while updates are installing.

This window will close when all updates have completed." -icon "$icon" -lockHUD > /dev/null 2>&1 &

	# Execute the install policy
	/usr/local/bin/jamf policy -id 1451
    
	echo ""
	echo "======================================"
	echo "RUM -- END"
	echo "======================================"
	echo ""
    
    reRUM
    
    CleanUp
	
fi
