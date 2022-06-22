#!/bin/bash


##################################################################
## script variables
##################################################################

# macOS Version+Build to Install (11.3_20E232)
osVer=$4

# macOS installation package location
macOSPackage="/private/var/tmp/macOS-$osVer.pkg"


##################################################################
## main script
##################################################################

# install macOS package
installer -pkg $macOSPackage -target /


exit 0
