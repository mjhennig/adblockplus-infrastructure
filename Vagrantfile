VAGRANTFILE_API_VERSION = "2"
require 'yaml'

def define_standard_vm(config, host_name, ip, role=nil)
  config.vm.define host_name do |config|

    config.vm.box = 'precise64'
    config.vm.box_url = 'http://cloud-images.ubuntu.com/vagrant/precise/current/precise-server-cloudimg-amd64-vagrant-disk1.box'
    config.vm.host_name = "#{host_name}.adblockplus.org"
    config.vm.network :private_network, ip: ip
    config.vm.provider :virtualbox do |vb|

      vb.customize ["modifyvm", :id, "--cpus", 1]

      # Work around https://www.virtualbox.org/ticket/11649
      vb.customize ['modifyvm', :id, '--natdnshostresolver1', 'on']

      if role == nil
        setup_path = File.join(Dir.pwd, "hiera", "hosts", "#{host_name}.yaml")
      else
        setup_path = File.join(Dir.pwd, "hiera", "roles", "#{role}.yaml")
      end

      setup = YAML.load_file(setup_path) rescue {}
      requirements = setup.fetch("requirements", {})

      requirements.each do |key, value|
        vb.customize ['modifyvm', :id, "--#{key}", "#{value}"]
      end

    end

    config.vm.provision :shell, :path => 'hiera/files/install-precise.sh'
    config.vm.provision :puppet do |puppet|
      puppet.options = [
        '--environment=development',
        '--external_nodes=/vagrant/hiera/files/puppet-node-classifier.rb',
        '--node_terminus=exec',
        '--verbose',
        '--debug',
      ]
      puppet.manifests_path = 'manifests'
      puppet.manifest_file = 'nodes.pp'
      puppet.module_path = 'modules'
      # Requires Puppet 3.x or later
      #puppet.hiera_config_path = 'hiera/vagrant.yaml'
    end

    yield(config) if block_given?

  end
end

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  configYAML = File.join(Dir.pwd, "hiera/hosts.yaml")
  configServers = YAML.load_file(configYAML)
  servers = configServers["servers"]
  servers.each do |server, items|
    ip = items["ip"][0]
    role = items.fetch("role", "default")
    define_standard_vm(config, server, ip, role)
  end
end
