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
    net-tools -y


debootstrap \
    --arch=amd64 \
    --variant=minbase \
    bullseye \
    $HOME/LIVE_BOOT/chroot \
    http://ftp.us.debian.org/debian/

# keyboard config
cp -r configs/debconf-keyboard-configuration.conf chroot/root/

# base setup script
cat <<'EOF' >$HOME/LIVE_BOOT/chroot/root/configure.sh
#!/bin/bash

#apt
apt-get update -y 
apt-get install debconf-utils -y
DEBIAN_FRONTEND=noninteractive apt-get install --no-install-recommends linux-image-amd64 live-boot systemd-sysv -y
DEBIAN_FRONTEND=noninteractive apt-get install ${CHROOTAPTI} --no-install-recommends network-manager net-tools wireless-tools wpagui curl openssh-client blackbox xserver-xorg-core xserver-xorg xinit xterm nano -y 
DEBIAN_FRONTEND=noninteractive apt-get install network-manager vim-nox mc nmap fping tftpd ansible procps iproute2 rsyslog iperf3 ssh git pwgen mingetty -y
DEBIAN_FRONTEND=noninteractive apt-get install iputils-ping dnsmasq dmidecode lighttpd pxelinux txt2html -y

debconf-set-selections < /root/debconf-keyboard-configuration.conf
apt clean

# clone repo for RTS LIVE SYSTEM ansible
git clone https://github.com/adambialy/RTS_ansible /root/RTS_ansible

# set hosname
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

#copy configs
cp -r configs/etc/ssh/* chroot/etc/ssh/

#systemd config
cp -r configs/etc/systemd/system/* chroot/etc/systemd/system/

#dnsmasq
cp -r configs/etc/dnsmasq.conf chroot/etc/

#root ssh config
cp -r configs/root/.ssh chroot/root/
chmod 700 chroot/root/.ssh
chmod 600 chroot/root/.ssh/*


#server info 
cp configs/etc/cron.d/server.info chroot/etc/cron.d/


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

mkdir chroot/srv/tftp
cp chroot/usr/lib/PXELINUX/pxelinux.0 chroot/srv/tftp/
cp -r configs/srv/pxelinux.cfg chroot/srv/tftp/

cp staging/live/filesystem.squashfs chroot/var/www/html/
cp chroot/boot/vmlinuz-* chroot/var/www/html/vmlinuz
cp chroot/boot/initrd.img-* chroot/var/www/html/initrd
cp staging/isolinux/* chroot/srv/tftp/

