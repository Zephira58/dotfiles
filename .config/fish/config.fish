if status is-interactive
    # Commands to run in interactive sessions can go here
end

function xanman
        echo "Xans quick and dirty man page for my custom commands"
        echo ""
        echo "-Log Commands-"
        echo "ufwlog: Print all logs created by the uncomplicated firewall"
        echo "sshlog: Print all of the sshd logs"
        echo "f2bstatus <optional:jail>: Prints fail2ban information such as banned ips and jails"
        echo ""
        echo "-Management-"
        echo "update: Updates your entire system automaticly."
        echo "uninstall <package>: Uninstalls the specified package and all of its files"
        echo "search <package>: Searches the default repos for the spesified package"
        echo "install <package>: Installs the spesified package"
        echo "listprograms: Lists all software on the server"
        echo ""
        echo "-Utils-"
        echo "bashup <file>: Allows you to upload a single file for easy sharing"
        echo "metastrip <file>: Strips the metadata of the file using exiftool"
        echo "metaview <file>: Prints out all metadata of the file using exiftool"
        echo "encrypt <inputfile> <outputfile>: Encrypts your files using XChaCha20 with Dexios"
        echo "decrypt <inputfile> <outputfile>: Decrypts your files using XChaCha20 with Dexios"
        echo "securedelete <file>: Securely deletes your file with Dexios by overwritting all data with random data."
        echo ""
        echo "-Filesystem-"
        echo "..: Goes one directory above your present working directory"
        echo "sortsize: Will automaticly sort all files by size reccursivly and print it"
        echo 'compress <archivename> <directory>: Will use 7zip to automaticly archive the directory
 with the highest compression level'
        echo "extract <archive>: Will extract the archive to the current directory"
        echo ""
        echo "-Misc-"
        echo "nowdate: Will print the current date in dd-mm-yyyy format"
        echo "now: Will print the current time"
        echo "publicip: Will print your ipv4 adress"
        echo "privateip: Prints your private ipv4 server adress"
end

#Custom Alias

#Logs
alias ufwlog="sudo cat /var/log/ufw.log"
alias sshlog="sudo journalctl -u ssh"
alias f2bstatus="sudo fail2ban-client status"

#Management
alias update="sudo apt update -y; sudo apt full-upgrade -y; sudo apt autoremove -y"
alias uninstall="sudo apt purge"
alias search="sudo apt search"
alias install="sudo apt install"
alias listprograms="sudo apt list"

#Utils
alias bashup="curl bashupload.com -T"
alias metastrip="exiftool -all="
alias metaview="exiftool"
alias encrypt="dexios -e"
alias decrypt="dexios -d"
alias securedelete="dexios erase --passes=3"

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
