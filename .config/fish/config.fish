if status is-interactive
    # Commands to run in interactive sessions can go here
end

#Custom Alias

#Logs
alias ufwlog="cat /var/log/ufw.log"
alias sshlog="journalctl -u ssh"

#Management
alias update="yay"
alias uninstall="yay -Rns"
alias search="yay -Ss"
alias install="yay -S"
alias listprograms="yay -Q"

#Programming utils
alias gacp="git add .; git commit; git push"

#Filesystem
alias ..="cd .."
alias mkdir="mkdir -pv"
alias home="cd ~/"

#Misc
alias grep="grep --color=auto"
alias now="date +"%T""
alias nowdate="date +\"%d-%m-%Y\""

#Init for starship customization
starship init fish | source
