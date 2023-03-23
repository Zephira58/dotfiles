#!/usr/bin/env sh

#Version 1.3.1
GREEN='\033[0;32m'  # Set the color code for green
RESET='\033[0m'     # Reset the color code
RED='\033[0;31m'    # Sets color code to red

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
apt install rclone -y
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
echo "${GREEN}[xans-startup-script] Installing Neofetch${RESET}"
apt install neofetch -y
echo "${GREEN}[xans-startup-script] Installing Borgbackup${RESET}"
apt install borgbackup -y
mkdir /mnt/borgbackup -p
echo "${GREEN}[xans-startup-script] Installing Dexios${RESET}"
wget https://github.com/brxken128/dexios/releases/download/v8.8.1/dexios-linux-amd64
chmod +x dexios-linux-amd64
mv dexios-linux-amd64 /usr/bin/dexios
echo "${GREEN}[xans-startup-script] Installing Neovim${RESET}"
apt install neovim -y
echo "${GREEN}[xans-startup-script] Installing Git${RESET}"
apt install git -y
echo "${GREEN}[xans-startup-script] Installing exiftool${RESET}"
apt install exiftool -y

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
echo "${GREEN}[xans-startup-script] Deploying Netdata${RESET}"
docker run -d --name=netdata -p 80:19999 netdata/netdata:stable
echo "${GREEN}[xans-startup-script] Starting and configuring UFW${RESET}"
systemctl start ufw
systemctl enable ufw
ufw allow 22/tcp
ufw logging low
echo "y" | ufw enable
echo "${GREEN}[xans-startup-script] Adding localdisk to rclone config${RESET}"
echo "[local]" >> /root/.config/rclone/rclone.conf
echo "type = local" >> /root/.config/rclone/rclone.conf

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
curl https://raw.githubusercontent.com/Xanthus58/dotfiles/main/.config/fish/config.fish > /home/$username/.config/fish/config.fish
echo "starship init fish | source" >> /home/$username/.config/fish/config.fish
chmod 664 /home/$username/.config/fish/config.fish
usermod --shell /usr/bin/fish $username

#configure neovim
echo "${GREEN}[xans-startup-script] Configuring Neovim with Kickstart${RESET}"
mkdir /home/$username/nvim/
git clone https://github.com/nvim-lua/kickstart.nvim /home/$username/nvim/


# set ownership of home directory to user
echo "${GREEN}[xans-startup-script] Setting ownership of home directory${RESET}"
chown -R $username:$username /home/$username

# set automatic backup
echo "${GREEN}[xans-startup-script] Configuring monthly automatic backups with Timeshift${RESET}"
echo "@monthly timeshift --create --yes" >> /var/spool/cron/crontabs/root

# take first backup
echo "${GREEN}[xans-startup-script] Taking initial backup with Timeshift${RESET}"
timeshift --create --yes --comment "[xans-startup-script] Initial Backup"

# fetch private and public ip
echo "${GREEN}[xans-startup-script] Fetching public/private ipv4 adresses${RESET}"
interface=$(ip route get 8.8.8.8 | awk '{print $5; exit}')
public_ip=$(curl https://api.ipify.org)
local_ip=$(ip addr show $interface | grep -oP '(?<=inet\s)\d+(\.\d+){3}' | head -1)

# remind user to update information
echo "${GREEN}[xans-startup-script] -Default login credentials-"
echo "[xans-startup-script] Username: ${RED}$username${GREEN}"
echo "[xans-startup-script] Password: ${RED}$password${GREEN}"
echo "[xans-startup-script] Public IP: ${RED}$public_ip${GREEN}"
echo "[xans-startup-script] Private IP: ${RED}$local_ip${GREEN}"
echo "[xans-startup-script] Please use '${RED}usermod -l xanthus <newusername>${GREEN}' to change your account name"
echo "[xans-startup-script] Please use '${RED}passwd${GREEN}' to change your password once you login"
echo "[xans-startup-script] Netdata has been deployed. This is a system monitor tool that can be accessed from your web browser.${RESET}"
