#!/bin/bash

if [ -f /boot/firmware/PPPwn/config.sh ]; then
source /boot/firmware/PPPwn/config.sh
fi
if [ -z $INTERFACE ]; then INTERFACE="eth0"; fi
if [ -z $DTLINK ]; then DTLINK=false; fi


if [ $DTLINK = true ] ; then
echo -e "\033[32mMonitoring link\033[0m\n" |  tee /dev/tty1
coproc read -t 60 && wait "$!" || true
while [[ $(ifconfig $INTERFACE) == *"RUNNING"* ]]
do
    coproc read -t 10 && wait "$!" || true
done
 systemctl stop pppoe
 killall pppoe-server
 ip link set $INTERFACE down
 iptables -P INPUT ACCEPT
 iptables -P FORWARD ACCEPT
 iptables -P OUTPUT ACCEPT
 iptables -t nat -F
 iptables -t mangle -F
 iptables -F
 iptables -X
 sysctl net.ipv4.ip_forward=0
 sysctl net.ipv4.conf.all.route_localnet=0
echo -e "\033[32mRestarting PPPwn\033[0m\n" |  tee /dev/tty1
 systemctl restart pipwn
fi
