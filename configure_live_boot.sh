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
DEBIAN_FRONTEND=noninteractive apt-get install network-manager vim-nox mc nmap fping tftpd isc-dhcp-server ansible procps iproute2 rsyslog iperf3 ssh git pwgen mingetty -y
debconf-set-selections < /root/debconf-keyboard-configuration.conf
apt clean

# clone repo for RTS LIVE SYSTEM ansible
git clone https://github.com/adambialy/RTS_ansible /root/RTS_ansible

# set hosname
echo "rts-live" > /etc/hostname

# scramble password
export PwgenPw=`pwgen 10 1` && echo -e "${PwgenPw}\n${PwgenPw}" | passwd
EOF

chmod 700 $HOME/LIVE_BOOT/chroot/root/configure.sh
chroot chroot/ /root/configure.sh

# copy configs
cp -r configs/etc/ssh/* chroot/etc/ssh/
cp -r configs/etc/systemd/system/* chroot/etc/systemd/system/
cp -r configs/root/.ssh chroot/root/



 
 
