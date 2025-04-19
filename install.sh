#!/bin/bash

clear

# Green, Yellow & Red Messages.
green_msg() {
  tput setaf 2
  echo "[*] ----- $1"
  tput sgr0
}

yellow_msg() {
  tput setaf 3
  echo "[*] ----- $1"
  tput sgr0
}

red_msg() {
  tput setaf 1
  echo "[*] ----- $1"
  tput sgr0
}

# Check if the user is root.
if [ "$EUID" -ne 0 ]; then
  red_msg "Please run this script as root."
  exit 1
fi

# Update & Upgrade packages
update_upgrade() {
  echo
  yellow_msg 'Updating & Upgrading packages...'
  echo
  sleep 0.5

  sudo apt update && sudo apt upgrade -y
  sudo apt install unzip -y

  echo
  green_msg 'Packages updated & upgraded.'
  echo
  sleep 0.5
}

# Get SSL
get_ssl() {
  echo 
  yellow_msg 'Getting SSL...'
  echo 
  sleep 0.5

  sudo bash -c "$(curl -sL https://raw.githubusercontent.com/erfjab/ESSL/master/essl.sh)" @ --install
  essl "$email" "$domain" /certs/

  echo
  green_msg 'Getting SSL finished.'
  echo 
  sleep 0.5
}

# Install OpenResty
install_openresty() {
  echo
  yellow_msg 'Installing OpenResty...'
  echo
  sleep 0.5

  sudo apt-get -y install --no-install-recommends wget gnupg ca-certificates lsb-release
  wget -O - https://openresty.org/package/pubkey.gpg | sudo gpg --dearmor -o /usr/share/keyrings/openresty.gpg
  echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/openresty.gpg] http://openresty.org/package/ubuntu $(lsb_release -sc) main" | sudo tee /etc/apt/sources.list.d/openresty.list > /dev/null
  sudo apt-get update
  sudo apt-get -y install openresty

  echo
  green_msg 'OpenResty Installed.'
  echo
  sleep 0.5
}

# OpenResty prerequisites
openresty_prerequisites(){
  echo 
  yellow_msg 'OpenResty prerequisites...'
  echo 

  sudo mkdir -p /var/www/html
  sudo wget "https://github.com/zoheirkabuli/soon-site/releases/download/v1.0.4/web.zip"
  unzip web.zip -d /var/www/html/
  sudo mv /var/www/html/out/* /var/www/html/
  sudo rm web.zip
  cp /etc/openresty/nginx.conf /etc/openresty/nginx.conf.bak
  rm -f /etc/openresty/nginx.conf
  curl -fsSL "https://raw.githubusercontent.com/zoheirkabuli/x-ui-advanced/refs/heads/main/nginx.conf" -o "/etc/openresty/nginx.conf"

  echo
  green_msg 'OpenResty prerequisites installed.'
  echo 
  sleep 0.5
}

# DNS Configuration
dns_configuration() {
    # Remove the /etc/resolv.conf file
    rm -f /etc/resolv.conf

    # Create a new /etc/resolv.conf file with the specified data
    cat <<EOF > /etc/resolv.conf
nameserver 1.1.1.1
nameserver 1.0.0.1
nameserver 2606:4700:4700::1111
nameserver 2606:4700:4700::1001
EOF

    # Make /etc/resolv.conf immutable
    chattr +i /etc/resolv.conf

    echo "DNS configuration updated and locked successfully."
}

# Setting SSH Port 1371 
change_ssh_port() {
  echo 
  yellow_msg 'Changing SSH Port...'
  echo 
  sleep 0.5
  
  sudo cp /etc/ssh/sshd_config /etc/ssh/sshd_config.bk
  sudo echo "Port 1371" >> /etc/ssh/sshd_config
  sudo ufw allow 1371/tcp
  sudo service ssh restart

  echo
  green_msg 'SSH Port Changed.'
  echo 
  sleep 0.5
}

# Reboot
reboot() {
  echo 
  yellow_msg 'Reboot in 3 Seconds...'
  echo 
  sleep 3
  
  shutdown -r 0 
}

update_upgrade
get_ssl
install_openresty
openresty_prerequisites
change_ssh_port
dns_configuration
reboot
