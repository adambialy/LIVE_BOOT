Rack Test System - live boot Debian
-----------------------------------

This is the basic live debian 13 designe to stress test server with nvdia GPU.
The system focus is on thermal capacity, but there is plenty of useful tools (full list in Appendix)

1. Create VM with Debian13

2. apt update/upgrade

3. Install git ```apt install git -y```

4. ``` cd /root && git clone https://github.com/adambialy/LIVE_BOOT.git ```

5. cd LIVE_BOOT

6. run script:

```
00-config_system.sh 
```
7. From inside chroot run:
```
	apt install git vim-nox -y
	cd /root
	git clone https://github.com/adambialy/LIVE_BOOT.git
	git clone https://github.com/adambialy/RTS_ansible.git
	cd LIVE_BOOT/
	git checkout deb13
```


8. exit to finish configuration

9. Download iso and write to usb
