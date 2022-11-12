# Windows Set Up Steps

Performs a number of tasks
1. Installs software if needed
    1. WSL Ubuntu 
    1. VS Code
    1. Terminal
    1. GIT
1. Adds Scheduled Task to fix Any Connect VPN Bug
1. Adds linux pre-requisites NPM and Puppeteer


## Mostly Scripted Setup

Note: Disconnect Cisco AnyConnect VPN if connected
1. Install the [App Installer](https://www.microsoft.com/en-us/p/app-installer/9nblggh4nns1) so we can automate the application installs
1. Open Powershell ISE as administrator [see screenshot](https://github.com/elihickey/wsl_setup/blob/main/docs/screenShots.md#opening-powershell-ise-as-administrator)
2. Paste Script from [installer.ps1](https://raw.githubusercontent.com/elihickey/wsl_setup/main/installer.ps1) to Powershell ISE [see screenshot](https://github.com/elihickey/wsl_setup/blob/main/docs/screenShots.md#scripts-in-ise)
   * :warning: Run the script with out saving - if you save you will also need to `Unblock-File -Path <path>`
3. Run Script (f5)
4. Installer may take a while to run.  Watch for prompts...
    1. Script Execution Policy (yes to all)
    2. Ubuntu will prompt for new user and password - remember what you enter here!  
5. Connect Cisco Any Connect VPN
6. In ubuntu confirm you have internet access with a command like ping google.com


## Data Connect Developer Prerequisites

If you plan to use DCD in WSL use these commands in ubuntu to run pre-requisites.
```
cd ~
git clone https://github.com/elihickey/wsl_setup.git
bash wsl_setup/wsl_dcd_prereq.sh
```
Note: you will be promted for ubuntu password.

Restart terminal for all changes to take affect.

You are now ready to follow the steps in https://git.ellucian.com/projects/ELLABORATION/repos/data-connect-developer/browse  starting with
` npx @ellucian/data-connect-developer init-project <project-name>`


