#!/bin/sh

# AUTHOR steven33 <stevenbeach33@gmail.com>

#install requirement
pkg update && pkg upgrade -y
pkg install file which python3 python-lxml curl wget zip -y

#make it executable and move pkg2zip to system
chmod +x nps_*.sh pyNPU.py bin/pkg2zip
test -d "$PREFIX/bin" && ln -s "$(pwd)"/nps_*.sh "$(pwd)"/pyNPU.py "$PREFIX/bin"
mv bin/pkg2zip $PREFIX/bin
./nps_tsv.sh
mkdir -p /sdcard/NPS/{PSV/{GAME,DLC,UPDATE},PSP/GAME,PSM/GAME}
