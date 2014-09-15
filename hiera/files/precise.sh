#!/bin/sh

if [ ! -e /usr/bin/puppet -o ! -e /usr/bin/hiera ]; then
  sudo apt-key add /vagrant/hiera/files/puppetlabs-keyring.gpg \
  && sudo cp /vagrant/hiera/files/puppetlabs.list /etc/apt/sources.list.d/ \
  && echo '
# Puppetlabs packages (e.g. hiera) would attempt to install a puppet 3.x
# or later release (which is not available in precise) if not pinned here
Package: puppet
Pin: release v=2.7.*
Pin-Priority: 666

Package: puppet-common
Pin: release v=2.7.*
Pin-Priority: 666
' | sudo tee /etc/apt/preferences.d/puppetlabs \
  && sudo apt-get -y update \
  && sudo apt-get -y install puppet \
  && sudo apt-get -y install hiera-puppet
fi

if [ ! -e /etc/puppet/hiera.yaml ]; then
  sudo ln -fs /vagrant/hiera/vagrant.yaml /etc/puppet/hiera.yaml
fi

if [ ! -L /etc/hiera.yaml ]; then
  rm -f /etc/hiera.yaml
  ln -fs puppet/hiera.yaml /etc/hiera.yaml
fi

if [ ! -e /usr/local/bin/puppet-node-classifier ]; then
  ln -fs /vagrant/hiera/files/classify.sh /usr/local/bin/puppet-node-classifier
fi
