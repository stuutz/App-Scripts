#!/bin/sh
## postinstall

pathToScript=$0
pathToPackage=$1
targetLocation=$2
targetVolume=$3

#do not want
/bin/rm /Library/LaunchAgents/com.oracle.java.Java-Updater.plist
/bin/rm /Library/LaunchDaemons/com.oracle.java.Helper-Tool.plist
/bin/rm /Library/Application\ Support/Oracle/Java/Deployment/deployment.config
/bin/rm /Library/Application\ Support/Oracle/Java/Deployment/deployment.properties
/bin/rm /Library/Application\ Support/Oracle/Java/Deployment/exception.sites

#want
mkdir /Library/Application\ Support/Oracle/Java/Deployment
chown root:wheel /Library/Application\ Support/Oracle/Java/Deployment
chmod 755 /Library/Application\ Support/Oracle/Java/Deployment

#get numeric variable of current java version to use so I can suppress the "out of date" nonsense for some time.
NUMBER=`/bin/cat /Library/Internet\ Plug-Ins/JavaAppletPlugin.plugin/Contents/Enabled.plist |grep ';deploy=' |cut -d"=" -f2 |cut -d"<" -f1`

# make new files and set permissions
/usr/bin/touch /Library/Application\ Support/Oracle/Java/Deployment/deployment.config
/usr/bin/touch /Library/Application\ Support/Oracle/Java/Deployment/deployment.properties
/usr/bin/touch /Library/Application\ Support/Oracle/Java/Deployment/exception.sites
/usr/sbin/chown root:wheel /Library/Application\ Support/Oracle/Java/Deployment/deployment.config
/usr/sbin/chown root:wheel /Library/Application\ Support/Oracle/Java/Deployment/deployment.properties
/usr/sbin/chown root:wheel /Library/Application\ Support/Oracle/Java/Deployment/exception.sites
/bin/chmod 755 /Library/Application\ Support/Oracle/Java/Deployment/deployment.config
/bin/chmod 755 /Library/Application\ Support/Oracle/Java/Deployment/deployment.properties
/bin/chmod 755 /Library/Application\ Support/Oracle/Java/Deployment/exception.sites

# Write deployment.config
/bin/echo deployment.system.config.mandatory=true > /Library/Application\ Support/Oracle/Java/Deployment/deployment.config
/bin/echo deployment.system.config=file:////Library/Application Support/Oracle/Java/Deployment/deployment.properties >> /Library/Application\ Support/Oracle/Java/Deployment/deployment.config

# Write deployment.properties
/bin/echo deployment.security.level=HIGH > /Library/Application\ Support/Oracle/Java/Deployment/deployment.properties
/bin/echo deployment.expiration.check.enabled=FALSE >> /Library/Application\ Support/Oracle/Java/Deployment/deployment.properties
/bin/echo deployment.javaws.shortcut=NEVER >> /Library/Application\ Support/Oracle/Java/Deployment/deployment.properties
/bin/echo deployment.security.mixcode=DISABLE >> /Library/Application\ Support/Oracle/Java/Deployment/deployment.properties
/bin/echo deployment.webjava.enabled=TRUE >> /Library/Application\ Support/Oracle/Java/Deployment/deployment.properties
/bin/echo deployment.macosx.check.update=false >> /Library/Application\ Support/Oracle/Java/Deployment/deployment.properties
/bin/echo deployment.macosx.check.update.locked >> /Library/Application\ Support/Oracle/Java/Deployment/deployment.properties
/bin/echo deployment.expiration.check.enabled=false >> /Library/Application\ Support/Oracle/Java/Deployment/deployment.properties
/bin/echo deployment.expiration.check.enabled.locked >> /Library/Application\ Support/Oracle/Java/Deployment/deployment.properties
/bin/echo deployment.expiration.decision=NEVER >> /Library/Application\ Support/Oracle/Java/Deployment/deployment.properties
/bin/echo deployment.expiration.decision.suppression=true >> /Library/Application\ Support/Oracle/Java/Deployment/deployment.properties
/bin/echo deployment.expiration.decision.suppression."$NUMBER".locked >> /Library/Application\ Support/Oracle/Java/Deployment/deployment.properties
/bin/echo deployment.expiration.decision.suppression."$NUMBER"=true >> /Library/Application\ Support/Oracle/Java/Deployment/deployment.properties
/bin/echo deployment.expiration.decision."$NUMBER".locked >> /Library/Application\ Support/Oracle/Java/Deployment/deployment.properties
/bin/echo deployment.expiration.decision."$NUMBER"=later >> /Library/Application\ Support/Oracle/Java/Deployment/deployment.properties
/bin/echo install.disable.sponsor.offers=true >> /Library/Application\ Support/Oracle/Java/Deployment/deployment.properties
/bin/echo deployment.user.security.exception.sites=/Library/Application\ Support/Oracle/Java/Deployment/exception.sites >> /Library/Application\ Support/Oracle/Java/Deployment/deployment.properties

#Write exception.sites
#/bin/echo http://site1.com/ > /Library/Application\ Support/Oracle/Java/Deployment/exception.sites
#/bin/echo http://site2.com/ >> /Library/Application\ Support/Oracle/Java/Deployment/exception.sites
#/bin/echo http://site3.com >> /Library/Application\ Support/Oracle/Java/Deployment/exception.sites

#Suppress system wide updating
/usr/bin/defaults write /Library/Preferences/com.oracle.java.Java-Updater JavaAutoUpdateEnabled -bool false
/usr/bin/defaults write /Library/Preferences/com.oracle.java.Deployment install.disable.sponsor.offers -string true


exit 0      ## Success
exit 1      ## Success