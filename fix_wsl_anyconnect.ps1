<# 
       
    Warning: Do not use this script if you already customize /etc/wsl.conf and/or /etc/resolv.conf in WSL Ubuntu
                You may use this script as a guide for the further customiztions you need to do to those files.
    This script fixes a bug that prevents internet access from WSL when Cisco AnyConnect is active
    This script needs to be called any time Any Connect connects or disconnects
    Performs 3 actions
    1.  Remove and recreate /etc/wsl.conf with setting generateResolvConf = false
    2.  Remove and recreate /etc/resolv.conf with the appropriate dns nameservers for the current connection.
    3.  Update the IP Interfaces for Cisco AnyConnect applying the metric of 6000 to the ipv4 interfaces
    # todo first add a check - if wsl-ubuntu is up
# next add check if dns is working
# only fix what needs to be fixed.
# if cisco is down make sure dns ir right.
# check dns with  --spider option - check page loads with out
# wget -q --spider --dns-timeout=2 http://google.com  

#>
function UpdateResolve {
    param (
        $dnsServers
    )
    $dnsServersStr = "[network]"
    foreach ($server in $dnsServers) {
        $dnsServersStr += "`n" + "nameserver " + $server
    }
    wsl -d Ubuntu --user root rm /etc/resolv.conf  
    wsl -d Ubuntu --user root rm /etc/wsl.conf  
    wsl -d Ubuntu --user root echo -e `"[network]\ngenerateResolvConf = false`" `| tee /etc/wsl.conf 
    wsl -d Ubuntu --user root echo -e `"$dnsServersStr`" `| tee /etc/resolv.conf
        
}
$wslStatus = wsl -l -v | Out-String | Select-String -Pattern 'U.b.u.n.t.u.*?R.u.n.n.i.n.g'
if ($wslStatus.Matches) {
    Write-Output "Ubuntu Running"
} else {
    Write-Output "Ubuntu Is not running - no need to continue"
    exit
}

wsl -d Ubuntu --exec wget -o wget.log --spider --dns-timeout=2 http://google.com 
$temp = wsl -d Ubuntu --exec cat wget.log  
$netCheck = $temp | Select-String -Pattern 'connected\.' 
if ($netCheck.Matches) {
    Write-Output  "WSL has internet connection - no need to continue"
    exit
}
$allAdpters = Get-NetAdapter
$ciscoIndex = ""
$ciscoStatus = ""
[System.Collections.ArrayList]$dnsServers = @()
foreach ($adapter in $allAdpters) {
    if ($adapter.InterfaceDescription -like "Cisco AnyConnect*" -and $adapter.status -eq "Up") {
        $ciscoIndex = $adapter.ifIndex;
        $ciscoStatus = $adapter.Status;
    }
}
if (!$ciscoIndex) {
    Write-Output "Anyconnect is not connected. Checking for default DNS"
    $dns = wsl -d Ubuntu cat /etc/resolv.conf | Select-String -Pattern '1\.1\.1\.1'
    if (!$dns.Matches) {
        Write-Output "Changing DNS to default"
        $dnsServers.Add("1.1.1.1")
        UpdateResolve -dnsServers $dnsServers
    }
    exit
}
# made it this far - wsl up,  no internet,  and any connect is connect
# fix dns and metric




$allInterfaces = Get-NetIPInterface
foreach ($interface in $allInterfaces ) {
    if ($interface.ifIndex -eq $ciscoIndex  -and $interface.AddressFamily -eq "IPv4") {
        $ciscoIpV4Interface = $interface
        $ciscoMetric = $interface.InterfaceMetric
    }
}

if ($ciscoMetric -ne "6000" -and $ciscoStatus -eq "Up"  -and $ciscoIpV4Interface ) {
    Write-Output "Change Metric "
    Set-NetIPInterface -InputObject $ciscoIpV4Interface -InterfaceMetric "6000" 
}

$dnsClients = Get-DnsClientServerAddress
foreach ($dnsClient in $dnsClients) {
    if( $dnsClient.InterfaceIndex -eq $ciscoIndex) {
        if ($dnsClient.ServerAddresses) {
            $dnsServers = $dnsClient.ServerAddresses
        }
    }
}
UpdateResolve -dnsServers $dnsServers


