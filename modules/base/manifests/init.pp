class base {
  stage {'pre': before => Stage['main']}
  stage {'post': require => Stage['main']}

  class {'users':
    stage => 'pre',
  }

  class {'apt':
    always_apt_update => true
  }

  Exec['apt_update'] -> Package <| |>

  include private::users, postfix, ssh

  package {['mercurial', 'vim', 'emacs', 'debian-goodies']: ensure => present}

  file {'/etc/timezone':
    ensure => file,
    owner => root,
    group => root,
    mode => 0644,
    content => 'UTC',
    notify => Service['cron']
  }

  file {'/etc/localtime':
    ensure => link,
    target => '/usr/share/zoneinfo/UTC',
    notify => Service['cron']
  }

  service {'cron':
    ensure => running,
    enable => true,
  }

  class {'logrotate':
    stage => 'post'
  }

  $servers = hiera("servers")
  create_resources(base::explicit_host_record, $servers)

  define explicit_host_record($ip, $ssh_public_key=undef){
    host{"$name,$ip":
      ensure => present,
      ip => $ip,
      name => "$name.adblockplus.org",
    }

    if $ssh_public_key != undef {
      @sshkey{$name:
        key => $ssh_public_key,
        type => ssh-rsa,
      }
    }
  }
}

