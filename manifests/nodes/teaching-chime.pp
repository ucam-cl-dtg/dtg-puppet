node /^teaching-chime/ {
  include 'dtg::minimal'

  class {'dtg::firewall::publichttps':}
  ->
  class {'dtg::firewall::publichttp':}
  ->
  class {'apache':}
  ->
  class {'dtg::apache::raven':
    server_description => 'Chime'
  }
  ->
  apache::module {'proxy':}
  ->
  apache::module {'proxy_http':}
  ->
  exec {'generate-AAHeaderKey':
    command => '/bin/bash -c "echo -n \"AAHeaderKey \"; openssl rand -hex 24" > /etc/apache2/AAHeaderKey.conf',
    creates => '/etc/apache2/AAHeaderKey.conf'
  }
  ->
  file {'/etc/apache2/AAHeaderKey.conf':
    owner => 'root',
    group => 'root',
    mode  => '0600'
  }
  ->
  exec {'generate-AACookieKey':
    command => '/bin/bash -c "echo -n \"AACookieKey \"; openssl rand -hex 24" > /etc/apache2/AACookieKey.conf',
    creates => '/etc/apache2/AACookieKey.conf'
  }
  ->
  file {'/etc/apache2/AACookieKey.conf':
    owner => 'root',
    group => 'root',
    mode  => '0600'
  }
  ->
  apache::module {'headers':}
  ->
  apache::module {'rewrite':}
  ->
  apache::module {'ssl':}
  ->
  apache::site {'chime':
    source => 'puppet:///modules/dtg/apache/chime.conf',
  }

  class {'letsencrypt':
    email          => $::from_address,
    configure_epel => false,
  } ->
  letsencrypt::certonly { 'chime.cl.cam.ac.uk':
    plugin        => 'webroot',
    webroot_paths => ['/var/www/'],
    manage_cron   => true,
  }

  file_line { 'sshd_port_222':
    notify => Service['sshd'],
    path   => '/etc/ssh/sshd_config',
    line   => 'Port 222',
    match  => '^Port 22$',
  }
  ->
  firewall { '007 accept on 222':
    proto  => 'tcp',
    dport  => '222',
    action => 'accept',
    source => '0.0.0.0/0',
  }
  
  class { 'postgresql::globals':
    version      => '9.5',
    encoding     => 'UTF-8',
    locale       => "'en_GB.UTF8'",
    datadir      => '/local/data/postgres',
    needs_initdb => true
  }
  ->
  class { 'postgresql::server':
    ip_mask_deny_postgres_user => '0.0.0.0/0',
    ip_mask_allow_all_users    => '127.0.0.1/32',
    listen_addresses           => '*',
    ipv4acls                   => ['hostssl all all 127.0.0.1/32 md5'],
  }
  ->
  postgresql::server::db{'chime':
    user     => 'chime',
    password => 'chime',
    grant    => 'ALL',
  }

  package{'tomcat8':
    ensure => 'installed',
  }
  ->
  file {'/opt/chime':
    ensure => 'directory',
    owner  => 'tomcat8',
    group  => 'tomcat8',
  }

  firewall { '030 redirect 22 to 2222':
    dport   => '22',
    table   => 'nat',
    chain   => 'PREROUTING',
    jump    => 'REDIRECT',
    iniface => 'eth0',
    toports => '2222',
  }
  ->
  firewall { '031 redirect 22 to 2222 localhost':
    dport       => '22',
    table       => 'nat',
    chain       => 'OUTPUT',
    jump        => 'REDIRECT',
    toports     => '2222',
    destination => '127.0.0.1/8',
  }
  ->
  firewall { '032 accept on 2222':
    proto  => 'tcp',
    dport  => '2222',
    action => 'accept',
    source => '0.0.0.0/0',
  }
}

if ( $::monitor ) {
  nagios::monitor { 'chime':
    parents    => 'nas04',
    address    => 'teaching-chime.dtg.cl.cam.ac.uk',
    hostgroups => [ 'http-servers' ],
  }

  # TODO(acr31) this machine is currently not set up in puppeta
  nagios::monitor { 'teaching-pottery-1':
    parents    => 'nas04',
    address    => 'teaching-pottery-1.dtg.cl.cam.ac.uk',
    hostgroups => [ 'ssh-servers' ],
  }
}