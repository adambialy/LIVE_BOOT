#!/bin/bash

apt-get install \
    debootstrap \
    squashfs-tools \
    xorriso \
    isolinux \
    syslinux-efi \
    grub-pc-bin \
    grub-efi-amd64-bin \
    grub-efi-ia32-bin \
    mtools \
    dosfstools \
    mc \
    vim-nox \
    nmap \
    sensible-utils \
    net-tools -y


debootstrap \
    --arch=amd64 \
    --variant=minbase \
    bullseye \
    $HOME/LIVE_BOOT/chroot \
    http://ftp.us.debian.org/debian/


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

# packages by apt
apt-get update -y 
apt-get install debconf-utils locales -y
DEBIAN_FRONTEND=noninteractive apt-get install --no-install-recommends linux-image-amd64 live-boot systemd-sysv -y
# Install utils
DEBIAN_FRONTEND=noninteractive apt-get install linux-headers-amd64 network-manager net-tools tcpdump netcat iputils-ping wireless-tools wpagui curl openssh-client blackbox xserver-xorg-core xserver-xorg xinit xterm nano fdisk -y 
DEBIAN_FRONTEND=noninteractive apt-get install atop htop dmraid ethtool hdparm iftop jq bc minicom mtools wget snapd ifupdown2 lm-sensors iotop tmux -y
DEBIAN_FRONTEND=noninteractive apt-get install network-manager vim-nox mc nmap ntfs-3g xfsprogs e2fsprogs btrfs-progs dosfstools screen testdisk nwipe rclone fping tftpd ansible procps iproute2 rsyslog iperf3 ssh git pwgen mingetty -y
DEBIAN_FRONTEND=noninteractive apt-get install iputils-ping dnsmasq dmidecode lighttpd php-fpm pxelinux txt2html fio stress stress-ng pciutils usbutils surf nvidia-cuda-toolkit nvidia-cuda-dev -y
# enable php module
lighty-enable-mod fastcgi-php-fpm

# nvdia drivers
echo "deb http://httpredir.debian.org/debian/ bullseye main contrib non-free" >> /etc/apt/sources.list.d/nvdia.list
apt-get update -y
DEBIAN_FRONTEND=noninteractive apt-get install nvidia-kernel-dkms -y
DEBIAN_FRONTEND=noninteractive apt install nvidia-cuda-dev nvidia-cuda-toolkit nvidia-driver -y


debconf-set-selections < /root/debconf-keyboard-configuration.conf

apt clean

# install packages by snap
#snap install core
#snap install nvtop

# clone repo for RTS LIVE SYSTEM ansible
git clone https://github.com/adambialy/RTS_ansible /root/RTS_ansible

# gpu-burn
cd /root
git clone https://github.com/wilicc/gpu-burn
cd gpu-burn
make
cd /root

# set hostname
echo "rts-pxeboot" > /etc/hostname

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

#copy lighttpd config
cp configs/etc/lighttpd/lighttpd.conf chroot/etc/lighttpd/lighttpd.conf

#copy hosts file
cp -r configs/etc/hosts chroot/etc/hosts

#copy php helper
cp configs/usr/bin/test_result.sh chroot/usr/bin/test_result.sh
chmod 775  chroot/usr/bin/test_result.sh

#copy index.php and servers.php
mkdir -P chroot/var/www/html
chmod 777 chroot/var/www/html
chmod 777 chroot/var/www
cp configs/var/www/html/index.php chroot/var/www/html/index.php
cp configs/var/www/html/servers.php chroot/var/www/html/servers.php

