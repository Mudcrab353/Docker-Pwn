#!/bin/bash

if [ -f /boot/firmware/PPPwn/upd.log ]; then
    rm -f /boot/firmware/PPPwn/upd.log
fi
echo "Checking for update..." |  tee /dev/tty1 |  tee /dev/pts/* |  tee -a /boot/firmware/PPPwn/upd.log
 mkdir /home/www-data
cd /home/www-data
 rm -f -r PI-Pwn
echo "Downloading files... " |  tee /dev/tty1 |  tee /dev/pts/* |  tee -a /boot/firmware/PPPwn/upd.log
git clone https://github.com/stooged/PI-Pwn
currentver=$(</boot/firmware/PPPwn/ver)
newver=$(<PI-Pwn/PPPwn/ver)
if [ $newver -gt $currentver ]; then
cd PI-Pwn
echo "Starting update..." |  tee /dev/tty1 |  tee /dev/pts/* |  tee -a /boot/firmware/PPPwn/upd.log
 systemctl stop pipwn
echo "Installing files... " |  tee /dev/tty1 |  tee /dev/pts/* |  tee -a /boot/firmware/PPPwn/upd.log
 cp -r PPPwn /boot/firmware/
FOUND=0
readarray -t rdirarr  < <( ls /media/pwndrives)
for rdir in "${rdirarr[@]}"; do
  readarray -t pdirarr  < <( ls /media/pwndrives/${rdir})
  for pdir in "${pdirarr[@]}"; do
     if [[ ${pdir,,}  == "payloads" ]] ; then 
	   FOUND=1
	   PSDRIVE='/media/pwndrives/'${rdir}
	   break
    fi
  done
    if [ "$FOUND" -ne 0 ]; then
      break
    fi
done  
if [[ ! -z $PSDRIVE ]] ;then
  if [ -f "USB Drive/goldhen.bin" ]; then
     if [ -f $PSDRIVE'/goldhen.bin' ]; then
	    rm -f $PSDRIVE'/goldhen.bin'
     fi
      cp "USB Drive/goldhen.bin" $PSDRIVE
  fi
fi
cd /boot/firmware/PPPwn
 chmod 777 *
 bash install.sh update
else
 rm -f -r PI-Pwn
echo "No update found." |  tee /dev/tty1 |  tee /dev/pts/* |  tee -a /boot/firmware/PPPwn/upd.log
fi
