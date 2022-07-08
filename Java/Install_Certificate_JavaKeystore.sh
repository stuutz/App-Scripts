#!/bin/bash

####################################################################################################
# ABOUT THIS SCRIPT
#
# CREATED BY
# 
#	Brian Stutzman
#
# DESCRIPTION
#
# 	This script will install certificates into the Java (cacerts) keystore.
#
# VERSION
# 
# 	1.0
#
####################################################################################################
# CHANGE HISTORY
#
# - Created script (1.0) - 4/26/2022
#
####################################################################################################


##################################################################
## Script variables
##################################################################

jamfHelper="/Library/Application Support/JAMF/bin/jamfHelper.app/Contents/MacOS/jamfHelper"
icon="/System/Library/CoreServices/JavaLauncher.app/Contents/Resources/class.icns"
iconERROR="/System/Library/CoreServices/Diagnostics Reporter.app/Contents/Resources/AppIcon.icns"
certName="CERTIFICATE_NAME.cer"
certAlias="CERTIFICATE_ALIAS"

##################################################################
## Script functions
##################################################################

function installCert ()
{

	versCheck=$(ls /Library/Java/JavaVirtualMachines | wc -l)

	if [[ $versCheck -gt 1 ]]; then
	
		javaInstalled=2

		echo "Script result: Found multiple Java versions"
	
		CHOOSE_JAVA_VERSION="$(/usr/bin/osascript -e 'text returned of (display dialog "Select which Java keystore to install certificates into?

Java location:
/Library/Java/JavaVirtualMachines

Please enter the exact version (ex: jdk1.8.0_271.jdk)" buttons {"Continue"} default answer "" with title "Multiple Java Versions Found")')"
		
		if [ -d "/Library/Java/JavaVirtualMachines/$CHOOSE_JAVA_VERSION" ]; then

			sudo keytool -storepasswd -new changeit -keystore /Library/Java/JavaVirtualMachines/${CHOOSE_JAVA_VERSION}/Contents/Home/jre/lib/security/cacerts -storepass changeit
			sudo keytool -–importcert -file //private/var/tmp/$certName -keystore /Library/Java/JavaVirtualMachines/${CHOOSE_JAVA_VERSION}/Contents/Home/jre/lib/security/cacerts -alias "$certAlias" -noprompt -storepass changeit		

		else

			echo "Script result: The Java version entered does not exist."

			"$jamfHelper" -windowType "hud" -icon "$iconERROR" -description "The Java version entered cannot be found.  

Please double check the spelling and try again." -button1 "CLOSE" -defaultButton 0 -lockHUD

			cleanUp

			exit 0

		fi

	else
	
		javaInstalled=1

		echo "Script result: Found one version of Java"
	
		INSTALLED_JAVA_VERSION=$(ls /Library/Java/JavaVirtualMachines | grep ".jdk")

		sudo keytool -storepasswd -new changeit -keystore /Library/Java/JavaVirtualMachines/${INSTALLED_JAVA_VERSION}/Contents/Home/jre/lib/security/cacerts -storepass changeit
		sudo keytool -–importcert -file //private/var/tmp/$certName -keystore /Library/Java/JavaVirtualMachines/${INSTALLED_JAVA_VERSION}/Contents/Home/jre/lib/security/cacerts -alias "$certAlias" -noprompt -storepass changeit	

	fi

}

function verifyCert ()
{
	# more than one Java version installed
	if [ "$javaInstalled" = "2" ]; then

		cert=$(sudo keytool -list -keystore /Library/Java/JavaVirtualMachines/${CHOOSE_JAVA_VERSION}/Contents/Home/jre/lib/security/cacerts -alias $certAlias -noprompt -storepass changeit | grep "$certAlias" | awk '{print $1}' | tr -d ',')
		if [ "$cert" ]; then

			certStatus="installed"

			echo "Script result: $certAlias $certStatus"

		else

			certStatus="NOT installed"

			echo "Script result: $certAlias $certStatus"

		fi

		"$jamfHelper" -windowType "hud" -icon "$icon" -description "Certificate Import Results:

$certAlias ---> $certStatus into $CHOOSE_JAVA_VERSION keystore" -button1 "CLOSE" -defaultButton 0 -lockHUD

	else

		# only one Java version installed
		cert=$(sudo keytool -list -keystore /Library/Java/JavaVirtualMachines/${INSTALLED_JAVA_VERSION}/Contents/Home/jre/lib/security/cacerts -alias $certAlias -noprompt -storepass changeit | grep "$certAlias" | awk '{print $1}' | tr -d ',')
		if [ "$cert" ]; then

			certStatus="installed"

			echo "Script result: $certAlias $certStatus"

		else

			certStatus="NOT installed"

			echo "Script result: $certAlias $certStatus"

		fi

		"$jamfHelper" -windowType "hud" -icon "$icon" -description "Certificate Import Results:

$certAlias ---> $certStatus into $INSTALLED_JAVA_VERSION keystore" -button1 "CLOSE" -defaultButton 0 -lockHUD

	fi

}

function cleanUp ()
{

	if [ -f /private/var/tmp/$certName ]; then

		rm -rf /private/var/tmp/$certName

		echo "Script result: deleted '$certName' file"

	fi

}

##################################################################
## main script
##################################################################

echo ""

javaCheck=$(ls /Library/Java/JavaVirtualMachines | wc -l)

if [[ $javaCheck -gt 0 ]]; then
	
	echo "Script result: Java Installed"
	
	installCert

	verifyCert
	
	cleanUp
	
else

	echo "Script result: Java NOT Installed"

	"$jamfHelper" -windowType "hud" -icon "$iconERROR" -description "Java missing.  Please install a version of Java before running this workflow." -button1 "CLOSE" -defaultButton 0 -lockHUD
	
	cleanUp
	
	exit 0
	
fi
