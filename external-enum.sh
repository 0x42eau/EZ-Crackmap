#external laziness

#usage : lazy-cme.sh user password dc-ip domain in-scope-ips-list

#check for args
	if [ $# -ne 3 ]; then
			echo 'Usage: ext-enum.sh <scope-list.txt> <domain> <who you is>'
			exit -1
	fi

LOGFILE=$2.log

#starting up
date >> $LOGFILE
echo 'Starting script -- logging to '$2'.log' 
echo ' '
echo ' '
echo 'Output is also logged to command oriented text files'
echo ' '
echo ' '

#echo 'Getting credmaster : git clone apt get https://github.com/knavesec/CredMaster.git'
#cd /opt
#apt get https://github.com/knavesec/CredMaster.git

apt install dirsearch -y

date >> $LOGFILE
cd /home/$3
mkdir $2
cd $2
echo 'Running : mkdir nmap dirsearch amass harvester nikto scope li2user '$2' in /home/'$3'/'$2
mkdir nmap dirsearch amass harvester nikto scope li2user



date >> $LOGFILE
echo 'Running amass : amass enum -ip -d '$2' -noalts -v | tee -a amass/amass.txt >> '$LOGFILE
amass enum -ip -d $2 -noalts -v | tee -a amass/amass.txt >> $LOGFILE

date >> $LOGFILE
echo 'Running harvester : theHarvester -d '$2' -b all -l 200 | tee -a harvester/harvester.txt'
theHarvester -d $2 -b all -l 200 | tee -a harvester/harvester.txt >> $LOGFILE

date >> $LOGFILE
echo 'Running tcp nmap : nmap -Pn -vvv -T4 -p- -iL '$1' -oA nmap-tcp '
nmap -Pn -vvv -T4 -p- -iL $1 -oA nmap-tcp | tee -a nmap/tcp-nmap.txt >> $LOGFILE
date >> $LOGFILE
echo 'Running tcp nmap :nmap -vvv -T4 -sU --top-ports 1337 '$1' -oA nmap-udp'
nmap -vvv -T4 -sU --top-ports 1337 $1 -oA nmap-udp | tee -a nmap/udp-nmap.txt >> $LOGFILE

date >> $LOGFILE
echo 'Running nikto : nikto -h ' $2
nikto -h https://$2 | tee -a nikto/nikto.txt

dirsearch -u https://$2

