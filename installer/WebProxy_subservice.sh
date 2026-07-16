#!/bin/bash
clear
cat << "EOF"
__        __   _     _  __           ___  ____  
\ \      / /__| |__ | |/ /___ _   _ / _ \/ ___| 
 \ \ /\ / / _ \ '_ \| ' // _ \ | | | | | \___ \ 
  \ V  V /  __/ |_) | . \  __/ |_| | |_| |___) |
   \_/\_/ \___|_.__/|_|\_\___|\__, |\___/|____/ 
                              |___/             
							  
 Subservice -WebProxy- Installer - WebKeyOS
EOF

echo ""

# Ask user to confirm Install
echo "Install Subservice -WebProxy- WebKeyOS"
read -p "¿Do you want to continue? (y/n) " agree

if [[ $agree != "y" ]]; then
  echo "Starting preparations for Subservice -WebProxy- WebKeyOS."
  exit 1
fi

HOMEDIR=$( getent passwd "$USER" | cut -d: -f6 )

if [ $USER = root ] ; then
  echo "You are root";
  sudo=""
else
  sudo="sudo "
fi

# Create the required folder structure to hold the installation
sudo systemctl stop webkeyos
cd ~/ || exit
cd webkeyos
sudo chmod -R 777 subservice
cd subservice
mkdir webproxy
sudo chmod -R 755 webproxy 
cd webproxy || exit

echo "-------------------------------------"

# Determine the CPU architecture of the host
if [[ $(uname -m) == "x86_64" ]]; then
  arch="amd64"
elif [[ $(uname -m) == "aarch64" ]]; then
  arch="arm64"
elif [[ $(uname -m) == "armv"* ]]; then
  arch="arm"
else
  read -p "Enter the target architecture (e.g. linux_amd64, darwin_amd64, windows_amd64): " arch
fi

# Download the corresponding executable from Repo_Dev / NAVI
if [[ $arch == "amd64" ]]; then
  download_url="https://github.com/XDEVGMS/WKLabs/raw/refs/heads/main/subservice/WebProxy/webproxy_linux_amd64"
elif [[ $arch == "arm64" ]]; then
  download_url="https://github.com/XDEVGMS/WKLabs/raw/refs/heads/main/subservice/WebProxy/webproxy_linux_arm64"
elif [[ $arch == "arm" ]]; then
  download_url="https://github.com/XDEVGMS/WKLabs/raw/refs/heads/main/subservice/WebProxy/webproxy_linux_arm"
elif [[ $arch == "windows_amd64" ]]; then
  download_url="https://github.com/XDEVGMS/WKLabs/raw/refs/heads/main/subservice/WebProxy/webproxy_windows_amd64.exe"
elif [[ $arch == "windows_arm64" ]]; then
  download_url="" #https://github.com/XDEVGMS/WKLabs/raw/refs/heads/main/subservice/WebProxy/webkeyos_windows_arm64.exe"
else
  download_url="https://github.com/XDEVGMS/WKLabs/raw/refs/heads/main/subservice/WebProxy/webproxy_${arch}"
fi

# Download the WebProxy binary
echo "Downloading WebProxy from ${download_url} ..."
wget -O webproxy "${download_url}"
sudo chmod -R 755 webproxy

# Download the Webpack
wget -O webproxy.tar.gz "https://github.com/XDEVGMS/WKLabs/raw/refs/heads/main/subservice/WebProxy/webproxy.tar.gz"
tar -xvzf webproxy.tar.gz
rm webproxy.tar.gz
sudo chmod -R 755 ../../subservice

echo "--------------------------------------------------------"
echo "Subservice -WebProxy- WebKeyOS installation completed!."
echo "Restart service WebKeyOS."
echo "--------------------------------------------------------"
sudo systemctl restart webkeyos
# rm ../../../WebProxy_subservice.sh