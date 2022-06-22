#!/bin/bash

function GetCsLoaderPath()
{
    version=$(sysctl kern.osrelease | awk -F. '{print $2}' | awk '{print $2}');
    if [[ ${version} -le 12 ]]
    then
        ret="/System/Library/Extensions/CsLoader.kext/"
    else
        ret="/Library/Extensions/CsLoader.kext/"
    fi
    echo ${ret}
}

function GetPlatformPath()
{
    version=$(sysctl kern.osrelease | awk -F. '{print $2}' | awk '{print $2}');
    if [[ ${version} -le 12 ]]
    then
        ret="/System/Library/Extensions/platform.kext/"
    else
        ret="/Library/Extensions/platform.kext/"
    fi
    echo ${ret}
}

function GetCsPath()
{
    echo "/Library/CS/"
}

function removeComponents()
{
    rm /Library/LaunchDaemons/com.crowdstrike.userdaemon.plist
}

function removeLoader()
{
    rm -rf "$(GetCsLoaderPath)"
    rm -rf "$(GetPlatformPath)"
}

function discardReceipts()
{
    local pkgs=(
        # current package names
        "com.crowdstrike.falcon.config"
        "com.crowdstrike.falcon.license"
        "com.crowdstrike.falcon.sensor"

        # old package names
        "com.crowdstrike.macFalconSensor.com.crowdstrike.userdaemon.pkg"
        "com.crowdstrike.macFalconSensor.CSDaemon.pkg"
        "com.crowdstrike.macFalconSensor.CsLoader.pkg"
        "com.crowdstrike.macFalconSensor.ECB.pkg"
        "com.crowdstrike.macFalconSensor.license.pkg"
        "com.crowdstrike.macFalconSensor.load.pkg"
        "com.crowdstrike.macFalconSensor.platform.pkg"
        "com.crowdstrike.macFalconSensor.uninstall.pkg"
        "com.crowdstrike.macFalconSensor.unload.pkg"
        "com.crowdstrike.sensor"
        "com.crowdstrike.falconhost.config"
        "com.crowdstrike.falconhost.license"
        "com.crowdstrike.falconhost.sensor"
    )

    for pkg in "${pkgs[@]}"; do
        pkgutil --forget "${pkg}" &> /dev/null
    done
}

function removeAll()
{
    sync
    if [ -f ./unload.sh ]; then
        sh ./unload.sh
    else
        sh "$(GetCsPath)/unload.sh"
    fi

    removeComponents
    removeLoader
    rm -rf "$(GetCsPath)"
    discardReceipts
    sync
    touch /System/Library/Extensions
}

removeAll
