#!/bin/bash

if [ -f /boot/firmware/PPPwn/upd.log ]; then
    rm -f /boot/firmware/PPPwn/upd.log
fi
while read -r stdo ; 
do 
  echo -e $stdo |  tee /dev/tty1 |  tee /dev/pts/* |  tee -a /boot/firmware/PPPwn/upd.log
done < <( bash /boot/firmware/PPPwn/update.sh)
