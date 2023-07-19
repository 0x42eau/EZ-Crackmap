#!/bin/bash
#v.03
#update and pipx cme 6.0+

apt remove crackmapexec -y
rm -rf /root/.cme
#Thanks, JR
rm -rf /opt/CrackMapExec

apt update -y

sleep 4
echo '' 
echo 'installing dependencies'
echo '' 
sleep 4

apt install -y libssl-dev libffi-dev python-dev-is-python3 build-essential python3-poetry python3.11-venv
python3 -m pip install pipx

sleep 4
echo ''
echo 'cloning github and installing in /opt'
echo '' 
sleep 4
cd /opt
git clone https://github.com/mpgn/CrackMapExec
cd CrackMapExec

sleep 4
echo '' 
echo 'installing crackmap'
echo '' 
sleep 4

pipx install .

sleep 4

echo 'adding to path, cme and crackmapexec should be global now'
#PATH=$PATH:/root/.local/bin
echo 'PATH=$PATH:/root/.local/bin' >> /root/.zshrc
#echo 'PATH=$PATH:/root/.local/bin' >> /home/kali/.zshrc
echo ''
echo 'restarting /root/.zshrc'
echo ''
source /root/.zshrc
#source /home/kali/.zshrc

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

echo '<<<Tell Sebby thanks for setting it up! :)>>>'
