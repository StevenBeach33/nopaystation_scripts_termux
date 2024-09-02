#!/bin/sh

# AUTHOR steven33 <stevenbeach33@gmail.com>

#install requirement
pkg update && pkg upgrade -y
pkg install file which python3 curl zip -y

#make it executable and let system know bin
chmod a+x *
chmod +x bin/pkg2zip
echo "export PATH=$PATH:~/nopaystation_scripts/bin" >> ~/.bashrc
source ~/.bashrc
bash nps_tsv.sh
