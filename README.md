Rack Test System - live boot Debian
-----------------------------------

1. Create VM with Debian11

2. apt update/upgrade

3. Install git "apt install git -y"

4. cd /root && git clone https://github.com/adambialy/LIVE_BOOT.git	

5. cd LIVE_BOOT

6. run scripts:
   6.1 01-configure_pxe.sh
   6.2 reboot (easiest way to umount dev, sys, etc...)
   6.3 02-configure-live.sh
   6.4 03-generate_iso.sh

7. After generate_iso.sh is finished you should endup with rts-live.iso image in /root/LIVE_BOOT directory, ready to be flashed on USB stick.


