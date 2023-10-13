#!/bin/bash

CHROOTAPTI="chroot chroot/ apt-get install "

chroot chroot/ apt-get update -y 
${CHROOTAPTI} --no-install-recommends linux-image-amd64 live-boot systemd-sysv -y

${CHROOTAPTI} --no-install-recommends network-manager net-tools wireless-tools wpagui curl openssh-client blackbox xserver-xorg-core xserver-xorg xinit xterm nano -y 

${CHROOTAPTI} network-manager vim-nox mc nmap fping tftpd isc-dhcp-server ansible procps iproute2 rsyslog iperf3 ssh git pwgen mingetty -y
  
chroot chroot/ apt clean

# scramble password
chroot chroot/ export PwgenPw=`pwgen 10 1` && echo -e "${PwgenPw}\n${PwgenPw}" | passwd

chroot chroot/ git clone https://github.com/adambialy/RTS_ansible /root/RTS_ansible

chroot chroot/ echo "rts-live" > /etc/hostname

cp -r configs/etc/ssh/* chroot/etc/ssh/
cp -r configs/etc/systemd/system/* chroot/etc/systemd/system/

cp -r configs/root/* chroot/root/


