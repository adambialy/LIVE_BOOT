#!/bin/bash


apt-get update && \
    apt-get install --no-install-recommends \
    linux-image-amd64 \
    live-boot \
    systemd-sysv -y

apt-get install --no-install-recommends \
    network-manager net-tools wireless-tools wpagui \
    curl openssh-client \
    blackbox xserver-xorg-core xserver-xorg xinit xterm \
    nano -y
    

apt-get install --no-install-recommends network-manager net-tools curl openssh-client \
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
        mingetty -y
