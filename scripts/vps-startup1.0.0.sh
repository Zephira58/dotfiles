#!/usr/bin/env sh

GREEN='\033[0;32m'  # Set the color code for green
NC='\033[0m'        # Reset the color code

username="xanthus"
password="xanthus"

# check if running as root
if [ "$(id -u)" -ne 0 ]; then
	   echo "[xans-startup-script] Please run as root" >&2
	      exit 1
fi

# update and upgrade the operating system
echo "${GREEN}[xans-startup-script] Updating the operating system${NC}"
apt update -y
echo "${GREEN}[xans-startup-script] Upgrading the operating system${NC}"
sudo apt full-upgrade -y
echo "${GREEN}[xans-startup-script] Removing unused packages${NC}"
sudo apt autoremove -y

# install required packages
echo "${GREEN}[xans-startup-script] Installing Fish shell${NC}"
apt install fish -y
echo "[xans-startup-script] Installing Docker${NC}"
apt install docker.io -y
echo "${GREEN}[xans-startup-script] Installing 7zip${NC}"
apt install 7zip -y
echo "${GREEN}[xans-startup-script] Installing Rclone${NC}"
curl https://rclone.org/install.sh | sudo bash
echo "${GREEN}[xans-startup-script] Installing Fail2ban${NC}"
apt install fail2ban -y
echo "${GREEN}[xans-startup-script] Installing OpenSSH Server${NC}"
apt install openssh-server -y
echo "${GREEN}[xans-startup-script] Installing Cron${NC}"
apt install cron -y
echo "${GREEN}[xans-startup-script] Installing Sudo${NC}"
apt install sudo -y
echo "${GREEN}[xans-startup-script] Installing UFW${NC}"
apt install ufw -y

# start and enable services
echo "${GREEN}[xans-startup-script] Starting and enabling Cron${NC}"
systemctl enable cron
systemctl start cron
echo "${GREEN}[xans-startup-script] Starting and enabling Fail2ban${NC}"
systemctl start fail2ban
systemctl enable fail2ban
echo "${GREEN}[xans-startup-script] Starting and enabling OpenSSH Server${NC}"
systemctl start sshd
systemctl enable sshd
echo "${GREEN}[xans-startup-script] Starting and enabling Docker${NC}"
systemctl start docker
systemctl enable docker
echo "${GREEN}[xans-startup-script] Starting and deploying Netdata${NC}"
docker run -d --name=netdata --net=host netdata/netdata:stable

# create and configure user account
echo "${GREEN}[xans-startup-script] Creating and configuring user account${NC}"
useradd -m -p $(openssl passwd -1 $password) -s /usr/bin/fish -G sudo $username
usermod -aG sudo $username
usermod -aG $username $username
usermod -aG docker $username

# set permissions for user's home directory
echo "${GREEN}[xans-startup-script] Setting permissions for user's home directory${NC}"
chmod -R 700 /home/$username
chmod 755 /home

# set up SSH access
echo "${GREEN}[xans-startup-script] Setting up SSH access${NC}"
mkdir /home/$username/.ssh
curl https://raw.githubusercontent.com/Xanthus58/dotfiles/main/.ssh/authorized_keys > /home/$username/.ssh/authorized_keys

# install Starship prompt
echo "${GREEN}[xans-startup-script] Installing Starship prompt${NC}"
curl -sS https://starship.rs/install.sh | sh

# configure Fish shell
echo "${GREEN}[xans-startup-script] Configuring Fish shell${NC}"
mkdir /home/$username/.config/fish/ -p
chmod -R 700 /home/$username/.config 
curl https://raw.githubusercontent.com/Xanthus58/dotfiles/main/.config/fish/config.fish > /home/$username/.config/fish/config.fish
echo "starship init fish | source" >> /home/$username/.config/fish/config.fish
chmod 664 /home/$username/.config/fish/config.fish

# set ownership of home directory to user
echo "${GREEN}[xans-startup-script] Setting ownership of home directory${NC}"
chown -R $username:$username /home/$username

# remind user to change password
echo "${GREEN}[xans-startup-script] Please use 'passwd' to change your password once you login${NC}"