#copy root ssh config
cp -r configs/root/.ssh chroot/root/
chmod 700 chroot/root/.ssh
chmod 600 chroot/root/.ssh/*

echo "at this point reboot is the easiest way of dismounting sys dev and proc"

cd $HOME/LIVE_BOOT/chroot  
umount -lf dev/pts
umount -lf dev
umount -lf proc
umount sys	
cd $HOME/LIVE_BOOT  

exit 0;


#pxeboot

mkdir -p $HOME/LIVE_BOOT/{staging/{EFI/BOOT,boot/grub/x86_64-efi,isolinux,live},tmp}

mksquashfs \
    $HOME/LIVE_BOOT/chroot \
    $HOME/LIVE_BOOT/staging/live/filesystem.squashfs \
    -e boot

cp $HOME/LIVE_BOOT/chroot/boot/vmlinuz-* \
    $HOME/LIVE_BOOT/staging/live/vmlinuz && \
cp $HOME/LIVE_BOOT/chroot/boot/initrd.img-* \
    $HOME/LIVE_BOOT/staging/live/initrd


cp $HOME/LIVE_BOOT/chroot/boot/vmlinuz-* \
    $HOME/LIVE_BOOT/staging/live/vmlinuz && \
cp $HOME/LIVE_BOOT/chroot/boot/initrd.img-* \
    $HOME/LIVE_BOOT/staging/live/initrd


cat <<'EOF' >$HOME/LIVE_BOOT/staging/isolinux/isolinux.cfg
UI vesamenu.c32

MENU TITLE Rack Test System Boot Menu
DEFAULT linux
TIMEOUT 50
MENU RESOLUTION 640 480
MENU COLOR border       30;44   #40ffffff #a0000000 std
MENU COLOR title        1;36;44 #9033ccff #a0000000 std
MENU COLOR sel          7;37;40 #e0ffffff #20ffffff all
MENU COLOR unsel        37;44   #50ffffff #a0000000 std
MENU COLOR help         37;40   #c0ffffff #a0000000 std
MENU COLOR timeout_msg  37;40   #80ffffff #00000000 std
MENU COLOR timeout      1;37;40 #c0ffffff #00000000 std
MENU COLOR msg07        37;40   #90ffffff #a0000000 std
MENU COLOR tabmsg       31;40   #30ffffff #00000000 std

LABEL linux
  MENU LABEL Live Boot RTS [BIOS/ISOLINUX]
  MENU DEFAULT
  KERNEL /live/vmlinuz
  APPEND initrd=/live/initrd boot=live toram

LABEL linux
  MENU LABEL Live Boot RTS [BIOS/ISOLINUX] (vga)
  MENU DEFAULT
  KERNEL /live/vmlinuz
  APPEND initrd=/live/initrd boot=live nomodeset toram
EOF


cat <<'EOF' > $HOME/LIVE_BOOT/staging/boot/grub/grub.cfg
insmod part_gpt
insmod part_msdos
insmod fat
insmod iso9660

insmod all_video
insmod font

set default="0"
set timeout=5

# If X has issues finding screens, experiment with/without nomodeset.

menuentry "Live Boot RTS [EFI/GRUB]" {
    search --no-floppy --set=root --label DEBLIVE
    linux ($root)/live/vmlinuz boot=live
    initrd ($root)/live/initrd
}

menuentry "Live Boot RTS [EFI/GRUB] (nomodeset)" {
    search --no-floppy --set=root --label DEBLIVE
    linux ($root)/live/vmlinuz boot=live nomodeset
    initrd ($root)/live/initrd
}
EOF

cp $HOME/LIVE_BOOT/staging/boot/grub/grub.cfg $HOME/LIVE_BOOT/staging/EFI/BOOT/


cat <<'EOF' >$HOME/LIVE_BOOT/tmp/grub-embed.cfg
if ! [ -d "$cmdpath" ]; then
    # On some firmware, GRUB has a wrong cmdpath when booted from an optical disc.
    # https://gitlab.archlinux.org/archlinux/archiso/-/issues/183
    if regexp --set=1:isodevice '^(\([^)]+\))\/?[Ee][Ff][Ii]\/[Bb][Oo][Oo][Tt]\/?$' "$cmdpath"; then
        cmdpath="${isodevice}/EFI/BOOT"
    fi
fi
configfile "${cmdpath}/grub.cfg"
EOF

cp /usr/lib/ISOLINUX/isolinux.bin "${HOME}/LIVE_BOOT/staging/isolinux/" && \
cp /usr/lib/syslinux/modules/bios/* "${HOME}/LIVE_BOOT/staging/isolinux/"
cp -r /usr/lib/grub/x86_64-efi/* "${HOME}/LIVE_BOOT/staging/boot/grub/x86_64-efi/"
mkdir chroot/srv/tftp
cp chroot/usr/lib/PXELINUX/pxelinux.0 chroot/srv/tftp/
cp -r configs/srv/pxelinux.cfg chroot/srv/tftp/
cp staging/live/filesystem.squashfs chroot/var/www/html/
cp chroot/boot/vmlinuz-* chroot/var/www/html/vmlinuz
cp chroot/boot/initrd.img-* chroot/var/www/html/initrd
cp staging/isolinux/* chroot/srv/tftp/

# live boot

cat <<'EOF' >$HOME/LIVE_BOOT/chroot/root/configure.sh
#!/bin/bash
DEBIAN_FRONTEND=noninteractive apt-get install dnsmasq -y
apt clean

# clone repo for RTS LIVE SYSTEM ansible
git clone https://github.com/adambialy/RTS_ansible /root/RTS_ansible

# set hostname
echo "rts-live" > /etc/hostname
EOF


chmod 700 $HOME/LIVE_BOOT/chroot/root/configure.sh
chroot chroot/ /root/configure.sh

#copy dnsmasq config
cp -r configs/etc/dnsmasq.conf chroot/etc/


