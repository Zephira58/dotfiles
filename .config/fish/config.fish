if status is-interactive
    # Commands to run in interactive sessions can go here
end

#Custom Alias

#Logs
alias ufwlog="sudo cat /var/log/ufw.log"
alias sshlog="sudo journalctl -u ssh"

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
alias rm="rm -rf"

#Misc
alias grep="grep --color=auto"
alias now="date +"%T""
alias nowdate="date +\"%d-%m-%Y\""

#Init for starship customization
starship init fish | source
