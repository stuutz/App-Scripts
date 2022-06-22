#!/bin/sh

dmgfile="uninstall_flash_player_osx.dmg"
volname="Flash"

url="https://fpdownload.macromedia.com/get/flashplayer/current/support/uninstall_flash_player_osx.dmg"


	currentinstalledver=`/usr/bin/defaults read "/Library/Internet Plug-Ins/Flash Player.plugin/Contents/version" CFBundleShortVersionString`
	if [ "${currentinstalledver}" ]; then
		/bin/echo "`date`: Downloading uninstaller."
		/usr/bin/curl -s -o /tmp/$dmgfile $url
		/bin/echo "`date`: Mounting uninstaller disk image."
		/usr/bin/hdiutil attach /tmp/$dmgfile -nobrowse -quiet
		/bin/echo "`date`: Uninstalling..."
		/Volumes/Flash\ Player/Adobe\ Flash\ Player\ Uninstaller.app/Contents/MacOS/Adobe\ Flash\ Player\ Install\ Manager -uninstall> /dev/null
		/bin/sleep 10
		/bin/echo "`date`: Unmounting uninstaller disk image."
		/usr/bin/hdiutil detach $(/bin/df | /usr/bin/grep ${volname} | awk '{print $1}') -quiet
		/bin/sleep 10
		/bin/echo "`date`: Deleting disk image."
		/bin/rm /tmp/${dmgfile}
	else
		/bin/echo "`date`: Flash is not installed"
		/bin/echo "--"
	fi