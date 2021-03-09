#!/bin/bash
set -ex 

# Ensure repositories are enabled
sudo add-apt-repository universe
sudo add-apt-repository multiverse
sudo add-apt-repository restricted

echo "🖥️ Dell Drivers for Ubuntu Focal Fossa"
sudo sh -c 'cat > /etc/apt/sources.list.d/focal-dell.list << EOF
deb http://dell.archive.canonical.com/updates/ focal-dell public
# deb-src http://dell.archive.canonical.com/updates/ focal-dell public
deb http://dell.archive.canonical.com/updates/ focal-oem public
# deb-src http://dell.archive.canonical.com/updates/ focal-oem public
deb http://dell.archive.canonical.com/updates/ focal-somerville public
# deb-src http://dell.archive.canonical.com/updates/ focal-somerville public
deb http://dell.archive.canonical.com/updates/ focal-somerville-melisa public
# deb-src http://dell.archive.canonical.com/updates focal-somerville-melisa public
EOF'

sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys F9FDA6BED73CDC22
sudo apt update

# Install general utilities
sudo apt install git htop lame net-tools flatpak audacity openssh-server sshfs simplescreenrecorder nano adb vlc gthumb gnome-tweaks ubuntu-restricted-extras ffmpeg ufw gnome-tweak-tool spell synaptic -y -qq

#sudo apt purge ubuntu-web-launchers

# Install drivers
sudo apt install oem-somerville-melisa-meta libfprint-2-tod1-goodix oem-somerville-meta tlp-config -y

# Remove snaps and Add Flatpak support:
sudo apt remove rhythmbox -y -q
sudo snap remove gnome-characters gnome-calculator gnome-system-monitor
sudo apt install gnome-characters gnome-calculator gnome-system-monitor gnome-software-plugin-flatpak -y

sudo apt purge snapd

sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

# Install fonts
sudo apt install fonts-roboto fonts-firacode fonts-open-sans -y -qq

# Install fusuma for handling gestures
sudo gpasswd -a $USER input
sudo apt install libinput-tools xdotool ruby -y -qq
sudo gem install fusuma

# Install Howdy for facial recognition
  sudo add-apt-repository ppa:boltgolt/howdy -y > /dev/null 2>&1
sudo apt update -qq
  sudo apt install howdy -y

# Setup GNOME material shell
# git clone https://github.com/PapyElGringo/material-shell.git ~/.local/share/gnome-shell/extensions/material-shell@papyelgringo
# gnome-extensions enable material-shell@papyelgringo
echo "🖥️ Customizing Desktop & Gnome Preferences"

# Install Icon Theme
[[ -d /tmp/tela-icon-theme ]] && rm -rf /tmp/tela-icon-theme
git clone https://github.com/vinceliuice/Tela-icon-theme.git /tmp/tela-icon-theme > /dev/null 2>&1
/tmp/tela-icon-theme/install.sh -a

gsettings set org.gnome.desktop.interface icon-theme 'Tela-grey-dark'

# Add Plata-theme
sudo add-apt-repository ppa:tista/plata-theme -y > /dev/null 2>&1
sudo apt update -qq && sudo apt install plata-theme -y

gsettings set org.gnome.desktop.interface gtk-theme "Plata-Noir"
gsettings set org.gnome.desktop.wm.preferences theme "Plata-Noir"

# Enable Shell Theme

sudo apt install gnome-shell-extensions -y
gnome-extensions enable user-theme@gnome-shell-extensions.gcampax.github.com
gsettings set org.gnome.shell.extensions.user-theme name "Plata-Noir"

# Setup Development tools

# Update python essentials
sudo apt install python3 python-is-python3 -y
sudo python3 -m pip install -U pip setuptools wheel
python -m pip install --user black

# Add build essentials
sudo apt install build-essential -y

# Add Java JDK LTS
sudo apt install openjdk-11-jdk -y

sudo apt remove docker docker-engine docker.io containerd runc
sudo apt install \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg-agent \
    software-properties-common -y -q

curl https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > /tmp/packages.microsoft.gpg
sudo install -o root -g root -m 644 /tmp/packages.microsoft.gpg /usr/share/keyrings/
sudo sh -c 'echo "deb [arch=amd64 signed-by=/usr/share/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/vscode stable main" > /etc/apt/sources.list.d/vscode.list'

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable" > /dev/null 2>&1

sudo apt update -qq && sudo apt install docker-ce docker-ce-cli docker-compose containerd.io code -y

## Post installation for docker
sudo groupadd -f docker
sudo usermod -aG docker $USER

## Post installation for code (sensible defaults)
code --install-extension ms-python.python
code --install-extension visualstudioexptteam.vscodeintellicode
code --install-extension eamodio.gitlens
code --install-extension ms-azuretools.vscode-docker
code --install-extension coenraads.bracket-pair-colorizer
code --install-extension equinusocio.vsc-community-material-theme
code --install-extension dbaeumer.vscode-eslint
code --install-extension equinusocio.vsc-material-theme
code --install-extension equinusocio.vsc-material-theme-icons
code --install-extension eg2.vscode-npm-script
code --install-extension esbenp.prettier-vscode
code --install-extension shan.code-settings-sync

