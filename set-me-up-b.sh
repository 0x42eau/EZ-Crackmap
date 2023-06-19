#!/bin/bash

alias grepi='grep -ai'
alias grepv='grep -avi'

alias turbonmap='sudo nmap -sS -Pn --host-timeout=1m --max-rtt-timeout=600ms --initial-rtt-timeout=300ms --min-rtt-timeout=300ms --stats-every 10s --top-ports 500 --min-rate 1000 --max-retries 0 -n -T5 --min-hostgroup 255 -oA fast_scan_output -iL'
