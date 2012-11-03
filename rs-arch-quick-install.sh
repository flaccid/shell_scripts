#!/bin/sh -e

# RightScale quick install for ArchLinux

pacman --noconfirm -Syu wget bash lsb-release binutils util-linux dnsutils

rm -Rf /tmp/rightscale
mkdir -p /tmp/rightscale
[ -e /opt/rightscale ] && mv -v /opt/rightscale /opt/rightscale.old.$(date +%s)

cd /tmp/rightscale

wget http://mirror.rightscale.com/rightscale_rightlink/5.8.8/ubuntu/rightscale_5.8.8-ubuntu_12.04-amd64.deb
ar vx ./rightscale_5.8.8-ubuntu_12.04-amd64.deb
tar zxf ./data.tar.gz
tar zxvf ./control.tar.gz

# apply patches
patch -p0 << 'EOF'
--- ./opt/rightscale/etc/init.d/rightscale_functions      2012-06-20 11:21:06.000000000 +1000
+++ ./opt/rightscale/etc/init.d/rightscale_functions      2012-11-03 10:28:17.650947104 +1100
@@ -53,6 +53,10 @@
         export RS_DISTRO=suse
         export RS_BASE_OS=suse
         ;;
+      archlinux*)
+        export RS_DISTRO=archlinux
+        export RS_BASE_OS=archlinux
+        ;;
       *)
         export RS_DISTRO=unknown
         export RS_BASE_OS=unknown
EOF

mv ./opt/rightscale /opt/

sh ./postinst

rm -Rf /tmp/rightscale    # cleanup