#!/bin/bash

# This script will generate root filesystem and install/configure packages

debootstrap \
    --arch=amd64 \
    --variant=minbase \
    bullseye \
    $HOME/LIVE_BOOT/chroot \
    http://ftp.us.debian.org/debian/


# mounting sys, dev, proc
cd $HOME/LIVE_BOOT/chroot  
mount -t proc /proc proc/
mount --rbind /sys sys/
mount --rbind /dev dev/
cd $HOME/LIVE_BOOT  


# keyboard config
cp -r configs/debconf-keyboard-configuration.conf chroot/root/

# base setup script
cat <<'EOF' >$HOME/LIVE_BOOT/chroot/root/configure.sh
#!/bin/bash

# install packages by apt

apt-get update -y 
apt-get install debconf-utils locales -y

# system
DEBIAN_FRONTEND=noninteractive apt-get install --no-install-recommends linux-image-amd64 live-boot systemd-sysv -y
DEBIAN_FRONTEND=noninteractive apt-get install linux-headers-amd64 -y

# X system
DEBIAN_FRONTEND=noninteractive apt-get install blackbox xserver-xorg-core xserver-xorg xinit xterm nano fdisk surf -y

# utils
DEBIAN_FRONTEND=noninteractive apt-get install txt2html procps git pwgen mingetty ansible iftop jq bc mtools lm-sensors iotop tmux vim-nox mc screen dmidecode html2txt -y

# network tools
DEBIAN_FRONTEND=noninteractive apt-get install nmap minicom ethtool iperf3 ssh dnsmasq tftpd iproute2 wget snmp fping network-manager net-tools tcpdump netcat iputils-ping wireless-tools wpagui curl links lynx openssh-client pxelinux lighttpd php-fpm ifupdown -y

# test tools
DEBIAN_FRONTEND=noninteractive apt-get install atop htop fio stress stress-ng pciutils usbutils -y

# disk/fs tools
DEBIAN_FRONTEND=noninteractive apt-get install hdparm ntfs-3g xfsprogs e2fsprogs btrfs-progs dosfstools testdisk nwipe rclone dmraid -y

# enable php module
lighty-enable-mod fastcgi-php-fpm

# nvdia drivers
echo "deb http://httpredir.debian.org/debian/ bullseye main contrib non-free" >> /etc/apt/sources.list.d/nvdia.list
apt-get update -y
DEBIAN_FRONTEND=noninteractive apt-get install nvidia-kernel-dkms -y
DEBIAN_FRONTEND=noninteractive apt install nvidia-cuda-dev nvidia-cuda-toolkit nvidia-driver -y


debconf-set-selections < /root/debconf-keyboard-configuration.conf

apt clean

# clone repo for RTS LIVE SYSTEM ansible
git clone https://github.com/adambialy/RTS_ansible /root/RTS_ansible

# gpu-burn
cd /root
git clone https://github.com/wilicc/gpu-burn
cd gpu-burn
make
cd /root

# set hostname
echo "rts-live" > /etc/hostname

# scramble password
export PwgenPw=`pwgen 10 1` && \
echo "root account password set to ${PwgenPw}" && \
echo "root password: ${PwgenPw}" > /root/root_pw.txt && \
chmod 600 /root/root_pw.txt && \
echo -e "${PwgenPw}\n${PwgenPw}" | passwd

EOF

chmod 700 $HOME/LIVE_BOOT/chroot/root/configure.sh
chroot chroot/ /root/configure.sh

#copy sshd config
cp -r configs/etc/ssh/* chroot/etc/ssh/

#copy X11 config
cp -r configs/etc/X11/* chroot/etc/X11/

#copy systemd config
cp -r configs/etc/systemd/system/* chroot/etc/systemd/system/

# copy motd
cp configs/etc/motd chroot/etc/

# network config for admin node
cat configs/etc/network/interfaces > chroot/etc/network/interfaces
cp configs/usr/sbin/start_control_server chroot/usr/sbin/
chmod 755 chroot/usr/sbin/start_control_server 

#copy lighttpd config
cp configs/etc/lighttpd/lighttpd.conf chroot/etc/lighttpd/lighttpd.conf

# copy dnsmasq config
cp configs/etc/dnsmasq.conf chroot/etc/

#copy hosts file
cp -r configs/etc/hosts chroot/etc/hosts

#copy php helper
cp configs/usr/bin/test_result.sh chroot/usr/bin/test_result.sh
chmod 775  chroot/usr/bin/test_result.sh

#copy index.php and servers.php
mkdir -p chroot/var/www/html
chmod 777 chroot/var/www/html
chmod 777 chroot/var/www
cp configs/var/www/html/index.php chroot/var/www/html/index.php
cp configs/var/www/html/servers.php chroot/var/www/html/servers.php

#copy root ssh config
cp -r configs/root/.ssh chroot/root/
chmod 700 chroot/root/.ssh
chmod 600 chroot/root/.ssh/*

# copy control server start script
cp configs/usr/sbin/start_control_server chroot/usr/sbin/

echo "at this point reboot is the easiest way of dismounting sys dev and proc"

cd $HOME/LIVE_BOOT/chroot  
umount -lf dev/pts
umount -lf dev
umount -lf proc
umount sys	
cd $HOME/LIVE_BOOT  

exit 0;

