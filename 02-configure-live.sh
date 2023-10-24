#!/bin/bash

# pxeboot image gen

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


