#!/bin/bash

# This is initial script which needs to be executed only on clean debian 11 install

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
    net-tools \
    alien 
    live-boot-doc \
    live-build \
    live-config-doc \
    live-manual-html -y

mkdir /root/lv ; cd /root/lv
lb clean
lb config --mode debian --system live --interactive shell --distribution trixie --architecture amd64 --archive-areas "main contrib non-free" --bootappend-live "boot=live" --bootloaders "syslinux" --security true --updates true --binary-images iso-hybrid --memtest none
cd /root
cp -r LIVE_BOOT/lv/* lv/
cd /root
lb build
