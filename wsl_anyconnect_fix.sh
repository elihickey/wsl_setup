#!/bin/bash
# Title:         WSL - fix net access with Anyconnect VPN
# Description:   See https://gist.github.com/machuu/7663aa653828d81efbc2aaad6e3b1431 for Anyconnect Fixes

# Using this script
# cd ~
# sudo nano ws_anyconnect_fix.sh
#  - paste contents of this script save and exit nano
# sudo chmod +x ws_annyconnect_fix.sh
# After Cisco VPN connect or disconnect run:
# sudo bash ws_annyconnect_fix.sh

 #>>>>>>>>>>>>>>>>>>>>>>>> functions >>>>>>>>>>>>>>>>>>>>>>>>
    function output () {
        GREEN='\033[0;32m'
        RED='\033[0;31m'
        WHITE='\033[0;37m'
        RESET='\033[0m'
        if [ "$2" = "error" ]; then
            msg="\n${RED}${1}\n${RESET}"
        else 
            msg="\n${GREEN}${1}\n${RESET}"
        fi
        echo -e "$msg" | ( TAB=$'\t' ; sed "s/^/$TAB/" ) 
        #echo -e "$1" | tee -a /home/emh/network_fix.log > /dev/null
    }
    function fixResolve () {
        # Removes symlink on resolv.conf and updates with 
        # correct nameservers for Ellucian AnyConnect
        # todo - periodically check if the ellucian  name servers have changed
        resolveFile="/etc/resolv.conf"
        if [ "$1" == "novpn" ]; then
            nameServers="nameserver 1.1.1.1"
        else
            nameServers="nameserver 172.30.0.149\nnameserver 149.24.1.111"
        fi
        rm -f "${resolveFile}"
        echo -e "${nameServers}" | tee "${resolveFile}" > /dev/null
        output "Added \n ${nameServers} \n to ${resolveFile} "
    }
    
    function fixWslConf () {
        wslFile="/etc/wsl.conf"
        toWrite=""
        wslStatus=""
        lineExists="false"
        groupExists="false"
        if [ -f "$wslFile" ]; then
            while IFS= read -r line || [ -n "$line" ]; do
            keyName=${line%"="*}
            keyName=${keyName// /}
            value=${line#*"="}
            value=${value// /}
            if [ "$keyName" == "[network]" ] ; then
                groupExists="true";
            fi
            
            if [ "$keyName" == "generateResolvConf" ]; then
                lineExists="true"
                if [  $value == "false" ]; then
                wslStatus="nochangeNeeded"
                break
                else
                    line="generateResolvConf = false"
                fi
            fi
        
            toWrite+="${line}\n"
            done < ${wslFile}
        else
            echo -e "[network]\ngenerateResolvConf = false" | tee "${wslFile}"
            output "updated ${wslFile}"
            return 0
        fi

        if [ $groupExists == "true" ]; then
            if [ $lineExists == "true" ]; then
                if [ "$wslStatus" != "nochangeNeeded" ]; then
                echo -e "${toWrite}" | tee "${wslFile}"
                fi
            fi
        else
            echo -e "[network]\ngenerateResolvConf = false" | tee -a "${wslFile}" > /dev/null
             output "updated ${wslFile}"

        fi
    }
    
# <<<<<<<<<<<<<<<<<<<<<<<< functions <<<<<<<<<<<<<<<<<<<<<<<<
output "Starting Network Fix Script $(date)"

fixWslConf

#full path required because SUDO limits PATH env var
psexe="/mnt/c/windows/System32/WindowsPowerShell/v1.0//powershell.exe"
getAnyConnectAdapter=' Get-NetAdapter | Where-Object {$_.InterFaceDescription -Match "AnyConnect" -and $_.Status -eq "Up"} | Select-Object -ExpandProperty "ifIndex"'
anyConnectIndex="$(${psexe} ${getAnyConnectAdapter})"
#remove newline char
anyConnectIndex=${anyConnectIndex//[$'\t\r\n']}
if [ "$anyConnectIndex" == "" ]; then
    fixResolve novpn
     output "Not Connected to Cisco AnyConnect VPN"
     output "Script Complete"
    exit 0
fi
fixResolve
currentIpV4Metric=`${psexe} Get-NetIPInterface -AddressFamily IPv4 -InterfaceIndex ${anyConnectIndex} \| Select-Object -ExpandProperty InterfaceMetric`
currentIpV4Metric=${currentIpV4Metric//[$'\t\r\n']}
# currentIpV6Metric=`${psexe} Get-NetIPInterface -AddressFamily IPv6 -InterfaceIndex "${anyConnectIndex}" \| Select-Object -ExpandProperty InterfaceMetric`
if [ "$currentIpV4Metric" == "1" ]; then
    output "Fixing Metrix"
     #Broken need to force network traffic to use 'vEthernet (WSL) Interface'
     # Increasing the Anyconnect metric higher then vEthernent Set-NetIPInterface -InterfaceMetric 6000
    updateMetricResponse=`${psexe} Set-NetIPInterface -InterfaceIndex ${anyConnectIndex} -AddressFamily IPv4 -InterfaceMetric 6000`

fi
output "Script Complete"
