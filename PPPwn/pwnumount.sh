#!/bin/bash

if [ ! -z $1 ] ;then
systemd-umount /media/pwndrives/$1 &
if [ -f /boot/firmware/PPPwn/vdev.txt ]; then
vdev=$(</boot/firmware/PPPwn/vdev.txt)
if [[ ${vdev//"/dev/"} == $1 ]]; then
rmmod g_mass_storage
rm -f /boot/firmware/PPPwn/vdev.txt
fi
fi
sleep 2
if [ -d /media/pwndrives/$1 ]; then
  rm -r /media/pwndrives/$1
fi
fi
