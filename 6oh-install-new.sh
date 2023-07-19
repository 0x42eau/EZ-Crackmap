#!/bin/bash

#update and bin cme 6.0+

apt remove crackmapexec -y
rm -f /root/.cme/workspaces/default/smb.db
rm -f /root/.cme/workspaces/default/ldap.db
rm -f /root/.cme/workspaces/default/ssh.db
rm -f /root/.cme/workspaces/default/ftp.db
rm -rf /opt/CrackMapExec


apt update


newest=6

current=$(crackmapexec | grep -ia 'version' | cut -d ':' -f 2 | cut -d '.' -f 1)

if [[ $current < $newest ]]; then
	echo 'gotta update CME...please hold'

		
	echo 'installing dependencies'
	sleep 4
	
	apt install -y libssl-dev libffi-dev python-dev-is-python3 build-essential python3-poetry python3.11-venv
	python3 -m pip install pipx
	
	echo 'cloning github and installing '
	sleep 4
	git clone https://github.com/mpgn/CrackMapExec
	cd CrackMapExec
	
	
	echo 'installing crackmap'
	sleep 4
	
	pipx install .
	
	
	sleep 4
	
	echo 'adding to path, cme and crackmapexec should be global now'
	PATH=$PATH:/root/.local/bin
	echo 'PATH=$PATH:/root/.local/bin' >> /root/.zshrc
	echo 'PATH=$PATH:/root/.local/bin' >> /home/kali/.zshrc
	
	sleep 4
	   
	echo 'running cme to see if its good to go'
   	sleep 4
   	
   	cd /
	if cme | grep -ai "bane"; then
	   	echo '!!!!looks like we gucci!!!!'
	else
	  	echo "might need to play with installing cme on your own, this failed"
	   	exit -1
	fi
else
	echo 'Current CME is good :)'
	exit 0
fi


echo '<<<Tell Sebby thanks for setting it up! :)>>>'
