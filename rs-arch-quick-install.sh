#!/bin/sh -e

# RightScale quick install for ArchLinux

#curl -L https://raw.github.com/flaccid/shell_scripts/master/rs-arch-quick-install.sh | bash -s

cloud=ec2

#pacman --noconfirm -Syu wget bash lsb-release binutils util-linux dnsutils sudo
pacman --noconfirm -Sy wget bash lsb-release binutils util-linux dnsutils sudo

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

patch -p0 << 'EOF'
--- ./opt/rightscale/right_link/scripts/system_configurator.rb    2012-11-03 05:17:11.190532061 +0000
+++ ./opt/rightscale/right_link/scripts/system_configurator.rb    2012-11-03 05:16:01.170531495 +0000
@@ -251,9 +251,13 @@
     end
 
     def restart_sshd
-      sshd_name = File.exist?('/etc/init.d/sshd') ? "sshd" : "ssh"
-      puts "Restarting SSHD..."
-      runshell("/etc/init.d/#{sshd_name} restart")
+      if ENV['RS_BASE_OS'] == 'archlinux'
+        system('systemctl restart sshd.service')
+      else
+        sshd_name = File.exist?('/etc/init.d/sshd') ? "sshd" : "ssh"
+        puts "Restarting SSHD..."
+        runshell("/etc/init.d/#{sshd_name} restart")
+      end
     end
 
     def retrieve_cloud_hostname_and_local_ip
EOF

# end patches

# mv rightscale files into place
mv ./opt/rightscale /opt/

# run rs post-install
sh ./postinst

# start rightscale (manual)
. /opt/rightscale/etc/init.d/rightscale_functions; logger -t RightScale "Rightscale Service start."; check_invoking_user_permissions; init_os_state; install_patch_if_needed 0; init_cloud_state 1; check_for_rightscale; check_boot_state; configure_proxy; ensure_sane_hostname; ensure_sudo_privilege; ensure_fresh_ssh_host_key; create_proxy_config_file; configure_proxy; install_patch_if_needed 1

# start rightlink (manual)
. /opt/rightscale/etc/init.d/rightscale_functions;  logger -t RightScale "RightLink Service start."; check_invoking_user_permissions; init_cloud_state 0; check_invoking_user_permissions; init_os_state; check_for_rightscale; configure_proxy; check_boot_state; install_right_link_scripts; enroll_right_link_instance; deploy_right_link_agent; enable_right_link_core_dumps; start_right_link_agent; update_boot_state

rm -Rf /tmp/rightscale    # cleanup temp files