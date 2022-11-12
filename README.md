# Setup for WSL with Cisco AnyConnect

Performs a number of tasks
1. Installs software if needed
    1. WSL Ubuntu 
    1. VS Code
    1. Terminal
    1. GIT
1. Adds Scheduled Task to fix Any Connect VPN Bug
1. Adds linux prerequisites NPM and Puppeteer


## Steps

Note: Disconnect Cisco AnyConnect VPN if connected
1. Install powershell's winget [App Installer](https://www.microsoft.com/en-us/p/app-installer/9nblggh4nns1) so we can automate the application installs
1. Open Powershell ISE as administrator [see screenshot](https://github.com/elihickey/wsl_setup/blob/main/docs/screenShots.md#opening-powershell-ise-as-administrator)
2. Paste Script from [installer.ps1](https://raw.githubusercontent.com/elihickey/wsl_setup/main/installer.ps1) to Powershell ISE [see screenshot](https://github.com/elihickey/wsl_setup/blob/main/docs/screenShots.md#scripts-in-ise)
   * :warning: Run the script with out saving - if you save you will also need to `Unblock-File -Path <path>`
3. Run Script (f5)
4. Installer may take a while to run.  Watch for prompts...
    1. Script Execution Policy (yes to all)
    2. Ubuntu will prompt for new user and password - remember what you enter here!  
5. Connect Cisco Any Connect VPN
6. In ubuntu confirm you have internet access with a linux command like `ping google.com`


## Data Connect Developer Prerequisites

If you plan to use DCD in WSL use these commands in ubuntu to run pre-requisites.
```
cd ~
git clone https://github.com/elihickey/wsl_setup.git
bash wsl_setup/wsl_dcd_prereq.sh
```
Note: you will be prompted for ubuntu password.

:grey_exclamation:Restart terminal for all changes to take affect.

You are now ready to follow the steps in [Data Connect Developer](https://git.ellucian.com/projects/ELLABORATION/repos/data-connect-developer/browse)  starting with
` npx @ellucian/data-connect-developer init-project <project-name>`

## Known Issues

### Ubuntu must be running when you connect/disconnect from AnyConnect

If you connect your vpn and then launch ubuntu it will not have internet access.  You can resolve by leaving ubuntu running and then disconnect and reconnect the VPN.  You can also resolve by manually running the fix_wsl_anyconnect.ps1 script located at `%userprofile%/wsl_setup/fix_wsl_anyconnect.ps1`

### References

[Cisco Community Issue Discussion](https://community.cisco.com/t5/vpn/anyconnect-wsl-2-windows-substem-for-linux/td-p/4179888)

[WSL Issue Discussion](https://github.com/microsoft/WSL/issues/5068)

[Solution](https://jamespotz.github.io/blog/how-to-fix-wsl2-and-cisco-vpn)

[Another Solution](https://gist.github.com/machuu/7663aa653828d81efbc2aaad6e3b1431)

