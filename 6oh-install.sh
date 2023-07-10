#!/bin/bash

#update and bin cme 6.0

apt update
apt upgrade -y

newest=6

current=$(crackmapexec | grep -ia 'version' | cut -d ':' -f 2 | cut -d '.' -f 1)

if [[ $current < $newest ]]; then
	  echo 'gotta update CME...please hold'
	  echo 'removing apt package and downloading current github'
	  cd /opt
	  apt remove crackmapexec -y
   	  rm -f /root/.cme/workspaces/default/smb.db
	  rm -rf /opt/CrackMapExec
	  apt install -y libssl-dev libffi-dev python-dev-is-python3 build-essential python3-poetry
	  git clone https://github.com/mpgn/CrackMapExec
	  cd CrackMapExec
	  poetry install
	  echo 'running cme to see if its good to go'
	  poetry run crackmapexec
	  if poetry run crackmapexec | grep -ai "bane"; then
	    	echo "looks like we gucci"
	  else
	   	echo "might need to play with installing cme on your own, this failed"
	    	exit -1
	  fi
else
	  echo 'Current CME is good :)'
	  exit 0
fi

echo 'putting cme into /usr/local/bin/'
echo '#!/bin/bash' > /usr/local/bin/crackmapexec
echo 'cd /opt/CrackMapExec && poetry run crackmapexec'
chmod +x /usr/local/bin/crackmapexec
cd /home/kali
echo "wait for it"
sleep 3
crackmapexec
