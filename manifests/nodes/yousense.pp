node 'yousense.dtg.cl.cam.ac.uk' {
  include 'dtg::minimal'
  dtg::add_user { 'ml421':
    real_name => 'Mattias Linnap',
    groups    => [ 'adm' ],
    keys      => 'Mattias Linnap <mattias@linnap.com>',
  }

  ssh_authorized_key {'mattias@wf':
     ensure => present,
     key => 'AAAAB3NzaC1yc2EAAAABIwAAAQEAzx9Clk40PXQZdqoahSL4rrsFf5JWIBPbOBgCwgwKMl7tnZbBqAk8hwVi2fUIiWbQKgDTtNdFIuUM/xEKzrV1Vz2/Cke0Yx5WUqKZrVb/3vAA+4qwhFAM2Fc1ezUr0yufHXJeZgFvXaMPzyAfFk4UXElAsLaYvgN/4f33o9OkLiTu+wUHrR0jD9xtGko0n6ckaxQvCn1fu3zEnq/6oB+9YkVfKwzc0JbAA9W6qJ2uTU9ryjj0lCqRqqc5iA4WkohwlJzFE9/bTyavTHoEL+Zty7maEZCZJ+WDKypSXwUf0X6+p/a8KACH6rxUHePpoGTQ1kWxmVN9kSQAzuVdP2OBSQ==',
     name => 'mattias@wf',
     type => 'ssh-rsa',
     user => 'ml421',
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
      require => Class['dtg::yousense::apt_serverdensity'],  
  }

  class {'dtg::firewall::publichttp': }
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
    require => Apt::Key['sdagent'],
    notify => Exec['apt_update_serverdensity'],
  }
  exec {'apt_update_serverdensity':
    command => 'apt-get update',
    logoutput => 'on_failure',
    refreshonly => true,
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
