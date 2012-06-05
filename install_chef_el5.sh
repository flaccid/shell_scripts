#!/bin/sh -ex

# Installs Chef on EL5/CentOS 5.x including Ruby and RubyGems install from package
# root/sudo required

if type -P ruby >/dev/null; then
	ruby_version=$(ruby -e "print RUBY_VERSION")
	case $ruby_version in 1.8.[56])
		echo "Removing installed Ruby $ruby_version..."
		yum -y remove ruby*
		;; *)
			echo 'Ruby 1.8.5 or 1.8.6 not detected installed.'
		;;
	esac
fi

wget http://rbel.frameos.org/rbel5 -O /tmp/rbel5.rpm && rpm -ivH /tmp/rbel5.rpm; [ -e /tmp/rbel5.rpm ] && rm /tmp/rbel5.rpm
yum -y update
yum -y install ruby ruby-devel ruby-ri ruby-rdoc ruby-shadow gcc gcc-c++ automake autoconf make curl dmidecode
yum -y install rubygems
gem update --system
gem install chef --no-ri --no-rdoc