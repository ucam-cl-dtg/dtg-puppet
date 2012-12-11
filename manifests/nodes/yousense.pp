node 'yousense.dtg.cl.cam.ac.uk' {
  include 'dtg::minimal'
  dtg::add_user { 'ml421':
    real_name => 'Mattias Linnap',
    groups    => [ 'adm' ],
    keys      => 'Mattias Linnap <mattias@linnap.com>',
  }

  package {
    ['nginx', 'uwsgi', 'uwsgi-plugin-python', 'python-pip', 'python-dev',
     'tree', 'htop', 'rabbitmq-server', 'inotify-tools']:
      ensure => installed,
  }

  class {'dtg::yousense::apt_postgresql': stage => 'repos'}
  package {
    ['postgresql-9.2', 'postgresql-server-dev-9.2']:
      ensure => installed,
      require => Apt::Ppa['ppa:pitti/postgresql'],
  }

  class {'dtg::yousense::apt_serverdensity': stage => 'repos'}
  package {
    'sd-agent':
      ensure => installed,
      require => Apt::Source['sdagent'],  
  }
}

class dtg::yousense::apt_postgresql {
  apt::ppa {'ppa:pitti/postgresql': }
}

class dtg::yousense::apt_serverdensity {
  apt::key {'sdagent':
    ensure => present,
    key_source => 'https://www.serverdensity.com/downloads/boxedice-public.key',
  }
  apt::source {'sdagent':
    ensure => present,
    location => 'http://www.serverdensity.com/downloads/linux/deb',
    repos => 'main',
    key_source => 'https://www.serverdensity.com/downloads/boxedice-public.key',
    release => 'all',
    include_src => false,
  }
}

if ( $::fqdn == $::nagios_machine_fqdn ) {
  nagios::monitor { 'yousense':
    parents    => '',
    address    => 'yousense.dtg.cl.cam.ac.uk',
    hostgroups => [ 'ssh-servers'],
  }
}

if ( $::fqdn == $::munin_machine_fqdn ) {
  munin::gatherer::configure_node { 'yousense': }
}
