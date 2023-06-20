#!/bin/bash

apt update -y
apt upgrade -y

sleep 3

cd /opt && git clone https://github.com/cheesemonkey00/scripts.git

mv /home/kali/.bashrc /home/kali/.bashrc.bak

cp /opt/scripts/kali0-bashrc /home/kali/.bashrc

exec bash

apt install neo4j && apt install bloodhound

#greps
#alias grepi='grep -ai'
#alias grepv='grep -avi'

#scans
#alias turbonmap='sudo nmap -sS -Pn --host-timeout=1m --max-rtt-timeout=600ms --initial-rtt-timeout=300ms --min-rtt-timeout=300ms --stats-every 10s --top-ports 500 --min-rate 1000 --max-retries 0 -n -T5 --min-hostgroup 255 -oA fast_scan_output -iL'
#alias nmap-all='nmap -p- -Pn -T4 --stats-every 20s -n -vvv -oA all-nmap -iL'
#alias nmap-users='nmap -p88 --script=krb5-enum-users --script-args="krb5-enum-users.realm='
#alias smbcrackmap='crackmapexec smb'
