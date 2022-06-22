#!/bin/bash


## Close AEM app
    osascript -e 'tell application "Adobe Experience Manager Desktop" to quit'

sleep 3

########################################################################
## Do a completed uninstall of AEM
########################################################################

echo "Removing Cache directory"
rm -rf ~/Library/Caches/com.adobe.aem.desktop

echo "Removing Application Support directory"
rm -rf ~/Library/Application\ Support/com.adobe.aem.desktop

echo "Removing local cache directory"
rm -rf ~/Library/Group\ Containers/group.com.adobe.aem.desktop

echo "Removing Pre-1.3 Cache directory"
rm -rf ~/Library/Caches/com.adobe.aem.assetscompanion

echo "Removing Pre-1.3 Application Support directory"
rm -rf ~/Library/Application\ Support/com.adobe.aem.assetscompanion

echo "Removing Pre-1.3 local cache directory"
rm -rf ~/Library/Group\ Containers/group.com.adobe.aem.assetscompanion

########################################################################

echo "Removing Application directory"
rm -rf /Applications/Adobe\ Experience\ Manager\ Desktop.app

echo "Removing finder integration directory"
rm -rf ~/Library/Containers/com.adobe.aem.desktop.finderintegration-plugin

echo "Removing Pre-1.3 Application directory"
rm -rf /Applications/AEM\ Assets\ Companion.app

echo "Removing Pre-1.3 finder integration directory"
rm -rf ~/Library/Containers/com.adobe.aem.assetscompanion.finderintegration-plugin

########################################################################

echo "Successfully removed all files."


exit 0
