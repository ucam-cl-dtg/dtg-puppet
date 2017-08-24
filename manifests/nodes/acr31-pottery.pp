node /^acr31-pottery/ {
  include 'dtg::minimal'

  class {'dtg::pottery::aptsources': stage => 'repos' }
  
  file{'/local/data/docker':
    ensure => directory,
    owner  => 'root'
  }
  ->
  package{'docker-ce':
    ensure => installed,
  }
  ->
  class { 'docker':
    tcp_bind                    => 'tcp://127.0.0.1:2375',
    socket_bind                 => 'unix:///var/run/docker.sock',
    root_dir                    => '/local/data/docker',
    use_upstream_package_source => false,
    manage_package              => false,
  }
  ->
  exec {'add-www-data-to-docker-group':
    unless  => "/bin/grep -q '^docker:\\S*www-data' /etc/group",
    command => '/usr/sbin/usermod -aG docker www-data',
  }
  ->
  docker::image { 'ubuntu':
    image_tag => '16.04'
  }
    
  class {'dtg::firewall::publichttps':}
  ->
  class {'dtg::firewall::publichttp':}

  $packages = ['openjdk-8-jdk','libapr1','tomcat8','golang-go',]

  package{$packages:
    ensure => installed,
  }

  class {'apache::ubuntu': }
  ->
  class {'dtg::apache::raven':
    server_description => 'Pottery'
  }
  ->
  apache::module {'proxy':}
  ->
  apache::module {'proxy_http':}
  ->
  apache::site {'pottery':
    source => 'puppet:///modules/dtg/apache/pottery.conf',
  }
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
  
  class { 'postgresql::globals':
    version  => '9.5',
    encoding => 'UTF-8',
    locale   => "'en_GB.UTF8'"
  }
  ->
  class { 'postgresql::server':
    ip_mask_deny_postgres_user => '0.0.0.0/0',
    ip_mask_allow_all_users    => '127.0.0.1/32',
    listen_addresses           => '*',
    ipv4acls                   => ['hostssl all all 127.0.0.1/32 md5'],
  }
  ->
  postgresql::server::db{'gogs':
    user     => 'gogs',
    password => 'gogs',
    grant    => 'ALL',
  }
  
}

class dtg::pottery::aptsources { # lint:ignore:autoloader_layout repo class
  apt::source{ 'docker':
    location => 'https://download.docker.com/linux/ubuntu',
    release  => 'xenial',
    repos    => 'stable',
    key      => {
      'id'     => '9DC858229FC7DD38854AE2D88D81803C0EBFCD88',
      'source' => 'https://download.docker.com/linux/ubuntu/gpg',
    }
  }
}
