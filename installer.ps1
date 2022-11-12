# 1. Make sure the Microsoft App Installer is installed:
#    https://www.microsoft.com/en-us/p/app-installer/9nblggh4nns1
# 2. Run this script as administrator.

# changing the install location is not tested
$installPath = $env:userprofile + "\wsl_setup"
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope LocalMachine

Write-Output "Installing Apps: Git, VS Code, Terminal, and Ubunto if needed"
$apps = @(
    @{name = "Git.Git" },
    @{name = "Microsoft.VisualStudioCode" },
    @{name = "Microsoft.WindowsTerminal" },
    @{name = "Canonical.Ubuntu" })

Foreach ($app in $apps) {
    $listApp = winget list --exact -q $app.name
    if (![String]::Join("", $listApp).Contains($app.name)) {
        Write-host "Installing: " $app.name
        winget install -e -h --accept-source-agreements --accept-package-agreements --id $app.name 
    }
    else {
        Write-host  $app.name " (already installed)"
    }
}

# Download GitHub Project

$command = "gh repo clone elihickey/wsl_setup " + $installPath
Invoke-Expression $command


# setup windows task
$anyConnectFixPath = $env:userprofile + "\wsl_setup\fix_wsl_anyconnect.ps1"
Unblock-File -Path  $anyConnectFixPath
$argument = "/c powershell.exe " + $anyConnectFixPath 
$Sta = New-ScheduledTaskAction -Execute "Cmd" -Argument $argument
   $triggers = @()
    $triggers += New-ScheduledTaskTrigger -AtLogOn
    $CIMTriggerClass = Get-CimClass -ClassName MSFT_TaskEventTrigger -Namespace Root/Microsoft/Windows/TaskScheduler:MSFT_TaskEventTrigger
    $trigger = New-CimInstance -CimClass $CIMTriggerClass -ClientOnly
    $trigger.Subscription = 
@"
<QueryList><Query Id="0" Path="Cisco AnyConnect Secure Mobility Client"><Select Path="Cisco AnyConnect Secure Mobility Client">*[System[Provider[@Name='acvpnagent'] and EventID=2039]]</Select></Query></QueryList>
"@
    $trigger.Enabled = $True 
    $triggers += $trigger

    $trigger2 = New-CimInstance -CimClass $CIMTriggerClass -ClientOnly
    $trigger2.Subscription = 
@"
<QueryList><Query Id="0" Path="Cisco AnyConnect Secure Mobility Client"><Select Path="Cisco AnyConnect Secure Mobility Client">*[System[Provider[@Name='acvpnagent'] and EventID=2037]]</Select></Query></QueryList>
"@
    $trigger2.Enabled = $True 
    $triggers += $trigger2

$STSet = New-ScheduledTaskSettingsSet
Register-ScheduledTask FixAnyConnectWsl -Action $Sta -Settings $STSet -Trigger $triggers

# setup ubuntu
wsl  --set-default-version 2
wsl --install --distribution Ubuntu
wsl --list --verbose
wsl --setdefault Ubuntu


