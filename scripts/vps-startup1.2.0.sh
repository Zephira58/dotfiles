#!/usr/bin/env sh

GREEN='\033[0;32m'  # Set the color code for green
RESET='\033[0m'        # Reset the color code
RED='\033[0;31m'

username="xanthus"
password="xanthus"

# check if running as root
if [ "$(id -u)" -ne 0 ]; then
	   echo "${RED}[xans-startup-script] Please run as root${RESET}" >&2
	      exit 1
fi

# enable automatic service restart
echo "${GREEN}[xans-startup-script] Enabling automatic service restart${RESET}"
echo "$nrconf{restart} = 'a';" >> /etc/needrestart/needrestart.conf

# update and upgrade the server 
echo "${GREEN}[xans-startup-script] Updating the package list${RESET}"
apt update -y
echo "${GREEN}[xans-startup-script] Updating server software${RESET}"
sudo apt full-upgrade -y
echo "${GREEN}[xans-startup-script] Removing unused packages${RESET}"
sudo apt autoremove -y

# install required packages
echo "${GREEN}[xans-startup-script] Installing Fish shell${RESET}"
apt install fish -y
echo "${GREEN}[xans-startup-script] Installing Docker${RESET}"
apt install docker.io -y
echo "${GREEN}[xans-startup-script] Installing 7zip${RESET}"
apt install 7zip -y
echo "${GREEN}[xans-startup-script] Installing Rclone${RESET}"
curl https://rclone.org/install.sh | sudo bash
echo "${GREEN}[xans-startup-script] Installing UFW${RESET}"
apt install ufw -y
echo "${GREEN}[xans-startup-script] Installing Fail2ban${RESET}"
apt install fail2ban -y
echo "${GREEN}[xans-startup-script] Installing OpenSSH Server${RESET}"
apt install openssh-server -y
echo "${GREEN}[xans-startup-script] Installing Cron${RESET}"
apt install cron -y
echo "${GREEN}[xans-startup-script] Installing Sudo${RESET}"
apt install sudo -y
echo "${GREEN}[xans-startup-script] Installing Timeshift${RESET}"
apt install timeshift -y
echo "${GREEN}[xans-startup-script] Installing HTOP${RESET}"
apt install htop -y
echo "${GREEN}[xans-startup-script] Installing Screen${RESET}"
apt install screen -y
echo "${GREEN}[xans-startup-script] Installing Rsnapshot${RESET}"
apt install rsnapshot -y

# start and enable services
echo "${GREEN}[xans-startup-script] Starting and enabling Cron${RESET}"
systemctl enable cron
systemctl start cron
echo "${GREEN}[xans-startup-script] Starting and enabling OpenSSH Server${RESET}"
systemctl start sshd
systemctl enable sshd
echo "${GREEN}[xans-startup-script] Starting and enabling Docker${RESET}"
systemctl start docker
systemctl enable docker
echo "${GREEN}[xans-startup-script] Starting and deploying Netdata${RESET}"
docker run -d --name=netdata -p 80:19999 netdata/netdata:stable
echo "${GREEN}[xans-startup-script] Starting and enabling UFW${RESET}"
systemctl start ufw
systemctl enable ufw
ufw allow 22/tcp
echo "y" | ufw enable


echo "${GREEN}[xans-startup-script] Starting and enabling Fail2ban${RESET}"
systemctl enable fail2ban
systemctl start fail2ban

# create and configure user account
echo "${GREEN}[xans-startup-script] Creating and configuring admin user account${RESET}"
useradd -m -p $(openssl passwd -1 $password) -s /usr/bin/fish -G sudo $username
usermod -aG sudo $username
usermod -aG $username $username
usermod -aG docker $username

# set permissions for user's home directory
echo "${GREEN}[xans-startup-script] Setting permissions for user's home directory${RESET}"
chmod -R 700 /home/$username
chmod 755 /home

# set up SSH access
echo "${GREEN}[xans-startup-script] Setting up SSH access${RESET}"
mkdir /home/$username/.ssh
curl https://raw.githubusercontent.com/Xanthus58/dotfiles/main/.ssh/authorized_keys > /home/$username/.ssh/authorized_keys

# install Starship prompt
echo "${GREEN}[xans-startup-script] Installing Starship prompt${RESET}"
curl -sS https://starship.rs/install.sh | sh

# configure Fish shell
echo "${GREEN}[xans-startup-script] Configuring Fish shell${RESET}"
mkdir /home/$username/.config/fish/ -p
chmod -R 700 /home/$username/.config 
curl https://raw.githubusercontent.com/Xanthus58/dotfiles/main/.config/fish/config.fish > /home/$username/.config/fish/config.fish
echo "starship init fish | source" >> /home/$username/.config/fish/config.fish
chmod 664 /home/$username/.config/fish/config.fish
usermod --shell /usr/bin/fish $username

# set ownership of home directory to user
echo "${GREEN}[xans-startup-script] Setting ownership of home directory${RESET}"
chown -R $username:$username /home/$username

# set automatic backup
echo "${GREEN}[xans-startup-script] Configuring weekly automatic backups with Timeshift${RESET}"
echo "@daily timeshift --create --yes" >> /var/spool/cron/crontabs/root
echo "${GREEN}[xans-startup-script] Configuring and testing Rsnapshot${RESET}"
curl https://raw.githubusercontent.com/Xanthus58/dotfiles/main/rsnapshot/base > /etc/rsnapshot.conf
rsnapshot configtest

#take first backup
echo "${GREEN}[xans-startup-script] Taking initial backup with Timeshift${RESET}"
timeshift --create --yes --comment "[xans-startup-script] Initial Backup"

# remind user to update information 
echo "${GREEN}[xans-startup-script] -Default login credentials-${RESET}"
echo "${GREEN}[xans-startup-script] Username: $username ${RESET}"
echo "${GREEN}[xans-startup-script] Password: $password ${RESET}"
echo "${GREEN}[xans-startup-script] Please use 'passwd' to change your password once you login${RESET}"
echo "${GREEN}[xans-startup-script] Please use 'usermod -l xanthus <newusername>' to change your account name${RESET}"
