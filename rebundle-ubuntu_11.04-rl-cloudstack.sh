#!/bin/sh -ex

# Rebundle Ubuntu 11.04 cloud image with RightScale RightLink

release=11.04
codename=natty
arch=amd64
cloud=cloudstack
rightscale_release=5.7.16
download_dest="$HOME/src/dev-images"

image="ubuntu-$release-server-cloudimg-$arch"
mp_chroot="/mnt/$codename-server-cloudimg-$arch"

mkdir -p "$download_dest"
cd "$download_dest"
wget "http://uec-images.ubuntu.com/releases/$codename/release/$image.tar.gz" -O "$download_dest/$image.tar.gz"
tar zxvf "$download_dest/$image.tar.gz"
mkdir -pv "/mnt/$codename-server-cloudimg-$arch"
mount -o loop "$download_dest/$codename-server-cloudimg-$arch.img" "$mp_chroot"

# use google dns in resolv.conf
echo "nameserver 8.8.8.8" > "$mp_chroot/etc/resolv.conf"

# update apt sources
chroot "$mp_chroot" apt-get -y update

# install rightscale/rightlink deps
chroot "$mp_chroot" apt-get -y install libc6 debconf curl git-core

# create rightscale.d folder
mkdir -p "$mp_chroot/etc/rightscale.d"

# set rs cloud
echo -n "$cloud" > "$mp_chroot/etc/rightscale.d/cloud"

# set intial release
echo -n "$rightscale_release" > "$mp_chroot/etc/rightscale.d/rightscale-release"

# install rightimage service
chroot "$mp_chroot" wget -q -O /etc/init.d/rightimage https://raw.github.com/rightscale/rightimage/master/cookbooks/rightimage/files/default/rightimage
chroot "$mp_chroot" chmod +x /etc/init.d/rightimage
chroot "$mp_chroot" update-rc.d rightimage defaults

# install rightscale/rightlink
wget "http://mirror.rightscale.com/rightlink/$rightscale_release/ubuntu/rightscale_$rightscale_release-ubuntu_10.04-$arch.deb" -O "$mp_chroot/tmp/rightscale_$rightscale_release-ubuntu_10.04-$arch.deb"
chroot "$mp_chroot" dpkg -i "/tmp/rightscale_$rightscale_release-ubuntu_10.04-$arch.deb"

# if this far, install some recommended defaults on top of what the image provides
chroot "$mp_chroot" apt-get -y install python ruby rubygems

cd "$download_dest"; umount "$mp_chroot"