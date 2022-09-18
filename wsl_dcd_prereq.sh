#!/bin/bash
# make sure connected
function output () {
        GREEN='\033[0;32m'
        RED='\033[0;31m'
        WHITE='\033[0;37m'
        RESET='\033[0m'
        if [ "$2" = "error" ]; then
            msg="\n${RED}${1}\n${RESET}"
        else 
            msg="${GREEN}${1}${RESET}"
        fi
        echo -e "$msg" | ( TAB=$'\t' ; sed "s/^/$TAB/" ) 
        #echo -e "$1" | tee -a /home/emh/network_fix.log > /dev/null
    }
wget -q --spider --dns-timeout=2 http://google.com 
if [ $? -eq 0 ]; then
    output "Internet is Connected"
else
    output "Could not connect. Please Check Internet Connection.  See WSL/Anyconnect fix https://...tbd..." error
    exit 1 
fi


# Installing NVM see https://github.com/nvm-sh/nvm#installing-and-updating
if [ -d "$HOME/.nvm" ]; then
     output "${HOME}/.nvm exists"
else
# need to check and install curl
     output "installing nvm"
     curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.1/install.sh | bash
   
fi
# set up to use nvm commands
  export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
# close reopen terminal if nvm command not found
if  [ -x "$(command -v nvm)" ]; then
  output 'Error: nvm is not available. Please close terminal session and then try again.' error
  exit 1
else 
    output "nvm version $(nvm --version) is Installed"
fi
nvmCurrent=$(nvm current)
if [[ $(nvm current) == v16* ]]; then
    output "npm version $(nvm current) is current"
else
    output "installing npm v16"
    nvm install 16
    nvm use 16
fi


sudo apt update && sudo apt upgrade -y
output "Installing Prereqs for puppeteer if not installed..."
echo "----------------------------------------------------------------------"
sudo apt-get install ca-certificates fonts-liberation libappindicator3-1 libasound2 libatk-bridge2.0-0 libatk1.0-0 libc6 libcairo2 libcups2 libdbus-1-3 libexpat1 libfontconfig1 libgbm1 libgcc1 libglib2.0-0 libgtk-3-0 libnspr4 libnss3 libpango-1.0-0 libpangocairo-1.0-0 libstdc++6 libx11-6 libx11-xcb1 libxcb1 libxcomposite1 libxcursor1 libxdamage1 libxext6 libxfixes3 libxi6 libxrandr2 libxrender1 libxss1 libxtst6 lsb-release wget xdg-utils
echo "----------------------------------------------------------------------"
output "Prereqs Installed"

ellReg='@ellucian:registry=https://artifactory.devops.ellucian.com/artifactory/api/npm/npmjs'
output "Checking .npmrc path for ellucian artificatory"
if ! grep -q $ellReg "$HOME/.npmrc"  ; then
    output "Adding path for ellucian artifactory to .npmrc"
    echo $ellReg | sudo tee -a $HOME/.npmrc  > /dev/null
fi



output "You should now be ready to initialize your first pipeline project"
output "  with command: npx @ellucian/data-connect-developer init-project <project-name>"
