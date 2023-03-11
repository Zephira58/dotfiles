if status is-interactive
    # Commands to run in interactive sessions can go here
end

#Custom Alias

#Logs
alias ufwlog="sudo cat /var/log/ufw.log"
alias sshlog="sudo journalctl -u ssh"
alias f2bstatus="sudo fail2ban-client status"

#Management
alias update="sudo apt update -y; sudo apt full-upgrade -y; sudo apt autoremove -y"
alias uninstall="sudo apt uninstall"
alias search="sudo apt search"
alias install="sudo apt install"
alias listprograms="sudo apt list"

#Programming utils
alias gacp="git add .; git commit; git push"
alias bashup="curl bashupload.com -T"

#Filesystem
alias ..="cd .."
alias mkdir="mkdir -pv"
alias sortsize="find . -type f -print0 | xargs -0 du -h | sort -rh"
alias compress="7z a -mx=9"
alias extract="7z x"

#Misc
alias grep="grep --color=auto"
alias now="date +"%T""
alias nowdate="date +\"%d-%m-%Y\""
alias publicip="curl https://api.ipify.org"

function privateip
    set interface (ip route | grep '^default' | sed -e 's/^.*dev //' -e 's/ .*//')
    ip addr show $interface | grep -oP '(?<=inet\s)\d+(\.\d+){3}' | head -1
end

#Init for starship customization
starship init fish | source
starship init fish | source
