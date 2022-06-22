#!/bin/bash
####################################################################################################
# ABOUT THIS SCRIPT
#
# CREATED BY
#   Brian Stutzman
#
# DESCRIPTION
#	This script will rename the MAU2.0 folder to MAU2.0.old.  This will disable the Microsoft
# updater application.
#
####################################################################################################
# CHANGE HISTORY
#
#	- Created script 12/27/16
#
####################################################################################################

if [ -d /Library/Application\ Support/Microsoft/MAU2.0 ] ; then
mv /Library/Application\ Support/Microsoft/MAU2.0 /Library/Application\ Support/Microsoft/MAU2.0.old
echo Folder MAU2.0 is incorrectly named...changing folder name to MAU2.0.old

else
echo Folder MAU2.0.old already exists.
fi

exit 0
