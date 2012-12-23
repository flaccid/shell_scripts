#!/bin/bash -e

# Bootstrap RightLink 5.8.8 for Ubuntu 12.04 (precise) on EC2

# enable root for rs access
#[ -e /home/ubuntu/.ssh/authorized_key ] && cp -v /home/ubuntu/.ssh/authorized_keys /root/.ssh/

# backwards compat
ln -svf /var/spool/cloud /var/spool/ec2

# ensure no user interaction with package installs
export DEBIAN_FRONTEND=noninteractive

# update apt sources
apt-get -y update

# install rightscale/rightlink deps (and wget)
apt-get -y install libc6 debconf curl git-core wget

# create rightscale.d folder and set cloud to ec2
mkdir -p /etc/rightscale.d
echo -n ec2 > /etc/rightscale.d/cloud

# set intial release
echo -n 5.8.8 > /etc/rightscale.d/rightscale-release

echo 'Installing RightImage service.'
set +e
rightimage_rc=$(curl -s -S -f https://raw.github.com/rightscale/rightimage/master/cookbooks/rightimage/files/default/rightimage)
if [ $? -eq 0 ]; then
  echo "$rightimage_rc" > /etc/init.d/rightimage
  chmod +x /etc/init.d/rightimage
  update-rc.d rightimage defaults
else
  echo "$rightimage_rc"
  echo 'RightImage service install failed! Problem with GitHub?'
fi
set -e

# install rightscale/rightlink
echo 'Installing RightScale RightLink.'
cd /tmp
wget http://mirror.rightscale.com/rightlink/5.8.8/ubuntu/rightscale_5.8.8-ubuntu_12.04-amd64.deb
dpkg -i rightscale_5.8.8-ubuntu_12.04-amd64.deb

# intialize rightscale
/etc/init.d/rightscale start
/etc/init.d/rightboot start

# upgrade to dev package if set
source /var/spool/cloud/user-data.sh
if [[ "$RS_SRC" ]]; then
	echo -n "$RS_SRC" > /etc/rightscale.d/rightscale-release
	# hack to remove existing rightscale package due to logical bugs in the deb maintainer scripts
	echo '#!/bin/sh' > /var/lib/dpkg/info/rightscale.postinst
	echo '#!/bin/sh' > /var/lib/dpkg/info/rightscale.postrm
	echo '#!/bin/sh' > /var/lib/dpkg/info/rightscale.prerm
	dpkg --purge rightscale
	[ -e /opt/rightscale ] && rm -Rf /opt/rightscale
	/etc/init.d/rightimage start
fi

# if this far, install some recommended defaults on top of what the image provides
apt-get -y install python ruby rubygems

# finally, start rightlink
/etc/init.d/rightlink start