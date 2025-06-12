#!/bin/sh

# AUTHOR steven33 <stevenbeach33@gmail.com>

#install requirement
pkg update && pkg upgrade -y
pkg install file which python3 python-lxml curl wget zip -y

#make it executable and move pkg2zip to system
chmod a+x *
chmod +x bin/pkg2zip
mv bin/pkg2zip $PREFIX/bin
bash nps_tsv.sh
mkdir -p /sdcard/NPS/{PSV/{GAME,DLC,UPDATE},PSP/GAME,PSM/GAME}