sudo flatpak install postman -y

read -p "Web development (y/n)?" choice
case "$choice" in 
  y|Y ) 
  echo "Installing Node JS"
  curl -sL https://deb.nodesource.com/setup_12.x | sudo -E bash -
  sudo apt-get install -y nodejs 
  curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
  echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list 
  sudo apt-get update -qq && sudo apt-get install -y yarn ;;
  n|N ) 
  echo "Skipping Install of JS SDKs";;
  * ) echo "invalid";;
esac

#jq - json building & parsing and querying
#csvkit - json export / import to csv
sudo apt install csvkit -y
sudo apt install timeshift -y
#sudo apt install deja-dup -y
sudo apt install guake -y
sudo apt install java-common -y
sudo apt install javascript-common -y
sudo apt install qbittorrent -y
#sudo apt install xournal++ -y
sudo apt install gnome-clocks -y
sudo apt install calc -y
sudo apt install fish -y
sudo apt install jq -y
sudo apt install scrcpy -y
sudo apt install virtualbox -y
sudo apt install virtualbox-guest-additions-iso -y
sudo apt-get install -f

sudo add-apt-repository ppa:micahflee/ppa
sudo apt update 
sudo apt install torbrowser-launcher

echo "🖥️ Installing Edge"
curl https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > microsoft.gpg
sudo install -o root -g root -m 644 microsoft.gpg /etc/apt/trusted.gpg.d/
sudo sh -c 'echo "deb [arch=amd64] https://packages.microsoft.com/repos/edge stable main" > /etc/apt/sources.list.d/microsoft-edge-dev.list'
sudo rm microsoft.gpg
sudo apt update
sudo apt install microsoft-edge-dev

sudo apt update

wget https://download2.interactivebrokers.com/installers/tws/latest-standalone/tws-latest-standalone-linux-x64.sh
chmod u+x tws-latest-standalone-linux-x64.sh
./tws-latest-standalone-linux-x64.sh

#wget https://download.mozilla.org/?product=firefox-aurora-latest-ssl&os=linux64&lang=en-US
#sudo cp -rp firefox-83.0b10.tar.bz2 /opt
#sudo rm -rf firefox-83.0b10.tar.bz2
#cd ~
#cd /opt
#sudo tar xjf /opt/firefox-83.0b10.tar.bz2
#sudo rm -rf /opt/firefox-83.0b10.tar.bz2
#sudo chown -R $USER /opt/firefox
#nano ~/.bashrc
#Step 13: Copy and paste this line that sets the path for the executable file: export PATH=/opt/firefox/firefox:$PATH

#create desktop shortcut
#cat > ~/.local/share/applications/firefoxDeveloperEdition.desktop <<EOL
#[Desktop Entry]
#Encoding=UTF-8
#Name=Firefox Developer Edition
#Exec=/opt/firefox/firefox
#Icon=/opt/firefox/browser/chrome/icons/default/default128.png
#Terminal=false
#Type=Application
#Categories=Network;WebBrowser;Favorite;
#MimeType=text/html;text/xml;application/xhtml_xml;x-scheme-handler/http;x-scheme-handler/https;x-scheme-handler/ftp; X-Ayatana-Desktop-Shortcuts=NewWindow;NewIncognitos;
#EOL


echo "🖥️ Remove Crap Packages"
# Remove packages:
sudo apt remove rhythmbox -y
sudo apt remove cheese -y
sudo apt remove cheese-common -y
sudo apt remove libcheese-gtk25 -y
sudo apt remove gnome-mahjongg -y
sudo apt remove gnome-mines -y
sudo apt remove thunderbird -y
sudo apt remove gnome-shell-extension-desktop-icons -y
sudo apt remove gnome-todo -y

sudo apt autoremove -y

#load gnome settings
wget https://raw.githubusercontent.com/prasitmankad/xps13/master/gnome-settings-backup 
dconf load / < gnome-settings-backup

#update swap file size
#https://bogdancornianu.com/change-swap-size-in-ubuntu/

# turn off existing swap
sudo swapoff -a

#Resize the swap
sudo dd if=/dev/zero of=/swapfile bs=1G count=8

#if = input file
#of = output file
#bs = block size
#count = multiplier of blocks

#Change permission
sudo chmod 600 /swapfile

#Make the file usable as swap
sudo mkswap /swapfile

#Activate the swap file
sudo swapon /swapfile

#Edit /etc/fstab and add the new swapfile if it isn’t already there with this statement /swapfile none swap sw 0 0

#Check the amount of swap available
grep SwapTotal /proc/meminfo

# Gotta reboot now:
sudo apt update -qq && sudo apt upgrade -y && sudo apt autoremove -y

echo $'\n'$"Ready for REBOOT"
