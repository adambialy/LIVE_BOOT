Rack Test System - live boot Debian
-----------------------------------

1. Create VM with Debian11

2. apt update/upgrade

3. Install git "apt install git -y"

4. cd /root && git clone https://github.com/adambialy/LIVE_BOOT.git	

5. cd LIVE_BOOT

6. run scripts:

```
00-config_system.sh 
01-generate_rootfs.sh
```
reboot vm to unmount all 
```
02-generate_iso.sh
```

7. After generate_iso.sh is finished you should endup with rts-live.iso image in /root/LIVE_BOOT directory, ready to be flashed on USB stick.

optional

8. install lighttpd on VM with config:

```server.modules = (
	"mod_indexfile",
	"mod_access",
	"mod_alias",
 	"mod_redirect",
)

server.document-root        = "/var/www/html"
server.upload-dirs          = ( "/var/cache/lighttpd/uploads" )
server.errorlog             = "/var/log/lighttpd/error.log"
server.pid-file             = "/run/lighttpd.pid"
server.username             = "www-data"
server.groupname            = "www-data"
server.port                 = 80
server.dir-listing = "enable"

server.feature-flags       += ("server.h2proto" => "enable")
server.feature-flags       += ("server.h2c"     => "enable")
server.feature-flags       += ("server.graceful-shutdown-timeout" => 5)

server.http-parseopts = (
)

index-file.names            = ( "index.php", "index.html" )
url.access-deny             = ( "~", ".inc" )
static-file.exclude-extensions = ( ".php", ".pl", ".fcgi" )

include_shell "/usr/share/lighttpd/use-ipv6.pl " + server.port
include_shell "/usr/share/lighttpd/create-mime.conf.pl"
include "/etc/lighttpd/conf-enabled/*.conf"

server.modules += (
	"mod_dirlisting",
	"mod_staticfile",
)
```

9. copy rts-live.iso to /var/www/html

10. In balena etcher you can "flash from url" http://[vm_ip]/rts-live.iso


