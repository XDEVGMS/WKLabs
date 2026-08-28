#!/bin/bash
SCRIPT_PATH=$(realpath -- "$0" 2>/dev/null || readlink -f -- "$0")

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
  echo "Installation aborted."
  exit 1
fi

HOMEDIR=$( getent passwd "$USER" | cut -d: -f6 )

if [ "$USER" = "root" ] ; then
  echo "You are root";
  sudo=""
else
  sudo="sudo "
fi

# Create the required folder structure to hold the installation
sudo systemctl stop webkeyos
cd ~/ || exit
sudo chmod 777 webkeyos/subservice
mkdir -p webkeyos/subservice/webproxy
chmod 777 webkeyos/subservice/webproxy

cd webkeyos/subservice/webproxy || exit

echo "-------------------------------------"

# Determine the host architecture and OS context
ARCH_RAW=$(uname -m)
OS_RAW=$(uname -s | tr '[:upper:]' '[:lower:]')

# Detectar arquitectura para la URL de descarga original
if [[ $ARCH_RAW == "x86_64" ]]; then
  arch="amd64"
  target="amd64"
elif [[ $ARCH_RAW == "aarch64" ]]; then
  arch="arm64"
  target="arm"
elif [[ $ARCH_RAW == "armv"* ]]; then
  arch="arm"
  target="arm"
else
  read -p "Enter the target architecture (e.g. amd64, arm64, arm): " arch
fi

# Define Download URL and Output Filename
if [[ "$OS_RAW" == *"mingw"* ]] || [[ "$OS_RAW" == *"cygwin"* ]] || [[ "$OS_RAW" == *"windows"* ]]; then
  # Windows target
  output_name="webproxy.exe"
  download_url="https://github.com/XDEVGMS/WKLabs/raw/refs/heads/main/subservice/WebProxy/webproxy_windows_${arch}.exe"
else
  # Linux / Unix target
  output_name="webproxy_linux_${target}"
  download_url="https://github.com/XDEVGMS/WKLabs/raw/refs/heads/main/subservice/WebProxy/webproxy_linux_${arch}"
fi

# Download the WebProxy binary with the dynamic name
echo "Downloading WebProxy from ${download_url} ..."
echo "Saving as: ${output_name}"
wget -O "${output_name}" "${download_url}"
sudo chmod -R 755 "${output_name}"

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

# Cleanup script safely
cleanup() {
  sudo rm -f -- "$SCRIPT_PATH"
}
trap cleanup EXIT
