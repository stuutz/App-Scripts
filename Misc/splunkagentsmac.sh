#!/bin/sh

#####################
##    functions    ##
#####################

function userSeed ()
{
	# USER-SEED.CONF
	# Set user and pass and install file in /etc/system/local
	sudo echo $'[user_info]\nUSERNAME = admin\nPASSWORD = <Nq97i6DjFPRN33w>' > $SPLUNK_HOME/etc/system/local/user-seed.conf
}

function deploymentClient ()
{
	# DEPLOYMENTCLIENT.CONF FILE
	# Set server and install file in /etc/system/local
	sudo echo $'[target-broker:deploymentServer]\ntargetUri = 10.88.254.2:8089' > $SPLUNK_HOME/etc/system/local/deploymentclient.conf
}

function fileCheck ()
{
	# Check if user-seed.conf exists
	if [ ! -f /opt/splunkforwarder/etc/system/local/user-seed.conf ]; then
		userSeed
	fi
	
	# Check if deploymentclient.conf exists
	if [ ! -f /opt/splunkforwarder/etc/system/local/deploymentclient.conf ]; then
		deploymentClient
	fi
}

function acceptLicense ()
{
	# Splunk First-Time-Run (FTR)
	# Accept SPLUNK License
	sudo $SPLUNK_HOME/bin/splunk start splunkd --accept-license --answer-yes --no-prompt
}

function enableBoot ()
{
	# ENABLE BOOT START
	# Enable and accept SPLUNK license
	# NOTE: This part MUST BE RUN AS root (or sudo)!
	# NOTE: If running splunk as non-root, add "-user splunk" to the argument list of "enable boot-start"
	sudo ${SPLUNK_HOME}/bin/splunk enable boot-start --accept-license --answer-yes --no-prompt
}

function restartSplunk ()
{
	sudo ${SPLUNK_HOME}/bin/splunk restart
}

function cleanUp ()
{
	# Delete SPLUNKFORWARDER installation file
	if [ -f /tmp/splunkforwarder*.tgz ]; then
		rm -rf /tmp/splunkforwarder*.tgz
	fi
}

#####################
##   main script   ##
#####################
	
# NOTE: script assumes there is exactly ONE splunkforwarder*.tgz package already present in /tmp/splunkforwarder*.tgz
clear;
set -x;
	
cd /opt/;
sudo mkdir -p /etc/profile.d/
sudo echo "export SPLUNK_HOME=/opt/splunkforwarder" > /etc/profile.d/splunkforwarder.sh
export SPLUNK_HOME=/opt/splunkforwarder
	
# UNPACK SPLUNKFORWARDER 
sudo tar xvf /tmp/splunkforwarder*.tgz
cd ./splunkforwarder/
	
sleep 3
	
userSeed
	
deploymentClient

fileCheck
	
acceptLicense
	
enableBoot
	
restartSplunk

cleanUp
