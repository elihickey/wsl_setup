<# 
       
    Warning: Do not use this script if you already customize /etc/wsl.conf and/or /etc/resolv.conf in WSL Ubuntu
                You may use this script as a guide for the further customiztions you need to do to those files.
    This script fixes a bug that prevents internet access from WSL when Cisco AnyConnect is active
    This script needs to be called any time Any Connect connects or disconnects
    Performs 3 actions
    1.  Remove and recreate /etc/wsl.conf with setting generateResolvConf = false
    2.  Remove and recreate /etc/resolv.conf with the appropriate dns nameservers for the current connection.
    3.  Update the IP Interfaces for Cisco AnyConnect applying the metric of 6000 to the ipv4 interfaces

#>
$allInterfaces = Get-NetIPInterface
$allAdpters = Get-NetAdapter
$dnsClients = Get-DnsClientServerAddress
$ciscoIndex = ""
$ciscoStatus = ""
[System.Collections.ArrayList]$dnsServers = @()
foreach ($adapter in $allAdpters) {
    if ($adapter.InterfaceDescription -like "Cisco AnyConnect*" -and $adapter.status -eq "Up") {
        $ciscoIndex = $adapter.ifIndex;
        $ciscoStatus = $adapter.Status;
    }
}

foreach ($dnsClient in $dnsClients) {
    if( $dnsClient.InterfaceIndex -eq $ciscoIndex) {
        #todo figure out how to skip when empty or status?
       if ($dnsClient.ServerAddresses) {
            $dnsServers = $dnsClient.ServerAddresses
       }
    }
}

if (!$dnsServers) {
   $dnsServers.Add("1.1.1.1")
}
$dnsServersStr = "[network]"
foreach ($server in $dnsServers) {
    $dnsServersStr += "`n" + "nameserver " + $server
}

foreach ($interface in $allInterfaces ) {
    if ($interface.ifIndex -eq $ciscoIndex  -and $interface.AddressFamily -eq "IPv4") {
        $ciscoIpV4Interface = $interface
        $ciscoMetric = $interface.InterfaceMetric
    }
}

if ($ciscoMetric -ne "6000" -and $ciscoStatus -eq "Up"  ) {
    Set-NetIPInterface -InputObject $ciscoIpV4Interface -InterfaceMetric "6000" 
}

wsl -d Ubuntu --user root rm /etc/resolv.conf  
wsl -d Ubuntu --user root rm /etc/wsl.conf  
wsl -d Ubuntu --user root echo -e `"[network]\ngenerateResolvConf = false`" `| tee /etc/wsl.conf 
wsl -d Ubuntu --user root echo -e `"$dnsServersStr`" `| tee /etc/resolv.conf
