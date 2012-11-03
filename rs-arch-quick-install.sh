#!/bin/sh -e

# RightScale quick install for ArchLinux

cloud=ec2

pacman --noconfirm -Syu wget bash lsb-release binutils util-linux dnsutils sudo

rm -Rf /tmp/rightscale
mkdir -p /tmp/rightscale
[ -e /opt/rightscale ] && mv -v /opt/rightscale /opt/rightscale.old.$(date +%s)

mkdir -p /etc/rightscale.d
echo "$cloud" > /etc/rightscale.d/cloud

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

patch -p0 << 'EOF'
--- ./opt/rightscale/bin/post_install.sh   2012-06-20 11:21:06.000000000 +1000
+++ ./opt/rightscale/bin/post_install.sh   2012-11-03 15:40:37.009184929 +1100
@@ -13,22 +13,22 @@
 
 install_right_link_scripts
 
-echo "Setting up System V init and motd"
-
-ln -f /opt/rightscale/etc/init.d/rightboot /etc/init.d/rightboot
-ln -f /opt/rightscale/etc/init.d/rightscale /etc/init.d/rightscale
-ln -f /opt/rightscale/etc/init.d/rightlink /etc/init.d/rightlink
+if [ "$RS_BASE_OS" != 'archlinux' ]; then
+  echo "Setting up System V init and motd"
+  ln -f /opt/rightscale/etc/init.d/rightboot /etc/init.d/rightboot
+  ln -f /opt/rightscale/etc/init.d/rightscale /etc/init.d/rightscale
+  ln -f /opt/rightscale/etc/init.d/rightlink /etc/init.d/rightlink
+  chmod +x /etc/init.d/rightboot
+  chmod +x /etc/init.d/rightscale
+  chmod +x /etc/init.d/rightlink
+fi
 
 mkdir -p /var/lib/rightscale/right_link/certs
 ln -s /var/lib/rightscale/right_link/certs /opt/rightscale/right_link/certs
 
 chmod -R +x /opt/rightscale/bin/*
 chmod +x /opt/rightscale/etc/init.d/*
-chmod +x /etc/init.d/rightboot
-chmod +x /etc/init.d/rightscale
-chmod +x /etc/init.d/rightlink
 chmod +x /opt/rightscale/right_link/bin/*
-
 mkdir -p /etc/rightscale.d
 
 if [ "$RS_BASE_OS" == "debian" ]; then
EOF

mv ./opt/rightscale /opt/

# these shouldn't be needed'
#mkdir -p /var/spool/ec2
#touch /var/spool/ec2/user-data.txt
#touch /var/spool/cloud/user-data.rb
#chmod +x /var/spool/cloud/user-data.rb
#chmod +x /opt/rightscale/bin/ec2/wait_for_eip.rb

sh ./postinst

rm -Rf /tmp/rightscale    # cleanup