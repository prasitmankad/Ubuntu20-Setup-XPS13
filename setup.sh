#!/bin/bash
set -x 

sudo rm -f /etc/apt/sources.list.d/*bionic* # remove bionic repositories
sudo apt install gnome-tweak-tool
sudo apt purge ubuntu-web-launchers

# Add dell drivers for focal fossa

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

sudo apt update

sudo apt install git htop lame net-tools flatpak npm \
openssh-server sshfs nano adb \
vlc gthumb gnome-tweaks ubuntu-restricted-extras \
python-is-python3 ffmpeg ufw \
gnome-tweak-tool spell synaptic -y -qq

# Install drivers
sudo apt install oem-somerville-melisa-meta libfprint-2-tod1-goodix oem-somerville-meta tlp-config -y

# Install fonts
sudo apt install fonts-firacode fonts-open-sans -y -qq

gsettings set org.gnome.desktop.interface font-name 'Open Sans 12'
gsettings set org.gnome.desktop.interface monospace-font-name 'Fira Code 13'

# Install fusuma for handling gestures
sudo gpasswd -a $USER input
sudo apt install libinput-tools xdotool ruby -y -qq
sudo gem install --silent fusuma

# Install Howdy for facial recognition
read -p "Facial recognition with Howdy (y/n)?" choice
case "$choice" in 
  y|Y ) 
  echo "Installing Howdy"
  sudo add-apt-repository ppa:boltgolt/howdy -y > /dev/null 2>&1
sudo apt update -qq
  sudo apt install howdy -y;;
  n|N ) 
  echo "Skipping Install of Howdy";;
  * ) echo "invalid";;
esac

# Remove packages:
sudo apt remove rhythmbox -y -q
sudo apt remove cheese -y -q
sudo apt remove libcheese-gtk25 -y -q
sudo apt remove gnome-mahjongg -y -q
sudo apt remove gnome-mines -y -q

# Remove snaps and Add Flatpak support:
sudo snap remove gnome-characters gnome-calculator gnome-system-monitor
sudo apt install gnome-characters gnome-calculator gnome-system-monitor \
gnome-software-plugin-flatpak -y

sudo apt purge snapd

sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

# Setup GNOME material shell
# git clone https://github.com/PapyElGringo/material-shell.git ~/.local/share/gnome-shell/extensions/material-shell@papyelgringo
# gnome-extensions enable material-shell@papyelgringo
echo "🖥️ Customizing Desktop & Gnome Preferences"

# Install Icon Theme
git clone https://github.com/vinceliuice/Tela-icon-theme.git /tmp/tela-icon-theme > /dev/null 2>&1
/tmp/tela-icon-theme/install.sh -a

gsettings set org.gnome.desktop.interface icon-theme 'Tela-grey-dark'

# Add Plata-theme
sudo add-apt-repository ppa:tista/plata-theme -y > /dev/null 2>&1
sudo apt update -qq && sudo apt install plata-theme -y

gsettings set org.gnome.desktop.interface gtk-theme "Plata-Noir-Compact"
gsettings set org.gnome.desktop.wm.preferences theme "Plata-Noir-Compact"

# Installing Canta theme
git clone https://github.com/vinceliuice/Canta-theme.git
mkdir ~/.themes/; mv Canta-theme $_
~/.themes/Canta-theme/install.sh -c dark -t standard -s standard

# Enable Shell Theme
sudo apt install gnome-shell-extensions -y
# sudo apt install chrome-gnome-shell
gnome-extensions enable user-theme@gnome-shell-extensions.gcampax.github.com
gsettings set org.gnome.shell.extensions.user-theme name "Plata-Noir-Compact"

# Gnome Tweaks > Top Bar
gsettings set org.gnome.desktop.interface clock-show-weekday true
gsettings set org.gnome.desktop.interface show-battery-percentage true
gsettings set org.gnome.desktop.interface clock-show-seconds=true
gsettings set org.gnome.desktop.interface document-font-name='Roboto Medium 11'
gsettings set org.gnome.desktop.interface font-name='Roboto Medium 11'
gsettings set org.gnome.desktop.interface monospace-font-name='Fira Code 12'
gsettings set org.gnome.desktop.media-handling autorun-never=true

gsettings set org.gnome.desktop.peripherals.mouse accel-profile='adaptive'
gsettings set org.gnome.desktop.peripherals.mouse natural-scroll=false
gsettings set org.gnome.desktop.peripherals.mouse speed=0.30000000000000004

gsettings set org.gnome.desktop.peripherals.touchpad speed=0.40714285714285725
gsettings set org.gnome.desktop.peripherals.touchpad two-finger-scrolling-enabled=true

gsettings set org.gnome.desktop.sound allow-volume-above-100-percent=false
gsettings set org.gnome.desktop.sound event-sounds=true
gsettings set org.gnome.desktop.sound theme-name='Yaru'


# Tweaks > Appearance
if [[ $(lsb_release -rs) == '18.04' ]]; then 
    cur_theme='whiteglass'
    icon_theme='Humanity'
else 
    cur_theme='Yaru'
    icon_theme='Yaru'
fi

# Setup Development tools

# Update python essentials
sudo python3 -m pip install -U pip setuptools wheel

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
sudo groupadd docker
sudo usermod -aG docker $USER

## Post installation for code (sensible defaults)

code --install-extension ms-python.python
code --install-extension visualstudioexptteam.vscodeintellicode
code --install-extension eamodio.gitlens

#code --install-extension ms-azuretools.vscode-docker

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

echo "Installing Chrome" # Because chrome-gnome-shell to install new extensions did not work with chromium

wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
sudo apt install -y ./google-chrome-stable_current_amd64.deb
rm google-chrome-stable_current_amd64.deb

## Chat
#sudo flatpak install discord -y

## Multimedia
# sudo apt install -y gimp
# sudo flatpak install spotify -y

## Games
# sudo apt install -y steam-installer

## Other packages
#virtualbox
#adb
#sudo apt install npm:all

# qbitrorrent

# Gotta reboot now:
sudo apt update -qq && sudo apt upgrade -y && sudo apt autoremove -y

echo $'\n'$"Ready for REBOOT"
