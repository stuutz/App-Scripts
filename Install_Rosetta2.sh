#!/bin/bash


####################################################################################################
#
# CREATED BY
#
#   Brian Stutzman
#
# DESCRIPTION
#
#	This script installs Rosetta 2.
#
# VERSION
#
#	- 1.0
#
# CHANGE HISTORY
#
# 	- Created script - 11/29/21 (1.0)
#
####################################################################################################


##########################################################################################
# Main script
##########################################################################################

# Identify chip architecture
arch=$(/usr/bin/arch)

if [ "$arch" == "arm64" ]; then
    
    echo "Apple Silicon - Installing Rosetta"
    
    /usr/sbin/softwareupdate --install-rosetta --agree-to-license
          
elif [ "$arch" == "i386" ]; then
    
    echo "Intel - Cannot Install Rosetta"
    
else
    
    echo "Unknown Architecture"
    
fi

exit 0
