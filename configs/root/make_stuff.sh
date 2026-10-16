apt install git mc vim-nox -y
cd /root
git clone https://github.com/adambialy/LIVE_BOOT.git
git clone https://github.com/adambialy/RTS_ansible.git
cd LIVE_BOOT/
cp -r configs/debconf-keyboard-configuration.conf /root/
apt-get install --no-install-recommends linux-image-amd64 live-boot systemd-sysv -y
apt-get install linux-headers-amd64 -y
apt-get install blackbox xserver-xorg-core xserver-xorg xinit xterm nano fdisk surf -y
apt-get install txt2html procps git pwgen mingetty ansible iftop jq bc mtools lm-sensors iotop tmux vim-nox mc screen dmidecode html2text -y
apt-get install nmap minicom ethtool iperf3 ssh dnsmasq iproute2 wget snmp fping network-manager net-tools tcpdump iputils-ping wireless-tools wpagui curl links lynx openssh-client pxelinux lighttpd php-fpm ifupdown -y
apt install nmap minicom ethtool iperf3 ssh dnsmasq iproute2 wget snmp fping network-manager net-tools tcpdump iputils-ping wireless-tools wpagui curl links lynx openssh-client pxelinux lighttpd php-fpm ifupdown -y
apt install atop htop fio stress stress-ng pciutils usbutils hdparm ntfs-3g xfsprogs e2fsprogs btrfs-progs dosfstools testdisk nwipe rclone -y
lighty-enable-mod fastcgi-php-fpm
apt-get install linux-headers-$(uname -r) build-essential -y
cd /root ; wget https://developer.download.nvidia.com/compute/cuda/repos/debian13/x86_64/cuda-keyring_1.1-1_all.deb
dpkg -i cuda-keyring_1.1-1_all.deb
apt update
apt install nvidia-open cuda-toolkit -y

# gpu-burn
cd /root
git clone https://github.com/wilicc/gpu-burn
cd gpu-burn
make
cd /root
cd LIVE_BOOT/configs/etc/ssh/
for I in ssh_host_ecdsa_key ssh_host_ecdsa_key.pub ssh_host_ed25519_key ssh_host_ed25519_key.pub ssh_host_rsa_key ssh_host_rsa_key.pub sshd_config; do cat /root/LIVE_BOOT/configs/etc/ssh/${I} > /etc/ssh/${I}; done
cp /root/LIVE_BOOT/configs/root/.ssh/* /root/.ssh/
chmod 600 /root/.ssh/authorized_keys 
chmod 600 /root/.ssh/id_rsa          
chmod 600 /root/.ssh/known_hosts 

