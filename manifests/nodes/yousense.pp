node 'yousense.dtg.cl.cam.ac.uk' {
  include 'dtg::minimal'

  dtg::add_user { 'ml421':
    real_name => 'Mattias Linnap',
    groups    => [ 'adm' ],
    keys      => ['Mattias Linnap <mattias@linnap.com>','Mattias Linnap (llynfi-ssh) <mattias@linnap.com>','Mattias Linnap (macmini-ssh) <mattias@linnap.com>'],
  }

  # Network Setup

  class { 'network::interfaces':
    interfaces => {
      'eth0' => {
        'method' => 'static',
        'address' => '128.232.98.171',
        'netmask' => '255.255.255.0',
        'gateway' => '128.232.98.1',
      }
    },
    auto => ["eth0"],
  }

  $dns = 'nameserver 128.232.1.1\nnameserver 128.232.1.2\nnameserver 128.232.1.3\nsearch dtg.cl.cam.ac.uk'
  file { '/etc/resolv.conf':
    content => '$dns',
  }
  file { '/etc/resolvconf/resolv.conf.d/original':
    content => '$dns',
  }


  # Package Setup

  package {
    ['nginx', 'uwsgi', 'uwsgi-plugin-python', 'rabbitmq-server', # Servers
     'python-pip', 'python-dev', 'tree', 'htop', 'inotify-tools']:  # Tools
      ensure => installed,
  }

  class {'dtg::yousense::apt_postgresql': stage => 'repos'}
  package {
    ['postgresql-9.2', 'postgresql-server-dev-9.2']:
      ensure => installed,
      require => Apt::Ppa['ppa:pitti/postgresql'],
  }

  class {'dtg::firewall::publichttp': }
  class {'dtg::firewall::publichttps': }
}

class dtg::yousense::apt_postgresql {
  apt::ppa {'ppa:pitti/postgresql': }
}

if ( $::fqdn == $::nagios_machine_fqdn ) {
  nagios::monitor { 'yousense':
    parents    => '',
    address    => 'yousense.dtg.cl.cam.ac.uk',
    hostgroups => [ 'ssh-servers', 'http-servers'],
  }
}

if ( $::fqdn == $::munin_machine_fqdn ) {
  munin::gatherer::configure_node { 'yousense': }
}
