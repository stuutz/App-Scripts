#!/bin/bash

sudo xattr -r -d com.apple.quarantine /Applications/Nitro\ PDF\ Pro.app

open --hide --fresh /Applications/Nitro\ PDF\ Pro.app --args -ActivationCode ENTER_CODE_HERE

sleep 20

pkill -x "Nitro PDF Pro"

