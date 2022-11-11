Windows Set Up Steps
====================
Following these steps will make sure the system is ready to run any project requiring NPM, Puppeteer, and/or Cisco AnyConnect VPN connection in WSL.

Setup Steps
----------------
1. Disconnect Cisco AnyConnect VPN if connected
1. (Open Powershell ISE as administrator)[https://github.com/elihickey/wsl_setup/blob/main/docs/screenShots.md#opening-powershell-ise-as-administrator]
    1. Click New file Button
    1. [Copy and Paste Script](https://github.com/elihickey/wsl_setup/blob/main/installer.ps1)
    1. Click Run Script (f5)


1. Disconnect Cisco AnyConnect VPN if connected
1. Install [VS Code](https://code.visualstudio.com/download)
    1. On the Additional Tasks setup dialog recommend checking these options:
        - Add "Open with Code action to Windows Explorer file context menu
        - Add "Open with code" action to Windows Explorer directory context menu
1. Install [VS Code Remote WSL Extension](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-wsl)
1. Optional Install [Windows Terminal](https://docs.microsoft.com/en-us/windows/terminal/install)
1. Launch Windows Terminal as Administrator (or another powershell terminal) and enter the following powershell commands
    1. `wsl  --set-default-version 2`
    1. `wsl --install --distribution Ubuntu`
    1. Confirm Installation `wsl --list --verbose` should show:
            
                NAME      STATE           VERSION
                * Ubuntu    Running         2
   1. If not the same response - reboot machine
1. Close and re-open Windows Terminal normally (not as administrator)           
1. Open Ubuntu - (from windows terminal select the carrot next in the tabs)
    1. Note: on the first launch ubuntu will ask that you define the username and password.  Be sure you remember the values you enter here.
* note when you paste multiple lines terminal will warn you. This is expected and you can click ok.
1. If you use Cisco AnyConnect
    1.  If you have git installed( verify if git is installed at ps prompt: git -v ) paste at the ps prompt:
        ```
        cd ~   #change directory to home
        mkdir powershell_scripts 
        git clone https://gist.github.com/3b397630beb816084d750a69e759f1d6.git powershell_scripts
        Unblock-File -Path .\powershell_scripts\fix_wsl_anyconnect.ps1
        .\powershell_scripts\fix_wsl_anyconnect.ps1
        ```
    1. If you do not have git installed paste this at powershell prompt
	```
	cd ~   
	mkdir powershell_scripts 
	ni powershell_scripts\fix_wsl_anyconnect.ps1  
	code powershell_scripts\fix_wsl_anyconnect.ps1 
	```
    1. Then in VS Code paste in contents of https://gist.github.com/elihickey/3b397630beb816084d750a69e759f1d6 and then save and exit vs code
    1. Back at powershell paste in
	```
	Unblock-File -Path .\powershell_scripts\fix_wsl_anyconnect.ps1
	.\powershell_scripts\fix_wsl_anyconnect.ps1
	```
   1. Download as xml and import in task schedule https://gist.github.com/elihickey/95b02abeb5bf524944a3e94bf06c4940
4. Create and Execute the wsl_dcd_prereq.sh script
    1. Log in to unbuntu
    1. Change Directory to home directory: `cd ~` 
    1. Create and edit script: `sudo nano wsl_dcd_prereq.sh`
    1. Paste in [setup script code](https://gist.github.com/elihickey/3e10e713726d4786738536abed79d7d5)
    1. Save and exit nano
    1. Execute wsl_dcd_prereq.sh: `bash wsl_dcd_prereq.sh`
        1. Do not run as sudo 
5. Restart terminal for all changes to take affect.

You are now ready to follow the steps in https://git.ellucian.com/projects/ELLABORATION/repos/data-connect-developer/browse  starting with
` npx @ellucian/data-connect-developer init-project <project-name>`

Know Issue - finding that the fix wsl anyconnect script needs to be run when first launching terminal.
