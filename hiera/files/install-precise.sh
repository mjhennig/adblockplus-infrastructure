#!/bin/sh

# Install Puppet 2.6.* and Hiera unless the packages are available already:
if [ ! -e /usr/bin/puppet -o ! -e /usr/bin/hiera ]; then
  sudo apt-key add /vagrant/hiera/files/puppetlabs-keyring.gpg \
  && sudo cp /vagrant/hiera/files/puppetlabs.list /etc/apt/sources.list.d/ \
  && echo '
# Puppetlabs packages (e.g. hiera) would attempt to install a puppet 3.x
# or later release (which is not available in precise) if not pinned here
Package: puppet
Pin: version 2.7.*
Pin-Priority: 1000

Package: puppet-common
Pin: version 2.7.*
Pin-Priority: 1000

Package: facter
Pin: version 1.6.*
Pin-Priority: 1000
' | sudo tee /etc/apt/preferences.d/puppetlabs \
  && sudo apt-get -y update \
  && sudo apt-get -y install puppet \
  && sudo apt-get -y install hiera-puppet
fi

# Default to the development versions of the Hiera and hosts configuration
# files if either one is absent:
if [ ! -e /etc/puppet/hiera.yaml ]; then
  sudo ln -fs /vagrant/hiera/vagrant.yaml /etc/puppet/hiera.yaml
fi

if [ ! -e /etc/puppet/hosts.yaml ]; then
  sudo ln -fs /vagrant/hiera/hosts.yaml /etc/puppet/hosts.yaml
fi
