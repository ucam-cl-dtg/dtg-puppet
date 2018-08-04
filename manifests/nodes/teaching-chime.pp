node /^teaching-chime/ {
  include 'dtg::minimal'

  class {'dtg::firewall::publichttps':}
  ->
  class {'dtg::firewall::publichttp':}
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
  apache::site {'chime':
    source => 'puppet:///modules/dtg/apache/chime.conf',
  }

  file_line { 'sshd_port_222':
    notify  => Service['sshd'], 
    path  => '/etc/ssh/sshd_config',
    line  => 'Port 222',
    match => '^Port 22$',
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
    owner => 'tomcat8',
    group => 'tomcat8',
  }
  ->
  dtg::nexus::fetch{'download-chime':
    groupID               => 'uk.ac.cam.cl.dtg.teaching',
    artifact_name         => 'chime',
    artifact_version      => '1.0.0-SNAPSHOT',
    artifact_type         => 'war',
    destination_directory => '/opt/chime/servlet',
    symlink               => "/var/lib/tomcat8/webapps/openroommap.war",
  }


}
