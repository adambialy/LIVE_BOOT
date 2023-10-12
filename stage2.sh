#!/bin/bash


echo "debian-live" > /etc/hostname

apt-get update -y && \
apt-get install --no-install-recommends \
    linux-image-amd64 \
    live-boot \
    systemd-sysv -y

apt-get install --no-install-recommends \
    network-manager net-tools wireless-tools wpagui \
    curl openssh-client \
    blackbox xserver-xorg-core xserver-xorg xinit xterm \
    nano -y 

apt install --no-install-recommends network-manager net-tools curl openssh-client \
        blackbox \
        xserver-xorg-core \
        xserver-xorg xinit \
        xterm \
        nano \
        vim-nox \
        mc \
        nmap \
        fping \
        tftpd \
        isc-dhcp-server \
        ansible \
        procps \
        iproute2 \
        rsyslog \
        iperf3 \
        ssh \
	git \
	pwgen \
	git \
        mingetty -y
  
apt clean

# scramble password
export PwgenPw=`pwgen 10 1` && echo -e "${PwgenPw}\n${PwgenPw}" | passwd


git clone https://github.com/adambialy/RTS_ansible /root/RTS_ansible

echo "rts-live" > /etc/hostname



