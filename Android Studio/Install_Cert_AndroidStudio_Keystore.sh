#!/bin/bash

####################################################################################################
#
# CREATED BY
#
#   Brian Stutzman
#
# DESCRIPTION
#
#	Installs certificate bundle into Android Studio Java keystore.
#
# VERSION
#
#	- 1.0
#
# CHANGE HISTORY
#
# 	- Created script - 5/20/2022 (1.0)
#
####################################################################################################

DIALOG=$(/usr/bin/osascript -e '
display dialog "Select the certificate file.

Note: Select Get PEM below if the file does not exist.  You have to run the cert_bundle script to generate this file." buttons {"Cancel", "Get PEM", "Continue"} default button "Cancel" with title "Android Studio Keystore"

set the button_pressed to the button returned of the result
if the button_pressed is "Get PEM" then
	open location "FULL WEBSITE URL HERE"
	error "User canceled." number -128
end if

set strPath to POSIX file "/Users/"
set chosenFile to choose file default location strPath
set appPath to POSIX path of chosenFile
#do shell script "keytool -import -keystore /Applications/Android\ Studio.app/contents/jre/Contents/Home/lib/security/cacerts -file " & appPath & ""
#do shell script "echo " & appPath & ""
')

sudo keytool -storepasswd -new changeit -keystore /Applications/Android\ Studio.app/Contents/jre/Contents/Home/lib/security/cacerts -storepass changeit
sudo keytool -–importcert -file /$DIALOG -keystore /Applications/Android\ Studio.app/Contents/jre/Contents/Home/lib/security/cacerts -alias "CERT_NAME_HERE" -noprompt -storepass changeit		


