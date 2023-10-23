RTS LIVE DEBIAN
---------------

1. Create VM with Debian11

2. apt update/upgrade

3. Install git "apt install git -y"

4. cd /root && git clone https://github.com/adambialy/LIVE_BOOT.git	

5. cd LIVE_BOOT

6. run script ./configure_live_boot.sh 

7. if all went ok you can generate iso running script: ./generate_iso.sh 

After generate_iso.sh is finished you should endup with rts-live.iso image in /root/LIVE_BOOT directory, ready to be flashed on USB stick.


