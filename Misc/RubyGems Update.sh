#!/bin/sh


####################################################################################################
#
# CREATED BY
#
#   Brian Stutzman
#
# DESCRIPTION
#
#	This will report on the version and attempt to update if outdated.
#
# VERSION
#
#	- 1.0
#
# CHANGE HISTORY
#
# 	- Created script - 10/2/19 (1.0)
#
####################################################################################################


rubygemsVER=$(gem -v)


if [ "rubygemsVER" = "$4" ]; then

	echo "RubyGems Version: $rubygemsVER (Current)"

else

	echo "RubyGems Version: $rubygemsVER (Outdated)"
    
    echo "Attempting to update RubyGems to $4"
	
    gem update --system

fi
